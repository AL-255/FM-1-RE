#!/usr/bin/env python3
"""fm1_ota — Linux CLI reimplementation of the M-Vave M-UPGRADE OTA client
for the FM-1 synthesizer (JieLi AC791N/WL82), protocol reverse-engineered
from live ALSA-seq captures of M-UPGRADE (see docs/io/11-ota-protocol.md).

Transport: MIDI System-Exclusive messages over the device's USB-MIDI port via
the ALSA sequencer (libasound). It uses neither pyusb nor HID and assumes no
physical UBOOT entry.

Session flow:
  1. normal mode ("FM-1 Midi", 4c4a:c755): handshake query -> ID block,
     then the "upgrade" command; the device verifies the .fwsc (pulling it
     with read requests) and reboots into the OTA loader.
  2. OTA mode ("ota-FM-1", 4d4a:4155, still USB-MIDI): handshake again,
     the same upgrade command, then the device pulls the whole image with
     read requests; an addr=0xF0000000 "finish" request ends the transfer and
     indicates that the loader reached its post-write finish path. The client
     verifies the model/version again after reboot.

Wire protocol (both directions):
  F0 00 32 41 41 [f1:4][addr:4][len:4] [pack7(data)...] F7
    f1/addr/len : three little-endian u32, each sent as 4 x 7-bit groups
                  (b0|b1<<7|b2<<14|b3<<21). len field = (length<<4)|flashtype.
    request     : device->host, f1=0
    response    : host->device, f1 = length>>4
    data        : 8->7 LSB-first bit-packed, plus one trailing checksum byte
                  ~(flashtype+sum(data)+sum(addr_LE)+sum(len_LE3)) & 0xFF
  Handshake:    F0 00 32 45 00 00 00 40 7F F7 -> ID block on 00 32 45 58
  Upgrade cmd:  F0 22 24 35 7F F7
  .fwsc image : the first 20*0x30 header bytes are interleaved as
                47 data + 1 marker per block; requests address the
                *logical* image (markers stripped), the rest is raw.

Usage:
  fm1_ota.py scan                    show device state (normal / OTA / none)
  fm1_ota.py flash FILE.fwsc         full update: enter OTA + transfer + finish
  fm1_ota.py serve FILE.fwsc         answer OTA requests (device already in OTA mode)
  fm1_ota.py logical FILE.fwsc       offline: write the marker-stripped image
"""
import argparse, os, re, subprocess, sys, time

# ---------------------------------------------------------------- constants
HS_QUERY = bytes([0xF0, 0x00, 0x32, 0x45, 0x00, 0x00, 0x00, 0x40, 0x7F, 0xF7])
                                   # handshake query; device replies with its
                                   # 34-byte "NAME_VERSION" ID block
UPGRADE_CMD = bytes([0xF0, 0x22, 0x24, 0x35, 0x7F, 0xF7])
HDR_DATA = b"\x00\x32\x41\x41"   # request/response channel (pack7 of 00 59 30)
HDR_HS   = b"\x00\x32\x45\x58"   # handshake channel (pack7 of 00 59 11)
REQ_TIMEOUT = 8.0                # s without requests -> step considered done
MAXDATA = 512                    # max bytes per response
RESP_DELAY = float(os.environ.get("FM1_RESP_DELAY", "0.010"))
START_DELAY = float(os.environ.get("FM1_START_DELAY", "2.0"))
VERIFY_DELAY = float(os.environ.get("FM1_VERIFY_DELAY", "3.0"))
NORMAL_USB_ID = "4c4a:c755"
OTA_USB_ID = "4d4a:4155"
LOG_PATH = os.environ.get("FM1_OTA_LOG", "/dev/null")
LOG = None if LOG_PATH == "/dev/null" else open(LOG_PATH, "a")
t0 = time.time()

# ------------------------------------------------------------------ packing
def pack7(data):
    out = bytearray(); acc = 0; nb = 0
    for b in data:
        acc |= b << nb; nb += 8
        while nb >= 7:
            out.append(acc & 0x7F); acc >>= 7; nb -= 7
    if nb: out.append(acc & 0x7F)
    return bytes(out)

