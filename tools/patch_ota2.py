#!/usr/bin/env python3
"""
patch_ota2.py — patch_v2: change the DECOMPRESSED FM-1 OTA loader image by
exactly one byte (same-loader / no-op protection bypass) while keeping it a
valid, bootable, functionally-identical loader, and keeping the total ota.bin
size EXACTLY 0x4e01 bytes.

Hardware-confirmed motivation (2026-07-20): the device accepts a flash of
cfg-bypass + container-only-patched ota.bin but still refuses to proceed right
after the last ota.bin read — exactly as with a fully stock ota.bin. The
container-level (inner-name) patch left the decompressed image bit-identical,
so the device's same-loader check (which depends on the decompressed image /
its inner_datacrc 0xb295) still fired. patch_v2 flips ONE byte inside the
decompressed image so the check no longer matches.

---------------------------------------------------------------------------
ota.bin IMAGE FORMAT (unchanged from patch_ota.py; all fields byte-verified)
---------------------------------------------------------------------------
  [0x00..0x20)  OUTER header: u16 outer_hdrcrc=crc(ota[0x02:0x20]),
                u16 outer_datacrc=crc(ota[0x20:0x4e01]), u32 doff=0x20,
                u32 dlen=0x4de1, u8 attr=0x41, u8 res, u16 last,
                name[16]="usb_hid_ota.bin"
  [0x20..0x40)  INNER header: u16 inner_hdrcrc=crc(ota[0x22:0x40]),
                u16 inner_datacrc=crc(decompressed image), u32 imgsize=0x5b1c,
                u32 loadaddr=0x01c0a800, u32 res, name[16]
  [0x40..0x4e01) 6 LZ4-block-format blocks, [u32 csize][u32 dsize][data],
                dsize = 0x1000 x5 + 0xb1c, dictionary continuous across blocks.
jl_crc16 = CRC-16/CCITT-FALSE (poly 0x1021, init 0). UFW-level entry dcrc =
jl_crc16(whole 0x4e01-byte ota.bin) — must be written into the .fwsc entry
list (printed by the self-check).

---------------------------------------------------------------------------
THE BYTE THAT CHANGES (and why it is safe)
---------------------------------------------------------------------------
  decompressed image offset 0x5ad0: 0x00 -> 0x01.

  * img+0x5ad0 lies inside the 32-byte .data buffer at image offset 0x5ac0
    (load address 0x1C102C0). That buffer holds the compile-time default
    "/*.ufw\\0" followed by 25 zero slack bytes. img+0x5ad0 is slack byte #16
    — a zero AFTER the string's NUL terminator (img+0x5ac6). It is NOT part
    of the "/*.ufw" string: the string bytes img+0x5ac0..0x5ac6 are left
    untouched, so every functional string stays byte-identical.
  * pi32v2 disassembly of the loader proves the ONLY instruction referencing
    this buffer is `memmove(0x1C102C0, rec+8, 32)` at 0x1C0DA44 (a call to the
    memmove at 0x1C0D226, confirmed dest=r0/src=r1). At runtime the whole
    32-byte buffer — including img+0x5ad0 — is OVERWRITTEN with 32 bytes of
    update-record data before it is ever used.
  * A full pointer-immediate scan of the image found no other references to
    img+0x5ac1..0x5adf; the neighboring u32 variables (0x5aac..0x5bc,
    0x5ae0..) are all accessed by exact-address word/byte stores, never by
    base+offset into the slack. String operations on the buffer stop at the
    NUL at 0x5ac6 and can never reach 0x5ad0.
  * Therefore the byte's initial value cannot influence any execution path:
    if the record-processing memmove runs, the byte is overwritten; if it
    does not run, nothing ever reads the slack. The loader remains
    functionally identical to stock — only the image (and hence
    inner_datacrc) now differs from the loader installed on the device.

---------------------------------------------------------------------------
HOW THE PAYLOAD IS REPRODUCED (exact-size re-encode)
---------------------------------------------------------------------------
The changed byte sits in block 6 (image offsets 0x5000..0x5b1c). The stock
zero-run there is LZ4-match-encoded, so no single literal can be flipped in
place; instead (strategy b):
  * blocks 1..5 are copied BYTE-FOR-BYTE from stock (their output is
    unchanged, so the dictionary seen by block 6 is identical);
  * block 6 is re-encoded from the modified image with an optimal-parse LZ4
    encoder (continuous dictionary = image[0:0x5000], same dsize=0xb1c), then
    deterministically de-optimized (selected matches converted to literal
    runs, output unchanged) until its compressed size is EXACTLY the stock
    block-6 csize (2442). Every block stays canonical: a strict LZ4-block
    decoder consumes exactly csize bytes and yields exactly dsize bytes, so
    the payload decodes correctly under input-driven AND output-driven
    decoders alike — no padding anywhere, total stays exactly 0x4e01.
Integrity fields recomputed: inner_datacrc (over the MODIFIED image),
inner_hdrcrc, outer_datacrc, outer_hdrcrc; new UFW-level dcrc printed.
"""
import os
import struct
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
REPO = os.path.dirname(HERE)
sys.path.insert(0, os.path.join(REPO, "3rd-party", "jl-misctools", "firmware"))
from jltech.crc import jl_crc16

