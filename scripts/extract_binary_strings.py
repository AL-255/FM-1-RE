#!/usr/bin/env python3
"""Extract printable ASCII strings with file offsets for build_funcdb.py."""

import argparse
from pathlib import Path


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("input", type=Path)
    parser.add_argument("output", type=Path)
    parser.add_argument("--min-length", type=int, default=4)
    args = parser.parse_args()

    data = args.input.read_bytes()
    found = []
    start = None
    for offset, byte in enumerate(data + b"\0"):
        if 0x20 <= byte <= 0x7E:
            if start is None:
                start = offset
        elif start is not None:
            if offset - start >= args.min_length:
                found.append((start, data[start:offset].decode("ascii")))
            start = None

    args.output.parent.mkdir(parents=True, exist_ok=True)
    with args.output.open("w", encoding="ascii") as output:
        for offset, value in found:
            output.write(f"0x{offset:x}\t{value}\n")
    print(f"wrote {args.output} ({len(found)} strings)")


if __name__ == "__main__":
    main()
