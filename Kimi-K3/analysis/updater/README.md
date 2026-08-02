# M-UPGRADE-FM1 V14 static analysis

`ota_worker_decomp.c` is a focused Ghidra 12.1.2 decompilation of the OTA
worker and its adjacent MIDI framing functions from the updater dated
2026-07-06. Regenerate it with `ghidra/DecompileOtaWorker.java`.

Confirmed host state machine:

1. Send raw SysEx `F0 22 24 35 7F F7`.
2. Wait 2000 ms, then receive 15-byte decoded request frames with an 8000 ms
   timeout per request.
3. Serve ordinary `(address, length)` reads from the marker-stripped `.fwsc`.
4. Reply to raw address `0xE0000000` with `success\0`, then wait 3000 ms. This
   completes first-stage verification.
5. In OTA mode, repeat the command and reads. Reply to raw address
   `0xF0000000` with `success\0`; only this sentinel means the flash upgrade
   completed.

The updater does not use `flashtype=0xF` as the finish condition and does not
send the previously hypothesized keepalive or pre-finish packets. The response
builder checksum covers flash type, address, u24 length, and payload. The
sentinel packets in `tools/fm1_ota.py` match the updater byte for byte.

The executable embeds a genuine V14 image (`FM-1_014`), not the V13 image.
The embedded `ota.bin` loader itself is nevertheless byte-identical to V13.