OTA_SIZE = 0x4e01
IMG_SIZE = 0x5b1c
BLOCK_DSIZES = (0x1000, 0x1000, 0x1000, 0x1000, 0x1000, 0xb1c)

PATCH_OFF = 0x5ad0          # offset in the DECOMPRESSED image
PATCH_FROM = 0x00
PATCH_TO = 0x01


# --------------------------------------------------------------------------
# LZ4 block-format decoder (continuous dictionary across blocks)
# --------------------------------------------------------------------------
def _lz4_block_decode(out: bytearray, src: bytes) -> int:
    i = 0
    while i < len(src):
        token = src[i]; i += 1
        litlen = token >> 4
        if litlen == 15:
            while True:
                b = src[i]; i += 1; litlen += b
                if b != 255:
                    break
        out += src[i:i + litlen]; i += litlen
        if i >= len(src):
            break
        offset = src[i] | (src[i + 1] << 8); i += 2
        if offset == 0 or offset > len(out):
            raise ValueError(f"bad LZ4 match offset {offset}")
        mlen = token & 0xF
        if mlen == 15:
            while True:
                b = src[i]; i += 1; mlen += b
                if b != 255:
                    break
        mlen += 4
        for _ in range(mlen):
            out.append(out[-offset])
    return i


def _parse_blocks(ota: bytes):
    """Return list of (hdr_off, data_off, csize, dsize) for the payload."""
    blocks = []
    off = 0x40
    while off < len(ota):
        csize, dsize = struct.unpack_from("<II", ota, off)
        blocks.append((off, off + 8, csize, dsize))
        off += 8 + csize
    assert off == len(ota), "blocks do not end exactly at EOF"
    return blocks


def decompress_image(ota: bytes) -> bytes:
    """Decompress the 6-block payload at 0x40 into the RAM image."""
    out = bytearray()
    for hdr_off, data_off, csize, dsize in _parse_blocks(ota):
        start = len(out)
        consumed = _lz4_block_decode(out, ota[data_off: data_off + csize])
        assert consumed == csize, f"block @{hdr_off:#x}: {consumed:#x}/{csize:#x} consumed"
        assert len(out) - start == dsize, f"block @{hdr_off:#x}: bad dsize"
    return bytes(out)


# --------------------------------------------------------------------------
# Optimal-parse LZ4 block encoder (LZ4 block format, continuous dictionary),
# with exact-size tuning. See module docstring for the cost model.
# --------------------------------------------------------------------------
_MINMATCH = 4
_MAXOFF = 65535
_HASHBITS = 16


def _litext(l):
    return 0 if l < 15 else (l - 15) // 255 + 1


def _mlext(m):
    v = m - 4
    return 0 if v < 15 else (v - 15) // 255 + 1


