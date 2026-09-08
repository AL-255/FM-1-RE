import copy
import json
from pathlib import Path
import sys
import unittest

sys.path.insert(0, str(Path(__file__).resolve().parents[1]))
from verify_reflash_record import DEFAULT_RECORD, verify


class ReflashRecordTests(unittest.TestCase):
    def setUp(self):
        self.record = json.loads(DEFAULT_RECORD.read_text(encoding="utf-8"))

    def test_recorded_chain_and_response_framing(self):
        self.assertIn("Recorded capture chain verified", verify(self.record))

    def test_terminal_alone_does_not_prove_installed_version(self):
        self.record["after"]["version"] = 16
        with self.assertRaisesRegex(ValueError, "post-boot V15"):
            verify(self.record)

    def test_rejects_verification_signal_as_flash_completion(self):
        self.record["flash"]["request_runs"][-1][0] = "0xE0000000"
        with self.assertRaisesRegex(ValueError, "missing completion"):
            verify(self.record)

    def test_rejects_incomplete_request_stream(self):
        self.record["flash"]["request_runs"].pop(0)
        with self.assertRaisesRegex(ValueError, "request count"):
            verify(self.record)

    def test_rejects_wrong_package_and_invalid_descriptor(self):
        for field in ("package", "descriptor"):
            record = copy.deepcopy(self.record)
            if field == "package":
                record["firmware"]["sha256"] = "0" * 64
            else:
                record["after"]["descriptor"]["valid"] = False
            with self.subTest(field=field), self.assertRaises(ValueError):
                verify(record)


if __name__ == "__main__":
    unittest.main()
