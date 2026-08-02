#!/usr/bin/env bash
# FM-1 demo firmware upload — OFFICIAL JieLi method (isd_download).
#
# Builds the modified firmware (patched app.bin + demo blob) and uploads it
# to the FM-1 over USB with JieLi's own isd_download tool, which re-packs,
# encrypts and flashes the JLFS image via the chip's USB download protocol.
#
# The FM-1 must be in an externally forced UBOOT/update mode. No working entry
# method is known for the retail device. If no device is present, isd_download
# just packages build/official/
# jl_isd.fw without flashing (safe to run any time to build the image).
set -euo pipefail

HERE="$(cd "$(dirname "$0")" && pwd)"
ROOT="$(cd "$HERE/../.." && pwd)"
PB=/home/yukidama/JL/toolchain/post-build/jieli-linux-post-build-tools-20260129.1
ISD="$PB/isd_download"
OUT="$ROOT/build/official"

# The correct isd_download identifiers for AC791N/WL82 are not yet verified.
DEV="${FM1_DEV:-}"
BOOT="${FM1_BOOT:-}"
WAIT="${FM1_WAIT:-300}"

require_unverified_target() {
  [ "${FM1_ALLOW_UNVERIFIED_ROM_FLASH:-}" = "AC791N" ] || {
    echo "ERROR: FM-1 is AC791N/WL82; this legacy ROM path is unverified." >&2
    echo "Set FM1_ALLOW_UNVERIFIED_ROM_FLASH=AC791N only on recoverable hardware." >&2
    exit 1
  }
  [ -n "$DEV" ] || { echo "ERROR: set an independently verified FM1_DEV." >&2; exit 1; }
  [ -n "$BOOT" ] || { echo "ERROR: set an independently verified FM1_BOOT." >&2; exit 1; }
}

build() {
  echo ">> building firmware blob (pi32v2)"
  make -C "$ROOT/firmware" build/demo.bin >/dev/null
  echo ">> staging official image files"
  python3 "$HERE/build_official.py"
}

upload() {
  require_unverified_target
  echo ">> uploading with JieLi isd_download (official method)"
  cd "$OUT"
  "$ISD" -tonorflash -dev "$DEV" -boot "$BOOT" -div8 -wait "$WAIT" \
      -uboot uboot.boot -app app.bin cfg_tool.bin -res cfg "$@"
  echo ">> done. If a device was attached, it was flashed; power-cycle it."
  echo "   Otherwise the image was only packaged to $OUT/jl_isd.fw"
}

case "${1:-}" in
  build)  build ;;
  upload) upload "${@:2}" ;;
  "")     build; echo ">> build only; device upload requires the explicit 'upload' command" ;;
  *) echo "usage: tools/legacy-uboot/upload.sh [build|upload] [extra isd_download args]" >&2; exit 1 ;;
esac