def _find_matches(data, dict_data):
    n = len(data)
    win = dict_data + data
    D = len(dict_data)
    htab = {}
    prev = [-1] * (D + n)
    for i in range(0, D - 3):
        h = hash(win[i:i + 4]) & (_HASHBITS - 1)
        prev[i] = htab.get(h, -1)
        htab[h] = i
    matches = [[] for _ in range(n)]
    for i in range(n):
        pos = D + i
        key = win[pos:pos + 4]
        if len(key) < 4:
            continue
        j = htab.get(hash(key) & (_HASHBITS - 1), -1)
        maxm_here = n - i
        while j >= 0:
            off = pos - j
            if off > _MAXOFF:
                break
            m = 0
            while m < maxm_here and win[j + m] == win[pos + m]:
                m += 1
            if m >= _MINMATCH:
                matches[i].append((off, m))
            j = prev[j]
        if pos + 4 <= len(win):
            h = hash(win[pos:pos + 4]) & (_HASHBITS - 1)
            prev[pos] = htab.get(h, -1)
            htab[h] = pos
    return matches


def _seq_cost(lits, off, m):
    l = len(lits)
    if off is None:
        return 1 + _litext(l) + l
    return 1 + _litext(l) + l + 2 + _mlext(m)


def _optimal_parse(data, dict_data):
    """Sequence list [[lits:bytes, off:int|None, m:int], ...]; final seq has
    off=None (literals only). Minimizes exact LZ4 encoded size."""
    n = len(data)
    matches = _find_matches(data, dict_data)
    INF = float('inf')
    dp = [INF] * (n + 1)
    mbest = [INF] * (n + 1)
    pick = [None] * (n + 1)
    dp[n] = 0
    for i in range(n - 1, -1, -1):
        for off, m in matches[i]:
            c = 2 + _mlext(m) + dp[i + m]
            if c < mbest[i]:
                mbest[i] = c
        best = INF
        bestch = None
        if mbest[i] < INF:
            best = 1 + mbest[i]
            bestch = ('m', i)
        maxL = n - i
        c_end = 1 + _litext(maxL) + maxL
        if c_end < best:
            best = c_end
            bestch = ('end',)
        for L in range(1, maxL):
            c = 1 + _litext(L) + L + mbest[i + L]
            if c < best:
                best = c
                bestch = ('lit', L, i + L)
        dp[i] = best
        pick[i] = bestch

    def select(j):
        best = None
        bestc = INF
        for off, m in matches[j]:
            c = 2 + _mlext(m) + dp[j + m]
            if c < bestc:
                bestc = c
                best = (off, m)
        return best

    seqs = []
    i = 0
    while i < n:
        ch = pick[i]
        if ch[0] == 'end':
            seqs.append([data[i:], None, 0])
            i = n
        elif ch[0] == 'm':
            off, m = select(ch[1])
            seqs.append([b'', off, m])
            i = ch[1] + m
        else:
            _, L, j = ch
            off, m = select(j)
            seqs.append([data[i:i + L], off, m])
            i = j + m
    return seqs


def _serialize(seqs) -> bytes:
    enc = bytearray()
    for lits, off, m in seqs:
        l = len(lits)
        if off is None:
            enc.append(min(l, 15) << 4)
        else:
            enc.append((min(l, 15) << 4) | min(m - 4, 15))
        if l >= 15:
            v = l - 15
            while v >= 255:
                enc.append(255)
                v -= 255
            enc.append(v)
        enc += lits
        if off is not None:
            enc.append(off & 0xFF)
            enc.append((off >> 8) & 0xFF)
            if m - 4 >= 15:
                v = m - 4 - 15
                while v >= 255:
                    enc.append(255)
                    v -= 255
                enc.append(v)
    return bytes(enc)


def _inflate_to_size(seqs, data: bytes, target: int):
    """Grow the serialized form to exactly `target` bytes (output unchanged)
    by converting selected matches into literal runs. Each conversion's size
    delta is computed exactly from the two affected sequences."""
    posmap = []

    def positions():
        p = 0
        posmap.clear()
        for l, o, m in seqs:
            posmap.append(p)
            p += len(l) + (m if o is not None else 0)

    def delta(i):
        l0, o0, m0 = seqs[i]
        p = posmap[i] + len(l0)
        merged = bytes(l0) + data[p:p + m0] + bytes(seqs[i + 1][0])
        old = _seq_cost(l0, o0, m0) + _seq_cost(*seqs[i + 1])
        new = _seq_cost(merged, seqs[i + 1][1], seqs[i + 1][2])
        return new - old

    cur = sum(_seq_cost(l, o, m) for l, o, m in seqs)
    need = target - cur
    if need < 0:
        raise ValueError(f'optimal parse {cur} exceeds target {target}')
    positions()
    while need > 0:
        best_i = -1
        best_d = 0
        for i in range(len(seqs) - 1):
            if seqs[i][1] is None:
                continue
            d = delta(i)
            if 0 < d <= need and d > best_d:
                best_i, best_d = i, d
        if best_i < 0:
            raise ValueError(f'cannot reach exact target, still need {need}')
        i = best_i
        l0, o0, m0 = seqs[i]
        p = posmap[i] + len(l0)
        merged = bytes(l0) + data[p:p + m0] + bytes(seqs[i + 1][0])
        seqs[i] = [merged, seqs[i + 1][1], seqs[i + 1][2]]
        del seqs[i + 1]
        positions()
        need -= best_d
    return seqs