def unpack7(s):
    out = bytearray(); acc = 0; nb = 0
    for b in s:
        acc |= b << nb; nb += 7
        while nb >= 8:
            out.append(acc & 0xFF); acc >>= 8; nb -= 8
    return bytes(out)

def u7(b):
    return b[0] | (b[1] << 7) | (b[2] << 14) | (b[3] << 21)

def e7(v):
    return bytes([(v) & 0x7F, (v >> 7) & 0x7F, (v >> 14) & 0x7F, (v >> 21) & 0x7F])

def build_response(addr, data, req_len=None, flashtype=0):
    """Data response. req_len = requested length (echoed in the len field and
    f1); the payload is the (full) data actually sent, followed by one
    checksum byte: ~(flashtype+sum(data)+sum(addr_LE)+sum(len_LE3)) & 0xFF — algorithm
    verified 48/48 against the firmware's verifier at update_cmd_dispatch
    (0x02026BC4)."""
    if req_len is None:
        req_len = len(data)
    chk = (~(flashtype + sum(data) + sum(addr.to_bytes(4, 'little'))
             + sum(req_len.to_bytes(3, 'little')))) & 0xFF
    return (b"\xF0" + HDR_DATA + e7(req_len >> 4) + e7(addr)
            + e7((req_len << 4) | flashtype) + pack7(data + bytes([chk])) + b"\xF7")

def parse_request(pkt):
    """Decode a device read-request frame -> (flashtype, addr, length) or None.
    Frame (after pack7): [00 59][type=0x30][N:3 LE][fl][addr:4 LE][len:3 LE][chk].
    addr is a raw u32 (0xE0000000 = verification-done, 0xF0000000 = upgrade-done)."""
    if len(pkt) < 4 or pkt[0] != 0xF0 or pkt[-1] != 0xF7:
        return None
    u = unpack7(pkt[1:-1])
    if len(u) != 15 or u[:3] != b"\x00\x59\x30":
        return None
    body_len = int.from_bytes(u[3:6], "little")
    if body_len != 8 or u[-1] != ((~sum(u[6:-1])) & 0xFF):
        return None
    fl = u[6]
    addr = int.from_bytes(u[7:11], "little")
    ln = int.from_bytes(u[11:14], "little")
    return (fl, addr, ln)

def parse_handshake_identity(pkt):
    """Decode the model and decimal version from a type-0x11 ID response.

    This mirrors M-UPGRADE's parser at 0x140016e10. The 20-byte identity field
    is stored relative to ASCII '0'; the parser adds '0' to each byte and uses
    the underscore position from the plain identity field to find the version.
    """
    if len(pkt) < 4 or pkt[0] != 0xF0 or pkt[-1] != 0xF7:
        return None
    decoded = unpack7(pkt[1:-1])
    if len(decoded) != 34 or decoded[:3] != b"\x00\x59\x11":
        return None
    body_len = int.from_bytes(decoded[3:6], "little")
    if body_len != 27 or decoded[-1] != ((~sum(decoded[6:-1])) & 0xFF):
        return None

    plain = decoded[6:31]
    separator = plain.find(b"_")
    if separator < 0:
        return None
    try:
        model = plain[:separator].decode("ascii")
    except UnicodeDecodeError:
        return None

    encoded = bytes((byte + ord("0")) & 0xFF for byte in decoded[14:34])
    match = re.match(rb"[0-9]+", encoded[separator + 1:])
    if not match:
        return None
    return {"model": model, "version": int(match.group(0), 10)}

# "success" reply for the done-signals (verification/upgrade complete)
def build_success(addr):
    payload = b"success\x00"
    body = bytes([0x00, 0x59, 0x30]) + (len(payload) + 8).to_bytes(3, "little") \
        + bytes([0]) + addr.to_bytes(4, "little") + len(payload).to_bytes(3, "little") + payload
    chk = (~sum(body[6:])) & 0xFF
    return b"\xF0" + pack7(body + bytes([chk])) + b"\xF7"

