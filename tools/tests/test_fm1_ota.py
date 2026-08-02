import ctypes
import io
import os
import sys
import tempfile
import unittest
from types import SimpleNamespace
from unittest import mock


TOOLS = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
sys.path.insert(0, TOOLS)

import alsalib
import fm1_ota


def request(addr, length, flash_type=0):
    body = (b"\x00\x59\x30" + (8).to_bytes(3, "little")
            + bytes([flash_type]) + addr.to_bytes(4, "little")
            + length.to_bytes(3, "little"))
    checksum = (~sum(body[6:])) & 0xFF
    return b"\xF0" + fm1_ota.pack7(body + bytes([checksum])) + b"\xF7"


def identity(name_version):
    plain = name_version.encode("ascii")
    if len(plain) != 8:
        raise ValueError("test identity must occupy the eight-byte plain field")
    encoded = bytes((byte - ord("0")) & 0xFF for byte in plain)
    payload = plain + encoded + bytes([0xD0]) * (19 - len(encoded))
    body = b"\x00\x59\x11" + len(payload).to_bytes(3, "little") + payload
    checksum = (~sum(payload)) & 0xFF
    return b"\xF0" + fm1_ota.pack7(body + bytes([checksum])) + b"\xF7"


class FakeLink:
    def __init__(self, packets):
        self.packets = list(packets)
        self.writes = []

    def read_sysex(self, _timeout):
        return self.packets.pop(0) if self.packets else None

    def write(self, data):
        self.writes.append(data)

    def close(self):
        pass


class CodecTests(unittest.TestCase):
    def test_pack7_round_trip(self):
        for size in range(65):
            data = bytes((i * 37 + size) & 0xFF for i in range(size))
            self.assertEqual(fm1_ota.unpack7(fm1_ota.pack7(data)), data)

    def test_parse_request_checks_checksum(self):
        packet = request(0x12345678, 0x200, 3)
        self.assertEqual(fm1_ota.parse_request(packet), (3, 0x12345678, 0x200))
        damaged = bytearray(packet)
        damaged[-2] ^= 1
        self.assertIsNone(fm1_ota.parse_request(bytes(damaged)))

    def test_data_response_matches_known_packet(self):
        actual = fm1_ota.build_response(0x1234, b"\x00\x7f\x80\xff", 4)
        expected = bytes.fromhex("f000324141000000003424000040000000007e017c7f16f7")
        self.assertEqual(actual, expected)

    def test_data_response_checksum_includes_flash_type(self):
        packet = fm1_ota.build_response(0x1234, b"\x00\x7f\x80\xff", 4, 3)
        payload = fm1_ota.unpack7(packet[17:-1])
        expected = (~(3 + sum(b"\x00\x7f\x80\xff")
                       + sum((0x1234).to_bytes(4, "little"))
                       + sum((4).to_bytes(3, "little")))) & 0xFF
        self.assertEqual(payload[-1], expected)

    def test_done_responses_match_updater(self):
        expected_verify = bytes.fromhex(
            "f00032410101000000000000000e010000736a0d1b566c5c39003c00f7")
        expected_finish = bytes.fromhex(
            "f00032410101000000000000000f010000736a0d1b566c5c39001c00f7")
        self.assertEqual(fm1_ota.build_success(0xE0000000), expected_verify)
        self.assertEqual(fm1_ota.build_success(0xF0000000), expected_finish)

    def test_handshake_identity_matches_windows_parser(self):
        packet = identity("FM-1_015")
        self.assertEqual(
            fm1_ota.parse_handshake_identity(packet),
            {"model": "FM-1", "version": 15},
        )
        damaged = bytearray(packet)
        damaged[-2] ^= 1
        self.assertIsNone(fm1_ota.parse_handshake_identity(bytes(damaged)))


