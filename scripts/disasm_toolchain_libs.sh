#!/usr/bin/env bash
# Disassemble all JieLi toolchain libraries (all ABI variants) with the vendor
# objdump into analysis/libdis/<variant>_<lib>.txt
set -euo pipefail
HERE="$(cd "$(dirname "$0")/.." && pwd)"
TC=/home/yukidama/JL/toolchain/toolchain/jieli-linux-toolchains-20250324.1
OBJDUMP="$TC/common/bin/objdump"
OUT="$HERE/analysis/libdis"
mkdir -p "$OUT"

for dir in "$TC"/pi32v2/lib "$TC"/pi32v2/lib/r{1,2,3,4,5}{,-large}; do
  [ -d "$dir" ] || continue
  var=$(basename "$dir")
  [ "$var" = "lib" ] && var="base"
  for a in "$dir"/*.a; do
    [ -f "$a" ] || continue
    lib=$(basename "$a" .a)
    dst="$OUT/${var}_${lib}.txt"
    [ -f "$dst" ] && continue
    "$OBJDUMP" -d "$a" > "$dst" 2>/dev/null || rm -f "$dst"
  done
done
ls "$OUT" | wc -l
