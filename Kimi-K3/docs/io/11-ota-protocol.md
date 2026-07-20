# FM-1 OTA / M-UPGRADE protocol (fully reverse-engineered)

How the M-Vave M-UPGRADE client updates the FM-1 (JieLi AC791N/BR22-class),
byte-verified against live ALSA-seq captures of M-UPGRADE under Wine and
against the stock `.fwsc`. `tools/fm1_ota.py` is a byte-exact Linux
reimplementation of the client. No UBOOT button exists on the device — the
whole update runs over USB-MIDI SysEx while the stock firmware runs.

## Device identities

| mode   | VID:PID       | enumerates as                              | MIDI |
|--------|---------------|--------------------------------------------|------|
| normal | `4c4a:c755`   | "FM-1 Midi" composite (USB-MIDI + UAC audio) | client 24 `USB Composite Device MIDI 1` |
| OTA    | `4d4a:4155`   | "ota-FM-1" composite (the OTA loader)      | same MIDI port name |

Everything — discovery, enter-OTA, and the transfer — runs over MIDI
System-Exclusive messages. There is no HID report traffic for the update
itself (the "USB HID" interface on the OTA device is unused by M-UPGRADE).

## Session flow

1. **Handshake query** (host→device):
   `F0 00 32 45 00 00 00 40 7F F7`
   The device answers with its 37-byte **ID block** on header `00 32 45 58`,
   e.g. `F0 00 32 45 58 01 00 00 23 4D 5A 44 79 05 06 4C 1C [17×00] 40 05 F7`
   (`4D 5A 44 79` = `"MZDy"`; name + version are encoded further in).
2. **Upgrade command** (host→device, same bytes for step 1 and step 2):
   `F0 22 24 35 7F F7`
3. **Step 1 (verification)**: the device starts *pulling* the update file with
   read requests (see below). After the entry reads it writes the boot record
   (`FM-1_009` + `ota-`, a JieLi `UPDATA_PARM`) and soft-resets into the OTA
   loader (re-enumerates as `4d4a:4155`).
4. **Step 2 (upgrade)**: handshake again, upgrade command again, then the
   device pulls the entire image (header reads, entry-list reads descending
   from the top, then the bulk data ascending).
5. **Finish**: the device requests `flashtype=0xF, addr=0, len=8`; the host
   answers with the 8-byte payload `"success\0"` on channel `00 32 41 01`.
   The loader flashes and reboots into the new firmware.

## Read-request / data-response framing

Device → host (request), host → device (response):

```
F0 00 32 41 41 [f1:4][addr:4][len:4] [pack7(data)…] F7
```

- `f1`, `addr`, `len` are three little-endian u32, each sent as 4×7-bit
  groups (`b0|b1<<7|b2<<14|b3<<21`).
- `len` field = `(length << 4) | flashtype`. Requests have `f1 = 0`;
  responses have `f1 = length >> 4`.
- `data` is an **8→7 LSB-first continuous bitstream** (7 wire bytes per 8
  data bytes). The packed stream holds `length+1` unpacked bytes: the data
  plus **one checksum byte** at the end:
  `chk = ~(sum(data) + sum(addr_LE_4) + sum(length_LE_4)) & 0xFF`
  (length as the plain u32, not the wire `(len<<4)` form; algorithm verified
  48/48 against captured packets and against the firmware's verifier at
  `update_cmd_dispatch 0x02026BC4`).

## The .fwsc logical image

Requests address a *logical* image, not the raw file:

- The first `20 × 0x30` (960) file bytes are the interleaved UFW header:
  each `0x30`-byte block carries `0x2F` data bytes + 1 marker byte. Strip the
  markers → 940 logical header bytes.
- Everything after offset 960 is raw.

So `logical = strip48(file[0:960]) + file[960:]` (704084 → 704064 bytes).
The UFW header decrypts (HDRKEY `0xFFFF`) to hdrcrc/listcrc/imgsize/numents
+ 8 entries: `flash.bin`, `info.log`, `USR`, `isd_config.ini`, `ota.bin`,
`script.ver`, `blimit.bin`, `tail.bin`. `script.ver` (SFC-encrypted, chipkey
`0x980F`) decrypts to `AC791N-v0.01-cfg_tool-v0.10`.

## Keepalive / ping

During long transfers the device pings every ~13 s with a request
`addr=0x100, len=0x402`; the host answers with the fixed 31-byte packet on
header `00 32 41 11`:
`F0 00 32 41 11 01 00 00 00 00 02 00 00 20 01 00 00 40 03 0E 22 58 4B 58 08 06 19 60 10 07 F7`.
The host also sends this spontaneously about every 13 s while streaming.

## syscmd core (normal-mode device control, cmd ids 17–48)

Separate from the OTA pull protocol: `serial_midi_task 0x02027AF4` →
`update_cmd_dispatch 0x02026BC4`, framing
`[hdr:2][cmd:1][len:3 LE][payload][~sum]`; info (17,18,21,33), ring read
(34), invoke callback (35,36,48), default-write (19,20,22–32,37–47);
callback table at `0x01C0E670+1336`.

## Known open items

- **Same-version refusal.** With the device running V9 firmware, both
  M-UPGRADE ("Same firmware version detected: 9") and the device itself
  (step-1 stalls after the JLFS entry walk at logical `0x92C3B`, the
  `cfg`/`eq_cfg_hw.bin` entries) refuse a V9 file. With the device on V13,
  the same V9 file passes step 1 and flashes. The exact field that carries
  the product version for this check is not pinned down yet (not app.bin's
  `FM-1_009` string/byte, not `script.ver`, not isd_config.ini, not the UFW
  header; probably inside the still-undecrypted `ota.bin` payload).
- The OTA-mode ID block differs from the normal-mode one; the version
  encoding inside the ID block (`03 93 03` vs `13 33 03` region) is not
  decoded, only reproduced.

## Files

- `tools/fm1_ota.py` — the Linux CLI (full client: handshake, serve requests,
  keepalive, finish; `flash` = both steps, `serve` = OTA-mode only).
- `tools/alsalib.py` — ALSA sequencer transport via libasound (ctypes).
  (Rawmidi is unusable while any seq subscriber exists, and PipeWire holds
  the input — the seq interface is what RtMidi/M-UPGRADE use.)
- `tools/alsaseq.py` — tiny pure-ioctl seq helper used for port discovery.
- `tools/99-jieli-fm1.rules` — udev rule for plugdev USB access.
- `tools/build_fwsc.py` — builds `build/FM-1-demo.fwsc`.
