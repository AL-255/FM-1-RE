# FM-1 firmware — disassembly & reconstruction (Opus4.8 workspace)

Reverse engineering of the **M-Vave FM-1** FM-synthesizer firmware
(`firmware-images/v13/raw_fw/FM-1.fwsc`), a JieLi Bluetooth-audio MCU running a
DX7-compatible 6-operator FM engine.

> All disassembly work lives here in `Opus4.8/`. Large regenerable artifacts
> (Ghidra install, downloaded toolchain) are git-ignored; only scripts and
> derived text are tracked.

## TL;DR of findings

| Item | Value |
|---|---|
| Product | M-Vave FM-1 (DX7-style 6-op FM synth; SMK-37 Pro family) |
| SoC | **JieLi JL-BR22 = AC693N** (Bluetooth Audio) |
| CPU / ISA | **pi32v2** — JieLi's custom Blackfin-derived 32-bit core, 16-bit LE iwords |
| CPU-code file | `files/app.bin` (583 068 bytes) — the **only** file that is CPU code |
| Load / entry | XIP flash @ `0x02000000`, entry `0x020000A0` |
| RAM | base `0x01c00000`, SP top `0x01c14bb4` |
| BSS | `0x01c09e7c`, size `0x17380` |
| `.data` | RAM `0x01c00000` ← flash LMA `0x02084820`, size `0x9e7c` |
| Synth core | **Dexed / MicroDexed** (Google *music-synthesizer-for-android* `msfa`) |
| Factory patches | literal Yamaha DX7 ROM1A cartridge |
| Toolchain | JieLi pi32 GCC (`jieli-linux-toolchains`) + post-build tools |

## What was done

1. **Firmware characterization** — chip, ISA, memory map (from the reset-vector
   C-runtime startup that sets SP, clears BSS, and copies `.data` from flash).
   See `docs/01-firmware-analysis.md`.
2. **Full disassembly** of `app.bin`, two independent ways:
   - **Authoritative:** JieLi's own `objdump` (Clang/LLVM 4.0 `pi32v2` backend) →
     **211 252 instructions**, **12 038 calls**. → `decomp/app_pi32v2_objdump.txt`.
   - **Cross-check + reassembly:** kagaimiq **ghidra-jieli** SLEIGH module →
     162 848 instructions. → `decomp/app_pi32v2_linear.asm`. (SLEIGH mis-splits
     the `80 ff` long-`call` prefix; the vendor objdump gets it right — see doc 04.)
3. **Function-entry identification** — every `call` target is an entry:
   **2 062 function entries** from the vendor listing (99.8 % land on clean
   instruction boundaries) + 125 RAM-resident functions.
   → `decomp/function_entries_vendor.csv` (ranked by call count).
4. **Byte-identical reassembly** — Ghidra's SLEIGH *assembler* reassembles
   **162 480 / 162 848 (99.77 %)** instructions to the exact original bytes
   (0 hard errors); the 368 remainder are pi32v2 SLEIGH constructor asymmetries,
   not decode errors. Rebuilt `app.bin` is **byte-for-byte identical** to the
   original (same SHA-256). → `reasm/app_reassembled.bin`, `docs/02-disassembly.md`.
5. **DX7 core identification** — Dexed/MicroDexed (`msfa`). See
   `docs/03-dx7-core-identification.md`.
6. **Toolchain + vendored blobs plan** — `docs/04-toolchain-and-vendoring.md`,
   `scripts/setup_toolchain.sh`.

## Full firmware teardown (function map)

A broad call-target-derived functional map, grouped by subsystem with a rebuild
guide, is in **`docs/reversing/`**. It is not proof that callback-only functions
or inferred data/code boundaries are complete:

| Doc | Contents |
|---|---|
| `reversing/00-overview.md` | device summary, method, confidence limits |
| `reversing/01-hardware-map.md` | SoC, memory/SFR map, peripherals to re-drive |
| `reversing/02-boot-and-runtime.md` | reset/CRT, interrupts, RAM layout, anchors |
| `reversing/03-audio-and-synth.md` | **bit-exact msfa proof**, FM engine location, DAC path |
| `reversing/04-subsystems.md` | per-subsystem teardown with anchor addresses |
| `reversing/09-function-index.md` | **every function**: subsystem, purpose, call-degree |
| `reversing/10-rebuild-guide.md` | build your own synth on this board |

Backing data: `analysis/` (function_db.json, master_classified.json, per-subsystem
lists, enriched disassembly shards). Reproduce with `scripts/build_funcdb.py`,
`match_libs.py`, `resolve_strings.py`, `build_master_index.py`, `build_slices.py`,
and the `wf_classify.js` workflow.

## Layout

```
Opus4.8/
├── README.md                     ← this file
├── docs/                         ← written analysis
│   └── reversing/                ← full function map + rebuild guide
├── scripts/
│   ├── setup_toolchain.sh        ← downloads JieLi toolchain to /home/yukidama/JL/toolchain
│   └── run_ghidra.sh             ← reproduces disassembly / round-trip
├── ghidra/scripts/*.java         ← headless Ghidra scripts (SLEIGH disasm/asm)
├── decomp/                       ← disassembly listings + function tables
├── reasm/                        ← reassembled byte-identical app.bin
└── reference/                    ← (git-ignored) Ghidra, ghidra-jieli, jielie docs, Dexed, Synth_Dexed
```

## Reproduce

```bash
# 1. tooling: Ghidra + ghidra-jieli SLEIGH module + reference sources
scripts/setup_reference.sh
# 2. disassembly, function entries, round-trip, byte-identical reassembly
scripts/run_ghidra.sh
# 3. JieLi pi32 toolchain (outside repo)
scripts/setup_toolchain.sh /home/yukidama/JL/toolchain
```

## Scope note

`app.bin` is the only CPU-code component and is what gets disassembled. The SPL
(`top/uboot.boot`), config (`files/cfg`), and the entire Bluetooth stack are
JieLi **vendor blobs** — they are taken from the JieLi SDK, not disassembled
(see `docs/04-toolchain-and-vendoring.md`).
