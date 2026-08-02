# 04 — Subsystems (narrative + anchors)

This is the functional teardown of `app.bin` by subsystem, with **anchor
addresses** established deterministically (exact table/descriptor/string matches
and call-graph facts). The exhaustive per-function listing with subsystem tags
is in `09-function-index.md`.

Confidence key: **[exact]** = proven by byte match / descriptor / call graph;
**[inferred]** = from disassembly reading.

---

## SYS — boot, runtime, interrupts  **[exact]**
Full detail in `02-boot-and-runtime.md`.
- Reset `0x02000000` → CRT (set sp/ssp, zero `.bss`, copy `.data`) → RAM overlay
  init → system/clock init `0x02058a64` → clock/rate config `0x02001c24`.
- Interrupt common entry `0x020000b0` saves full pi32v2 context and calls the
  **C dispatcher `0x020002a2`**.
- System hw-info struct at RAM `0x01c7fd50`. Stacks at `0x01c14bb4/0x01c15bb4`.

## MEMLIB / MATHLIB — C library  **[exact]**
Exact signature matches against the toolchain libs (hot functions, called 100s×):
`memmove 0x02042642`, `memset 0x02042f08`, `memcmp 0x0204260a`,
`strcmp 0x02042730`, `strcpy 0x020427d0`, `strlen 0x0204283e`,
`strncmp 0x0204284a`, `strcat 0x02042704`, `strchr 0x0204271c`,
`__udivdi3 0x020023e8`, `get_number 0x02028fdc`, plus libm (`remquol`, …).
The `0x0204xxxx` band is largely libc/libm. These come from the SDK — reuse, don't
rewrite.

## SYNTH_FM — the DX7 / Dexed engine  **[exact tables]**
Full detail in `03-audio-and-synth.md`. The engine is msfa (Dexed/MicroDexed),
proven by exact table matches:
- `pitchmodsenstab 0x0204eb90`, `ampmodsenstab 0x0204ef4c`,
  `velocity_data 0x0204f760`, `coarsemul 0x0204fc44`.
- DX7 note/voice + operator/env/lfo code clusters in **`~0x0203d900–0x0203ec00`**
  and neighbours; synth tables in rodata `0x0204e000–0x02050000`.
- Parameter surface (UI strings): 6 operators (`OP1..OP6` Envelope/Tuning/
  Sens&Lvl/Scaling), `PitchEnvelope`, `LFO`/`Lfo Sync`, `Algorithm`,
  `Pitch Sens/Up/Dn`.

## AUDIO_OUT — DAC output  **[inferred]**
FM render → mix → on-chip audio **DAC** via DMA ring buffer (JieLi SDK audio
driver), driven from the audio IRQ/task at the boot-configured sample rate.
`/tmp/audio`, `%s_devbuf`, `audio_cmd` strings mark the audio buffer/command
plumbing. Tagged `AUDIO_OUT` in the index.

## MIDI + USB — control I/O  **[exact descriptors]**
USB is a **composite MIDI + Audio device**:
- Device descriptor `0x0204f07d`: **VID `0x4C4A` ("JL"), PID `0x4155` ("UA")**,
  USB 2.0, 64-byte EP0, iMfr/iProduct/iSerial = 1/2/3.
- Strings: `"FM-1 Midi" 0x0204f0cb`, `"FM-1 Audio" 0x0204f182`,
  `"Jieli Technology" 0x0204f46f`, `"USB Composite Device" 0x0204f573`.
- `midi_route 0x0204ed77` string → the MIDI routing layer (USB↔synth↔BLE).
- Key MIDI functions (from analysis):
  - `0x02000c48` — MIDI byte-stream engine (running-status + `F0/F7` SysEx decode).
  - `0x02000a02` — app SysEx command dispatcher (patch/device ops, replies).
  - `0x02006384` — USB-MIDI SysEx + DX7 7-bit voice param pack/unpack.
  - **`0x02023ea0` — Yamaha/DX7 SysEx (`F0 43`): voice & 32-voice bank bulk dump +
    single-parameter, checksum-verified, loaded into the synth voice buffer** —
    i.e. full DX7 SysEx interop.
  - `0x0201fdde` — enqueue outgoing MIDI (TX ring, running-status), `0x020008b0`
    device handshake.
  - MIDI channel-voice → FM is `0x0201f5f4` (see `03-audio-and-synth.md`).
Tagged `USB` / `MIDI` in the index.

## UI_MENU / UI_DISPLAY / INPUT — front panel  **[inferred + strings]**
- The UI is a **retained-mode widget-tree framework** (JieLi SDK UI, at
  `0x02008xxx–0x0200axxx`): elements with parent/child/sibling links, a
  signal/observer binding system (connect/disconnect handlers), a layout engine
  (margins, rectangles, horizontal/vertical content extents, scroll offsets), a
  property/attribute store (realloc-grown arrays), and an animation/transition
  system. A global element manager lives at RAM `global[176]`. Element create is
  `0x0200965c`; the state-change/redraw dispatcher is `0x02008ac4`; widget-tree
  event/focus propagation is `0x02008d96`.
- Menu tree with paged pages (`"1/6 OP1 Envelope"`, `"3/6 OP1 Tuning"`, …,
  `"Sequencer"`, `"Arpeggio"`, `"GLOBE"`(global)). Text is **resource-driven**
  (JieLi menu resources in `files/cfg`), referenced by ID — so menu strings do
  not attach to code by C pointer.
- Effects submenu is a real pointer table at `0x0204f90c`:
  `Preset, Phaser, Low Pass, Band Pass, …`.
- Inputs: keybed + buttons (GPIO scan), encoder(s), and **Pitch/Mod wheels via
  ADC** (the firmware has a wheel calibration mode: `"calibration mode for
  malfunctioning Pitch/Mod wheels"`). Tagged `INPUT`.

## FX — effects  **[strings]**
`Reverb 0x0205552d? / 0x00055515`, `Chorus`, `Phaser`, plus `Low Pass`/`Band
Pass`/`High Pass` filter modes and `S&Hold`/`Fix` LFO-ish options. Applied
post-mix before the DAC. Tagged `FX`.

## STORAGE — filesystem & patch banks  **[inferred]**
- JieLi flash `nor_sdfile` + FAT/`jlfs` filesystem; paths under
  `/mnt/sdfile/app/{usr,btif,cfg_tool.bin}`, `NO NAME FAT16` volume.
- Filesystem code (path parse, directory scan, 32-byte FAT entries, sector
  compaction) is a clear cluster (e.g. `0x0202e108+` — verified in classification).
- Patch/bank layer stores DX7 banks (32×128-byte voices) to files; `ble_ota.bin`
  handles OTA image. Tagged `STORAGE_FS` / `STORAGE_PATCH`.

## BT — Bluetooth (vendored)  **[strings]**
Build stamps `INCLUDE_BTSTACK`, `JL_A2DP`, `JL-BR22`; `btstack_lowpwer_deal`,
`btencry`. The stack itself is vendor blob (`fw-AC63_BT_SDK`); the app calls into
it for A2DP/AVRCP/HFP/BLE and BLE-MIDI/OTA. Tagged `BT`.

## POWER / PERIPH  **[strings/inferred]**
`sys_power`, charge/LDO/sleep management, and low-level GPIO/UART/timer drivers.
Tagged `POWER` / `PERIPH`.

---

### How to use this with the index
`09-function-index.md` lists every function under these subsystem tags with a
one-line purpose and call-degree. Start from an anchor above, then follow
`callers`/`callees` in `analysis/master_classified.json` to walk the subsystem.