def _encode_block_exact(data: bytes, dict_data: bytes, target: int) -> bytes:
    seqs = _optimal_parse(data, dict_data)
    size = sum(_seq_cost(l, o, m) for l, o, m in seqs)
    if size < target:
        seqs = _inflate_to_size(seqs, data, target)
    elif size > target:
        raise ValueError(f'optimal parse {size} exceeds target {target}')
    enc = _serialize(seqs)
    assert len(enc) == target, f'{len(enc)} != {target}'
    return enc


# --------------------------------------------------------------------------
# integrity fields
# --------------------------------------------------------------------------
def verify_all(ota: bytes, quiet=False) -> bool:
    """Recompute and check every integrity field of ota.bin. Returns bool."""
    assert len(ota) == OTA_SIZE, f"bad size {len(ota):#x}"
    outer_hdrcrc, outer_datacrc, doff, dlen, attr, res, last, oname = \
        struct.unpack_from("<HHIIBBH16s", ota, 0x00)
    inner_hdrcrc, inner_datacrc, imgsz, loadaddr, rsvd, iname = \
        struct.unpack_from("<HHIII16s", ota, 0x20)

    checks = []
    checks.append(("outer_hdrcrc", outer_hdrcrc, jl_crc16(ota[0x02:0x20])))
    checks.append(("outer layout", 0, 0 if (doff == 0x20 and dlen == OTA_SIZE - 0x20
                                            and attr == 0x41) else 1))
    checks.append(("outer_datacrc", outer_datacrc, jl_crc16(ota[0x20:OTA_SIZE])))
    checks.append(("inner_hdrcrc", inner_hdrcrc, jl_crc16(ota[0x22:0x40])))
    image = decompress_image(ota)
    checks.append(("image size", imgsz, len(image)))
    checks.append(("inner_datacrc", inner_datacrc, jl_crc16(image)))

    ok = True
    for name, stored, calc in checks:
        good = stored == calc
        ok &= good
        if not quiet:
            print(f"  {name:14s}: stored={stored:#08x} calc={calc:#08x} {'OK' if good else 'FAIL'}")
    if not quiet:
        print(f"  outer name={oname!r} inner name={iname!r} load={loadaddr:#x} res={res}/{last}/{rsvd}")
        print(f"  UFW-level dcrc (jl_crc16 of whole ota.bin) = {jl_crc16(ota):#06x}")
    return ok


