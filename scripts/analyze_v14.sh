#!/bin/sh
set -eu

ROOT=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
IMAGE="$ROOT/firmware-images/v14/raw_fw/FM-1.fwsc_unpack/files/app.bin"
OBJDUMP="$ROOT/firmware-images/v14/decomp/app_pi32v2_objdump.txt"
OUT="$ROOT/firmware-images/v14/analysis"

mkdir -p "$OUT"
python3 "$ROOT/scripts/extract_binary_strings.py" \
    "$IMAGE" "$OUT/strings_raw.txt"
python3 "$ROOT/scripts/build_funcdb.py" \
    "$OBJDUMP" "$OUT/strings_raw.txt" \
    --base 0x02000000 --entry 0x020000A0 --out-dir "$OUT"

echo "V14 function and string indexes regenerated in $OUT"