# ------------------------------------------------------------- .fwsc image
def fwsc_logical(path):
    """Return the marker-stripped logical image the device requests into."""
    with open(path, "rb") as image:
        raw = image.read()
    out = bytearray()
    for off in range(0, 20 * 0x30, 0x30):
        blk = raw[off:off + 0x30]
        if len(blk) < 0x30:
            raise SystemExit(f"{path}: truncated header block at {off:#x}")
        out += blk[:0x2F]
    out += raw[20 * 0x30:]
    return bytes(out)

def fwsc_info(path):
    """Best-effort parse of the 20-slot header for display."""
    lg = fwsc_logical(path)
    # UFW header is HDRKEY(0xFFFF)-scrambled; chipname sits at offset 0x10
    hdr = bytearray(lg[:0x40])
    import sys as _s
    tools = os.path.dirname(os.path.abspath(__file__))
    _s.path.insert(0, os.path.join(tools, "..", "..", "3rd-party", "jl-misctools", "firmware"))
    from jltech.cipher import jl_enc_cipher
    jl_enc_cipher(hdr, 0, 0x40, 0xFFFF)
    name = bytes(hdr[0x10:0x10 + 16]).split(b"\0")[0].decode("ascii", "replace")
    with open(path, "rb") as image:
        raw = image.read(20 * 0x30)
    markers = [raw[i * 0x30 + 0x2F] for i in range(20)]
    product = "".join(chr((marker - i - 1) & 0xFF)
                      for i, marker in enumerate(markers) if marker != 0x7D)
    return {"chip": name, "product": product, "logical_size": len(lg)}

# ------------------------------------------------------------------ rawmidi
import alsalib, alsaseq

def find_midi_port():
    """Locate the FM-1 kernel MIDI port (client, port), or None."""
    c = alsaseq.SeqClient()
    try:
        for name in (b'USB Composite Device', b'FM-1', b'USB-Midi', b'Sinco-Midi'):
            port = c.find_port(name)
            if port:
                return port
        return None
    finally:
        c.close()

def device_is_ota():
    try:
        out = subprocess.run(['lsusb'], capture_output=True, text=True).stdout.lower()
    except FileNotFoundError:
        return None
    if OTA_USB_ID in out:
        return True
    if NORMAL_USB_ID in out:
        return False
    return None

def find_rawmidi(prefer_ota=None):
    """Compatibility shim: returns (description, is_ota, card) — port lookup
    is done separately via find_midi_port()."""
    st = device_is_ota()
    if st is None:
        return None
    if prefer_ota is not None and st != prefer_ota:
        return None
    return ('seq', st, -1)

class MidiLink:
    def __init__(self, _path=None):
        self.link = alsalib.MidiLink()
        addr = find_midi_port()
        if not addr:
            raise RuntimeError("FM-1 MIDI port not found")
        self.link.connect(addr)
        self.buf = bytearray()

    def fileno(self):
        return self.link.fileno()

    def write(self, data):
        self.link.send(bytes(data))

    def read_sysex(self, timeout):
        pkt = self.link.recv_sysex(int(timeout * 1000))
        if not pkt:
            return None
        if pkt and pkt[0] != 0xF0:
            return b""
        return pkt

    def drain(self):
        while self.link.recv_sysex(0):
            pass

    def close(self):
        self.link.close()


def handshake(link, attempts=3, timeout=1.0):
    """Probe a candidate port and return its ID block, or None."""
    link.drain()
    for _ in range(attempts):
        link.write(HS_QUERY)
        end = time.time() + timeout
        while time.time() < end:
            pkt = link.read_sysex(end - time.time())
            if pkt is None:
                break
            if pkt.startswith(b"\xF0" + HDR_HS) and pkt.endswith(b"\xF7"):
                return pkt
    return None

