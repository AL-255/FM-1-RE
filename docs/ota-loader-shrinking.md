# FM-1 OTA loader size-limit experiments

This is the historical hardware log from 2026-07-21. Later static analysis of
the unmodified loader is recorded in
`analysis/device/ota-loader/finish-gates.md` and `TODO_aug2.md`; the hypotheses
and next steps below describe what was known at the time of the experiment.

## Observed replacement-path limit

The stock FM-1 OTA loader payload is **19937 bytes** (outer `dlen = 0x4de1`).
In modified packages that forced the step-1 verifier to replace this payload,
the device copied it to a loader flash/VM region and read it back for a CRC
self-check. The write/read round trip was identical only through **19456
bytes** (`0x4c00`); longer test payloads returned stale data at the tail and
failed with `LOADER_VERIFY_ERR` (131).

This is a limit of the forced replacement path observed on the tested device,
not proof that every stock update rewrites `ota.bin`. V13 and V14 ship the same
loader, and the bundled updater logs include a successful stock downgrade.

## Observed 512-byte alignment rule

Testing with fixed-size payloads built from the stock image showed that the
verifier accepts some sizes and rejects others even though the CRC over the
declared `dlen` bytes is correct:

| dlen   | result |
|--------|--------|
| 16384  | pass   |
| 16896  | pass   |
| 17408  | pass   |
| 17920  | pass   |
| 18432  | pass   |
| 18944  | pass   |
| 19267  | refuse |
| 19453  | refuse |
| 19454  | refuse |
| 19455  | refuse |
| 19456  | pass   |

Within this test set, only payloads whose `dlen` is an exact multiple of **512
bytes** passed. The largest passing replacement payload was **19456 bytes**
(`38 × 512`).

In the passing modified packages, non-aligned compressed payloads were padded
with zeros to the next 512-byte boundary. The outer `dlen` and `datacrc`
covered that padding, which followed the final LZ4 block and was ignored by
the loader decoder.

## Current status (2026-07-21)

The step-1 staging mechanics for these modified packages were reproduced:

- A test package changed only padding in `eq_cfg_hw.bin`, changing the cfg CRC
  while leaving its payload identical, and passed the cfg/eq no-op gate.
- The loader can be shrunk below the 19456-byte limit and step-1 now accepts
  the image, builds the `FM-1_009 + ota-` boot record, and soft-resets into the
  OTA loader.
- `tools/fm1_ota.py` detects the loader re-enumeration by MIDI port presence
  (the loader re-uses the normal `4c4a:c755` PID, not `4d4a:4155`).

Step 2 now boots the shrunken loader and serves ~48 read requests covering the
whole logical image, ending at `addr = 0xab940`.  At that point the loader sends
a request for `addr = 0xE0000000 len = 8`, which `fm1_ota.py` answers with the
"success" payload.  The device then reboots to normal mode (`4c4a:c755`) **without
ever sending the `0xF0000000` upgrade-finish handshake**.

A post-attempt handshake query still decodes to the stock version encoding
(`03 93 03` region → `FM-1_009`), so **nothing was actually flashed**.

The same behavior occurred with a stock-application control image in which
only the loader and configuration changed, so the application payload was not
the cause. The working hypotheses at the time were:

1. The shrunken loader stops at the `0xE0000000` verification-complete signal
   and never reaches the `0xF0000000` upgrade-complete signal. Static analysis
   of M-UPGRADE V14 confirms both raw-address sentinels and the `success\0`
   response, so the finish command itself is no longer unknown.
2. The modified loader image fails an internal integrity/product check (e.g.
   it compares the incoming `ota.bin` against a hard-coded digest or a stored
   copy before allowing `0xF0000000`).
3. The previous client closed the ALSA connection immediately after the
   verification reply and could reopen the pre-reset normal-mode port. The
   corrected client now matches M-UPGRADE's 3-second post-reply delay and
   accepts either the stock OTA PID or the experimental loader's normal PID.

The V14 updater embeds a genuine new application image, but its loader is
still byte-identical to V13. Hardware is required to distinguish the remaining
loader integrity gate from the corrected host-side timing.

## Hardware verification log

| attempt | loader size | step-1 | step-2 requests | finish (`0xF0000000`) | result |
|---------|-------------|--------|-----------------|-----------------------|--------|
| forced stock-loader replacement (19937 B) | — | fails at observed staging limit | — | — | never enters OTA |
| shrunken loader (≤ 19456 B) | pass | ~48 reads to 0xab940, then `0xE0000000` | **no** | reboots to `FM-1_009` |
| stock app + shrunken loader | pass | same | **no** | reboots to `FM-1_009` |

## Next steps recorded on 2026-07-21

1. Retest with the corrected timing and re-enumeration logic in
   `tools/fm1_ota.py`.
2. Dissect the loader's post-transfer path (`FUNC_02083394` → result handler)
   to identify any notify code or integrity gate that suppresses the
   `0xF0000000` request.
3. Attempt to read back the stored loader region via the OTA protocol or any
   exposed syscmd to see whether the new loader was written at all.

The modified loader binaries and construction utilities used for these
experiments are preserved on the `with-custom-firmware` branch. This branch
retains only the observations and stock-loader analysis.
