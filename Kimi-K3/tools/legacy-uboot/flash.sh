#!/usr/bin/env bash
# FM-1 demo firmware flasher — raw alternative via jl-uboot-tool.
#
# This reference-only script flashes build/official/jl_isd.fw
# directly at flash offset 0 with the raw-SCSI UBOOT protocol — use it when
# the device enumerates as a plain "UBOOT" mass-storage device and
# isd_download's USB protocol is not usable.
#
# Always dump first. Recovery = restore the dump.
set -euo pipefail

HERE="$(cd "$(dirname "$0")" && pwd)"
ROOT="$(cd "$HERE/../.." && pwd)"
REPO="$(cd "$ROOT/.." && pwd)"
JLTOOL="$REPO/3rd-party/jl-uboot-tool/jluboottool.py"
OUT="$ROOT/build/official"
BACKUPDIR="$ROOT/backups"
CHIP="${FM1_CHIP:-br22}"
FLASH_SIZE=$((0x100000))

find_device() {
  if [ -n "${FM1_DEVICE:-}" ]; then echo "$FM1_DEVICE"; return; fi
  python3 "$(dirname "$JLTOOL")/jldevfind.py" 2>/dev/null | awk '{print $1; exit}'
}
run_tool() { python3 "$JLTOOL" --chip "$CHIP" --device "$(find_device)" "$@"; }

cmd_probe() {
  python3 "$(dirname "$JLTOOL")/jldevfind.py" || true
  echo "Device: $(find_device || echo none)"
}

cmd_dump() {
  mkdir -p "$BACKUPDIR"
  local out="$BACKUPDIR/fm1_stock_$(date +%Y%m%d_%H%M%S).bin"
  echo "Reading $((FLASH_SIZE)) bytes of flash into $out ..."
  run_tool read 0 "$FLASH_SIZE" "$out"
  echo "Backup written: $out (keep it safe — it is your recovery image)"
}

cmd_write() {
  local img="$OUT/jl_isd.fw"
  local latest
  latest=$(ls -t "$BACKUPDIR"/fm1_stock_*.bin 2>/dev/null | head -1 || true)
  [ -n "$latest" ] || { echo "ERROR: run 'tools/legacy-uboot/flash.sh dump' first." >&2; exit 1; }
  [ -f "$img" ] || { echo "ERROR: $img missing — run: tools/legacy-uboot/upload.sh build" >&2; exit 1; }
  echo "Using backup $latest as safety net."
  echo "Erasing flash..."
  run_tool erase 0 "$FLASH_SIZE"
  echo "Writing $img at 0x0 ..."
  run_tool write 0 "$img"
  echo "Done. Power-cycle the FM-1."
}

cmd_restore() {
  local img="${1:?usage: tools/legacy-uboot/flash.sh restore BACKUP.bin}"
  [ -f "$img" ] || { echo "ERROR: $img not found" >&2; exit 1; }
  run_tool erase 0 "$FLASH_SIZE"
  run_tool write 0 "$img"
  echo "Stock image restored. Power-cycle the FM-1."
}

case "${1:-}" in
  probe)   cmd_probe ;;
  dump)    cmd_dump ;;
  write)   cmd_write ;;
  restore) shift; cmd_restore "$@" ;;
  *) echo "usage: tools/legacy-uboot/flash.sh {probe|dump|write|restore FILE}" >&2; exit 1 ;;
esac
