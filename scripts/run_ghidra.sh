#!/usr/bin/env bash
# Reproduce: disassembly, function-entry ID, round-trip test, byte-identical reassembly.
# Requires scripts/setup_reference.sh to have run first.
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
G=$(ls -d "$ROOT"/reference/ghidra_*_PUBLIC | head -1)
APP="$ROOT/firmware-images/v13/raw_fw/FM-1.fwsc_unpack/files/app.bin"
PROJ="$ROOT/ghidra/proj"; SCR="$ROOT/ghidra/scripts"
DECOMP="$ROOT/analysis/disassembly"; REASM="$ROOT/analysis/reassembly"
mkdir -p "$PROJ" "$DECOMP" "$REASM"

hl() { "$G/support/analyzeHeadless" "$PROJ" "$1" \
        -import "$APP" -processor "pi32v2:LE:32:default" \
        -loader BinaryLoader -loader-baseAddr 0x02000000 \
        -scriptPath "$SCR" -preScript "$2" -noanalysis -deleteProject; }

echo "== linear-sweep disassembly =="
ASM_OUT="$DECOMP/app_pi32v2_linear.asm" hl sweep LinearSweep.java

echo "== function entries (call-target harvest) =="
python3 "$ROOT/scripts/harvest_entries.py" "$DECOMP/app_pi32v2_linear.asm" "$DECOMP"

echo "== round-trip assemble/compare =="
MISMATCH_OUT="$DECOMP/roundtrip_mismatches.txt" hl rt RoundTrip.java

echo "== byte-identical reassembly =="
REASM_OUT="$REASM/app_reassembled.bin" hl reasm ReassembleFirmware.java
cmp "$APP" "$REASM/app_reassembled.bin" \
  && echo "*** app_reassembled.bin is BYTE-IDENTICAL to original app.bin ***"
