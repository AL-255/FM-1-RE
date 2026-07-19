# 05 — Reconstruction plan (toward a compilable rebuild)

## Honest scope

`app.bin` is 583 KB / ~211 k instructions of `pi32v2` code. A line-by-line
decompilation of all of it to clean, compilable C is a multi-month effort and is
**not** what produces the best result here, because most of the binary is code
we already have in source form:

- **~40–60 %** is JieLi SDK + BTStack + libc/libm/compiler-rt → **vendored** (doc 04).
- **The FM synth DSP core** is **open source** (Dexed / msfa, doc 03) → reused, not decompiled.
- What is genuinely proprietary and worth recovering is the **product glue**:
  patch/bank management, the menu/UI tree, MIDI routing, arpeggiator, sequencer,
  and the effects — a small fraction of the image.

So "rewrite a compilable version" is best delivered as a **reconstruction that
links known-good open/vendored components and re-implements only the glue**,
built with the real JieLi `pi32v2` toolchain (doc 04) so the output is an
actual runnable firmware — not a pseudo-C dump that never compiles.

## Two build targets

1. **Host build (fast to demonstrate, no hardware):** compile `reference/Synth_Dexed`
   (`EngineMsfa`) with a small `main` that loads the DX7 ROM1A bank, plays MIDI
   notes, and renders WAV. Proves the synth core is faithfully the device's
   engine and lets you A/B against firmware audio. Pure host GCC, compiles today.

2. **Firmware build (bit-for-bit target):** JieLi SDK app for BR22/AC693N +
   `Synth_Dexed` core + reconstructed glue, linked against the vendored BT libs
   with the SDK linker script and packed with the post-build tools into a
   `.fwsc`. This is the path to a firmware that runs on the device.

## Step-by-step

1. **Fix the disassembler** (small, high-leverage): add the `80 ff` long-`call`
   prefix (and the reg-pair `mov`/`clr`, `swi` immediate) to ghidra-jieli, or
   just rely on the vendor objdump listing. This makes the call graph and
   function boundaries fully reliable.
2. **Map the glue functions** using `decomp/function_entries_vendor.csv` +
   string cross-refs. Anchor points already located by string:
   - UI/menu tree: `"1/6 OP1 Envelope"`, `"OP1 Tuning"`, `"Sens&Lvl"`, `"Scaling"`,
     `"PitchEnvelope"`, `"LFO"`, `"Arpeggio"`, `"Sequencer"`, `"Patches"`, `"Preset"`.
   - MIDI routing: `"midi_route"`.
   - Bank I/O: `"Dx7 32 Voice Save To"`, `/mnt/sdfile/app/usr`, FAT16 image.
   - Effects: `"Reverb"`, `"Filter"`.
3. **Reconstruct data first, code second.** Extract the DX7 factory bank and the
   parameter/patch structs from the `.data` LMA (`0x02084820`) and rodata. The
   patch format is the standard DX7 VMEM (128-byte packed voice ×32); the msfa
   `unpackProgram()` defines the field layout, so the structs are known.
4. **Re-implement glue** in C against the `Synth_Dexed` API
   (`Dexed::loadVoiceParameters`, `keydown/keyup`, `getSamples`,
   `ProgramChange`, sysex encode/decode), driven by the recovered menu/MIDI model.
5. **Integrate into the SDK app** for BR22, link vendored BT `.a` libs, build
   with `pi32v2/bin/cc`, pack with post-build tools, verify on device.

## Status in this workspace

- Upstream cores cloned: `reference/dexed`, `reference/Synth_Dexed`.
- Toolchain installed and smoke-tested (compiles pi32v2, doc 04).
- Authoritative disassembly + function entries produced (doc 02, 04).
- Remaining: the glue-mapping and re-implementation work above (the large,
  iterative part), plus obtaining the BR22 SDK app template + BT libs.
