# Stock firmware images

This directory keeps immutable stock firmware inputs separate from derived
analysis databases and generated output.

| directory | bundle label | product marker | application size | status |
|---|---|---|---:|---|
| `v13/` | 2026-07-03 V13 baseline | `FM-1_009` | 583068 bytes | indexed under `analysis/` and `docs/` |
| `v14/` | 2026-07-06 M-UPGRADE bundle | `FM-1_014` | 584956 bytes | extracted and linearly disassembled; function mapping is pending |

Each version keeps the original `.fwsc`, reproducible extraction scripts, and
the unpacked JLFS files together. Generated analysis that compares versions or
describes executable behavior belongs in `analysis/`, not beside the
immutable inputs.
