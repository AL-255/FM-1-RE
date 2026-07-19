#!/usr/bin/env python3
"""fm1_ota — Linux CLI for the M-Vave FM-1 (JieLi BR22/AC693N) firmware
update, replicating the M-UPGRADE client's OTA flow (no UBOOT button).

Protocol (reverse-engineered, see Kimi-K3/docs/io/05-midi.md + ota.md):

  Normal mode : FM-1 Midi composite device, VID 0x4C4A PID 0xC755.
  Enter OTA   : raw 8-byte USB bulk write to the MIDI endpoint (EP4 OUT,
                0x04):  [02 01 42 04 02 01, 0x7D | 0x7F, 0xF7]
                (verified against the firmware's loader-mode check at
                0x02006384). The device then reboots into the OTA loader.
  OTA mode    : "ota-FM-1" USB HID device, VID 0x4D4A PID 0x4155.
  Transfer    : the .fwsc is uploaded to the OTA loader over HID reports;
                update blocks carry the 0x5A04..0x5A08 JL update magic and
                are CRC-verified by the loader (jieli_ufw_update_run).

  syscmd core (device control, cmd ids 17-48 over MIDI/USB):
                packet = [hdr:2][cmd:1][len:3 LE][payload:len][~sum&0xFF]

USB access needs write permission to the device node; install
tools/99-jieli-fm1.rules (udev) or run with sudo.

Usage:
  fm1_ota.py find                 list the FM-1 device state (normal / OTA)
  fm1_ota.py enter [--fake]       send the OTA-enter trigger (normal mode)
  fm1_ota.py flash FILE.fwsc      enter OTA mode + upload the firmware
  fm1_ota.py info                 query device version via syscmd (MIDI)
  fm1_ota.py packet CMD [hexpay]  build a syscmd packet (offline test)
Options: --dry-run (build/print, don't send), --vid/--pid overrides.
"""
import argparse, os, struct, sys, time

try:
    import usb.core, usb.util
except ImportError:
    usb = None

# ---- device identities -----------------------------------------------------
VID_NORMAL, PID_NORMAL = 0x4C4A, 0xC755      # FM-1 Midi composite
VID_OTA, PID_OTA = 0x4D4A, 0x4155            # ota-FM-1 USB HID
EP_MIDI_OUT = 0x04                            # EP4 OUT (bulk)

# Handshake / verification query — captured verbatim from M-UPGRADE
# (byte-identical across sessions; the device accepts it and stays in normal
# mode; entering OTA happens on the following "upgrade" command).
HANDSHAKE = bytes([
    0xF0, 0x00, 0x32, 0x45, 0x58, 0x01, 0x00, 0x00, 0x23,
    0x4D, 0x5A, 0x44, 0x79, 0x05, 0x26, 0x4C, 0x19,
] + [0x00] * 17 + [0x60, 0x06, 0xF7])

LOADER_MAGIC = bytes([0x02, 0x01, 0x42, 0x04, 0x02, 0x01])
JL_UPDATE_MAGIC = 0x5A04

# ---- syscmd core -----------------------------------------------------------

def syscmd_packet(cmd, payload=b"", hdr=0):
    """[hdr:2][cmd:1][len:3 LE][payload][~sum(payload)&0xFF]"""
    ck = (~sum(payload)) & 0xFF if payload else 0xFF
    return struct.pack("<H", hdr) + bytes([cmd]) + \
           len(payload).to_bytes(3, "little") + payload + bytes([ck])

def syscmd_parse(buf):
    if len(buf) < 7:
        raise ValueError("short packet")
    hdr = struct.unpack_from("<H", buf, 0)[0]
    cmd = buf[2]
    ln = int.from_bytes(buf[3:6], "little")
    if ln + 7 != len(buf):
        raise ValueError(f"bad length {ln}+7 != {len(buf)}")
    payload = buf[6:6 + ln]
    ck = buf[6 + ln]
    want = (~sum(payload)) & 0xFF if payload else 0xFF
    if ck != want:
        raise ValueError(f"bad checksum {ck:#x} != {want:#x}")
    return hdr, cmd, payload

SYSCMD = {
    17: "get_device_info_a", 18: "get_device_info_b", 21: "get_version",
    33: "get_device_info_c", 34: "ring_read", 35: "invoke_a", 36: "invoke_b",
    48: "invoke_c",
}

# ---- USB helpers -----------------------------------------------------------

def _need_usb():
    if usb is None:
        sys.exit("pyusb not installed (pip3 install pyusb)")

def find_device(vid, pid):
    return usb.core.find(idVendor=vid, idProduct=pid)

def claim(dev, ifnum=4):
    try:
        if dev.is_kernel_driver_active(ifnum):
            dev.detach_kernel_driver(ifnum)
    except Exception:
        pass
    usb.util.claim_interface(dev, ifnum)

# ---- commands --------------------------------------------------------------

def cmd_find(args):
    _need_usb()
    d = find_device(args.vid, args.pid)
    if d:
        print(f"normal mode : {hex(d.idVendor)}:{hex(d.idProduct)} (FM-1 Midi)")
    d2 = find_device(VID_OTA, PID_OTA)
    if d2:
        print(f"OTA mode    : {hex(d2.idVendor)}:{hex(d2.idProduct)} (ota-FM-1)")
    if not d and not d2:
        print("no FM-1 device found (normal 4c4a:c755 or ota 4d4a:4155)")

