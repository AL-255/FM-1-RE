# Stock firmware images

This directory keeps immutable stock firmware inputs separate from the custom
firmware source and derived analysis databases.

| directory | bundle label | product marker | application size | status |
|---|---|---|---:|---|
| `v13/` | 2026-07-03 V13 baseline | `FM-1_009` | 583068 bytes | fully indexed under `Opus4.8/` and `Kimi-K3/analysis/` |
| `v14/` | 2026-07-06 M-UPGRADE bundle | `FM-1_014` | 584956 bytes | extracted and linearly disassembled; function mapping is pending |

Each version keeps the original `.fwsc`, reproducible extraction scripts, and
the unpacked JLFS files together. Generated analysis that compares versions or
describes executable behavior belongs in `Kimi-K3/analysis/`, not beside the
immutable inputs.
