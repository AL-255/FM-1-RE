#!/usr/bin/env python3
"""Check the redacted V16 -> stock V15 capture record offline; no device I/O."""

import argparse
import hashlib
import json
from pathlib import Path

from fm1_ota import build_response, build_success, fwsc_logical, parse_handshake_identity, unpack7

STOCK_V15_SHA256 = "DB1642B2B6FA5C2CCCB11FFD13878068BB28601678D3644049F99DC40E7EDB8A"
DEFAULT_RECORD = Path(__file__).parent / "tests/fixtures/fm1-v15-reflash-2026-09-04.json"


def require(condition, message):
    if not condition:
        raise ValueError(message)


def expand_requests(runs):
    for address, length, flash_type, count, stride in runs:
        require(all(type(value) is int for value in (length, flash_type, count, stride)),
                "request run fields must be integers")
        require(0 < count <= 4096, "invalid request run count")
        for index in range(count):
            yield int(address, 16) + index * stride, length, flash_type


def check_frame(frame, address, data, flash_type):
    require(frame[0] == 0xF0 and frame[-1] == 0xF7, "missing SysEx delimiters")
    require(all(byte < 128 for byte in frame[1:-1]), "non-MIDI byte in SysEx")
    decoded = unpack7(frame[1:-1])
    require(decoded[:3] == b"\x00\x59\x30", "wrong response command")
    require(int.from_bytes(decoded[3:6], "little") == len(decoded) - 7 == len(data) + 8,
            "response body length mismatch")
    require(decoded[6] == flash_type and int.from_bytes(decoded[7:11], "little") == address,
            "response target fields mismatch")
    require(int.from_bytes(decoded[11:14], "little") == len(data) and decoded[14:-1] == data,
            "response payload mismatch")
    require(sum(decoded[6:]) & 255 == 255, "response checksum mismatch")


def verify(record, firmware=None):
    require(record["schema_version"] == 1, "unknown record schema")
    require(record["request_run_columns"] == ["address_hex", "length", "flash_type", "count", "stride"],
            "unknown request encoding")
    image = record["firmware"]
    require(image["product"] == "FM-1_015" and image["sha256"] == STOCK_V15_SHA256,
            "record is not the stock V15 package")
    require((image["raw_size"], image["logical_size"]) == (699956, 699936), "package size mismatch")
    logical = None
    if firmware is not None:
        raw = Path(firmware).read_bytes()
        require(hashlib.sha256(raw).hexdigest().upper() == image["sha256"], "firmware SHA-256 mismatch")
        logical = fwsc_logical(firmware)
        require(len(logical) == image["logical_size"], "logical image size mismatch")

    before, ota, after = record["before"], record["ota"], record["after"]
    require((before["model"], before["version"], before["usb_id"], before["read_only"])
            == ("FM-1", 16, "4C4A:C755", True), "missing initial read-only V16 observation")
    require(ota["usb_id"] == "4D4A:4155", "missing OTA enumeration")
    identity = parse_handshake_identity(bytes.fromhex(ota["identity_sysex_hex"]))
    require(identity == {"model": "ota-FM-1", "version": 15}
            and (ota["model"], ota["version"]) == ("ota-FM-1", 15), "OTA identity mismatch")

    for name, finish, expected_count in (("stage", 0xE0000000, 48), ("flash", 0xF0000000, 1167)):
        requests = list(expand_requests(record[name]["request_runs"]))
        require(len(requests) - 1 == record[name]["data_requests"] == expected_count,
                f"{name}: recorded request count mismatch")
        require(requests[-1] == (finish, 8, 0), f"{name}: missing completion request")
        for address, length, flash_type in requests[:-1]:
            require(0 <= address and 0 < length <= 512 and address + length <= image["logical_size"],
                    f"{name}: request outside logical image")
            data = logical[address:address + length] if logical is not None else bytes(length)
            check_frame(build_response(address, data, length, flash_type), address, data, flash_type)
        check_frame(build_success(finish), finish, b"success\0", 0)
    require((0xAAB20, 481, 0) in list(expand_requests(record["stage"]["request_runs"])),
            "missing the observed partial loader block")

    require((after["model"], after["version"], after["usb_id"], after["read_only"])
            == ("FM-1", 15, "4C4A:C755", True), "missing separate post-boot V15 observation")
    descriptor = after["descriptor"]
    require(descriptor["length"] == descriptor["declared_length"] == 293 and descriptor["valid"] is True,
            "invalid post-boot USB descriptor")
    interfaces = {item["name"]: (item["status"], item["problem"]) for item in after["interfaces"]}
    require(all(interfaces.get(name) == ("OK", 0) for name in ("FM-1 Audio", "FM-1 Midi")),
            "missing healthy audio/MIDI enumeration")
    return "Recorded capture chain verified: FM-1 V16 -> OTA V15 -> flash complete -> FM-1 V15."


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("record", nargs="?", type=Path, default=DEFAULT_RECORD)
    parser.add_argument("--firmware", type=Path, help="optional local stock V15 package for payload replay")
    args = parser.parse_args()
    try:
        print(verify(json.loads(args.record.read_text(encoding="utf-8")), args.firmware))
        print("Offline only: checks the supplied record and framing; does not authenticate a past flash or contact hardware.")
        print("Payload replay:", "verified local stock package" if args.firmware else "synthetic zero payloads; firmware not supplied")
        return 0
    except (ValueError, KeyError, TypeError, OSError) as error:
        print(f"Record check failed: {error}")
        return 1


if __name__ == "__main__":
    raise SystemExit(main())
