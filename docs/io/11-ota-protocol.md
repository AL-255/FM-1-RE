# FM-1 OTA / M-UPGRADE protocol and open device-side gates

How the M-Vave M-UPGRADE client updates the FM-1 (JieLi AC791N/WL82),
byte-verified against live ALSA-seq captures of M-UPGRADE under Wine and
against the stock `.fwsc`. `tools/fm1_ota.py` is a byte-exact Linux
reimplementation of the client framing and state machine. No physical UBOOT
entry has been demonstrated; the observed update starts over USB-MIDI SysEx
while the stock firmware is running.

The [2026-09-04 V16 to stock V15 reflash](12-v15-reflash-proof.md) records a
successful Windows MIDI run and corrects the partial-block framing below.

## Device identities

| mode | observed VID:PID | enumerates as | MIDI |
|---|---|---|---|
| normal | `4c4a:c755` | "FM-1 Midi" composite (USB-MIDI + UAC audio) | capture used client 24, `USB Composite Device MIDI 1` |
| stock OTA | `4d4a:4155` | "ota-FM-1" composite | same MIDI port name |

Everything — discovery, enter-OTA, and the transfer — runs over MIDI
System-Exclusive messages. There is no HID report traffic for the update
itself (the "USB HID" interface on the OTA device is unused by M-UPGRADE).

The V13 application also embeds a device-descriptor template at `0x0204F07D`
with VID:PID `4c4a:4155`. This differs from the captured normal-mode PID
`c755`, so the template is either patched or superseded before enumeration.
The USB teardown records the template; host discovery uses the observed IDs.

## Session flow

1. **Handshake query** (host→device):
   `F0 00 32 45 00 00 00 40 7F F7`
   The device answers with a 34-byte decoded (41-byte packed) **ID block** on
   header `00 32 45 58`, e.g.
   `F0 00 32 45 58 01 00 00 23 4D 5A 44 79 05 06 4C 1C [21×00] 40 05 F7`
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
5. **Finish**: the device requests raw address `0xF0000000`, length 8; the host
   answers with the 8-byte payload `"success\0"` on channel `00 32 41 01`.
   Static loader analysis places this request after its write and metadata
   gates. Post-reboot identity must still be checked before reporting success.

## Read-request / data-response framing

Build the complete unpacked message, then encode it as one continuous
LSB-first 8-to-7-bit stream between `F0` and `F7`:

```
00 59 30 | body_length:u24le | flash_type:u8 | address:u32le |
requested_length:u24le | data (response only) | checksum:u8
```

- `body_length` is 8 for requests and `len(data) + 8` for responses.
- `requested_length` is the exact requested payload size; ordinary responses
  must contain that many bytes. The address retains all 32 bits, including
  `0xE0000000` and `0xF0000000`.
- `checksum = ~sum(bytes from flash_type through the end of data) & 0xFF`.
- The device requires `body_length + 7 == decoded_packet_length` before
  dispatching a command. A checksum-correct message can still fail this check.

