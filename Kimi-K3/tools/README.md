# Flashing the FM-1 custom synth demo

## What gets flashed

| file | flash offset | what it is |
|---|---|---|
| `build/fm1_demo_flash.bin` | `0x000000` | stock app area (0x94000) with the demo hooks patched into `app.bin` |
| `build/demo_blob.bin` | `0xEA000` | the demo synthesizer (Dexed/msfa engine, ~21 KB) in the USR region |

The stock SPL (`uboot.boot`), config, VM and BTIF regions are untouched.
The demo blob lives in the user patch-storage (USR) region — **saving patches
from the stock UI over that area may corrupt the demo**; re-run
`tools/flash.sh write` to restore it.

## Entering UBOOT (update) mode

The FM-1 must present its JieLi USB bootloader, not the normal "FM-1 Midi"
device:

1. Power off.
2. Hold the front-panel encoder/button (per the unit's `isd_config`, the
   update strap is `PB01_08`).
3. Power on while holding it; the unit enumerates as a USB storage device
   named **`UBOOT`** / `UDISK` / `DEVICE` (check with `lsblk`, `dmesg`, or
   `tools/flash.sh probe`).

If the normal "FM-1 Midi" device appears, the strap didn't take — retry,
or use the stock firmware's own "update mode" menu if present.

## Requirements

- Linux with `/dev/sg*` access for the device (the tool talks raw SCSI).
  You may need `sudo` or a udev rule for the `/dev/sgN` node.
- Python 3 with `pyyaml`, `tqdm` (used by `3rd-party/jl-uboot-tool`).

## Workflow

```bash
tools/flash.sh probe          # confirm the device is in UBOOT mode
tools/flash.sh dump           # ALWAYS FIRST: backs up the whole 1 MiB flash
tools/flash.sh write          # flash the demo
```

After writing, power-cycle. Expected behavior:

- the unit boots normally (stock UI shows),
- USB-MIDI (and UART/BLE MIDI) notes play our basic synth on the
  headphone/line output; program change 0–3 selects SAW LEAD / SQ BASS /
  SYNC PAD / PLUCK,
- the bottom of the LCD shows the demo overlay: physical keys held (`KEY`),
  the last MIDI note received (`MIDI`), and the current preset,
- the stock UI/menu remains usable above the overlay.

## Recovery (back to stock)

```bash
tools/flash.sh restore backups/fm1_stock_YYYYMMDD_HHMMSS.bin
```

## If something goes wrong

- **No sound / no boot after write**: the demo blob may not be mapped or the
  hooks mismatched the firmware version — restore the backup.
- **Device won't enumerate at all**: the flash at 0x0 was disturbed. The
  JieLi mask-ROM UBOOT is in ROM and always works: re-enter UBOOT mode and
  `tools/flash.sh restore <backup>`.
- **Weird behavior only in the menu**: cosmetic; the demo does not touch the
  UI. Restore if it bothers you.

The patched hooks were built for exactly the dumped V13 firmware
(`disasm_FM-1_2026_07_03_V13`). Do not flash onto a unit with a different
firmware version — the hook addresses will be wrong.
