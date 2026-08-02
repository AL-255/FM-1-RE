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

# chip/download parameters (BR22 / AC693N; boot SPL at flash 0x120)
DEV="${FM1_DEV:-br22}"
BOOT="${FM1_BOOT:-0x120}"
WAIT="${FM1_WAIT:-300}"

build() {
  echo ">> building firmware blob (pi32v2)"
  make -C "$ROOT/firmware" build/demo.bin >/dev/null
  echo ">> staging official image files"
  python3 "$HERE/build_official.py"
}

upload() {
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
  "")     build; upload ;;
  *) echo "usage: tools/legacy-uboot/upload.sh [build|upload] [extra isd_download args]" >&2; exit 1 ;;
esac
