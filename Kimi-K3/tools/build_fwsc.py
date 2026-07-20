#!/usr/bin/env python3
"""Repack the stock FM-1.fwsc into FM-1-demo.fwsc (M-UPGRADE / OTA format).

Surgical approach — keeps the stock container byte-identical except:
  1. flash.bin: app.bin gets the demo hooks (boot + MIDI) and the demo blob
     at 0x46600 (inside the font/bitmap rodata region). Same size (0x94000).
  2. the UFW entry list's flash.bin data-CRC + the header/list CRCs are
     recomputed to match.

Everything else (USR region, isd_config, ota.bin, SPL, partitions) stays
exactly as in the stock file, so M-UPGRADE / the on-device OTA loader treat
it as a valid FM-1 update. The blob lives inside the app area (OTA always
writes flash.bin) and inside the proven XIP map.

Verify with: python3 3rd-party/jl-misctools/firmware/fwunpack_newfw.py \
              --dirname demo_unpack Kimi-K3/build/FM-1-demo.fwsc
"""
import os, struct, sys, json

HERE = os.path.dirname(os.path.abspath(__file__))
ROOT = os.path.dirname(HERE)
FWSC = "/home/yukidama/JL/FM-1/disasm_FM-1_2026_07_03_V13/raw_fw/FM-1.fwsc"
APPBIN = "/home/yukidama/JL/FM-1/disasm_FM-1_2026_07_03_V13/raw_fw/FM-1.fwsc_unpack/files/app.bin"
DEMO_BIN = os.path.join(ROOT, "firmware", "build", "demo.bin")
DEMO_MAP = os.path.join(ROOT, "firmware", "build", "demo.map.json")
OUT = os.path.join(ROOT, "build", "FM-1-demo.fwsc")

sys.path.insert(0, "/home/yukidama/JL/FM-1/3rd-party/jl-misctools/firmware")
from jltech.crc import jl_crc16
from jltech.cipher import jl_enc_cipher, jl_sfc_cipher
from jltech.chipkeybin import chipkeybin_decode

XIP = 0x02000000
APP_AREA_BASE = 0x4000          # JLFS app area base (sfc cipher base)
APP_BIN_FW = 0x4120             # flash offset of app.bin data
APP_BIN_SIZE = 0x8E59C
FLASH_DISK = 0x414              # flash.bin offset inside the .fwsc
FLASH_SIZE = 0x94000
BLOB_OFF = 0x46600              # demo blob offset inside app.bin (font region)
CHIPKEY = 0x980F                # 38927

# version identity inside app.bin: "FM-1_009" rodata string + version byte;
# keep the product string unchanged (boot-record name must stay "FM-1_009"),
# bump only the version byte so M-UPGRADE's same-version check passes.
VER_OFF = 0x4F241               # offset of the 24-byte name/version field
VER_NAME = b"FM-1_009"
VER_BYTE = 0x0E
HDRKEY = 0xFFFF

USR_APP_TASK = 0x02022CFE
MIDI_DISPATCH = 0x0201F5F4


def enc_call(site, target):
    return b"\x80\xff" + struct.pack("<i", target - site - 6)


def load_fwsc_header(data):
    """Reassemble the logical header from 0x30 blocks (load_fwsc)."""
    header = bytearray()
    off = 0
    markers = []
    for _ in range(20):
        header += data[off:off + 0x30][:0x2f]
        markers.append(data[off + 0x2f])
        off += 0x30
    return header, markers


