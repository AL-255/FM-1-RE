# Uploading the FM-1 demo firmware over USB

## Method 1 (primary): official JieLi `isd_download`

JieLi's own download tool re-packs, encrypts and flashes the JLFS image via
the chip's USB download protocol.

```bash
tools/upload.sh            # build + upload (packages only if no device attached)
tools/upload.sh build      # just build build/official/*
tools/upload.sh upload     # just run isd_download
```

What it does:

1. `firmware/` builds the pi32v2 demo blob (`make`).
2. `tools/build_official.py` patches stock `app.bin` with the demo hooks
   (boot + MIDI), appends the demo blob at `0x8E600`, and stages
   `build/official/{app.bin,uboot.boot,cfg,cfg_tool.bin,ota.bin,isd_config.ini}`.
3. JieLi `isd_download` (`/home/yukidama/JL/toolchain/post-build/...`) runs
   `-tonorflash -dev br22 -boot 0x120 -div8 -wait 300 -uboot uboot.boot -app
   app.bin cfg_tool.bin -res cfg`, producing `build/official/jl_isd.fw` and
   flashing it when a device in UBOOT/update mode is attached.

The packaged `jl_isd.fw` was verified to unpack back to the exact patched
`app.bin` with both hook trampolines and the demo blob present.

## Method 2 (alternative): raw jl-uboot-tool write

When the device shows up as a plain "UBOOT" mass-storage device and the
official protocol is unusable, write the same `jl_isd.fw` at flash `0x0`:

```bash
tools/flash.sh dump        # ALWAYS FIRST: full 1 MiB backup
tools/flash.sh write       # writes build/official/jl_isd.fw at 0x0
tools/flash.sh restore backups/fm1_stock_*.bin
```

## Entering UBOOT (update) mode

1. Power off.
2. Hold the front-panel encoder/button (`isd_config` strap `PB01_08`).
3. Power on while holding; the unit enumerates as `UBOOT`/`UDISK`/`DEVICE`.

## After flashing

Power-cycle. The unit boots the stock UI; the bottom LCD strip shows the demo
overlay (`KEY` = physical keys held, `MIDI` = last MIDI note + preset), and
USB/UART/BLE MIDI plays the basic synth (program change 0–3 selects SAW
LEAD / SQ BASS / SYNC PAD / PLUCK).

## Recovery

Restore the dump (`tools/flash.sh restore <backup>`) or re-flash the stock
`FM-1.fwsc` with `isd_download`. The JieLi mask-ROM UBOOT is in ROM, so
UBOOT mode always works even after a bad write.

## Notes / layout changes vs stock

- `isd_download` relocates the VM/BTIF/USERIF regions because the app grew:
  VM moves to `0x97000` (from `0x94000`), USERIF to `0xed000` (from
  `0xEA000`). Saved config / BT pairing / user patches are reset on first
  boot after flashing (the drivers re-init those regions). The demo no
  longer uses the USR region — the blob is appended to `app.bin`.
- Only flash the image built for exactly the V13 dump.
