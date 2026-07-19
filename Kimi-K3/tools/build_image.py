#!/usr/bin/env python3
"""Build the FM-1 custom-synth demo flash image.

Takes the stock FM-1.fwsc (UFW), decrypts its app area, applies the demo
patches (boot trampoline + MIDI call-site hooks), re-encrypts, and emits:

  build/fm1_demo_flash.bin   0x94000 bytes — write at flash offset 0x0
  build/demo_blob.bin        N bytes      — write at flash offset 0xEA000 (USR)

Patches (all inside app.bin, file-offset == XIP - 0x02000000):
  - 0x22CFE (usr_app_task entry): 6-byte call -> __tramp_usr_app_task
  - 5 midi_msg_dispatch call sites: redirect to demo_midi_hook
The DAC render hook is installed at runtime by demo_install (RAM pointer).

Verify with --verify after building.
"""
import os, struct, sys, json

HERE = os.path.dirname(os.path.abspath(__file__))
ROOT = os.path.dirname(HERE)
FWSC = "/home/yukidama/JL/FM-1/disasm_FM-1_2026_07_03_V13/raw_fw/FM-1.fwsc"
APPBIN = "/home/yukidama/JL/FM-1/disasm_FM-1_2026_07_03_V13/raw_fw/FM-1.fwsc_unpack/files/app.bin"
DEMO_BIN = os.path.join(ROOT, "firmware", "build", "demo.bin")
DEMO_MAP = os.path.join(ROOT, "firmware", "build", "demo.map.json")
OUT = os.path.join(ROOT, "build")

sys.path.insert(0, "/home/yukidama/JL/FM-1/3rd-party/jl-misctools/firmware")
from jltech.crc import jl_crc16
from jltech.cipher import jl_enc_cipher, jl_sfc_cipher
from jltech.chipkeybin import chipkeybin_decode

XIP = 0x02000000
APP_AREA_BASE = 0x4000          # JLFS app area base in flash.bin
APP_BIN_FW = 0x4120             # flash offset of app.bin data
APP_BIN_SIZE = 0x8E59C
CFG_END = 0x9283B               # end of cfg_tool.bin in flash
BLOB_FW = 0xEA000               # where the demo blob is written (USR region)

# hook call sites (app.bin file offsets), from the disassembly call-graph
USR_APP_TASK = 0x02022CFE
MIDI_DISPATCH = 0x0201F5F4      # midi_msg_dispatch entry (patched with 6-byte call)


def extract_flash_bin(path):
    """UFW -> raw flash.bin (mirror of fwunpack_newfw.load_fwsc)."""
    data = open(path, "rb").read()
    header = bytearray()
    f_off = 0
    for _ in range(20):
        header += data[f_off:f_off + 0x30][:0x2f]
        f_off += 0x30
    offskew = f_off - len(header)
    jl_enc_cipher(header, 0, 0x40, 0xFFFF)
    hdrcrc, hdata = struct.unpack_from("<H62s", header, 0)
    assert jl_crc16(hdata) == hdrcrc, "UFW header CRC fail"
    _, listcrc, imgsize, numents, _, _, chipname = struct.unpack_from("<HHIHHI48s", header, 0)
    assert jl_crc16(header[0x40:0x40 + numents * 0x50]) == listcrc, "UFW list CRC fail"
    for off in range(0x40, 0x40 + numents * 0x50, 0x50):
        jl_enc_cipher(header, off, 0x50, 0xFFFF)
        etype, eindex, edcrc, ewa1, eoffset, esize, esize2, ewa2, ename = \
            struct.unpack_from("<HHHHIII44s16s", header, off)
        if etype == 0:
            fw = bytearray(data[eoffset + offskew: eoffset + offskew + esize])
            assert jl_crc16(fw) == edcrc, "flash.bin CRC fail"
            return fw, chipname.split(b"\x00")[0].decode()
    raise RuntimeError("no flash.bin entry in UFW")


def enc_call(site_vma, target_vma):
    """6-byte pi32v2 long call: 80 ff + s32(target - site - 6)."""
    return b"\x80\xff" + struct.pack("<i", target_vma - site_vma - 6)


def main():
    os.makedirs(OUT, exist_ok=True)

    flash, chipname = extract_flash_bin(FWSC)
    print(f"flash.bin {len(flash):#x} bytes, chip {chipname}")

    ckdata = bytes(flash[0x38d0:0x38d0 + 32])
    chipkey = chipkeybin_decode(ckdata)
    print(f"chipkey {chipkey:#06x}")

    demo = open(DEMO_BIN, "rb").read()
    dmap = json.load(open(DEMO_MAP))
    tramp = dmap["__tramp_usr_app_task"]
    tramp_midi = dmap["__tramp_midi"]
    print(f"demo blob {len(demo)} bytes; tramp {tramp:#x} tramp_midi {tramp_midi:#x}")

    # decrypt app area in place (absolute offsets, sfc base = APP_AREA_BASE)
    app = bytearray(flash)
    jl_sfc_cipher(app, APP_AREA_BASE, CFG_END - APP_AREA_BASE, APP_AREA_BASE, chipkey)

    stock_app = open(APPBIN, "rb").read()
    assert bytes(app[APP_BIN_FW: APP_BIN_FW + len(stock_app)]) == stock_app, \
        "app area decryption mismatch"

    # --- patch 1: boot trampoline at usr_app_task entry
    site = USR_APP_TASK
    off = APP_BIN_FW + (site - XIP)
    app[off:off + 6] = enc_call(site, tramp)
    print(f"boot hook @ {site:#x} -> {tramp:#x}")

    # --- patch 2: MIDI entry trampoline at midi_msg_dispatch entry
    site = MIDI_DISPATCH
    off = APP_BIN_FW + (site - XIP)
    app[off:off + 6] = enc_call(site, tramp_midi)
    print(f"midi hook @ {site:#x} -> {tramp_midi:#x}")

    # re-encrypt app area
    jl_sfc_cipher(app, APP_AREA_BASE, CFG_END - APP_AREA_BASE, APP_AREA_BASE, chipkey)
    newflash = app

    out_flash = os.path.join(OUT, "fm1_demo_flash.bin")
    out_blob = os.path.join(OUT, "demo_blob.bin")
    open(out_flash, "wb").write(newflash)
    open(out_blob, "wb").write(demo)

    # verification pass: decrypt the new image, check patches present
    chk = bytearray(newflash)
    jl_sfc_cipher(chk, APP_AREA_BASE, CFG_END - APP_AREA_BASE, APP_AREA_BASE, chipkey)
    ok_boot = bytes(chk[APP_BIN_FW + USR_APP_TASK - XIP: APP_BIN_FW + USR_APP_TASK - XIP + 6]) == enc_call(USR_APP_TASK, tramp)
    ok_midi = bytes(chk[APP_BIN_FW + MIDI_DISPATCH - XIP: APP_BIN_FW + MIDI_DISPATCH - XIP + 6]) == enc_call(MIDI_DISPATCH, tramp_midi)
    print(f"verify: boot hook {'OK' if ok_boot else 'FAIL'}, midi hooks {'OK' if ok_midi else 'FAIL'}")
    assert ok_boot and ok_midi

    with open(os.path.join(OUT, "flash_regions.txt"), "w") as f:
        f.write(f"0x000000 {out_flash}   # modified app area (0x94000)\n")
        f.write(f"0x{0xEA000:06x} {out_blob}   # demo blob ({len(demo)} bytes)\n")
    print(f"wrote {out_flash} ({len(newflash):#x}) and {out_blob} ({len(demo):#x})")


if __name__ == "__main__":
    main()
