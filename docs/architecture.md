# FM-1 firmware architecture

This document describes the currently mapped architecture of the **M-Vave FM-1**
synthesizer firmware (`FM-1.fwsc`, V13 / 2026-07-03 dump), as established by
the classification of **2062 direct-call-target-derived entries** in V13 `app.bin`
(see `function-index.md` and `analysis/db.json`).

Confidence: recorded addresses, sizes, direct calls, and byte comparisons are
exact for the checked-in V13 image. Function boundaries are call-target-derived,
and purposes are tagged high/med/low confidence in the index.

## 1. System overview

The FM-1 is a Yamaha-DX7-compatible 6-operator FM synthesizer on a
**JieLi AC791N/WL82** multimedia SoC. Embedded `JL-BR22` strings identify
linked library lineage, not the physical SoC:

- **CPU**: JieLi **pi32v2** (custom Blackfin-derived 32-bit core, 16-bit LE
  instruction words, algebraic asm). 240 MHz (PLL from 24 MHz xtal).
- **Sound engine**: a port of Google's **msfa** (the core of Dexed /
  MicroDexed / Synth_Dexed), proven by byte-exact DX7 lookup tables
  (`docs/io/04-synth-engine.md`). 12-voice polyphony, 44118 Hz, 64-sample
  blocks, integer fixed-point DSP.
- **OS**: a FreeRTOS-derived **SMP kernel** with JieLi's own API layer
  (`os_taskq_*`, `sys_timer_*`), a device framework (`dev_manager`), a
  jlstream audio pipeline, and a dlmalloc mspace heap
  (`docs/io/02-rtos.md`).
- **I/O**: USB (composite **"FM-1 Midi" USB-MIDI** + **"FM-1 Audio" UAC1**
  device), UART MIDI (DIN via TRS), **BLE-MIDI** (GATT), 240×240 SPI LCD,
  key matrix + 2 encoders + 2 ADC wheels (pitch/mod), internal audio DAC,
  NOR-flash filesystem (patches), Bluetooth (Classic + BLE, mostly vestigial
  for this product), OTA update.

### Firmware image composition (2062 inferred entries categorized)

| subsystem | funcs | what it is |
|---|---|---|
| BT | 719 | btctrler BLE link layer, btstack HCI/L2CAP/ATT/GATT/SM, BR/EDR, profiles |
| RTOS | 224 | FreeRTOS-derived SMP kernel, tasks/queues/timers, dlmalloc, mem_pool |
| STORAGE_FS | 215 | NOR/SFC driver, FatFS-derived FS + exFAT, VFS, VM flash KV store |
| UI_MENU | 165 | JieLi ui_core widget framework + FM-1 menu tree |
| AUDIO_OUT | 137 | DAC driver, DMA ring, jlstream nodes, codec/ADDA, SRC, mixer |
| MEMLIB | 103 | libc (memmove/memset/str*/printf family) |
| UI_DISPLAY | 91 | LCD SPI driver, draw/blit/font engine |
| USB | 74 | USB device stack (MUSB-derived SIE), EP0, USB-MIDI + UAC1 classes |
| SECURITY | 70 | AES/SHA-256/HMAC/P-192 ECC, SSP pairing, update signature |
| PERIPH | 55 | GPIO, UART/SPI/I2C/timer/PWM/ADC low-level drivers |
| MATHLIB | 46 | libm + soft-float + 64-bit arith |
| SYS | 42 | boot/CRT, clocks, IRQ dispatch, chip config |
| MIDI | 28 | MIDI parser, routing, DX7 sysex, arpeggiator/sequencer |
| APP | 26 | top-level app state machine, main task, hooks |
| POWER | 21 | battery/charge, sleep/wake, low-power |
| SYNTH_FM | 20 | msfa/Dexed engine (voice/op/env/LFO/pitchenv/freqlut/sin/exp2) |
| FX | 9 | reverb/phaser/chorus/filters (post-mix) |
| INPUT | 3 | key scan, encoder poll, ADC wheel scan |
| STORAGE_PATCH | 3 | DX7 bank pack/unpack/store |
| UNKNOWN | 11 | end-of-image/data artifacts (0.5 %) |

## 2. Memory and flash map

### CPU address space

