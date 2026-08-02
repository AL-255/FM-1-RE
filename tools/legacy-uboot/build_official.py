#!/usr/bin/env python3
"""Build the files for the OFFICIAL JieLi USB upload (isd_download).

Produces build/official/ containing everything isd_download needs:
  app.bin        stock app.bin + demo hooks (boot + MIDI) + demo blob appended
  uboot.boot     stock SPL
  cfg            stock config resource
  cfg_tool.bin   stock config-tool binary
  isd_config.ini FM-1 (AC693N) download config

isd_download re-packs and encrypts the JLFS image itself, so app.bin here is
PLAINTEXT (no chipkey encryption on our side).
"""
import os, struct, sys, json, shutil

HERE = os.path.dirname(os.path.abspath(__file__))
TOOLS = os.path.dirname(HERE)
ROOT = os.path.dirname(TOOLS)
REPO = ROOT
UNPACK = os.path.join(REPO, "firmware-images", "v13", "raw_fw", "FM-1.fwsc_unpack")
APPBIN = os.path.join(UNPACK, "files", "app.bin")
DEMO_BIN = os.path.join(ROOT, "firmware", "build", "demo.bin")
DEMO_MAP = os.path.join(ROOT, "firmware", "build", "demo.map.json")
ISD_CONFIG = os.path.join(HERE, "isd_config.ini")
OUT = os.path.join(ROOT, "build", "official")

XIP = 0x02000000
BLOB_OFF = 0x8E600          # demo blob offset inside app.bin (== XIP 0x0208E600)

USR_APP_TASK = 0x02022CFE
MIDI_DISPATCH = 0x0201F5F4


def enc_call(site_vma, target_vma):
    return b"\x80\xff" + struct.pack("<i", target_vma - site_vma - 6)


def main():
    app = bytearray(open(APPBIN, "rb").read())
    demo = open(DEMO_BIN, "rb").read()
    dmap = json.load(open(DEMO_MAP))
    tramp, tramp_midi = dmap["__tramp_usr_app_task"], dmap["__tramp_midi"]

    assert dmap["demo_install"] >= XIP + BLOB_OFF, "blob must be linked at BLOB_OFF"

    # hooks
    app[USR_APP_TASK - XIP: USR_APP_TASK - XIP + 6] = enc_call(USR_APP_TASK, tramp)
    app[MIDI_DISPATCH - XIP: MIDI_DISPATCH - XIP + 6] = enc_call(MIDI_DISPATCH, tramp_midi)

    # append blob at BLOB_OFF (pad gap with 0xFF)
    if len(app) < BLOB_OFF:
        app += b"\xff" * (BLOB_OFF - len(app))
    app += demo

    os.makedirs(OUT, exist_ok=True)
    open(os.path.join(OUT, "app.bin"), "wb").write(app)

    for src, dst in [
        (os.path.join(UNPACK, "top", "uboot.boot"), "uboot.boot"),
        (os.path.join(UNPACK, "files", "cfg"), "cfg"),
        (os.path.join(UNPACK, "files", "cfg_tool.bin"), "cfg_tool.bin"),
        (ISD_CONFIG, "isd_config.ini"),
    ]:
        shutil.copy(src, os.path.join(OUT, dst))

    # verify hook patches present
    ok = (bytes(app[USR_APP_TASK - XIP: USR_APP_TASK - XIP + 6]) == enc_call(USR_APP_TASK, tramp)
          and bytes(app[MIDI_DISPATCH - XIP: MIDI_DISPATCH - XIP + 6]) == enc_call(MIDI_DISPATCH, tramp_midi))
    print(f"official app.bin {len(app):#x} bytes (hooks {'OK' if ok else 'FAIL'}), blob @{BLOB_OFF:#x}")
    print(f"staged in {OUT}")
    assert ok


if __name__ == "__main__":
    main()
