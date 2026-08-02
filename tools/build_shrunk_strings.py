#!/usr/bin/env python3
"""Build a shrunken FM-1 OTA loader that fits the 19456-byte step-1 limit.

Strategy (verified by disassembly in docs/ota-loader-shrinking.md):
- Replace the payload-bearing USB string descriptors (manufacturer / serial /
  product / "USB-Midi") with valid but *empty* string descriptors
  (bLength=2, bDescriptorType=3).  The language-ID descriptor (index 0) is
  left untouched.  This keeps USB enumeration working while removing the
  bulk of the string payload.
- Zero optional debug / dead file-name strings at 0x2da4..0x2e1e, but keep
  the "success", "UPDATE_JUMP" and "VM" strings that the loader uses.
- Zero the unused file-filter string "/*.ufw" at 0x5ac0..0x5ac6.

The step-1 verifier requires the outer `dlen` to be an exact multiple of 512.
The compressed payload is inflated in the last LZ4 block (by converting a match
into literal bytes, which does not change the decompressed image) so that the
payload ends exactly at a 512-byte boundary with no trailing padding.  Some
loader builds do not tolerate post-block padding, so an exact fit is safer.
"""
import os, struct, sys

HERE = os.path.dirname(os.path.abspath(__file__))
ROOT = os.path.dirname(HERE)
REPO = ROOT
sys.path.insert(0, HERE)
import patch_ota2
sys.path.insert(0, os.path.join(REPO, "3rd-party", "jl-misctools", "firmware"))
from jltech.crc import jl_crc16

OTA_SIZE = 0x4e01
IMG_SIZE = 0x5b1c
BLOCK_DSIZES = (0x1000, 0x1000, 0x1000, 0x1000, 0x1000, 0xb1c)
BLOCK_OFFS = (0, 0x1000, 0x2000, 0x3000, 0x4000, 0x5000)
STOCK_OTA = os.path.join(ROOT, "analysis", "device", "ota-loader", "ota_stock.bin")
MAX_DLEN = 19456

# Regions to zero (start inclusive, end exclusive)
ZERO_REGIONS = [
    (0x2bc4, 0x2c4d),   # USB string descriptor content, rebuilt below
    (0x2d98, 0x2e04),   # POWER_PIN / cfg_tool.bin / flash.bin dead strings
    (0x5ac0, 0x5ae0),   # whole 32-byte .data buffer that holds "/*.ufw" (overwritten at runtime)
]

# Empty USB string descriptors (bLength=2, bDescriptorType=3)
EMPTY_STRING_DESC = {
    0x2bc4, 0x2be6, 0x2c08, 0x2c3b,
}


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


def encode_blocks(img):
    """Return (enc_bytearray, list_of_csize)."""
    enc = bytearray()
    csizes = []
    for off, dsize in zip(BLOCK_OFFS, BLOCK_DSIZES):
        blk = img[off:off + dsize]
        dict_data = img[:off]
        seqs = patch_ota2._optimal_parse(bytes(blk), bytes(dict_data))
        comp = patch_ota2._serialize(seqs)
        enc.extend(struct.pack('<II', len(comp), dsize))
        enc.extend(comp)
        csizes.append(len(comp))
    return enc, csizes


def build():
    stock_ota = open(STOCK_OTA, 'rb').read()
    img = bytearray(decompress(stock_ota))
    assert len(img) == IMG_SIZE

    for s, e in ZERO_REGIONS:
        for i in range(s, e):
            img[i] = 0

    # Restore empty USB string descriptors so the host sees valid descriptors.
    for off in EMPTY_STRING_DESC:
        img[off] = 2          # bLength
        img[off + 1] = 3      # bDescriptorType (string)

    enc, csizes = encode_blocks(img)
    real_dlen = len(enc)
    outer_data = real_dlen + 0x20

    if outer_data > MAX_DLEN:
        raise ValueError(f"compressed payload needs {outer_data} bytes, max {MAX_DLEN}")

    # Round outer_data up to the next 512-byte multiple (step-1 verifier rule).
    target_dlen = ((outer_data + 511) // 512) * 512
    inflate = target_dlen - outer_data

    if inflate:
        # Inflate the last block by `inflate` bytes without changing the image.
        last_idx = len(BLOCK_OFFS) - 1
        last_off = BLOCK_OFFS[last_idx]
        last_dsize = BLOCK_DSIZES[last_idx]
        target_csize = csizes[last_idx] + inflate
        new_last = patch_ota2._encode_block_exact(
            bytes(img[last_off:last_off + last_dsize]),
            bytes(img[:last_off]),
            target_csize,
        )
        # Replace the last block in enc.
        block_start = sum(8 + csizes[i] for i in range(last_idx))
        enc[block_start:block_start + 8 + csizes[last_idx]] = (
            struct.pack('<II', target_csize, last_dsize) + new_last
        )
        real_dlen = len(enc)
        outer_data = real_dlen + 0x20
        assert outer_data == target_dlen, f"{outer_data} != {target_dlen}"

    # Rebuild file: keep stock outer + inner headers, then new compressed blocks
    new = bytearray(stock_ota[:0x40])
    new.extend(enc)
    assert len(new) == 0x20 + target_dlen

    # Inner header integrity fields
    struct.pack_into('<H', new, 0x22, jl_crc16(bytes(img)))          # inner_datacrc
    struct.pack_into('<H', new, 0x20, jl_crc16(new[0x22:0x40]))      # inner_hdrcrc

    # Outer header
    struct.pack_into('<I', new, 0x08, target_dlen)                   # dlen
    struct.pack_into('<H', new, 0x02, jl_crc16(new[0x20:0x20 + target_dlen]))  # outer_datacrc
    struct.pack_into('<H', new, 0x00, jl_crc16(new[0x02:0x20]))      # outer_hdrcrc

    if len(new) < OTA_SIZE:
        new.extend(bytes(OTA_SIZE - len(new)))
    return bytes(new), real_dlen, target_dlen


if __name__ == "__main__":
    out = sys.argv[1] if len(sys.argv) > 1 else '/tmp/ota_shrunk_strings.bin'
    ota, dlen, target = build()
    open(out, 'wb').write(ota)
    print(f"wrote {out}: real_dlen={dlen} outer_dlen={target} total={len(ota)}")