# ------------------------------------------------------------------ pieces
def serve_requests(link, logical, stop_after=REQ_TIMEOUT, progress=True, on_finish=None):
    """Answer device read requests until they stop. Returns request count.
    Per the M-UPGRADE spec: data requests (addr < 0x10000000) are served from
    the logical image; addr 0xE0000000 (verification done) and 0xF0000000
    (upgrade done) get the 8-byte "success" reply with the addr echoed."""
    served = 0; last_req = time.time(); last_addr = -1
    while True:
        pkt = link.read_sysex(1.0)
        if pkt is None:
            if time.time() - last_req > stop_after:
                return served
            continue
        req = parse_request(pkt)
        if req is None:
            if LOG:
                LOG.write(f"{time.time()-t0:9.3f} RAW {pkt.hex()}\n"); LOG.flush()
            continue
        fl, addr, ln = req
        if LOG:
            LOG.write(f"{time.time()-t0:9.3f} fl={fl:x} addr={addr:#x} len={ln}\n"); LOG.flush()
        if addr in (0xE0000000, 0xF0000000):
            try:
                link.write(build_success(addr))
            except OSError:
                return served
            last_req = time.time()
            if on_finish and on_finish(addr):
                return served
            continue
        if ln > MAXDATA or addr > len(logical) or addr + ln > len(logical):
            raise RuntimeError(f"invalid device request: addr={addr:#x}, len={ln}")
        time.sleep(RESP_DELAY)   # MCU needs time to process (M-UPGRADE paces ~10ms)
        data = logical[addr:addr + ln]
        try:
            link.write(build_response(addr, data, ln, fl))
        except OSError:
            return served
        served += 1
        last_req = time.time()
        if progress and (addr != last_addr + 512 or served % 200 == 0):
            print(f"\r  served {served} reqs, addr={addr:#08x} ({100*addr/len(logical):.0f}%)",
                  end="", flush=True)
        last_addr = addr

def wait_device(is_ota, timeout=30.0):
    end = time.time() + timeout
    while time.time() < end:
        got = find_rawmidi(prefer_ota=is_ota)
        if got and find_midi_port():
            return got
        time.sleep(0.5)
    return None

def wait_device_any(timeout=30.0):
    """Wait for either stock or alternate-loader USB identity after step 1."""
    end = time.time() + timeout
    while time.time() < end:
        got = find_rawmidi()
        if got and find_midi_port():
            return got
        time.sleep(0.5)
    return None

# ------------------------------------------------------------------- verbs
def cmd_scan(_):
    got = find_rawmidi()
    if not got:
        print("no FM-1 device found")
        return 1
    path, is_ota, card = got
    print(f"{'OTA' if is_ota else 'NORMAL'} mode: {path} (card {card})")
    return 0

def cmd_logical(a):
    lg = fwsc_logical(a.file)
    out = a.out or a.file + ".logical"
    with open(out, "wb") as image:
        image.write(lg)
    print(f"wrote {out} ({len(lg)} bytes)")
    return 0

def cmd_serve(a):
    got = find_rawmidi()
    if not got:
        print("FM-1 device not found"); return 1
    logical = fwsc_logical(a.file)
    print(f"serving {a.file} ({len(logical)} logical bytes) on {got[0]}")
    link = MidiLink(got[0])
    if not handshake(link):
        link.close()
        print("FM-1 handshake failed"); return 1
    link.write(UPGRADE_CMD)
    time.sleep(START_DELAY)
    fin = {}
    def _fin(addr):
        if addr == 0xF0000000:
            fin['done'] = True
        else:
            fin['verification_only'] = True
        return True
    n = serve_requests(link, logical, on_finish=_fin)
    link.close()
    print(f"\n  done: {n} requests served")
    return 0 if fin.get('done') else 1

