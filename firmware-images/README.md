# Stock firmware images

This directory keeps stock firmware inputs and version-specific extraction
artifacts separate from the repository-wide analysis under `analysis/`.

| directory | bundle label | product marker | application size | status |
|---|---|---|---:|---|
| `v13/` | 2026-07-03 V13 baseline | `FM-1_009` | 583068 bytes | indexed under `analysis/` and `docs/` |
| `v14/` | 2026-07-06 M-UPGRADE bundle | `FM-1_014` | 584956 bytes | extracted, linearly disassembled, and indexed under `v14/analysis/` |

Each version keeps the original `.fwsc`, reproducible extraction scripts, and
the unpacked JLFS files together. V14 also retains its version-local function
and string indexes. Cross-version findings and behavioral conclusions belong
under the top-level `analysis/` and `docs/` directories.
