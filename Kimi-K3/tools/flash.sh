#!/usr/bin/env bash
# FM-1 demo firmware flasher (dump-first, recoverable).
#
# Usage:
#   tools/flash.sh probe            find the JieLi device (UBOOT mode)
#   tools/flash.sh dump             read the full 1 MiB flash to a timestamped backup
#   tools/flash.sh write            flash the custom-synth demo (needs a backup first)
#   tools/flash.sh restore FILE     write a previous backup back to the device
#
# Entering UBOOT mode: power the FM-1 on while holding its encoder/button
# (or use the vendor update tool once); it enumerates as a USB storage device
# named "UBOOT..." — see tools/README.md for details and recovery.
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
JLTOOL="/home/yukidama/JL/FM-1/3rd-party/jl-uboot-tool/jluboottool.py"
BUILD="$ROOT/build"
BACKUPDIR="$ROOT/backups"
CHIP="${FM1_CHIP:-br22}"
FLASH_SIZE=$((0x100000))          # 1 MiB
BLOB_ADDR=$((0xEA000))            # demo blob flash offset (USR region)

have() { command -v "$1" >/dev/null 2>&1; }

find_device() {
  if [ -n "${FM1_DEVICE:-}" ]; then echo "$FM1_DEVICE"; return; fi
  python3 "$(dirname "$JLTOOL")/jldevfind.py" 2>/dev/null | awk '{print $1; exit}'
}

run_tool() {
  python3 "$JLTOOL" --chip "$CHIP" --device "$(find_device)" "$@"
}

cmd_probe() {
  echo "Looking for JieLi device (UBOOT mode)..."
  python3 "$(dirname "$JLTOOL")/jldevfind.py" || true
  echo "Device: $(find_device || echo none)"
}

cmd_dump() {
  mkdir -p "$BACKUPDIR"
  local out="$BACKUPDIR/fm1_stock_$(date +%Y%m%d_%H%M%S).bin"
  echo "Reading $((FLASH_SIZE)) bytes of flash into $out ..."
  run_tool read 0 "$FLASH_SIZE" "$out"
  echo "Backup written: $out (keep this file safe — it is your recovery image)"
}

cmd_write() {
  local latest
  latest=$(ls -t "$BACKUPDIR"/fm1_stock_*.bin 2>/dev/null | head -1 || true)
  if [ -z "$latest" ]; then
    echo "ERROR: no backup found in $BACKUPDIR — run 'tools/flash.sh dump' first." >&2
    exit 1
  fi
  [ -f "$BUILD/fm1_demo_flash.bin" ] || { echo "ERROR: $BUILD/fm1_demo_flash.bin missing — run: python3 tools/build_image.py" >&2; exit 1; }
  [ -f "$BUILD/demo_blob.bin" ] || { echo "ERROR: $BUILD/demo_blob.bin missing — run: python3 tools/build_image.py" >&2; exit 1; }
  echo "Using backup $latest as safety net."
  echo "Erasing app area + demo blob region..."
  run_tool erase 0 "$FLASH_SIZE"
  echo "Writing app area..."
  run_tool write 0 "$BUILD/fm1_demo_flash.bin"
  printf -v blobhex '0x%x' "$BLOB_ADDR"
  echo "Writing demo blob at $blobhex..."
  run_tool write "$BLOB_ADDR" "$BUILD/demo_blob.bin"
  echo "Done. Power-cycle the FM-1. It should boot into the custom synth demo"
  echo "(autoplay melody after ~4 s idle; USB-MIDI notes/programs work as usual)."
}

cmd_restore() {
  local img="${1:?usage: tools/flash.sh restore BACKUP.bin}"
  [ -f "$img" ] || { echo "ERROR: $img not found" >&2; exit 1; }
  echo "Erasing flash and restoring $img ..."
  run_tool erase 0 "$FLASH_SIZE"
  run_tool write 0 "$img"
  echo "Stock image restored. Power-cycle the FM-1."
}

case "${1:-}" in
  probe)   cmd_probe ;;
  dump)    cmd_dump ;;
  write)   cmd_write ;;
  restore) shift; cmd_restore "$@" ;;
  *) echo "usage: tools/flash.sh {probe|dump|write|restore FILE}" >&2; exit 1 ;;
esac