def main():
    data = bytearray(open(FWSC, "rb").read())
    demo = open(DEMO_BIN, "rb").read()
    dmap = json.load(open(DEMO_MAP))
    tramp, tramp_midi = dmap["__tramp_usr_app_task"], dmap["__tramp_midi"]
    assert dmap["demo_install"] >= XIP + BLOB_OFF, "blob must be linked at the font region"

    # ---- 1. flash.bin: decrypt app area, patch, write blob, re-encrypt
    flash = bytearray(data[FLASH_DISK:FLASH_DISK + FLASH_SIZE])
    # sanity: app area round-trips to stock app.bin
    jl_sfc_cipher(flash, APP_AREA_BASE, len(flash) - APP_AREA_BASE, APP_AREA_BASE, CHIPKEY)
    assert bytes(flash[APP_BIN_FW:APP_BIN_FW + APP_BIN_SIZE]) == open(APPBIN, "rb").read(), \
        "app area decryption mismatch (chipkey)"

    flash[APP_BIN_FW + USR_APP_TASK - XIP: APP_BIN_FW + USR_APP_TASK - XIP + 6] = enc_call(USR_APP_TASK, tramp)
    flash[APP_BIN_FW + MIDI_DISPATCH - XIP: APP_BIN_FW + MIDI_DISPATCH - XIP + 6] = enc_call(MIDI_DISPATCH, tramp_midi)
    flash[APP_BIN_FW + BLOB_OFF: APP_BIN_FW + BLOB_OFF + len(demo)] = demo
    # NOTE: no version bump / no JLFS datacrc touch — the stock step-1
    # verifier accepts the image as-is; changing those fields made the
    # verifier take a different (failing) path.

    jl_sfc_cipher(flash, APP_AREA_BASE, len(flash) - APP_AREA_BASE, APP_AREA_BASE, CHIPKEY)
    data[FLASH_DISK:FLASH_DISK + FLASH_SIZE] = flash

    # ---- 2. fix the UFW header: flash.bin edcrc, then listcrc, then hdrcrc
    # (listcrc is over the ENCRYPTED entry list; hdrcrc over decrypted [2:0x40])
    header, markers = load_fwsc_header(data)
    jl_enc_cipher(header, 0, 0x40, HDRKEY)                 # decrypt UFW header
    hdrcrc, listcrc, imgsize, numents, wa3, wa4, chipname = struct.unpack_from("<HHIHHI48s", header, 0)
    headersize = 0x40 + numents * 0x50
    for off in range(0x40, headersize, 0x50):
        jl_enc_cipher(header, off, 0x50, HDRKEY)           # decrypt entries
    # update flash.bin entry's data crc (etype == 0, field at entry+4)
    for off in range(0x40, headersize, 0x50):
        etype, eindex, edcrc, ewa1, eoffset, esize, esize2, ewa2, ename = \
            struct.unpack_from("<HHHHIII44s16s", header, off)
        if etype == 0:
            struct.pack_into("<H", header, off + 4, jl_crc16(flash))
            break
    for off in range(0x40, headersize, 0x50):
        jl_enc_cipher(header, off, 0x50, HDRKEY)           # re-encrypt entries
    listcrc = jl_crc16(header[0x40:headersize])            # over ENCRYPTED list
    struct.pack_into("<H", header, 2, listcrc)
    hdrcrc = jl_crc16(header[2:0x40])                      # over decrypted [2:0x40]
    struct.pack_into("<H", header, 0, hdrcrc)
    jl_enc_cipher(header, 0, 0x40, HDRKEY)                 # re-encrypt UFW header

    # ---- 3. re-interleave the header into 0x30 blocks (keep stock markers)
    out = bytearray(data)
    for i in range(20):
        blk = bytes(header[i * 0x2f:(i + 1) * 0x2f]) + bytes([markers[i]])
        out[i * 0x30:(i + 1) * 0x30] = blk
    # data regions (flash.bin) already replaced in `out` via `data`

    os.makedirs(os.path.dirname(OUT), exist_ok=True)
    open(OUT, "wb").write(out)
    print(f"wrote {OUT} ({len(out):#x} bytes)")
    print("verify: python3 3rd-party/jl-misctools/firmware/fwunpack_newfw.py "
          "--dirname demo_unpack " + OUT)


if __name__ == "__main__":
    main()