def cmd_enter(args):
    _need_usb()
    d = find_device(args.vid, args.pid)
    if not d:
        sys.exit("device not found (need normal-mode FM-1 Midi 4c4a:c755)")
    if args.dry_run:
        print("handshake (EP4 OUT):", HANDSHAKE.hex())
        return
    claim(d, 4)
    # 1. handshake / verification query over the MIDI bulk endpoint (the
    #    M-UPGRADE "First step"; the device accepts it and stays in normal mode)
    n = d.write(EP_MIDI_OUT, HANDSHAKE, timeout=2000)
    print(f"sent handshake ({n} bytes)")
    time.sleep(1.0)
    # 2. request OTA entry (loader trigger)
    code = 0x7F if args.fake else 0x7D
    msg = LOADER_MAGIC + bytes([code, 0xF7])
    n = d.write(EP_MIDI_OUT, msg, timeout=2000)
    print(f"sent OTA-enter trigger ({n} bytes, code {code:#04x}); "
          "device should re-enumerate as ota-FM-1 (4d4a:4155)")
    time.sleep(2.0)
    d2 = find_device(VID_OTA, PID_OTA)
    print("ota device present" if d2 else
          "ota device NOT seen — enter trigger may differ (see docs/io/11-ota-protocol.md)")

def cmd_flash(args):
    _need_usb()
    data = open(args.file, "rb").read()
    print(f"image {args.file}: {len(data)} bytes")
    if not args.no_enter:
        cmd_enter(args)
        time.sleep(1.0)
    d = find_device(VID_OTA, PID_OTA)
    if not d and not args.dry_run:
        sys.exit("ota-FM-1 (4d4a:4155) not found — device did not enter OTA mode")
    upload(d, data, args)

def upload(dev, data, args):
    """Upload the .fwsc to the OTA loader.

    The loader (`usb_hid_ota.bin`) parses the .fwsc stream itself; the host
    just streams it in report-sized chunks. The exact per-report command
    header was not recovered from ota.bin in this pass, so the default is a
    plain raw stream (63 B reports, no per-report header) — validate/adjust
    against a live M-UPGRADE capture. Set FM1_OTA_CHUNK / FM1_OTA_HEADER=hex
    to tweak without editing.
    """
    chunk_sz = int(os.environ.get("FM1_OTA_CHUNK", "63"))
    header = bytes.fromhex(os.environ.get("FM1_OTA_HEADER", ""))
    off, total, t0 = 0, len(data), time.time()
    last_pct = -1
    if header:
        dev.write(0x01, header + struct.pack("<I", total), timeout=2000)
    while off < total:
        chunk = data[off:off + chunk_sz]
        if args.dry_run:
            if off == 0 or off + chunk_sz >= total:
                print(f"  [{off:#07x}] report {len(chunk)}B {chunk[:8].hex()}..")
        else:
            dev.write(0x01, chunk, timeout=3000)   # EP1 OUT (HID interrupt)
        off += len(chunk)
        pct = 100 * off // total
        if pct != last_pct and (pct % 5 == 0 or off >= total):
            print(f"  {pct:3d}% ({off}/{total})")
            last_pct = pct
    print(f"streamed {total} bytes in {time.time()-t0:.1f}s"
          + (" (dry-run)" if args.dry_run else ""))
    if not args.dry_run:
        print("loader verifies + flashes, then reboots to normal mode")

def cmd_info(args):
    """syscmd get_version (cmd 21) over raw USB-MIDI bulk (normal mode)."""
    _need_usb()
    d = find_device(args.vid, args.pid)
    if not d:
        sys.exit("device not found")
    pkt = syscmd_packet(21)
    if args.dry_run:
        print("syscmd get_version packet:", pkt.hex())
        return
    claim(d, 4)
    d.write(EP_MIDI_OUT, pkt, timeout=1000)
    try:
        rep = bytes(d.read(0x84, 64, timeout=1000))
        print("reply:", rep.hex())
        try:
            hdr, cmd, payload = syscmd_parse(rep)
            print(f"  hdr={hdr:#x} cmd={cmd} payload={payload!r}")
        except ValueError as e:
            print("  (parse:", e, ")")
    except usb.core.USBTimeoutError:
        print("no reply (syscmd may use a different transport)")

def cmd_packet(args):
    pkt = syscmd_packet(args.code, bytes.fromhex(args.payload or ""))
    print(pkt.hex())

def main():
    ap = argparse.ArgumentParser(description="FM-1 OTA Linux CLI (M-UPGRADE core)")
    ap.add_argument("--vid", type=lambda x: int(x, 0), default=VID_NORMAL)
    ap.add_argument("--pid", type=lambda x: int(x, 0), default=PID_NORMAL)
    ap.add_argument("--dry-run", action="store_true")
    sub = ap.add_subparsers(dest="cmd", required=True)
    sub.add_parser("find")
    e = sub.add_parser("enter")
    e.add_argument("--fake", action="store_true", help="send 0x7F instead of 0x7D")
    f = sub.add_parser("flash")
    f.add_argument("file")
    f.add_argument("--no-enter", action="store_true", help="device already in OTA mode")
    sub.add_parser("info")
    p = sub.add_parser("packet")
    p.add_argument("code", type=int)
    p.add_argument("payload", nargs="?")
    args = ap.parse_args()
    {"find": cmd_find, "enter": cmd_enter, "flash": cmd_flash,
     "info": cmd_info, "packet": cmd_packet}[args.cmd](args)

if __name__ == "__main__":
    main()