The former fixed `00 32 41 41` prefix only happened to encode the correct
length for aligned blocks. A 481-byte response needs body length 489, whereas
the old builder declared 488. The [vendor host builder](../../analysis/host-updater/ota_worker_decomp.c#L1455)
writes the complete length before packing. See the
[recorded failure, correction and reflash](12-v15-reflash-proof.md).

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

## Terminal signals and timing

Static decompilation of the 2026-07-06 M-UPGRADE worker confirms that the
terminal conditions are raw addresses, not flash types:

- `0xE0000000`, length 8: verification complete. Reply with `success\0`, keep
  the MIDI connection open for 3000 ms, then wait for re-enumeration.
- `0xF0000000`, length 8: loader finish request. Reply with `success\0`. Its
  receipt proves that the loader reached the post-write finish path, not that
  the requested version subsequently booted.

The worker sleeps 2000 ms after each upgrade command before reading requests,
and each receive has an 8000 ms timeout. It sends no keepalive or pre-finish
packet; those were artifacts of an earlier incorrect frame interpretation.

## syscmd core (normal-mode device control, cmd ids 17–48)

Separate from the OTA pull protocol: `serial_midi_task 0x02027AF4` →
`update_cmd_dispatch 0x02026BC4`, framing
`[00 59][cmd:1][len:3 LE][payload][~sum(payload)]`. V14 has the same
dispatcher at `0x0202730E` and the same 32-entry branch table.

The decoded command map is:

| command | behavior |
|---|---|
| 17 | return a fixed 27-byte record |
| 18 | return a fixed 13-byte descriptor |
| 19, 20 | no operation; return without a response |
| 21 | drain up to the requested length from the common ring at `ENG+960/+964/+968` |
| 22–32 | no operation; return without a response |
| 33 | callback object method `+0`: `(u32 arg)` |
| 34 | callback object method `+8`: `(payload_data, u32 arg, u24 len)`; write-shaped |
| 35 | callback object method `+4`: `(response_data, u32 arg, u24 len)`; read-shaped |
| 36 | callback object method `+12`: `(u32 arg0, u32 arg1)`; returns a 16-bit value |
| 37–47 | no operation; return without a response |
| 48 | complete a previously armed transfer after matching stored token and length |

Commands 33–36 select one of eight callback objects. The table is at V13
`ENG+1336` (`0x01C0EBA8`) and V14 `ENG+1400` (`0x01C0EC08`). Only the four
dispatcher reads have been found; no direct writer or non-null stock object
has been recovered. Command 48 is not an arbitrary callback or unconditional
write: it compares the request against `ENG+416/+420`, requires the destination
at `ENG+424`, copies only after those checks, clears the armed state, and posts
`ENG+1876`.

The dispatcher's third argument is a transport selector. `0` is the USB-MIDI
8-to-7-bit SysEx path staged at V13 `ENG+812`; `1` is the Bluetooth packet
handler's event `0x72` path staged at `ENG+648`. Replies use different length
units/staging records. Guessed requests, especially commands 33–36 and 48,
must not be sent to the only recoverable device.

This is also distinct from the SDK's optional `new_cfg_tool.c` protocol. That
tool uses a `5A AA A5`/CRC16 frame over USB CDC and includes physical flash
read, erase, write, and MaskROM-entry commands. The signature is absent from
the V13/V14 applications, UBOOTs, and extracted OTA loaders, and stock normal
USB exposes no CDC interface. The packaged `cfg_tool.bin` is a data resource,
not evidence that this transport is linked or usable as recovery.

## Step-1 verifier — hardware-verified findings (2026-07-21)

Exhaustive on-device probing (build a fwsc, flash step-1, watch for the
`0xE0000000` verification-done signal / a soft reset) established:

- **The forced loader-replacement read-back is identical for payloads up to
  19456 bytes (0x4C00).** In these modified-package tests, the verifier wrote
  the incoming `ota.bin` payload to the loader flash region as plaintext and
  read it back for the payload CRC. Payloads of 64, 512, 1024, 2048, 4096,
  8192, 12288, 16384, 16896, 17408, 18432, and 19456 bytes passed. No
  scrambling was required, disproving the earlier SFC-descramble theory.
- **The tested replacement path rejects payloads above 19456 bytes.** A
  19456-byte payload passes and a 19457-byte payload fails. The stock loader's
  compressed payload is 19937 bytes (`dlen=0x4DE1`), 481 bytes above this
  observed staging limit, and its overflow tail did not read back correctly.
  This does not mean an ordinary stock update must replace the loader: the
  stock V13/V14 loader is identical, and bundled logs record a successful
  stock downgrade.
- **The tail is NOT descrambled with any known key.** 16 pre-scramble variants
  (plain jl_enc_cipher + jl_sfc_cipher with seeds 0x375F, 0x980F, 0xFFFF,
  0xFFFE, 0x0000, 0x0001, 0x035e, 0x1dbf, 0x31f0, 0x67ac, 0x68ff, 0xadde, and
  SFC bases 0/0x4000/0x94000/0x90000) all failed — so the overflow tail is
  write-dropped at the region limit (read-back = stale data), not descrambled.
- The seed `h[0x1C7FD6C]` (used by `FUNC_0200380a → FUNC_020037c8` for the
  encrypted-region read-back) is a per-chip OTP value read by the SPL from a
  companion die (see the SPL analysis); it is NOT needed for ≤ 19456-byte
  payloads and does not affect the > 19456 overflow.
- The result handler `FUNC_02027F88` resets into the loader **iff
  verifier-return==0 AND notify byte `b[0x1C0E670+60]==0`** — no other no-op
  gate after the CRC. The verifier clears notify on CRC success, so the CRC is
  the only post-bulk-copy gate.
- **Consequence for the historical experiment:** forcing a different loader
  through this staging path required a payload no larger than 19456 bytes.
  Optimal-parse one-block LZ4 reached 19578 bytes, still 122 bytes over, so the
  preservation branch trimmed the loader image for subsequent tests.

## Known open items

- **Same-version / no-op refusal — how far we got.** The step-1 verifier
  (`FUNC_02082D24`, called from `FUNC_02083394` when the update-state field is
  `0x5A06`) reads the incoming image and refuses to reboot into the OTA loader
  when it judges the update a "no-op" vs what's already on the device. The
  accept path (`FUNC_02027F88`) requires verifier-return==0 **and** the notify
  byte `b[0x1C0E670+60]==0` to build the `FM-1_009 + ota-` boot record and
  soft-reset (`[0x10000] |= 0x10`).
- **cfg gate — BYPASSED (verified on hardware).** The verifier reads the
  incoming `cfg` JLFS daisychain entry header (32 bytes at flash `0x9283B`,
  logical `0x92C3B`) and compares it to the stored cfg; identical → refuse.
  An experimental package flipped one padding byte in the nested
  `eq_cfg_hw.bin` entry's 16-byte name field, which changed the cfg
  `datacrc`/`hdrcrc` while leaving the EQ payload and both entry names
  byte-identical. The device then proceeded past cfg to the `ota.bin` stage.
  This is the first no-op gate (confirmed by request log: 9 requests became
  49 requests).
- **ota.bin container format — byte-verified.** It is a nested bootable
  image at logical `0xA6F20` (fwsc file `0xA6F34`, `0x4E01` bytes):
  `[outer_hdrcrc:2][outer_datacrc:2][doff=0x20][dlen=0x4DE1][attr=0x41][rsvd][last]["usb_hid_ota.bin"]`
  then an inner boot header
  `[inner_hdrcrc:2][inner_datacrc:2][imgsize=0x5B1C][loadaddr=0x1C0A800][rsvd]["usb_hid_ota.bin"]`
  then 6 back-to-back **LZ4 block-format** chunks (continuous dictionary;
  dsize `0x1000`×5 + `0xB1C` = `0x5B1C`). All CRCs are `jl_crc16`
  (CRC-16/CCITT-FALSE); `inner_datacrc` covers the *decompressed* image;
  `outer_datacrc` covers `ota[0x20:]`. UFW-entry dcrc covers the whole file.
  `scripts/extract_ota_loader.py` contains the retained integrity verifier and
  continuous-dictionary LZ4 decoder.
- **ota.bin / accept gate — STILL BLOCKED.** The verifier loads ota.bin to
  the VM/loader flash area (49 read requests), the payload-CRC self-check
  (`@0x020832E2`, plain CRC16 — verified passing for stock and patched images)
  passes, yet the device still does not reset (stays `4c4a:c755`, no error
  frame; M-UPGRADE likewise reports only "Verification timeout"). The
  verifier's result handler takes the ERROR path because a notify code
  `b[0x1C0E670+60]` is left non-zero by an **obfuscated no-op/product check**
  (`FUNC_02083394` → callback chain → `FUNC_02027F88`). Tried and ruled out as
  the compare key: ota.bin outer/inner datacrc/hdrcrc, UFW edcrc, inner name,
  the compressed bytes, the *decompressed* image (a `.data` slack byte
  `0x5AD0` **and** a code-region string byte `0x2DA2`, via both a re-encode
  and a literal-preserving flip with valid CRCs), the UFW header `wa3/wa4`
  fields, the app `FM-1_0xx` string + header markers (bumped to `_014`, still
  refused), and the app build strings (`VER-$…INCLUDE_…`, `V11.D11.121…`).
  The V14 M-UPGRADE bundle embeds a genuine `FM-1_014` image with a changed
  application, but its `usb_hid_ota.bin` is byte-identical to V13 (`aa eb 81 58`
  = hdrcrc `0xebaa` + datacrc `0x5881`). So the check is **not** a
  simple content/CRC/version compare of the loader; it most plausibly requires
  a different loader *build* (unavailable) or a device-state value we cannot
  read without JTAG/UART. Next: capture the exact notify code, or the stored
  loader, via hardware access.
- **V14 recovery (2026-08-01).** The embedded V14 `.fwsc` is 704052 bytes and
  its `app.bin` is 1888 bytes larger than V13. Focused decompilation of the
  updater confirms the raw `0xE0000000`/`0xF0000000` state machine above. No
  device was available to retest the corrected Linux client.
- **ID block decoded (2026-08-01).** M-UPGRADE function `0x140016E10` takes the
  model before `_`, adds ASCII `0` to each byte of a second 20-byte identity
  field, and parses the decimal suffix as the version. The Linux client now
  validates the post-reboot model and version using this algorithm. Hardware
  validation of the Linux parser remains pending.
- **Stock downgrade accepted.** The bundled 2026-06-26 log records FM-1
  version 10 successfully installing `FM-1_008`, receiving the second-stage
  completion, and reconnecting as version 8. This does not establish recovery
  from an application whose update service cannot start.

## Files

- `tools/fm1_ota.py` — the Linux CLI (full client: handshake, serve requests,
  terminal replies; `flash` = both steps, `serve` = OTA-mode only).
- `tools/alsalib.py` — ALSA sequencer transport via libasound (ctypes).
  (Rawmidi is unusable while any seq subscriber exists, and PipeWire holds
  the input — the seq interface is what RtMidi/M-UPGRADE use.)
- `tools/alsaseq.py` — tiny pure-ioctl seq helper used for port discovery.
- `tools/99-jieli-fm1.rules` — udev rule for plugdev USB access.
- `scripts/extract_ota_loader.py` — validates and extracts the stock nested OTA
  executable.
