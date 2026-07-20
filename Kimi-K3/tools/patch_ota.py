#!/usr/bin/env python3
"""
patch_ota.py — make a minimal, SAFE 1-byte-class modification to the FM-1
(JieLi AC791N, pi32v2) OTA loader image "ota.bin" (UFW entry "usb_hid_ota.bin")
so it differs from the stock image while remaining a valid, bootable loader.

---------------------------------------------------------------------------
ota.bin IMAGE FORMAT (fully reverse-engineered, all fields byte-verified)
---------------------------------------------------------------------------

Total size: 0x4e01 bytes (the UFW entry payload; logical 0xa6f20..0xabd21
in the .fwsc, i.e. fwsc FILE offset 0xa6f34..0xabd35).

  [0x00..0x20)  OUTER JLFS-style header:
    0x00  u16  outer_hdrcrc = jl_crc16(ota[0x02:0x20])
    0x02  u16  outer_datacrc = jl_crc16(ota[0x20:0x4e01])
    0x04  u32  data offset   = 0x20
    0x08  u32  data length   = 0x4de1  (= filesize - 0x20)
    0x0c  u8   attr          = 0x41    (bit6 set = "payload compressed")
    0x0d  u8   reserved      = 0x00
    0x0e  u16  last-flag     = 0x0000
    0x10  char name[16]      = "usb_hid_ota.bin\\0"   <- matched by the app

  [0x20..0x40)  INNER (boot) header:
    0x20  u16  inner_hdrcrc = jl_crc16(ota[0x22:0x40])
    0x22  u16  inner_datacrc = jl_crc16(decompressed_image)   (0x5b1c bytes)
    0x24  u32  image size    = 0x5b1c (decompressed)
    0x28  u32  load address  = 0x01c0a800
    0x2c  u32  reserved      = 0
    0x30  char name[16]      = "usb_hid_ota.bin\\0"   <- informational only

  [0x40..0x4e01) 6 compressed blocks, back to back:
    each: u32 csize, u32 dsize, then csize bytes of LZ4 *block-format*
    stream. dsize = 0x1000 for blocks 1..5, 0xb1c for block 6
    (sum = 0x5b1c). The LZ4 dictionary is CONTINUOUS across blocks
    (matches may reach back into the output of previous blocks).

  UFW container level (outside ota.bin, in the .fwsc entry list):
    entry dcrc = jl_crc16(whole 0x4e01-byte ota.bin)  -> must be refreshed
    in the fwsc entry list after any edit (value printed by self-check).

jl_crc16 = CRC-16/CCITT-FALSE (poly 0x1021, init 0x0000, no reflection)
as implemented by jltech.crc.jl_crc16 in jl-misctools.

---------------------------------------------------------------------------
THE PATCH (and why it is safe)
---------------------------------------------------------------------------

Changed: ota[0x30] = 'u' (0x75) -> 'U' (0x55) — the first letter of the
INNER header's name field ("usb_hid_ota.bin" -> "Usb_hid_ota.bin").

* The inner name is informational: the app finds this file via the UFW
  entry ("ota.bin" / outer name "usb_hid_ota.bin", both untouched) and the
  boot ROM only consumes imgsize/loadaddr/datacrc from the inner header.
* It is covered ONLY by inner_hdrcrc and outer_datacrc — both recomputed
  here. It is NOT covered by inner_datacrc (that CRC is over the
  decompressed image only, which stays bit-identical).
* The compressed payload (0x40..end) is untouched, so the booted image —
  every instruction and every functional string ("success", "UPDATE_JUMP",
  "POWER_PIN", "cfg_tool.bin", "flash.bin", "app_dir_head", "uboot.boot",
  "isd_config.ini", "/*.ufw", "BTIF", "UTTX", "UTBD", "USBDP", "USBDM") —
  is byte-identical to stock. The loader behaves exactly as stock.

After the edit these fields are recomputed:
  inner_hdrcrc @0x20, outer_datacrc @0x02, outer_hdrcrc @0x00
(outer_hdrcrc must be refreshed because it covers the outer_datacrc field).
Total bytes changed: 7 (1 name byte + 3 u16 CRC fields).
"""
import struct, sys

