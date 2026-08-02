#!/bin/sh
set -eu

ROOT=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
OUT="$ROOT/analysis/device/ota-loader"
SCR="$ROOT/ghidra/scripts"
PROJECTS="$ROOT/ghidra"

if [ -n "${GHIDRA_HOME:-}" ]; then
    GHIDRA=$GHIDRA_HOME
else
    GHIDRA=
    for candidate in "$ROOT"/reference/ghidra_*_PUBLIC; do
        if [ -f "$candidate/Ghidra/Processors/JieLi/data/languages/pi32v2.sla" ]; then
            GHIDRA=$candidate
            break
        fi
    done
fi

if [ -z "$GHIDRA" ]; then
    echo "No Ghidra installation with the JieLi pi32v2 processor was found." >&2
    echo "Set GHIDRA_HOME or run scripts/setup_reference.sh." >&2
    exit 1
fi

mkdir -p "$OUT" /tmp/fm1-ghidra-config /tmp/fm1-ghidra-cache
export XDG_CONFIG_HOME=/tmp/fm1-ghidra-config
export XDG_CACHE_HOME=/tmp/fm1-ghidra-cache
LOG_DIR=$(mktemp -d /tmp/fm1-ghidra-loader.XXXXXX)
trap 'rm -rf "$LOG_DIR"' EXIT HUP INT TERM

run_headless() {
    log=$1
    shift
    if "$@" >"$log" 2>&1; then
        :
    else
        cat "$log"
        return 1
    fi
    cat "$log"
    if grep -q 'SCRIPT ERROR' "$log"; then
        echo "Ghidra reported a script error despite returning success." >&2
        return 1
    fi
}

export ASM_OUT="$OUT/usb_hid_ota_linear.asm"
run_headless "$LOG_DIR/sweep.log" \
    "$GHIDRA/support/analyzeHeadless" "$PROJECTS" ota-loader-sweep \
    -import "$OUT/usb_hid_ota.bin" \
    -processor pi32v2:LE:32:default \
    -loader BinaryLoader -loader-baseAddr 0x01C0A800 \
    -scriptPath "$SCR" -preScript LinearSweep.java \
    -noanalysis -deleteProject

python3 "$ROOT/scripts/harvest_entries.py" \
    "$OUT/usb_hid_ota_linear.asm" "$OUT" 0x01C0A800 \
    usb_hid_ota_annotated.asm

export TARGETS="$OUT/finish_targets.txt"
export DECOMP_OUT="$OUT/finish_decomp.c"
run_headless "$LOG_DIR/targets.log" \
    "$GHIDRA/support/analyzeHeadless" "$PROJECTS" ota-loader-targets \
    -import "$OUT/usb_hid_ota.bin" \
    -processor pi32v2:LE:32:default \
    -loader BinaryLoader -loader-baseAddr 0x01C0A800 \
    -scriptPath "$SCR" -postScript DecompileTargets.java \
    -noanalysis -deleteProject

echo "Ghidra loader artifacts regenerated in $OUT"