| range | contents |
|---|---|
| `0x02000000 … 0x0208E59C` | flash XIP — `app.bin` (.text + .rodata + .data image) |
| `0x0208FEE0 … 0x020FDFE0` | flash XIP beyond app.bin (whole 1 MB flash is linear-mapped, XIP = flash_offset − 0x4120 + 0x02000000) |
| `0x01C00000 …` | RAM: .data `0x01C00000` (0x9E7C), .bss `0x01C09E7C` (0x17380) |
| `0x01C14BB4 / 0x01C15BB4` | main / system stack tops |
| `0x01C7FD50` | boot hwinfo struct (from SPL) |
| `0x04000120` | overlay / cache-locked window |
| `0x00010000 … 0x00100000` | peripheral SFRs (LSB/HSB windows; see `io/01-boot.md`) |

### Flash layout (1 MB, from the JLFS directory in `FM-1.fwsc`)

| flash offset | contents |
|---|---|
| `0x00000` | flash header (burner/VID/PID "AC791N") |
| `0x000A0` | SPL `uboot.boot` ("UBOOT2.00", 0x3830) |
| `0x038D0` | `isd_config.ini` (contains chip key `0x980F`) |
| `0x04000` | app area (JLFS, chipkey-encrypted): directory + `app.bin` at `0x4120` (0x8E59C) + `cfg_tool.bin` at `0x926BC` (0x17F) + `cfg` at `0x9283B` (0xB79) |
| `0x94000` | VM region (config KV store, 0x55000) |
| `0xE9000` | BTIF region (0x1000) |
| `0xEA000` | USR region (user patch storage, 0x12000) |
| `0xFC000+` | free / `key_mac` at `0xFF000` |

The firmware container is a **UFW** update package (chip "AC791N") holding
`flash.bin` (0x94000, the image above) plus update scripts; the JLFS app
area is encrypted with the chip key (`jl_sfc_cipher`, base 0x4000), the SPL
with the fixed header key `0xFFFF`; the unpacked metadata is retained in
`firmware-images/v13/raw_fw/FM-1.fwsc_unpack/jlfw.yaml`.

## 3. Boot chain

1. Mask ROM loads SPL from flash `0xA0` (XIP) and jumps in.
2. SPL (`uboot.boot`) sets up clocks/SDRAM-less defaults, reads the JLFS
   directory, maps the app area XIP at `0x02000000` and jumps to
   `0x020000A0`.
3. App CRT (`0x02000000`): set SP/SSP, zero `.bss`, copy `.data` from flash
   `0x02084820`, copy overlay to `0x04000120`, copy boot params to hwinfo
   `0x01C7FD50`.
4. `pll_clock_init 0x020000F8` → 240 MHz; `clock_board_init 0x02001AB0`
   (contains `0x02001C24` rate config).
5. Kernel init + `main` (`0x0200457A` neighborhood): initcall tables,
   `board_init 0x0200417E` (keys/ADC/SPI display/audio server at 44118 Hz),
   then task creation (`usr_app_task 0x02022CFE` = the UI app) and
   `os_start 0x0205A6B6`.

Interrupts: vectors at `0x020000A0–0x020000C4` save the full pi32v2 context;
the C dispatcher `0x020002A2` scans pending IRQ bitfields and calls handlers
registered with `request_irq(index, prio, handler, cpu) 0x020016D2` (RAM
vector table `0x01C7FE00`). Details: `io/01-boot.md`, `io/02-rtos.md`.

## 4. The audio path

```
 USB-MIDI ─┐
 UART-MIDI ┼─> midi_stream_parser 0x02000C48 ─> midi_msg_dispatch 0x0201F5F4
 BLE-MIDI ─┘        (running status/sysex)         (voice alloc, 12×468B voices)
 keys/arp/seq ──────> 0x0202423C / 0x02020724 ───────┘
                                                          │
                                   msfa engine (RAM-resident kernels):
                                   dx7note_compute_block 0x020862FA
                                   fm_core_render        0x02085A28
                                   (64-sample blocks, 12 voices)
                                                          │
                                   synth ping-pong 0x01C10694/0x01C10794
                                   pump 0x02086AD6 (DMA IRQ 0x02088EEE)
                                                          │
                                   FX chain 0x02087A26 (reverb/phaser/filter)
                                                          │
                          DAC DMA half-buffer IRQ 0x02041478:
                          cb = [ENG 0x01C0E670 + 4228 + 36]
                          cb(priv=[+32], buf+half_off, nbytes)
                                                          ▼
                                                   internal audio DAC
```

