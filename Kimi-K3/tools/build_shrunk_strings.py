#!/usr/bin/env python3
"""Build a shrunken FM-1 OTA loader that fits the 19456-byte step-1 limit.

Strategy (verified by disassembly in docs/ota-loader-shrinking.md):
- Zero the USB string descriptors that are not required for enumeration
  (manufacturer / product / serial / "USB-Midi"), keeping only the language
  ID at 0x2bc0..0x2bc3.
- Zero optional debug / dead file-name strings at 0x2d90..0x2dc3.
- Zero the unused file-filter string "/*.ufw" at 0x5ac0..0x5ac6.
- Patch the USB device descriptor iManufacturer / iProduct indices to 0 so
  the host no longer requests the zeroed strings.

Expected real compressed payload: ~19440 bytes, padded to 19456 (a valid
512-byte multiple) for the device verifier.  This keeps the core HID/OTA
flash-update path intact.
"""
import struct, sys
sys.path.insert(0, "/home/yukidama/JL/FM-1/Kimi-K3/tools")
import patch_ota2
sys.path.insert(0, "/home/yukidama/JL/FM-1/3rd-party/jl-misctools/firmware")
from jltech.crc import jl_crc16

OTA_SIZE = 0x4e01
IMG_SIZE = 0x5b1c
BLOCK_DSIZES = (0x1000, 0x1000, 0x1000, 0x1000, 0x1000, 0xb1c)
STOCK_OTA = "/tmp/ota_re/ota_real.bin"
TARGET_DLEN = 19456

# Image regions to zero (start inclusive, end exclusive)
ZERO_REGIONS = [
    (0x2bc4, 0x2c50),   # USB strings except language ID (host won't request them)
    (0x2d90, 0x2dc4),   # optional debug / dead strings
    (0x2e04, 0x2e1f),   # uboot.boot / isd_config.ini / VM strings (not needed for HID OTA)
    (0x5ac0, 0x5ac7),   # unused "/*.ufw" filter string
]

# Arbitrary byte patches: (image_offset, new_value)
BYTE_PATCHES = [
    (0x5b0e, 0x00),     # USB device descriptor iManufacturer -> 0
    (0x5b0f, 0x00),     # USB device descriptor iProduct -> 0
]


def decompress(ota):
    dlen = struct.unpack_from('<I', ota, 0x08)[0]
    out = bytearray()
    off = 0x40
    while off < 0x20 + dlen:
        csize, dsize = struct.unpack_from('<II', ota, off)
        consumed = patch_ota2._lz4_block_decode(out, ota[off + 8:off + 8 + csize])
        assert consumed == csize
        off += 8 + csize
    return bytes(out)


def build():
    stock_ota = open(STOCK_OTA, 'rb').read()
    img = bytearray(decompress(stock_ota))
    assert len(img) == IMG_SIZE

    for s, e in ZERO_REGIONS:
        for i in range(s, e):
            img[i] = 0
    for off, val in BYTE_PATCHES:
        img[off] = val

    enc = bytearray()
    for off, dsize in zip((0, 0x1000, 0x2000, 0x3000, 0x4000, 0x5000), BLOCK_DSIZES):
        blk = img[off:off + dsize]
        dict_data = img[:off]
        seqs = patch_ota2._optimal_parse(bytes(blk), bytes(dict_data))
        comp = patch_ota2._serialize(seqs)
        enc.extend(struct.pack('<II', len(comp), dsize))
        enc.extend(comp)
    real_dlen = len(enc)
    if real_dlen > TARGET_DLEN:
        raise ValueError(f"compressed payload {real_dlen} exceeds target {TARGET_DLEN}")

    # Rebuild file: keep stock outer + inner headers, then new compressed blocks
    new = bytearray(stock_ota[:0x40])
    new.extend(enc)

    if len(new) < 0x20 + TARGET_DLEN:
        new.extend(bytes(TARGET_DLEN - (len(new) - 0x20)))

    # Inner header integrity fields
    struct.pack_into('<H', new, 0x22, jl_crc16(bytes(img)))          # inner_datacrc
    struct.pack_into('<H', new, 0x20, jl_crc16(new[0x22:0x40]))      # inner_hdrcrc

    # Outer header
    struct.pack_into('<I', new, 0x08, TARGET_DLEN)                   # dlen
    struct.pack_into('<H', new, 0x02, jl_crc16(new[0x20:0x20 + TARGET_DLEN]))  # outer_datacrc
    struct.pack_into('<H', new, 0x00, jl_crc16(new[0x02:0x20]))      # outer_hdrcrc

    if len(new) < OTA_SIZE:
        new.extend(bytes(OTA_SIZE - len(new)))
    return bytes(new), real_dlen


if __name__ == "__main__":
    out = sys.argv[1] if len(sys.argv) > 1 else '/tmp/ota_shrunk_strings.bin'
    ota, dlen = build()
    open(out, 'wb').write(ota)
    print(f"wrote {out}: real_dlen={dlen} padded_dlen={TARGET_DLEN} total={len(ota)}")
