# FM-1 firmware reverse engineering

Reverse engineering and experimental firmware work for the M-Vave FM-1
synthesizer.

## Repository layout

- `firmware-images/`: immutable V13 and V14 stock packages, extraction scripts,
  and unpacked inputs.
- `Opus4.8/`: V13 disassembly pipeline, call graph, function database, and
  reconstruction notes.
- `Kimi-K3/`: classified device analysis, protocol documentation, host updater
  decompilation, Linux USB-MIDI tooling, and the experimental synth firmware.
- `3rd-party/`: pinned firmware parsing and JieLi boot-tool submodules.
- `TODO_Aug1.md`: current safety review and the release gates for device
  flashing.

## Safety status

The custom firmware is **not flash-ready**. Offline package checks and protocol
tests pass, but the device-side OTA loader has not emitted the final
`0xF0000000` commit request for a custom image. Read `TODO_Aug1.md` before using
any update or flash utility.
