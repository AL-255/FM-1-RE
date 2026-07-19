# FM-1 OTA / syscmd protocol (reverse-engineered)

How the M-Vave M-UPGRADE client talks to the FM-1 (JieLi BR22/AC693N), and
how `tools/fm1_ota.py` (the Linux CLI) replicates it. No UBOOT button exists
on this device — the update runs over USB while the stock firmware runs.

## Device identities

| mode | VID:PID | name | what |
|---|---|---|---|
| normal | `0x4C4A:0xC755` | "FM-1 Midi" composite | USB-MIDI (EP4 bulk 0x04/0x84) + UAC1 audio |
| OTA   | `0x4D4A:0x4155` | "ota-FM-1" USB HID   | the OTA loader (`usb_hid_ota.bin`) |

## Flow (from M-UPGRADE's own logs)

1. **Handshake / verification query** over MIDI SysEx — device responds
   ("Connected to device: FM-1"), stays in normal mode.
2. (user picks the file + starts upgrade) **"First step (verification)"** →
   the device **enters OTA mode** and re-enumerates as `ota-FM-1` (USB HID).
3. **HID transfer** of the `.fwsc`; the loader verifies + flashes and reboots.

## Handshake query (captured from M-UPGRADE, byte-identical across sessions)

37-byte SysEx over the MIDI bulk endpoint:

```
F0 00 32 45 58 01 00 00 23 4D 5A 44 79 05 26 4C 19
[17 × 00]
60 06 F7
```

`4D 5A 44 79` = `"MZDy"`. The two trailing fields (`05 26 4C 19`, `60 06`)
are CRCs over the packet. The device accepts it and stays in normal mode —
this is device discovery, not the OTA trigger.

## syscmd core (device control, cmd ids 17–48)

Over the MIDI path (`serial_midi_task 0x02027AF4` → `update_cmd_dispatch
0x02026BC4`). Packet framing:

```
[ hdr : 2 ][ cmd : 1 ][ length : 3 LE ][ payload : length ][ ~sum(payload)&0xFF ]
```

Commands: info (17, 18, 21, 33), ring read (34), invoke registered callback
(35, 36, 48, and the default "write" for 19,20,22–32,37–47); callback table
at `0x01C0E670+1336`.

## Enter-OTA trigger (the "First step")

After the handshake, the client's upgrade command makes the device write the
boot record `FM-1_009` + `ota-` (112 B, the `UPDATA_PARM` from JieLi's
`update.h`) and soft-reset (`[0x10000] |= 0x10`). The SPL reads the record
and boots the OTA loader (`usb_hid_ota.bin`).

**Not fully recovered here:** the exact bytes of that upgrade command and the
HID transfer framing. A candidate loader-mode trigger found in the firmware
(`0x02006384`): an 8-byte packet `[<6B magic @0x01C07E2C>, 0x7D|0x7F, 0xF7]`
did not reset the device in my tests — the real "First step" is a different
(later) command. Getting it needs a live M-UPGRADE + USB capture, which I
could not do in this environment (GUI inaccessible, usbmon needs root).

## .fwsc transfer (OTA mode)

The OTA loader parses the `.fwsc` (JL update magic `0x5A04..0x5A08`, per-block
CRC) and flashes it (`jieli_ufw_update_run`). The client streams it over HID
reports (64-byte). Exact per-report framing unconfirmed — see the caveat above.

## Files

- `tools/fm1_ota.py` — the Linux CLI (handshake + syscmd core + transfer skeleton).
- `tools/99-jieli-fm1.rules` — udev rule for plugdev USB access.
- `tools/build_fwsc.py` — builds `build/FM-1-demo.fwsc`.
