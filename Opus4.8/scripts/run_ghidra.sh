#!/usr/bin/env bash
# Reproduce: disassembly, function-entry ID, round-trip test, byte-identical reassembly.
# Requires scripts/setup_reference.sh to have run first.
set -euo pipefail
HERE="$(cd "$(dirname "$0")/.." && pwd)"
REPO="$(cd "$HERE/.." && pwd)"
G=$(ls -d "$HERE"/reference/ghidra_*_PUBLIC | head -1)
APP="$REPO/firmware-images/v13/raw_fw/FM-1.fwsc_unpack/files/app.bin"
PROJ="$HERE/ghidra/proj"; SCR="$HERE/ghidra/scripts"
mkdir -p "$PROJ" "$HERE/decomp" "$HERE/reasm"

hl() { "$G/support/analyzeHeadless" "$PROJ" "$1" \
        -import "$APP" -processor "pi32v2:LE:32:default" \
        -loader BinaryLoader -loader-baseAddr 0x02000000 \
        -scriptPath "$SCR" -preScript "$2" -noanalysis -deleteProject; }

echo "== linear-sweep disassembly =="
ASM_OUT="$HERE/decomp/app_pi32v2_linear.asm" hl sweep LinearSweep.java

echo "== function entries (call-target harvest) =="
python3 "$SCR/../../scripts/harvest_entries.py" "$HERE/decomp/app_pi32v2_linear.asm" "$HERE/decomp"

echo "== round-trip assemble/compare =="
MISMATCH_OUT="$HERE/decomp/roundtrip_mismatches.txt" hl rt RoundTrip.java

echo "== byte-identical reassembly =="
REASM_OUT="$HERE/reasm/app_reassembled.bin" hl reasm ReassembleFirmware.java
cmp "$APP" "$HERE/reasm/app_reassembled.bin" \
  && echo "*** app_reassembled.bin is BYTE-IDENTICAL to original app.bin ***"
