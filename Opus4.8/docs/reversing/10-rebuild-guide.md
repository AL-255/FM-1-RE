# 10 — Build your own synth on this hardware

Goal: reuse the FM-1 board (JieLi **BR22 / AC693N**, pi32v2) to run *your own*
firmware — an FM synth, or anything else. This is the practical path that the
rest of the docs support.

## 0. What you're working with

- CPU: JieLi **pi32v2** (custom, Blackfin-derived). No mainline GCC/LLVM — you
  need JieLi's toolchain (a custom Clang/LLVM 4.0). Installed by
  `../../scripts/setup_toolchain.sh` into `/home/yukidama/JL/toolchain`.
- SoC: BR22 has one CPU core, on-chip flash (XIP @ `0x02000000`), RAM @
  `0x01c00000`, audio DAC, USB, Bluetooth, ADC, GPIO. See `01-hardware-map.md`.
- Firmware container: JieLi `.fwsc`. Build with the SDK, pack with the
  post-build tools, flash over USB with JieLi's downloader.

## 1. Get the SDK (gives you SPL, drivers, linker script, BT/USB/flash)

```
git clone https://github.com/Jieli-Tech/fw-AC63_BT_SDK      # BR2x/AC63 family
# or the AIoT line on gitee: https://gitee.com/Jieli-Tech
```
The SDK provides for BR22/AC693N: the SPL (`uboot.boot`), CPU/clock/power init,
SFR register headers, the RTOS/task scheduler, USB device stack, the Bluetooth
stack (prebuilt `.a` blobs), the flash + FAT/`jlfs` filesystem driver, and the
audio DAC driver. **Reuse these** — they are the "vendored blobs" and are the
hard part to reproduce. Your job is only the application on top.

## 2. Toolchain usage

```
TC=/home/yukidama/JL/toolchain/toolchain/jieli-linux-toolchains-*/
$TC/pi32v2/bin/cc  -O2 -c yourcode.c -o yourcode.o     # compile (clang -target pi32v2)
$TC/pi32v2/bin/ld  ... -T sdk_linker.ld                # link with SDK objects/libs
$TC/common/bin/objdump -d yourcode.o                   # inspect
```
Libraries available: `pi32v2/lib/{libc,libm,libg,libcompiler-rt}.a` (+ `r1..r5`
register-ABI variants). ELF machine id `0xf1`.

## 3. Drop in the FM engine (open source — don't reinvent)

The FM-1's synth is the **Dexed / msfa** core. Reuse it directly:

```
git clone https://codeberg.org/dcoredump/Synth_Dexed     # EngineMsfa = bit-accurate DX7
```
- The pure DSP files (`fm_core`, `fm_op_kernel`, `env`, `lfo`, `pitchenv`,
  `freqlut`, `sin`, `exp2`, `dx7note`) are portable C++; compile them for pi32v2.
  Replace the Teensy `<arm_math.h>`/`AudioStream` deps with plain math.
- Feed `Dexed::getSamples()` output into the SDK's DAC ring buffer (see the
  audio-out path in `03-audio-and-synth.md`). Match the sample rate the DAC
  driver is configured for (44.1/48 kHz).
- Patch format is standard DX7 VMEM (128-byte packed voice × 32 per bank); use
  `unpackProgram()`.

## 4. Wire up the I/O (from the SDK + these docs)

| Need | Use |
|---|---|
| Note on/off, params | USB-MIDI (SDK usb-midi class) + your MIDI parser |
| Audio out | SDK DAC driver + DMA ring buffer, fed by the FM engine |
| Keys / encoder / wheels | SDK GPIO + ADC; scan in a task or timer ISR |
| Display + menu | SDK display driver; your menu state machine |
| Preset storage | SDK `nor_sdfile` / FAT; store banks under `/mnt/sdfile/app/usr` |
| Bluetooth (optional) | SDK BT stack (A2DP sink/source, BLE-MIDI) |

## 5. Minimal bring-up order

1. Build the SDK's "hello" app for BR22, flash it, confirm boot + UART log.
2. Add the DAC output task; play a test tone from a wavetable — confirm audio.
3. Compile & link `Synth_Dexed`; render one DX7 voice to the DAC on a fixed note.
4. Add USB-MIDI; drive note on/off from a DAW.
5. Add controls, menu, and preset storage.
6. (Optional) BT audio / BLE-MIDI.

## 6. Reference: how the stock firmware does it

`04-subsystems.md` + `09-function-index.md` give the exact functions the stock
firmware uses for each of the above — read those to see, e.g., how it configures
the DAC, parses MIDI, lays out the menu, and stores banks, and mirror the parts
you want to match. The stock app is byte-identically reproducible from the
disassembly (`../02-disassembly.md`), so any detail can be re-checked against the
real code.
