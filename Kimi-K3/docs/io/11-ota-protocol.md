# FM-1 OTA / syscmd protocol (reverse-engineered)

How the M-Vave M-UPGRADE client talks to the FM-1 (JieLi BR22/AC693N), and
how `tools/fm1_ota.py` (the Linux CLI) replicates it. No UBOOT button exists
on this device — the update is done over USB while the stock firmware runs.

## Device identities

| mode | VID:PID | name | what |
|---|---|---|---|
| normal | `0x4C4A:0xC755` | "FM-1 Midi" composite | USB-MIDI (EP4 bulk 0x04/0x84) + UAC1 audio |
| OTA   | `0x4D4A:0x4155` | "ota-FM-1" USB HID   | the OTA loader (`usb_hid_ota.bin`) after the enter trigger |

## Enter-OTA trigger (normal → OTA)

Verified from the firmware's loader-mode check at `0x02006384`
(`usb_midi_rx_parse`): the host writes **8 raw bytes** to the MIDI bulk
endpoint (EP4 OUT, `0x04`) as ONE packet:

```
[ 0x02 0x01 0x42 0x04 0x02 0x01 , 0x7D | 0x7F , 0xF7 ]
  \________ 6-byte magic ______/   \_ cmd _/   \_end_/
```

- The 6-byte magic is the value stored at `0x01C07E2C` (the firmware memcmps
  against it).
- byte 6: `0x7D` → enter loader/OTA mode (mask-ROM call `0xFFC02532`);
  `0x7F` → the variant that only posts a reply (no reset).
- byte 7: `0xF7` terminator.
- The check requires the packet to be **exactly 8 bytes** (`if (len != 8) skip`).

After this, the device reboots into the OTA loader and re-enumerates as
`0x4D4A:0x4155` (USB HID). This is a raw USB write, not a MIDI message —
use libusb/pyusb (needs device-node write permission: install
`tools/99-jieli-fm1.rules` or run with sudo).

## syscmd core (device control, cmd ids 17–48)

Used by the client to query the device (and for misc control) over the MIDI
path (`serial_midi_task 0x02027AF4` → `update_cmd_dispatch 0x02026BC4`).

Packet framing (from `update_cmd_dispatch`):

```
[ hdr : 2 ][ cmd : 1 ][ length : 3 LE ][ payload : length ][ checksum : 1 ]
```

- `length` = payload byte count (24-bit LE). Total packet = `length + 7`.
- `checksum` = `~sum(payload) & 0xFF` (or `0xFF` when length == 0).
- `hdr` (2 bytes) is not validated by the dispatcher (don’t-care / magic).

Commands (from the `tbh` jump table at `0x02026C26`):

| cmd | handler | meaning |
|---|---|---|
| 17 | `0x02026C44` | device info reply (27 B blob) |
| 18 | `0x02026C5D` | device info reply (13 B blob) |
| 21 | `0x02026C6A` | get version (27 B blob) |
| 33 | `0x02026C95` | device info reply (13 B blob) |
| 34 | `0x02026CAD` | ring-buffer read (OTA data/log out) |
| 35 | `0x02026CD5` | invoke registered callback `[tbl+N][0]` (24-bit arg) |
| 36 | `0x02026D16` | invoke registered callback `[tbl+N][8]` (with payload) |
| 48 | `0x02026D5E` | invoke registered callback `[tbl+N][4]` + reply checksum |
| default (19,20,22–32,37–47) | `0x02026D88` | invoke registered callback `[tbl+N][4]` with payload — the generic "write" |

The registered-callback table is at `0x01C0E670+1336` (8 slots × {+0,+4,+8,+12}).

## .fwsc transfer (OTA mode)

The OTA loader (`usb_hid_ota.bin`, 19969 B, header magic `0x5881EBAA`)
parses the `.fwsc` and its update blocks (JL update magic `0x5A04..0x5A08`,
per-block CRC, then `jieli_ufw_update_run` in the app verifies/flashes).
The client streams the `.fwsc` to the loader over HID reports (64-byte).

**Caveat:** the exact HID report framing (command header per report) was not
fully recovered from `usb_hid_ota.bin` in this pass — the CLI implements a
configurable report layer (see `tools/fm1_ota.py upload()`), which should be
validated/adjusted against a live M-UPGRADE USB capture (usbmon on Windows,
or usbmon under Wine). Everything else (trigger, identities, syscmd framing,
.fwsc structure) is verified against the firmware/binary.

## Files

- `tools/fm1_ota.py` — the Linux CLI.
- `tools/99-jieli-fm1.rules` — udev rule for plugdev USB access.
- `tools/build_fwsc.py` — builds `build/FM-1-demo.fwsc` (the image to flash).
