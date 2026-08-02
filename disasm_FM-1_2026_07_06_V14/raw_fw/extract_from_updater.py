#!/usr/bin/env python3
"""Extract the embedded FM-1 V14 .fwsc from M-UPGRADE-FM1.exe."""

import argparse
import hashlib
from pathlib import Path


EXE_SHA256 = "4359d9183eb2679d65fcf3284764728f71df747c40058de5700b639917dc12cd"
FW_SHA256 = "a1adca99b1f9823ff2873292be74877a7a14ca0846fca3d25a23aba2750162d3"
QT_RESOURCE_DATA = 0x24A30
FW_RESOURCE_OFFSET = 0x4004


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("updater", type=Path)
    parser.add_argument("-o", "--output", type=Path, default=Path("FM-1.fwsc"))
    args = parser.parse_args()

    executable = args.updater.read_bytes()
    digest = hashlib.sha256(executable).hexdigest()
    if digest != EXE_SHA256:
        raise SystemExit(f"unsupported updater SHA-256: {digest}")

    header = QT_RESOURCE_DATA + FW_RESOURCE_OFFSET
    size = int.from_bytes(executable[header:header + 4], "big")
    firmware = executable[header + 4:header + 4 + size]
    digest = hashlib.sha256(firmware).hexdigest()
    if digest != FW_SHA256:
        raise SystemExit(f"embedded firmware SHA-256 mismatch: {digest}")

    args.output.write_bytes(firmware)
    print(f"wrote {args.output} ({len(firmware)} bytes, SHA-256 {digest})")


if __name__ == "__main__":
    main()
