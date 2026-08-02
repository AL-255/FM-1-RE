# Stock UBOOT analysis

This directory contains reproducible vendor-toolchain disassembly and indexes
for the 14,384-byte `uboot.boot` shipped by both FM-1 V13 and V14.

The stock blob has SHA-256
`730e54f0a439f58d147be4364ad21e19566945ada9d3a7bbc8371dce5068d3ef`.
It is byte-identical to `cpu/wl82/tools/uboot.boot` at AC79 SDK commit
`3df0315c330de6e9b78bebf0ca395df9c093fb34` and tag
`AC79NN_SDK_V1.1.9_2023-08-01`. This identifies the SPL as an AC791N/WL82
artifact, not a BR22/AC693N SDK artifact. The `debug/` artifacts come from the
paired `uboot.boot_debug` at that exact tag; its strings provide symbol-like
context for the corresponding stripped stock code.

Regenerate everything with:

```sh
scripts/analyze_uboot.sh
```

The configured load address is `0x01C02000`. The files contain mixed code,
tables, configuration-key strings, and padding. Function boundaries in the
JSON/CSV indexes are call-target-derived and must not be treated as complete
ground truth.

Safety conclusions and unresolved recovery questions are tracked in
`TODO_aug2.md` at the repository root.
