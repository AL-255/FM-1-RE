# Analysis artifacts

This directory combines two independently developed V13 analysis pipelines and
the later OTA work. The pipelines are complementary rather than interchangeable.

## Current classification pipeline

- `db.json`: canonical 2062-entry database used by the current documentation.
- `function_index.csv` and `../docs/function-index.md`: generated flat and
  human-readable indexes.
- `shards/` and `classified/`: enriched classification inputs and results.
- `libdis/`, `lib_hits.json`, and `mech_tags.json`: toolchain signatures and
  deterministic labels.

## Independent disassembly pipeline

- `disassembly/`: vendor and Ghidra listings plus harvested function entries.
- `reassembly/`: byte-identical reconstructed V13 application image.
- `function_db.json`, `master_index.json`, and `callgraph.json`: independently
  derived call-target database and merged index.
- `raw-shards/`: original 51 disassembly slices. These are retained because the
  newer `shards/` add different call/data-reference annotations and are not
  byte-equivalent replacements.
- `subsystems/` and `../docs/reversing/`: the earlier classification output and
  subsystem-oriented documentation.

The four baseline toolchain listings formerly present under two names were
byte-identical. Only `libdis/base_libc.txt`, `base_libcompiler-rt.txt`,
`base_libg.txt`, and `base_libm.txt` are retained.

## OTA analysis

- `device/ota-loader/`: stock device-side OTA loader image and its analysis.
- `host-updater/`: decompilation of the Windows M-UPGRADE worker.

Neither the databases nor the offline OTA checks establish a ROM-level recovery
path or safe interrupted-write behavior. See `../TODO_aug2.md` for the open
questions.