sys.path.insert(0, "/home/yukidama/JL/FM-1/3rd-party/jl-misctools/firmware")
from jltech.crc import jl_crc16

OTA_SIZE   = 0x4e01
PATCH_OFF  = 0x30          # inner-name first letter
PATCH_FROM = 0x75          # 'u'
PATCH_TO   = 0x55          # 'U'


# --------------------------------------------------------------------------
# LZ4 block-format decoder (continuous dictionary across blocks), used only
# by the self-check to prove the decompressed image is unchanged.
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


def decompress_image(ota: bytes) -> bytes:
    """Decompress the 6-block payload at 0x40 into the RAM image."""
    out = bytearray()
    off = 0x40
    while off < len(ota):
        csize, dsize = struct.unpack_from("<II", ota, off)
        start = len(out)
        consumed = _lz4_block_decode(out, ota[off + 8: off + 8 + csize])
        assert consumed == csize, f"block @{off:#x}: {consumed:#x}/{csize:#x} consumed"
        assert len(out) - start == dsize, f"block @{off:#x}: bad dsize"
        off += 8 + csize
    assert off == len(ota), "blocks do not end exactly at EOF"
    return bytes(out)


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


def patch(ota: bytes) -> bytes:
    """Take the raw 0x4e01-byte ota.bin; return a modified, still-valid one.

    One content byte changed (inner-name 'u'->'U' at 0x30); the three CRC
    fields covering it (inner_hdrcrc, outer_datacrc, outer_hdrcrc) are
    recomputed. The compressed payload and the decompressed boot image are
    bit-identical to the input.
    """
    ota = bytearray(ota)
    assert len(ota) == OTA_SIZE, f"ota.bin must be {OTA_SIZE:#x} bytes"
    assert ota[PATCH_OFF] == PATCH_FROM, "unexpected stock byte at patch offset"
    # base sanity: outer header must validate, i.e. input really starts at
    # the UFW entry payload (logical 0xa6f20 / fwsc file 0xa6f34).
    assert jl_crc16(ota[0x02:0x20]) == struct.unpack_from("<H", ota, 0)[0], \
        "outer header CRC bad — is this the correctly-based ota.bin?"

    ota[PATCH_OFF] = PATCH_TO                                              # 1 content byte
    struct.pack_into("<H", ota, 0x20, jl_crc16(ota[0x22:0x40]))            # inner_hdrcrc
    struct.pack_into("<H", ota, 0x02, jl_crc16(ota[0x20:OTA_SIZE]))        # outer_datacrc
    struct.pack_into("<H", ota, 0x00, jl_crc16(ota[0x02:0x20]))            # outer_hdrcrc
    return bytes(ota)


def _self_check():
    stock = open("/tmp/ota_re/ota_real.bin", "rb").read()
    print("[1] verify stock image:")
    assert verify_all(stock), "stock image failed verification?!"

    patched = patch(stock)
    print("[2] verify patched image:")
    assert verify_all(patched), "patched image failed verification!"

    print("[3] decompressed image identical to stock:",
          decompress_image(patched) == decompress_image(stock))

    diffs = [i for i in range(OTA_SIZE) if stock[i] != patched[i]]
    print(f"[4] changed bytes ({len(diffs)}):",
          ", ".join(f"{i:#x}({stock[i]:#04x}->{patched[i]:#04x})" for i in diffs))
    assert decompress_image(patched) == decompress_image(stock)
    print("[5] UFW entry-list dcrc to write into the .fwsc:",
          f"{jl_crc16(patched):#06x} (stock was {jl_crc16(stock):#06x})")
    print("ALL CHECKS PASSED")


if __name__ == "__main__":
    _self_check()