class TransferTests(unittest.TestCase):
    def setUp(self):
        self.old_delay = fm1_ota.RESP_DELAY
        fm1_ota.RESP_DELAY = 0

    def tearDown(self):
        fm1_ota.RESP_DELAY = self.old_delay

    def test_serves_data_then_stops_on_finish(self):
        logical = bytes(range(256)) * 2
        link = FakeLink([request(0x80, 0x100), request(0xF0000000, 8)])
        signals = []

        served = fm1_ota.serve_requests(
            link, logical, progress=False,
            on_finish=lambda addr: signals.append(addr) or True)

        self.assertEqual(served, 1)
        self.assertEqual(signals, [0xF0000000])
        self.assertEqual(link.writes[0], fm1_ota.build_response(0x80, logical[0x80:0x180], 0x100))
        self.assertEqual(link.writes[1], fm1_ota.build_success(0xF0000000))

    def test_rejects_out_of_bounds_request(self):
        link = FakeLink([request(0xF0, 0x20)])
        with self.assertRaisesRegex(RuntimeError, "invalid device request"):
            fm1_ota.serve_requests(link, bytes(256), progress=False)


class ImageTests(unittest.TestCase):
    def test_logical_image_strips_twenty_marker_bytes(self):
        header = b"".join(bytes([i]) * 47 + bytes([0xA0 + i]) for i in range(20))
        tail = b"payload"
        with tempfile.NamedTemporaryFile() as image:
            image.write(header + tail)
            image.flush()
            logical = fm1_ota.fwsc_logical(image.name)
        expected = b"".join(bytes([i]) * 47 for i in range(20)) + tail
        self.assertEqual(logical, expected)

    def test_alsa_pollfd_layout(self):
        self.assertEqual(ctypes.sizeof(alsalib.PollFD), 8)
        self.assertEqual(alsalib.PollFD.events.offset, 4)
        self.assertEqual(alsalib.PollFD.revents.offset, 6)


class FlashStateTests(unittest.TestCase):
    def run_flash(self, second_stage_signal, installed="FM-1_014"):
        signals = iter((0xE0000000, second_stage_signal))

        def serve(_link, _logical, **kwargs):
            kwargs["on_finish"](next(signals))
            return 12

        patches = (
            mock.patch.object(fm1_ota, "fwsc_logical", return_value=bytes(1024)),
            mock.patch.object(fm1_ota, "fwsc_info", return_value={"product": "FM-1_014"}),
            mock.patch.object(fm1_ota, "find_rawmidi", return_value=("seq", False, -1)),
            mock.patch.object(fm1_ota, "MidiLink", side_effect=lambda _path: FakeLink([])),
            mock.patch.object(fm1_ota, "handshake", return_value=identity(installed)),
            mock.patch.object(fm1_ota, "serve_requests", side_effect=serve),
            mock.patch.object(fm1_ota, "wait_device_any", return_value=("seq", True, -1)),
            mock.patch.object(fm1_ota, "wait_device", return_value=("seq", False, -1)),
            mock.patch.object(fm1_ota.time, "sleep"),
        )
        with patches[0], patches[1], patches[2], patches[3], patches[4], \
             patches[5], patches[6], patches[7], patches[8]:
            with mock.patch("sys.stdout", new=io.StringIO()):
                return fm1_ota.cmd_flash(SimpleNamespace(file="image.fwsc"))

    def test_flash_requires_upgrade_complete_signal(self):
        self.assertEqual(self.run_flash(0xF0000000), 0)

    def test_second_verification_signal_is_failure(self):
        self.assertEqual(self.run_flash(0xE0000000), 1)

    def test_flash_rejects_wrong_installed_version(self):
        self.assertEqual(self.run_flash(0xF0000000, installed="FM-1_009"), 1)

    def test_flash_rejects_wrong_device_model(self):
        self.assertEqual(self.run_flash(0xF0000000, installed="FX-1_014"), 1)


if __name__ == "__main__":
    unittest.main()