def cmd_flash(a):
    logical = fwsc_logical(a.file)
    image_info = fwsc_info(a.file)
    print(f"image: {image_info} ({len(logical)} logical bytes)")
    expected = re.fullmatch(r"(.+)_([0-9]+)", image_info.get("product", ""))
    if expected is None:
        print("package identity is not in MODEL_NNN form"); return 1
    expected_model, expected_version = expected.group(1), int(expected.group(2), 10)
    got = find_rawmidi(prefer_ota=False)
    if not got:
        print("FM-1 not found in normal mode"); return 1
    link = MidiLink(got[0])
    print("step 1: handshake + enter OTA (verification) ...")
    normal_packet = handshake(link)
    normal_identity = parse_handshake_identity(normal_packet) if normal_packet else None
    if normal_identity is None:
        link.close()
        print("FM-1 handshake failed"); return 1
    if normal_identity["model"] != expected_model:
        link.close()
        print(
            f"connected device is {normal_identity['model']}, "
            f"but package targets {expected_model}"
        )
        return 1
    link.write(UPGRADE_CMD)
    time.sleep(START_DELAY)
    fin = {}
    def _fin1(addr):
        if addr == 0xE0000000:
            fin['v'] = True
            return True
        return False
    n = serve_requests(link, logical, stop_after=8.0, progress=False, on_finish=_fin1)
    print(f"  step 1 served {n} requests{' (verification done)' if fin.get('v') else ''}; waiting for OTA mode ...")
    if not fin.get('v'):
        link.close()
        print("device did not confirm step-1 verification"); return 1
    # M-UPGRADE keeps the connection alive for three seconds after replying
    # to 0xE0000000, allowing the response to drain before re-enumeration.
    time.sleep(VERIFY_DELAY)
    link.close()
    got = wait_device_any(timeout=30.0)
    if not got:
        print("device did not re-enumerate after step-1"); return 1
    time.sleep(1.0)
    link = MidiLink(got[0])
    print("step 2: handshake + transfer ...")
    ota_packet = handshake(link)
    ota_identity = parse_handshake_identity(ota_packet) if ota_packet else None
    if ota_identity is None:
        link.close()
        print("OTA-loader handshake failed"); return 1
    ota_model = ota_identity["model"]
    if ota_model.lower().startswith("ota-"):
        ota_model = ota_model[4:]
    if ota_model != expected_model:
        link.close()
        print(
            f"OTA loader identifies as {ota_identity['model']}, "
            f"but package targets {expected_model}"
        )
        return 1
    link.write(UPGRADE_CMD)
    time.sleep(START_DELAY)
    fin2 = {}
    def _fin2(addr):
        if addr == 0xF0000000:
            fin2['done'] = True
        else:
            fin2['verification_only'] = True
        return True
    # Step 2 may pause while the loader erases/writes flash; use a long idle
    # timeout so we don't give up during a long write cycle.
    n = serve_requests(link, logical, stop_after=180.0, on_finish=_fin2)
    if fin2.get('done'):
        outcome = "finish exchange answered"
    elif fin2.get('verification_only'):
        outcome = "stopped at verification"
    else:
        outcome = "idle timeout"
    print(f"\n  step 2 {outcome}; waiting for reboot ...")
    link.close()
    if not fin2.get('done'):
        if fin2.get('verification_only'):
            print("loader stopped at verification; image was not flashed")
        else:
            print("loader never sent the upgrade-complete signal")
        return 1
    got = wait_device(is_ota=False, timeout=30.0)
    if not got:
        print("device did not come back in normal mode"); return 1

    link = MidiLink(got[0])
    identity_packet = handshake(link)
    link.close()
    identity = parse_handshake_identity(identity_packet) if identity_packet else None
    if identity is None:
        print("device returned, but installed identity could not be verified")
        return 1
    if (identity["model"], identity["version"]) != (expected_model, expected_version):
        print(
            "device returned with unexpected firmware: "
            f"{identity['model']}_{identity['version']:03d}; expected "
            f"{expected_model}_{expected_version:03d}"
        )
        return 1
    print(
        "finish acknowledged and installed identity verified: "
        f"{identity['model']}_{identity['version']:03d}"
    )
    return 0

def main():
    ap = argparse.ArgumentParser(description=__doc__,
                                 formatter_class=argparse.RawDescriptionHelpFormatter)
    sub = ap.add_subparsers(dest="cmd", required=True)
    sub.add_parser("scan")
    p = sub.add_parser("logical"); p.add_argument("file"); p.add_argument("-o", "--out")
    p = sub.add_parser("serve"); p.add_argument("file")
    p = sub.add_parser("flash"); p.add_argument("file")
    a = ap.parse_args()
    return {"scan": cmd_scan, "logical": cmd_logical,
            "serve": cmd_serve, "flash": cmd_flash}[a.cmd](a)

if __name__ == "__main__":
    sys.exit(main())
