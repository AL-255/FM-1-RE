# Kimi-K3 — FM-1 firmware RE: function map, architecture & custom synth demo

This workspace continues the reverse engineering of the **M-Vave FM-1**
synthesizer firmware begun in `../Opus4.8`. It delivers:

1. **A broad function map** — **2062 direct-call-target-derived entries** from
   V13 `app.bin`, categorized by subsystem with purpose and confidence
   (`docs/function-index.md`, machine-readable: `analysis/db.json`,
   `analysis/function_index.csv`).
2. **Architecture documentation** — boot, RTOS, drivers, synth engine
   (`docs/architecture.md`).
3. **Key I/O subsystem teardowns** — keyboard/ADC wheels, tone generation,
   MIDI (USB-MIDI + UART + BLE), USB device stack, audio DAC, storage, display
   (`docs/io/`).
4. **A custom synthesizer demo** that runs on the original hardware
   (`firmware/`), built with the JieLi pi32v2 toolchain, plus a flash script
   (`tools/`).

## Layout

```
Kimi-K3/
├── README.md                  ← this file
├── docs/
│   ├── function-index.md      ← 2062 inferred entries, grouped by subsystem
│   ├── architecture.md        ← system architecture (boot→RTOS→drivers→synth)
│   └── io/                    ← per-subsystem I/O teardowns
│       ├── 01-boot.md 02-rtos.md 03-audio-dac.md 04-synth-engine.md
│       ├── 05-midi.md 06-usb.md 07-input.md 08-display.md
│       └── 09-storage.md 10-bluetooth.md
├── analysis/
│   ├── db.json                ← master function DB (xrefs, sigs, labels)
│   ├── function_index.csv     ← flat table of all functions
│   ├── CLASSIFY_BRIEF.md      ← taxonomy/ISA guide used for classification
│   ├── shards/                ← enriched per-range disassembly packets
│   ├── classified/            ← per-shard classification results
│   ├── libdis/                ← toolchain library disassemblies (signatures)
│   ├── device/ota-loader/     ← stock/patched device-side loader images
│   └── host-updater/          ← Windows M-UPGRADE worker decompilation
├── scripts/
│   ├── build_db.py            ← parse vendor objdump → db.json
│   ├── disasm_toolchain_libs.sh
│   ├── match_libs.py          ← exact lib-signature matcher
│   ├── mech_tag.py            ← deterministic subsystem tagging
│   ├── export_shards.py       ← emit classification packets
│   └── aggregate.py           ← merge classifications → docs
├── firmware/                  ← custom synth demo (pi32v2 + host)
│   ├── dexed/                 ← msfa/Dexed engine (ported, host+pi32v2)
│   ├── src/                   ← demo runtime, hooks, shared voices
│   ├── host/                  ← ALSA app, LV2 plugin, test tools
│   └── Makefile               ← `make` (blob), `make host`, `make image`
├── build/                     ← generated firmware artifacts (git-ignored)
├── tools/
│   ├── fm1_ota.py             ← active USB-MIDI update client
│   ├── build_fwsc.py          ← build a development UFW package
│   ├── build_image.py         ← UFW decode → patch hooks → re-encrypt (reference)
│   ├── symbols.py             ← export blob entry addresses
│   ├── make_font.py           ← 8×16 LCD font generator (Pillow)
│   ├── tests/                 ← offline OTA protocol tests
│   ├── legacy-uboot/          ← unavailable ROM/UBOOT workflows (reference)
│   └── README.md              ← flashing/recovery instructions
└── reference/                 ← (git-ignored) SDK clones
```

## Key facts (established in Opus4.8, extended here)

- SoC **JieLi BR22 / AC693N** (pi32v2 CPU), flash XIP `0x02000000`, RAM
  `0x01C00000`, entry `0x020000A0`, chip key `0x980F`.
- OS: **FreeRTOS-derived SMP kernel** (JieLi "OS" layer) + JieLi device
  framework; audio via **jlstream** pipeline nodes.
- Synth: **msfa (Dexed/MicroDexed)** 6-op FM, proven byte-exact; render
  kernels RAM-resident (`.data` image `0x02084820+`).
- USB: composite **"FM-1 Midi" + "FM-1 Audio"** (VID 0x4C4A PID 0x4155);
  USB-MIDI on bulk EP, plus UART MIDI and BLE-MIDI.
- Storage: FatFS-derived FS (+exFAT) over NOR flash; DX7 VMEM banks.

## Reproduce

