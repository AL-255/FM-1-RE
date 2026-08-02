#!/usr/bin/env python3
"""Verify and extract the executable carried by an FM-1 ota.bin image."""

import argparse
import hashlib
import sys
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]
sys.path.insert(0, str(ROOT))

from tools.patch_ota import decompress_image, verify_all  # noqa: E402


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
    if not verify_all(container, quiet=True):
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
