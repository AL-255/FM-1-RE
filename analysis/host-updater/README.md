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
   `0xF0000000` with `success\0`. The loader emits this request only after its
   write and metadata gates return success.

The updater does not use `flashtype=0xF` as the finish condition and does not
send the previously hypothesized keepalive or pre-finish packets. The response
builder checksum covers flash type, address, u24 length, and payload. The
sentinel packets in `tools/fm1_ota.py` match the updater byte for byte.

The Windows worker labels the upgrade complete immediately after sending the
finish reply; it does not re-read the installed version. The loader retries a
non-`success` reply four times but returns zero after retry exhaustion, so the
reply is not a reliable commit acknowledgment by itself.

The device identity parser is at `0x140016E10`. It validates a 34-byte decoded
type-`0x11` response, takes the model before `_`, reconstructs a 20-byte field
by adding ASCII `0` to each byte, and parses the decimal suffix as the version.
`tools/fm1_ota.py` now mirrors this and requires the post-reboot model/version
to match the package header.

The bundled logs also contain a successful stock downgrade on 2026-06-26:
the updater reports FM-1 version 10, installs `FM-1_008`, receives the second
stage completion, and subsequently reports version 8. This proves that the
stock path accepts a lower version; it does not prove recovery when a custom
application cannot start its update service.

The executable embeds a genuine V14 image (`FM-1_014`), not the V13 image.
The embedded `ota.bin` loader itself is nevertheless byte-identical to V13.
