# FM-1 firmware reverse engineering

Reverse engineering, update-protocol tooling, and experimental firmware for the
M-Vave FM-1 synthesizer. The target is a JieLi BR22/AC693N SoC with a pi32v2
CPU, XIP flash at `0x02000000`, and a Dexed/msfa-derived six-operator FM engine.

## Repository layout

- `analysis/`: V13 disassembly, reassembly, function databases, classifications,
  raw and enriched shards, OTA loader images, and host updater decompilation.
- `docs/`: firmware characterization, architecture, subsystem teardowns,
  function indexes, reconstruction notes, and OTA protocol findings.
- `firmware/`: the experimental on-device synth, shared Dexed port, host tools,
  and plugin targets.
- `scripts/`: the unified disassembly and classification pipelines.
- `tools/`: firmware package builders, USB-MIDI updater, tests, and quarantined
  legacy UBOOT helpers.
- `ghidra/`: checked-in pi32v2 headless analysis scripts.
- `firmware-images/`: immutable V13 and V14 packages and unpacked inputs.
- `reference/`: ignored SDKs, Ghidra installation, and upstream source mirrors.
- `3rd-party/`: pinned firmware parsing and JieLi boot-tool submodules.
- `TODO_Aug1.md`: current safety review and the release gates for device
  flashing.

See `analysis/README.md` for the relationship between the two function-analysis
pipelines. `analysis/db.json` and `docs/function-index.md` are the current
classification outputs; the independent `function_db.json`/`master_index.json`
pipeline remains checked in for cross-validation and provenance.

## Reproduce

Run commands from the repository root:

```bash
# Low-level disassembly and independent function map
scripts/run_ghidra.sh
python3 scripts/build_funcdb.py
python3 scripts/resolve_strings.py
python3 scripts/match_libs.py
python3 scripts/build_master_index.py
python3 scripts/build_slices.py

# Current enriched classification database and documentation
python3 scripts/build_db.py
scripts/disasm_toolchain_libs.sh
python3 scripts/match_libs.py
python3 scripts/mech_tag.py
python3 scripts/export_shards.py
python3 scripts/aggregate.py

# Firmware and offline OTA checks
make -C firmware image
python3 -m unittest discover -s tools/tests -v
```

## Safety status

The custom firmware is **not flash-ready**. Offline package checks and protocol
tests pass, but the device-side OTA loader has not emitted the final
`0xF0000000` commit request for a custom image. Read `TODO_Aug1.md` before using
any update or flash utility.
