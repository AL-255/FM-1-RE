# 00 — FM-1 firmware: overview & how to read these docs

This doc set is a functional map of the **M-Vave FM-1** firmware, produced by
disassembling `app.bin` and analysing all ~2000 functions. The aim is enough
understanding to **build your own synthesizer on the same JieLi hardware**.

## The device in one paragraph

The FM-1 is a **Yamaha DX7-compatible 6-operator FM synthesizer** built on a
**JieLi JL-BR22 / AC693N** Bluetooth-audio SoC (custom **pi32v2** CPU). The synth
engine is a port of the open-source **Dexed / MicroDexed** core (Google
*music-synthesizer-for-android*, "msfa"); factory patches are the literal DX7
ROM1A cartridge. It has USB-MIDI, an on-device menu UI for editing all DX7
parameters, an arpeggiator, a sequencer, effects (reverb/filter/phaser), patch
banks stored on internal flash, and Bluetooth. Firmware is built on JieLi's
`fw-AC63_BT_SDK`.

## Document map

| Doc | Contents |
|---|---|
| `00-overview.md` | this file |
| `01-hardware-map.md` | SoC, memory map, SFR regions, peripherals to re-drive |
| `02-boot-and-runtime.md` | reset/CRT startup, interrupt path, RAM layout, anchors |
| `03-audio-and-synth.md` | audio-out (DAC), the FM/Dexed engine, voice flow |
| `04-subsystems.md` | narrative per subsystem, with key function addresses |
| `09-function-index.md` | **every** function: address, subsystem, purpose, call degree |
| `../03-dx7-core-identification.md` | proof the engine is Dexed/msfa |
| `../04-toolchain-and-vendoring.md` | JieLi toolchain + which blobs to vendor |
| `../05-reconstruction-plan.md` | how to build your own firmware |

## Method (so you can trust / extend it)

1. **Disassembly** — `app.bin` is pi32v2 code at `0x02000000`. The authoritative
   listing is from JieLi's own `objdump` (`decomp/app_pi32v2_objdump.txt`,
   211k instructions). A Ghidra/SLEIGH cross-check reassembles byte-identically.
2. **Function DB** — every `call` target is a function entry (2003 in flash +
   42 in RAM). objdump's `<_fw+0x..>` annotations give the full call graph and
   data/string cross-references (`analysis/function_db.json`, `master_*.json`).
3. **Auto-labelling** — exact signature matches against the toolchain
   `libc/libm/compiler-rt` name the standard library functions.
4. **Classification** — each function was read and assigned a subsystem + a
   one-line purpose (confidence tagged). Aggregated in `09-function-index.md`.

## Confidence & limits

- Addresses, sizes, call graph, byte-identical reassembly: **exact**.
- Library-name matches: **exact** (signature).
- Per-function purpose / subsystem: **inferred from disassembly** — high for
  library and string-anchored code, lower for leaf helpers. Confidence is noted
  per function. The UI text is resource-driven (in `files/cfg`), so menu strings
  don't always attach to code by pointer.
- Exact peripheral register names need the JieLi BR22 SDK headers (not in the
  binary). Pointers given in `01-hardware-map.md`.