```bash
python3 scripts/build_db.py              # function DB from Opus4.8 listing
bash   scripts/disasm_toolchain_libs.sh  # lib signatures
python3 scripts/match_libs.py            # exact lib matches
python3 scripts/mech_tag.py              # deterministic tags
python3 scripts/export_shards.py         # classification packets
python3 scripts/aggregate.py             # → docs/function-index.md
```

The 51-shard LLM classification was run over `analysis/shards/` with
`analysis/CLASSIFY_BRIEF.md`; results are committed in `analysis/classified/`.

## Flashing status

See `tools/README.md` and `../TODO_Aug1.md`. The buttonless USB-MIDI client is
implemented, but a custom image has not reached the loader's commit handshake.
The ROM/UBOOT workflows are retained under `tools/legacy-uboot/` for analysis;
the retail FM-1 has no known way to enter that mode. Do not flash the custom
image until the P0 release gates in `TODO_Aug1.md` are complete.

## The demo

The on-device demo is a **basic polyphonic synthesizer** (8 voices, polyblep
saw/square/sine oscillators + sub-osc, ADSR, Chamberlin lowpass; 4 presets:
SAW LEAD / SQ BASS / SYNC PAD / PLUCK) grafted into the stock firmware via
boot/MIDI trampolines + a DAC-feed hook, plus an **on-device display UI**:
a 240×56 LCD overlay (bottom of the panel, SPI1, 8×16 font) showing physical
keys held (`KEY`), the last MIDI note received (`MIDI`), and the preset.
The identical synth code runs on the host (`make host`).

## Host native mode

The same basic synth and presets also run on the host:

```bash
cd firmware && make host
./host/fm1_synth -l          # list MIDI keyboards (ALSA)
./host/fm1_synth -m 24:0     # play from that keyboard, audio out via ALSA
./host/fm1_jack -l           # list JACK MIDI sources
./host/fm1_jack              # low-latency JACK audio + MIDI
./host/sim                   # render the demo behavior to host/demo.wav
```

- `firmware/host/fm1_synth` — standalone synth app: ALSA MIDI in → ALSA audio
  out. Works with any MIDI keyboard (including the FM-1 itself over USB-MIDI).
  Prints each NOTE ON/OFF with note name, MIDI number, velocity and active
  voice count.
- `firmware/host/fm1_jack` — standalone JACK client: JACK MIDI in → JACK audio
  out. Auto-connects to the first available JACK MIDI source; use `-m` to pick
  one explicitly. Same on-screen note/patch feedback as the ALSA version.
- `firmware/host/lv2/fm1_dexed.so` — **LV2 instrument plugin** (loads into
  Ardour, Carla, Zrythm and other DAWs): MIDI in → mono audio out, with a
  `Patch` control (0–3: SAW LEAD/SQ BASS/SYNC PAD/PLUCK). Install:
  `mkdir -p ~/.lv2/fm1-dexed.lv2 && cp firmware/host/lv2/{fm1_dexed.so,manifest.ttl,fm1_dexed.ttl} ~/.lv2/fm1-dexed.lv2/`.
- `firmware/host/vst/fm1_dexed.so` — **VST2 instrument plugin** for DAWs that
  still load VST2 (e.g. Reaper, older Bitwig). MIDI in → mono audio out,
  program-change patch switching.
- `firmware/host/sim` — offline render of the whole demo flow to a WAV.
- `firmware/host/midi_blaster` — MIDI-injection test utility.
- `firmware/host/render_test` — reference validation of the Dexed/msfa port
  (kept in `firmware/dexed/`, used to prove the stock engine's identity).

## Verification status

- all 2062 discovered call-target entries categorized (0.5 % unknown, many
  low-confidence) → `docs/function-index.md`
- msfa/Dexed engine proven byte-exact (tables) and mapped line-by-line
- pi32v2 demo blob builds with the JieLi toolchain (13 KB), links at XIP
  `0x02046600` (replaces part of the V13 font/bitmap region)
- image builder re-encrypts the app area with chip key `0x980F`; hook
  patches verified by re-decryption (`tools/build_image.py`)
- host: synth render, MIDI input path, preset switching, and the LV2 plugin
  all validated
- one upstream Synth_Dexed heap-overflow bug found and fixed
  (`voices[i]`→`voices[note]` in `Dexed::keydown`)
- on-device OTA flashing remains hardware-unverified after correcting the
  Linux client's handshake, timing, ALSA polling, re-enumeration, and terminal
  status handling. The prior shrunken-loader run stopped at `0xE0000000`
  without sending the required `0xF0000000` finish signal. V14 (`FM-1_014`)
  and the matching Windows worker are now extracted and disassembled; details
  are in `docs/ota-loader-shrinking.md`.