# --------------------------------------------------------------------------
# the patch
# --------------------------------------------------------------------------
def patch(ota: bytes) -> bytes:
    """Take the raw 0x4e01-byte ota.bin; return a modified, still-valid one
    whose DECOMPRESSED image differs from stock by exactly one byte
    (img+0x5ad0: 0x00 -> 0x01, zero slack after the "/*.ufw" string — see
    module docstring for the safety proof). Total size stays 0x4e01."""
    assert len(ota) == OTA_SIZE, f"ota.bin must be {OTA_SIZE:#x} bytes"
    assert jl_crc16(ota[0x02:0x20]) == struct.unpack_from("<H", ota, 0)[0], \
        "outer header CRC bad — is this the correctly-based ota.bin?"

    blocks = _parse_blocks(ota)
    assert len(blocks) == len(BLOCK_DSIZES), "expected 6 blocks"
    for (_, _, _, dsize), want in zip(blocks, BLOCK_DSIZES):
        assert dsize == want, f"unexpected block dsize {dsize:#x}"

    # 1) decompress and flip the one byte
    img = bytearray(decompress_image(ota))
    assert len(img) == IMG_SIZE
    assert img[PATCH_OFF] == PATCH_FROM, "unexpected stock byte at patch offset"
    img[PATCH_OFF] = PATCH_TO
    img = bytes(img)

    # 2) blocks 1..5 copied verbatim (their output is unchanged); last block
    #    re-encoded to EXACTLY its stock csize from the modified image.
    last_hdr, last_data, last_csize, last_dsize = blocks[-1]
    blk_start = sum(BLOCK_DSIZES[:-1])          # 0x5000
    enc_last = _encode_block_exact(img[blk_start:], img[:blk_start], last_csize)

    new = bytearray(ota[:last_hdr])
    new += struct.pack("<II", last_csize, last_dsize)
    new += enc_last
    assert len(new) == OTA_SIZE, f"rebuilt size {len(new):#x} != {OTA_SIZE:#x}"

    # 3) integrity fields
    struct.pack_into("<H", new, 0x22, jl_crc16(img))                 # inner_datacrc
    struct.pack_into("<H", new, 0x20, jl_crc16(new[0x22:0x40]))      # inner_hdrcrc
    struct.pack_into("<H", new, 0x02, jl_crc16(new[0x20:OTA_SIZE]))  # outer_datacrc
    struct.pack_into("<H", new, 0x00, jl_crc16(new[0x02:0x20]))      # outer_hdrcrc
    return bytes(new)


# --------------------------------------------------------------------------
# self-check
# --------------------------------------------------------------------------
def _self_check():
    stock = open("/tmp/ota_re/ota_real.bin", "rb").read()
    print("[1] verify stock image:")
    assert verify_all(stock), "stock image failed verification?!"

    patched = patch(stock)
    print("[2] verify patched image:")
    assert verify_all(patched), "patched image failed verification!"

    img_stock = decompress_image(stock)
    img_patched = decompress_image(patched)

    print("[3] (i) decompressed images differ by EXACTLY one byte:")
    diffs = [i for i in range(IMG_SIZE) if img_stock[i] != img_patched[i]]
    print(f"    diffs = {[(hex(i), hex(img_stock[i]), hex(img_patched[i])) for i in diffs]}")
    assert diffs == [PATCH_OFF], "expected exactly one differing byte at the patch offset"
    assert img_stock[PATCH_OFF] == PATCH_FROM and img_patched[PATCH_OFF] == PATCH_TO

    print(f"[4] (ii) total size == {OTA_SIZE:#x}:", len(patched) == OTA_SIZE)
    assert len(patched) == OTA_SIZE

    print("[5] (iii) every integrity field verifies: see [2] above (all OK)")

    print("[6] (iv) re-decompressing the patched payload yields the modified image:")
    img_mod = bytearray(img_stock)
    img_mod[PATCH_OFF] = PATCH_TO
    print("    byte-for-byte match:", img_patched == bytes(img_mod))
    assert img_patched == bytes(img_mod)

    print(f"[7] (v) changed byte: decompressed image offset {PATCH_OFF:#06x}: "
          f"{PATCH_FROM:#04x} -> {PATCH_TO:#04x}")
    print("    why safe: img+0x5ad0 is a zero slack byte inside the 32-byte .data")
    print("    buffer at 0x1C102C0 that defaults to \"/*.ufw\\0\"; it sits AFTER the")
    print("    string's NUL terminator (not part of the string). Loader disassembly")
    print("    shows the only reference to this buffer is memmove(0x1C102C0, rec+8, 32)")
    print("    at 0x1C0DA44, which overwrites the whole buffer at runtime; nothing")
    print("    else references the slack, and string reads stop at the NUL. The byte")
    print("    can never influence execution, so the loader is functionally identical.")

    print(f"[8] container-level changed bytes vs stock: "
          f"{sum(a != b for a, b in zip(stock, patched))} (payload re-encode + 4 CRC fields)")
    print("[9] UFW entry-list dcrc to write into the .fwsc:",
          f"{jl_crc16(patched):#06x} (stock was {jl_crc16(stock):#06x})")
    print("ALL CHECKS PASSED")


if __name__ == "__main__":
    _self_check()
