# 01 — Hardware & memory map

Target SoC: **JieLi AC791N/WL82**, custom **pi32v2** CPU. Embedded `JL-BR22`
tokens identify linked library lineage rather than the physical SoC.
Physical marking on this unit: **`C156211-11B8`** (LQFP48). Single CPU core
(`CPU_CORE_NUM 1`).

## Address space

| Range | Contents |
|---|---|
| `0x02000000 … 0x02084820` | **Flash (XIP)** — `.text` + `.rodata`, interleaved per source module |
| `0x02084820 … 0x0208e59c` | `.data` initializer image (copied to RAM at boot) |
| `0x01c00000 …` | **RAM** — `.data` @`0x01c00000`(len `0x9e7c`), `.bss` @`0x01c09e7c`(len `0x17380`) |
| `0x01c14bb4 / 0x01c15bb4` | main / system stack tops |
| `0x01c7fd50` | boot/system hw-info struct |
| `0x04000120 …` | fast/cache-locked RAM window (overlay code/data) |
| low `0x0000_0xxx … 0x0004_xxxx` | **SFR / peripheral registers** (most-referenced region: ~3000 hits) |

The image is a JieLi "new-fw" `.fwsc` with an SPL (`uboot.boot`, "UBOOT2.00")
that loads `app.bin` to flash-XIP and jumps to `0x020000a0`. Chip-key `0x980F`.

## Clocks / audio rate

Boot code at `0x02001c24` derives clocks by dividing a `1,000,000` base by
chip-strap config fields read from `0x02040204` and `0x02040400`. Audio sample
rate for the DX7 engine is set here / in the audio-out init (see
`03-audio-and-synth.md`). JieLi BR-series audio DACs typically run 44.1/48 kHz.

## Audio DAC / codec registers (recovered from the DAC driver)

Function analysis of the audio-out driver (`0x0203c9xx–0x02040dxx`) exposes the
actual audio SFR addresses — directly useful for re-driving audio:

| SFR | Role |
|---|---|
| `0x51000`, `0x51030` | audio **clock-gate** / analog clock config |
| `0x12F00` | **DAC digital main control** (rate/routing/enable bits) |
| `0x12F20` | DAC digital **volume/gain** (L/R) |
| `0x12F40` | **second/AUX DAC** channel control |
| `0x12B00`, `0x12E00` | DAC digital / analog config & de-init |
| `0x119c4` | analog **codec routing mux** (per device+channel) |
| `0x119c8`, `0x119cc` | codec channel enable / select / config bitfields |
| `0x119e0` | analog **codec gain** (scaled from percentage) |

Default audio-stream **sample rate = 44100 Hz** (`0x020067cc`); a rate table maps
8k–192k to clock-divider config (`0x0203e03c`, `0x0203f730`). Main DAC
open/configure is `0x0203f0b0`; the PCM-push/DMA-ISR path is `0x0203ce06`;
digital volume set is `0x0203f018`. Analog trim/calibration (binary-search a trim
value against a comparator SFR) is at `0x0203eeee`/`0x0203ef56`. See
`03-audio-and-synth.md` and `09-function-index.md` (subsystem `AUDIO_OUT`).

## Other peripheral register access

Outside audio, the firmware touches the low SFR region heavily but accesses
individual registers through a base-register + offset pattern (and immediate
constants like `256/512/4096` are bit masks, not addresses), so most non-audio
register names are **not** recoverable from the binary alone. The AC791N/WL82
SDK headers provide the closest authoritative names. Observed
SFR-region reference hot addresses (offsets into the SFR window) include
`0x100, 0x10c, 0x110, 0x114, 0x140, 0x200, 0x270, 0x712/0x714/0x716,
0x1004/0x1008/0x1032, 0x1810/0x1812, 0x8080` — candidate clock-gate / GPIO /
timer / audio blocks to confirm against the SDK map.

## Observed board peripherals

The peripherals used by the stock firmware, confirmed by subsystem analysis,
are:

| Function | Peripheral | Notes |
|---|---|---|
| Audio output | internal audio **DAC** + DAC-DMA ring buffer | 6-op FM render feeds this |
| MIDI I/O | **USB** device (USB-MIDI) + UART MIDI | class-compliant USB-MIDI |
| Bluetooth | on-chip BT controller (Classic + BLE) | vendored stack |
| Keys / buttons | GPIO matrix / IO-map scan | keybed + function keys |
| Encoders | GPIO (quadrature) | menu/data encoder(s) |
| Pitch / Mod wheels | **ADC** channels | calibration mode exists in FW |
| Display | segment/char LCD or small OLED over GPIO/SPI/I2C | menu UI |
| Preset storage | on-chip **flash** (`nor_sdfile`) + FAT/jlfs | `/mnt/sdfile/app/usr` |
