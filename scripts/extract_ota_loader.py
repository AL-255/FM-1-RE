#!/usr/bin/env python3
"""Verify and extract the executable carried by an FM-1 ota.bin image."""

import argparse
import hashlib
import struct
import sys
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]
JLTOOLS = ROOT / "3rd-party/jl-misctools/firmware"
sys.path.insert(0, str(JLTOOLS))

from jltech.crc import jl_crc16  # noqa: E402


OTA_SIZE = 0x4E01


def _lz4_block_decode(out: bytearray, src: bytes) -> int:
    i = 0
    while i < len(src):
        token = src[i]
        i += 1
        literal_length = token >> 4
        if literal_length == 15:
            while True:
                value = src[i]
                i += 1
                literal_length += value
                if value != 255:
                    break
        out += src[i:i + literal_length]
        i += literal_length
        if i >= len(src):
            break

        offset = src[i] | (src[i + 1] << 8)
        i += 2
        if offset == 0 or offset > len(out):
            raise ValueError(f"invalid LZ4 match offset {offset}")

        match_length = token & 0x0F
        if match_length == 15:
            while True:
                value = src[i]
                i += 1
                match_length += value
                if value != 255:
                    break
        for _ in range(match_length + 4):
            out.append(out[-offset])
    return i


def decompress_image(container: bytes) -> bytes:
    """Decompress the continuous-dictionary LZ4 blocks after offset 0x40."""
    output = bytearray()
    offset = 0x40
    while offset < len(container):
        compressed_size, decompressed_size = struct.unpack_from(
            "<II", container, offset
        )
        block = container[offset + 8:offset + 8 + compressed_size]
        start = len(output)
        consumed = _lz4_block_decode(output, block)
        if consumed != compressed_size:
            raise ValueError(f"block at {offset:#x} was not consumed exactly")
        if len(output) - start != decompressed_size:
            raise ValueError(f"block at {offset:#x} has incorrect output size")
        offset += 8 + compressed_size
    if offset != len(container):
        raise ValueError("compressed blocks do not end at the container boundary")
    return bytes(output)


def verify_all(container: bytes) -> bool:
    """Validate the nested loader headers, layout, and payload CRCs."""
    if len(container) != OTA_SIZE:
        return False

    outer_header_crc, outer_data_crc, data_offset, data_length, attr = (
        struct.unpack_from("<HHIIB", container, 0)
    )
    inner_header_crc, inner_data_crc, image_size = struct.unpack_from(
        "<HHI", container, 0x20
    )
    try:
        image = decompress_image(container)
    except (IndexError, struct.error, ValueError):
        return False

    return all(
        (
            outer_header_crc == jl_crc16(container[0x02:0x20]),
            data_offset == 0x20,
            data_length == OTA_SIZE - 0x20,
            attr == 0x41,
            outer_data_crc == jl_crc16(container[0x20:]),
            inner_header_crc == jl_crc16(container[0x22:0x40]),
            image_size == len(image),
            inner_data_crc == jl_crc16(image),
        )
    )


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument(
        "input",
        nargs="?",
        type=Path,
        default=ROOT / "analysis/device/ota-loader/ota_stock.bin",
    )
    parser.add_argument(
        "-o",
        "--output",
        type=Path,
        default=ROOT / "analysis/device/ota-loader/usb_hid_ota.bin",
    )
    args = parser.parse_args()

    container = args.input.read_bytes()
    if not verify_all(container):
        raise SystemExit(f"{args.input}: nested OTA integrity check failed")

    image = decompress_image(container)
    if len(image) != 0x5B1C:
        raise SystemExit(f"{args.input}: unexpected executable size {len(image):#x}")

    args.output.parent.mkdir(parents=True, exist_ok=True)
    args.output.write_bytes(image)
    print(
        f"wrote {args.output} ({len(image)} bytes, "
        f"SHA-256 {hashlib.sha256(image).hexdigest()})"
    )


if __name__ == "__main__":
    main()
