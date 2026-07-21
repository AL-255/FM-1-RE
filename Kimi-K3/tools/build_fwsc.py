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
# ota.bin (the OTA loader) UFW entry: logical 0xA6F20 == fwsc file offset 0xA6F34
# (logical = file - 20 for offsets past the 960-byte interleaved header).
OTA_FW = 0xA6F34
OTA_SIZE = 0x4E01

# Product name + version live in the interleave block MARKERS: the byte at
# offset 0x2F of each 0x30 block encodes one ASCII char as (char + index + 1).
# "FM-1_009" -> markers[5,6,7] are the version digits. Bump to _014 so the
# stock V9 device's same-version check passes (verified by the M-UPGRADE
# parser spec: name up to '_', then 3 decimal digits, ends at raw 0x7D).
VER_NAME = "FM-1_015"
HDRKEY = 0xFFFF

USR_APP_TASK = 0x02022CFE
MIDI_DISPATCH = 0x0201F5F4


def enc_call(site, target):
    return b"\x80\xff" + struct.pack("<i", target - site - 6)


def encode_markers(name):
    """Encode 'FM-1_014' into the 20 interleave markers (char+index+1,
    terminator 0x7D for the rest)."""
    m = []
    for i in range(20):
        if i < len(name):
            m.append((ord(name[i]) + i + 1) & 0xFF)
        else:
            m.append(0x7D)
    return m


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
    # FM1_STOCK_APP=1 builds a control image: NO demo app.bin modifications
    # (used to isolate whether the OTA refusal is caused by the demo code).
    stock_app = os.environ.get("FM1_STOCK_APP") == "1"
    if not stock_app:
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

    if not stock_app:
        flash[APP_BIN_FW + USR_APP_TASK - XIP: APP_BIN_FW + USR_APP_TASK - XIP + 6] = enc_call(USR_APP_TASK, tramp)
        flash[APP_BIN_FW + MIDI_DISPATCH - XIP: APP_BIN_FW + MIDI_DISPATCH - XIP + 6] = enc_call(MIDI_DISPATCH, tramp_midi)
        flash[APP_BIN_FW + BLOB_OFF: APP_BIN_FW + BLOB_OFF + len(demo)] = demo
    # product/version string in app.bin: the device's OTA verifier reads the
    # version from here ("FM-1_009"); bump it in step with the header markers
    voff = APP_BIN_FW + 0x4F241
    assert bytes(flash[voff:voff + 8]) == b"FM-1_009", "product string not found"
    flash[voff:voff + 8] = VER_NAME.encode()
    # JLFS entry for app.bin (at 0x4020): [hdrcrc:2][datacrc:2][off][size][flags][name]
    # datacrc must cover the patched app.bin or the OTA loader rejects the image
    struct.pack_into("<H", flash, 0x4022, jl_crc16(bytes(flash[APP_BIN_FW:APP_BIN_FW + APP_BIN_SIZE])))
    # hdrcrc covers the rest of the 32-byte entry header (bytes 2..31)
    struct.pack_into("<H", flash, 0x4020, jl_crc16(bytes(flash[0x4022:0x4040])))

    # app_area_head datacrc covers the whole app area from 0x4020 to the start
    # of the cfg daisychain at 0x9283B; update it because app.bin changed.
    APP_AREA_HEAD = 0x4000
    APP_AREA_CRC_END = 0x9283B
    struct.pack_into("<H", flash, APP_AREA_HEAD + 2,
                     jl_crc16(bytes(flash[0x4020:APP_AREA_CRC_END])))
    struct.pack_into("<H", flash, APP_AREA_HEAD,
                     jl_crc16(bytes(flash[APP_AREA_HEAD + 2:APP_AREA_HEAD + 32])))

    # --- cfg "same-version" no-op bypass -----------------------------------
    # The on-device step-1 verifier reads the incoming cfg JLFS entry header
    # (32 bytes at flash 0x9283B) and refuses the update when it matches the
    # cfg already stored on the device (a same-config no-op). The stored cfg
    # is byte-identical to the stock one in every image we have, so every
    # stock-cfg image is refused regardless of the FM-1_0xx version strings.
    # Fix: change ONE padding byte in the nested eq_cfg_hw.bin entry's 16-byte
    # name field (inside the cfg data). That changes the cfg datacrc/hdrcrc
    # the verifier reads, so the incoming cfg no longer matches, while the eq
    # payload and both entry names stay byte-identical (fully valid JLFS).
    CFG_E = 0x9283B          # cfg daisychain entry offset in flash
    EQ_E = 0x9285B           # nested eq_cfg_hw.bin entry offset
    EQ_DATA_LEN = 2873       # eq_cfg_hw.bin payload length
    EQ_NAME_PAD = 0x9287A    # last pad byte of eq entry's 16-byte name field
    assert flash[EQ_NAME_PAD] == 0xFF, "eq name padding not where expected"
    flash[EQ_NAME_PAD] = 0xFE
    # eq entry hdrcrc (eq datacrc unchanged: eq payload untouched)
    struct.pack_into("<H", flash, EQ_E, jl_crc16(bytes(flash[EQ_E + 2:EQ_E + 32])))
    # cfg datacrc covers the nested eq entry (header + payload = 32 + 2873)
    struct.pack_into("<H", flash, CFG_E + 2,
                     jl_crc16(bytes(flash[EQ_E:EQ_E + 32 + EQ_DATA_LEN])))
    # cfg hdrcrc
    struct.pack_into("<H", flash, CFG_E, jl_crc16(bytes(flash[CFG_E + 2:CFG_E + 32])))

    jl_sfc_cipher(flash, APP_AREA_BASE, len(flash) - APP_AREA_BASE, APP_AREA_BASE, CHIPKEY)
    data[FLASH_DISK:FLASH_DISK + FLASH_SIZE] = flash

    # ---- 1.5. ota.bin (the OTA loader) -------------------------------------
    # MECHANISM (verified on hardware 2026-07-21): the step-1 verifier writes
    # the incoming ota.bin payload to the loader flash region as PLAINTEXT and
    # reads it back for the payload CRC. For payloads <= 19456 bytes (0x4C00)
    # the write/read round-trip is IDENTITY (verified: 64..19456-byte payloads
    # all PASS with plain datacrc, no scrambling needed). The stock loader is
    # 19937 bytes (0x4DE1) — 481 bytes over the limit; the tail does NOT read
    # back correctly (write is dropped at the ~19456-byte region limit, not
    # descrambled: 16 plain/SFC pre-scramble keys all failed). So the stock
    # loader can never pass as-is; it must be SHRUNK to <= 19456 bytes.
    # FM1_OTA_FILE: inject a pre-built ota.bin (e.g. the shrunken loader).
    # FM1_OTA_SEED: (legacy, only for experimenting with the descramble path)
    # per-512-byte-chunk pre-scramble of the payload; "none" (default) leaves
    # the payload plaintext.
    from jltech.cipher import jl_enc_cipher as _jl_enc
    if os.environ.get("FM1_STOCK_OTA") == "1":
        ota = bytearray(data[OTA_FW:OTA_FW + OTA_SIZE])   # leave ota.bin stock
    elif os.environ.get("FM1_OTA_FILE"):
        ota = bytearray(open(os.environ["FM1_OTA_FILE"], "rb").read())
    else:
        import patch_ota2
        ota = bytearray(patch_ota2.patch(bytes(data[OTA_FW:OTA_FW + OTA_SIZE])))
    # The step-1 verifier uses the ota.bin outer header's dlen field to decide
    # how many payload bytes to copy to the loader region.  The UFW entry's
    # `size` must match dlen+0x20 so the boot record's loader size is correct.
    # Shrunken loaders may be shorter than OTA_SIZE; pad to the disk allocation
    # so the rest of the layout is unchanged.
    ota_dlen = struct.unpack_from("<I", ota, 0x08)[0]
    ota_ufw_size = ota_dlen + 0x20
    assert 0x20 < ota_ufw_size <= OTA_SIZE
    if len(ota) < OTA_SIZE:
        ota.extend(bytes(OTA_SIZE - len(ota)))
    assert len(ota) == OTA_SIZE
    seed_s = os.environ.get("FM1_OTA_SEED", "none")
    if seed_s.lower() != "none":
        seed = int(seed_s, 0) & 0xFFFF
        # per-512-byte-chunk pre-scramble of the payload (LFSR restarts/chunk)
        KS = bytearray(512)
        _jl_enc(KS, 0, 512, seed)                          # one chunk keystream
        for off in range(0x20, OTA_SIZE, 512):
            n = min(512, OTA_SIZE - off)
            for i in range(n):
                ota[off + i] ^= KS[i]
    patched_ota = bytes(ota)
    data[OTA_FW:OTA_FW + OTA_SIZE] = patched_ota

    # ---- 2. fix the UFW header: flash.bin edcrc, then listcrc, then hdrcrc
    # (listcrc is over the ENCRYPTED entry list; hdrcrc over decrypted [2:0x40])
    header, markers = load_fwsc_header(data)
    jl_enc_cipher(header, 0, 0x40, HDRKEY)                 # decrypt UFW header
    hdrcrc, listcrc, imgsize, numents, wa3, wa4, chipname = struct.unpack_from("<HHIHHI48s", header, 0)
    headersize = 0x40 + numents * 0x50
    for off in range(0x40, headersize, 0x50):
        jl_enc_cipher(header, off, 0x50, HDRKEY)           # decrypt entries
    # update the data crc of the entries we modified (etype 0 = flash.bin,
    # etype 100 = ota.bin; dcrc field at entry+4)
    for off in range(0x40, headersize, 0x50):
        etype, eindex, edcrc, ewa1, eoffset, esize, esize2, ewa2, ename = \
            struct.unpack_from("<HHHHIII44s16s", header, off)
        if etype == 0:
            struct.pack_into("<H", header, off + 4, jl_crc16(flash))
        elif etype == 100:
            # Shrink the UFW-reported size to the actual valid ota.bin length;
            # keep size2 (disk allocation) unchanged so the rest of the layout
            # does not move.  The dcrc covers only the valid bytes.
            struct.pack_into("<I", header, off + 12, ota_ufw_size)
            struct.pack_into("<H", header, off + 4, jl_crc16(patched_ota[:ota_ufw_size]))
    for off in range(0x40, headersize, 0x50):
        jl_enc_cipher(header, off, 0x50, HDRKEY)           # re-encrypt entries
    listcrc = jl_crc16(header[0x40:headersize])            # over ENCRYPTED list
    struct.pack_into("<H", header, 2, listcrc)
    hdrcrc = jl_crc16(header[2:0x40])                      # over decrypted [2:0x40]
    struct.pack_into("<H", header, 0, hdrcrc)
    jl_enc_cipher(header, 0, 0x40, HDRKEY)                 # re-encrypt UFW header

    # ---- 3. re-interleave the header into 0x30 blocks with the bumped
    # name/version markers (FM-1_015) so the stock V9 device accepts it
    out = bytearray(data)
    markers = encode_markers(VER_NAME)
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
