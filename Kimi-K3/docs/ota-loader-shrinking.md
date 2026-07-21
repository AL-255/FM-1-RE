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

## Current status

A candidate that zeroed 13 small regions (total 509 bytes) compressed to
`dlen = 19262`, padded to 19456, and **passes step-1 verification**.  However,
the device did not re-enumerate in OTA mode, indicating that at least one of
the zeroed regions is live code.  Bisection is in progress.

Preliminary disassembly review shows that region `0x0056..0x006a` is inside the
early interrupt-handler path (right after the initial `rti`), so it is almost
certainly live and must not be zeroed.

## Next steps

1. Reconnect the device (it reset after the last failed loader attempt).
2. Test smaller subsets of the 13 candidate regions to identify the genuinely
   dead ones.
3. Build a loader that uses only dead regions and verify it boots into OTA
   mode and can complete step-2 flashing.
