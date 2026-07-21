#!/usr/bin/env python3
"""Build a shrunken ota.bin by zeroing image regions and re-encoding with
the stock-compatible optimal LZ4 encoder, then pad the compressed payload
to a multiple of 512 (max 19456) so the device's step-1 verifier accepts it."""
import struct, sys
sys.path.insert(0, "/home/yukidama/JL/FM-1/Kimi-K3/tools")
import patch_ota2
sys.path.insert(0, "/home/yukidama/JL/FM-1/3rd-party/jl-misctools/firmware")
from jltech.crc import jl_crc16

OTA_SIZE = 0x4e01
IMG_SIZE = 0x5b1c
BLOCK_DSIZES = (0x1000, 0x1000, 0x1000, 0x1000, 0x1000, 0xb1c)
STOCK_OTA = "/tmp/ota_re/ota_real.bin"

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

def build(regions, target_dlen=19456):
    stock_ota = open(STOCK_OTA, 'rb').read()
    img = bytearray(decompress(stock_ota))
    assert len(img) == IMG_SIZE
    for s, e in regions:
        for i in range(s, e):
            img[i] = 0

    # Re-encode all 6 blocks with the optimal encoder
    enc = bytearray()
    for off, dsize in zip((0, 0x1000, 0x2000, 0x3000, 0x4000, 0x5000), BLOCK_DSIZES):
        blk = img[off:off + dsize]
        dict_data = img[:off]
        seqs = patch_ota2._optimal_parse(bytes(blk), bytes(dict_data))
        comp = patch_ota2._serialize(seqs)
        enc.extend(struct.pack('<II', len(comp), dsize))
        enc.extend(comp)
    real_dlen = len(enc)

    if real_dlen > target_dlen:
        raise ValueError(f"compressed payload {real_dlen} exceeds target {target_dlen}")

    # Rebuild file: keep stock outer + inner headers, then new compressed blocks
    new = bytearray(stock_ota[:0x40])
    new.extend(enc)

    if len(new) < 0x20 + target_dlen:
        new.extend(bytes(target_dlen - (len(new) - 0x20)))

    # Inner header integrity fields
    struct.pack_into('<H', new, 0x22, jl_crc16(bytes(img)))          # inner_datacrc
    struct.pack_into('<H', new, 0x20, jl_crc16(new[0x22:0x40]))      # inner_hdrcrc

    # Outer header
    struct.pack_into('<I', new, 0x08, target_dlen)                   # dlen
    struct.pack_into('<H', new, 0x02, jl_crc16(new[0x20:0x20 + target_dlen]))  # outer_datacrc
    struct.pack_into('<H', new, 0x00, jl_crc16(new[0x02:0x20]))      # outer_hdrcrc

    if len(new) < OTA_SIZE:
        new.extend(bytes(OTA_SIZE - len(new)))
    return bytes(new), real_dlen

if __name__ == "__main__":
    regions = [(int(s.split('-')[0], 0), int(s.split('-')[1], 0)) for s in sys.argv[1:]]
    out = sys.argv[0].replace('.py', '.bin') if len(sys.argv) < 2 else '/tmp/ota_shrunk.bin'
    ota, dlen = build(regions)
    open(out, 'wb').write(ota)
    print(f"wrote {out}: real_dlen={dlen} padded_dlen=19456")