Full path: `io/03-audio-dac.md`, `io/04-synth-engine.md`.

## 5. The MIDI surface

- **Parser** `midi_stream_parser 0x02000C48`: running status, per-status
  length table, sysex state machine, shared engine struct `0x01C0E670`.
- **Dispatch** `midi_msg_dispatch 0x0201F5F4(ctx, msg)`: note on/off with
  voice alloc/steal (stride 468), CC 1/2/4/64, 14-bit pitch bend.
- **DX7 sysex** `midi_message_handler 0x02023EA0`: bulk 32-voice dump
  (`F0 43 0n 09 20 00`, 4096 B, checksum), single voice (`F0 43 0n 00 1B`),
  7-byte param changes into the edit buffer at `ENG+5608`.
- **Vendor sysex** magic `F0 35 59 F7` (config/update).
- **Arpeggiator** `0x02020724` (patterns, octaves, random via SFR RNG) and a
  step sequencer (`io/05-midi.md`).

## 6. USB device

Composite **USB-MIDI + UAC1 audio** device. Its embedded descriptor template
uses VID:PID `4c4a:4155`; hardware captures enumerate normal mode as
`4c4a:c755` (see `io/11-ota-protocol.md`). Strings are "FM-1 Midi" / "FM-1
Audio" / "Jieli Technology" / "USB
Composite Device", serial = hex chip ID. MUSB-derived SIE, 8-endpoint table
`0x01C0C3C0`, EP0 dispatcher `0x0200707C`, USB-MIDI on a 64-byte bulk EP
pair (RX parse `0x02006384`, TX sysex engine `0x02005D86`), UAC1 24-bit/2-ch
adaptive ISO (`0x020611CC`). Details: `io/06-usb.md`.

## 7. Storage

NOR flash over SPI0 (`0x11C00`) + SFC command mode (`0x40200`), FatFS-derived
FS with exFAT (`mount_volume 0x02029352`, `fatfs_open 0x0202C19A`), VFS, and
a ping-pong-sector VM KV store (`vm_read 0x0203249C`, magics
`0x55AAAA54/0xDDEEAA54`) used for config (incl. BT MAC id 102, wheel
calibration). DX7 patches: 155-byte edit buffer → 128-byte VMEM pack
(`dx7voice_pack_store 0x0201D532`) stored as bank files. Firmware update:
UFW engine `0x02082D24` (magics `0x5A02..0x5A08`), OTA via BLE
(`io/09-storage.md`).

## 8. Input & display

41-key matrix + debounce (`0x020244A2`), two rotary encoders
(`0x020247AA`), SARADC channels 3/4 for pitch/mod wheels
(`adc_channel_scan 0x0200053A`, `0x13100`), event queue at
`0x01C0E670+3588` consumed by `usr_app_task`. 240×240 LCD on SPI1
(`0x11D00`), JieLi ui_core widget tree, RGB565 blitter, UTF-8 font engine
(`io/07-input.md`, `io/08-display.md`).

## 9. Bluetooth

BLE link layer (8-slot pool, `ble_ll_conn_create 0x0205F928`), btstack
HCI/L2CAP/ATT/GATT/SM with AES-CCM/P-192/SHA-256 crypto. **BLE-MIDI** rides
GATT (service/char UUIDs at `0x020436C5/0x020436E0`, MIDI on ATT handle
0x72, notifications `att_server_notify 0x020801A4`). Classic BT
(A2DP/AVRCP/HFP/SBC) is present as SDK carryover — vestigial for the FM-1
(`io/10-bluetooth.md`).

## 10. Where to look next

- `docs/function-index.md` — 2062 V13 call-target-derived entries by subsystem.
- `docs/io/*.md` — per-subsystem teardowns with function tables.
- `analysis/db.json` — machine-readable master DB (xrefs, strings, labels).
- `tools/` — updater protocol client and offline tests.
