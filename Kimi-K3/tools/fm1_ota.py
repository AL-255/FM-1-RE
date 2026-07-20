#!/usr/bin/env python3
"""fm1_ota — Linux CLI reimplementation of the M-Vave M-UPGRADE OTA client
for the FM-1 synthesizer (JieLi AC791N/BR22-class), protocol reverse-engineered
from live ALSA-seq captures of M-UPGRADE (see Kimi-K3/docs/io/11-ota-protocol.md).

Transport: MIDI System-Exclusive messages over the device's USB-MIDI port via
the ALSA sequencer (libasound). No pyusb, no HID, no UBOOT button.

Session flow:
  1. normal mode ("FM-1 Midi", 4c4a:c755): handshake query -> ID block,
     then the "upgrade" command; the device verifies the .fwsc (pulling it
     with read requests) and reboots into the OTA loader.
  2. OTA mode ("ota-FM-1", 4d4a:4155, still USB-MIDI): handshake again,
     the same upgrade command, then the device pulls the whole image with
     read requests; a flashtype=0xF "finish" request ends the transfer and
     the loader flashes + reboots.

Wire protocol (both directions):
  F0 00 32 41 41 [f1:4][addr:4][len:4] [pack7(data)...] F7
    f1/addr/len : three little-endian u32, each sent as 4 x 7-bit groups
                  (b0|b1<<7|b2<<14|b3<<21). len field = (length<<4)|flashtype.
    request     : device->host, f1=0
    response    : host->device, f1 = length>>4
    data        : 8->7 LSB-first bit-packed, plus one trailing checksum byte
                  ~(sum(data)+sum(addr_LE)+sum(len_LE)) & 0xFF
  Handshake:    F0 00 32 45 00 00 00 40 7F F7 -> ID block on 00 32 45 58
  Upgrade cmd:  F0 22 24 35 7F F7
  Keepalive:    F0 00 32 41 11 ... F7 every ~13 s while transferring
  .fwsc image : the first 20*0x30 header bytes are interleaved as
                47 data + 1 marker per block; requests address the
                *logical* image (markers stripped), the rest is raw.

Usage:
  fm1_ota.py scan                    show device state (normal / OTA / none)
  fm1_ota.py flash FILE.fwsc         full update: enter OTA + transfer + finish
  fm1_ota.py serve FILE.fwsc         answer OTA requests (device already in OTA mode)
  fm1_ota.py logical FILE.fwsc       offline: write the marker-stripped image
"""
import argparse, glob, os, select, struct, sys, time

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
LOG = open(os.environ.get("FM1_OTA_LOG", "/dev/null"), "a")
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
    checksum byte: ~(sum(data)+sum(addr_LE)+sum(len_LE)) & 0xFF — algorithm
    verified 48/48 against the firmware's verifier at update_cmd_dispatch
    (0x02026BC4)."""
    if req_len is None:
        req_len = len(data)
    chk = (~(sum(data) + sum(addr.to_bytes(4, 'little'))
             + sum(req_len.to_bytes(4, 'little')))) & 0xFF
    return (b"\xF0" + HDR_DATA + e7(req_len >> 4) + e7(addr)
            + e7((req_len << 4) | flashtype) + pack7(data + bytes([chk])) + b"\xF7")

def parse_request(pkt):
    """Decode a device read-request frame -> (flashtype, addr, length) or None.
    Frame (after pack7): [00 59][type=0x30][N:3 LE][fl][addr:4 LE][len:3 LE][chk].
    addr is a raw u32 (0xE0000000 = verification-done, 0xF0000000 = upgrade-done)."""
    if len(pkt) < 4 or pkt[0] != 0xF0 or pkt[-1] != 0xF7:
        return None
    u = unpack7(pkt[1:-1])
    if len(u) < 15 or u[:2] != b"\x00\x59" or u[2] != 0x30:
        return None
    fl = u[6]
    addr = int.from_bytes(u[7:11], "little")
    ln = int.from_bytes(u[11:14], "little")
    return (fl, addr, ln)

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
    raw = open(path, "rb").read()
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
    _s.path.insert(0, "/home/yukidama/JL/FM-1/3rd-party/jl-misctools/firmware")
    from jltech.cipher import jl_enc_cipher
    jl_enc_cipher(hdr, 0, 0x40, 0xFFFF)
    name = bytes(hdr[0x10:0x10 + 16]).split(b"\0")[0].decode("ascii", "replace")
    return {"name": name, "logical_size": len(lg)}

# ------------------------------------------------------------------ rawmidi
import alsalib, alsaseq

def find_midi_port():
    """Locate the FM-1 kernel MIDI port (client, port), or None."""
    c = alsaseq.SeqClient()
    try:
        return c.find_port(b'USB Composite Device')
    finally:
        c.close()

def device_is_ota():
    import subprocess
    out = subprocess.run(['lsusb'], capture_output=True, text=True).stdout
    if '4d4a:4155' in out:
        return True
    if '4c4a:c755' in out:
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
            continue
        fl, addr, ln = req
        if LOG:
            LOG.write(f"{time.time()-t0:9.3f} fl={fl:x} addr={addr:#x} len={ln}\n"); LOG.flush()
        if addr in (0xE0000000, 0xF0000000):
            link.write(build_success(addr))
            last_req = time.time()
            if on_finish:
                on_finish(addr)
            continue
        time.sleep(RESP_DELAY)   # MCU needs time to process (M-UPGRADE paces ~10ms)
        data = logical[addr:addr + ln]
        if len(data) < ln:
            data = data + bytes(ln - len(data))
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
        if got:
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
    open(out, "wb").write(lg)
    print(f"wrote {out} ({len(lg)} bytes)")
    return 0

def cmd_serve(a):
    got = find_rawmidi(prefer_ota=True)
    if not got:
        print("device not in OTA mode"); return 1
    logical = fwsc_logical(a.file)
    print(f"serving {a.file} ({len(logical)} logical bytes) on {got[0]}")
    link = MidiLink(got[0])
    link.drain()
    link.write(HS_QUERY)
    link.read_sysex(2.0)
    link.write(UPGRADE_CMD)
    fin = {}
    def _fin(addr):
        if addr == 0xF0000000:
            fin['done'] = True
            raise StopIteration
    try:
        n = serve_requests(link, logical, on_finish=_fin)
    except StopIteration:
        n = -1
    print(f"\n  done: {n} requests served")
    return 0

def cmd_flash(a):
    logical = fwsc_logical(a.file)
    print(f"image: {fwsc_info(a.file)} ({len(logical)} logical bytes)")
    got = find_rawmidi(prefer_ota=False)
    if not got:
        print("FM-1 not found in normal mode"); return 1
    link = MidiLink(got[0])
    print("step 1: handshake + enter OTA (verification) ...")
    link.drain()
    link.write(HS_QUERY)
    link.read_sysex(2.0)
    link.write(UPGRADE_CMD)
    fin = {}
    def _fin1(addr):
        if addr == 0xE0000000:
            fin['v'] = True
            raise StopIteration
    try:
        n = serve_requests(link, logical, stop_after=6.0, progress=False, on_finish=_fin1)
    except StopIteration:
        n = -1
    print(f"  step 1 served {n} requests{' (verification done)' if fin.get('v') else ''}; waiting for OTA mode ...")
    try:
        os.close(link.fileno())
    except OSError:
        pass
    got = wait_device(is_ota=True, timeout=30.0)
    if not got:
        print("device did not re-enumerate in OTA mode"); return 1
    time.sleep(1.0)
    link = MidiLink(got[0])
    print("step 2: handshake + transfer ...")
    link.drain()
    link.write(HS_QUERY)
    link.read_sysex(2.0)
    link.write(UPGRADE_CMD)
    fin2 = {}
    def _fin2(addr):
        if addr == 0xF0000000:
            fin2['done'] = True
            raise StopIteration
    try:
        n = serve_requests(link, logical, on_finish=_fin2)
    except StopIteration:
        n = -1
    print(f"\n  step 2 complete (finish exchange answered); waiting for reboot ...")
    try:
        os.close(link.fileno())
    except OSError:
        pass
    got = wait_device(is_ota=False, timeout=30.0)
    if not got:
        print("device did not come back in normal mode"); return 1
    print("flash complete: device back in normal mode")
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
