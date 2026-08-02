# Shrinking the FM-1 OTA loader

## The problem

The stock FM-1 OTA loader (`ota.bin`) is **19937 bytes** (outer `dlen = 0x4de1`).
The on-device step-1 verifier copies the incoming loader payload to a dedicated
flash/VM region and then reads it back for a CRC self-check.  Empirically, this
write/read round-trip is identity only when the payload is **≤ 19456 bytes**
(`0x4c00`).  For the 19937-byte stock loader the tail does **not** read back
correctly, so step-1 always fails with `LOADER_VERIFY_ERR` (131).

Conclusion: any custom loader must be compressed to **≤ 19456 payload bytes**.

## Hidden size rule: payload must be a multiple of 512

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

Only payloads whose `dlen` is an exact multiple of **512 bytes** pass.  The
maximum usable payload is therefore **19456 bytes** (`38 × 512`).

If a modified loader compresses to a non-multiple of 512 (e.g. 19267 bytes), the
payload must be **padded** with harmless bytes (zeros work) up to the next
512-byte multiple, and the outer `dlen`/`datacrc` must cover the padded length.
The padding sits after the last LZ4 block and is ignored by the loader's
decoder.

## Builder tool

`tools/build_shrunk.py` automates this:

1. Start from the stock decompressed loader image.
2. Zero the requested image region(s).
3. Re-encode all six LZ4 blocks with the stock-compatible optimal parser from
   `patch_ota2.py` (continuous dictionary across blocks).
4. Pad the compressed payload to the largest multiple of 512 that is ≤ 19456.
5. Recompute inner/outer CRCs and write a valid `ota.bin`.

Usage example (zeroing regions that are believed to be dead code):

```bash
python3 tools/build_shrunk.py 0x1df2-0x1e34 0x29a8-0x29e9
```

The output is written to `/tmp/ota_shrunk.bin` by default.

## Current status (2026-07-21)

Step-1 verification is fully solved:

- The cfg/eq no-op gate is bypassed (`tools/build_fwsc.py` flips a padding byte
  in `eq_cfg_hw.bin`, changing cfg CRC while leaving payload identical).
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

The same behavior occurs with a stock-app control image (only the loader and cfg
changed), so the failure is not caused by the custom `app.bin`.  The most likely
remaining causes are:

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
   accepts either the stock OTA PID or the custom loader's normal PID.

The V14 updater embeds a genuine new application image, but its loader is
still byte-identical to V13. Hardware is required to distinguish the remaining
loader integrity gate from the corrected host-side timing.

## Hardware verification log

| attempt | loader size | step-1 | step-2 requests | finish (`0xF0000000`) | result |
|---------|-------------|--------|-----------------|-----------------------|--------|
| stock loader (19937 B) | — | fails at region limit | — | — | never enters OTA |
| shrunken loader (≤ 19456 B) | pass | ~48 reads to 0xab940, then `0xE0000000` | **no** | reboots to `FM-1_009` |
| stock app + shrunken loader | pass | same | **no** | reboots to `FM-1_009` |

## Next steps

1. Retest with the corrected timing and re-enumeration logic in
   `tools/fm1_ota.py`.
2. Dissect the loader's post-transfer path (`FUNC_02083394` → result handler)
   to identify any notify code or integrity gate that suppresses the
   `0xF0000000` request.
3. Attempt to read back the stored loader region via the OTA protocol or any
   exposed syscmd to see whether the new loader was written at all.
4. Until the loader reaches the finish handshake, the host-native synth
   (`firmware/host/fm1_synth`, `fm1_jack`, LV2/VST plugins) is the working
   deliverable for playing the custom synth from a MIDI keyboard.
