#!/bin/sh
set -eu

ROOT=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
OUT="$ROOT/analysis/device/ota-loader"
TOOLCHAIN=${JIELI_TOOLCHAIN:-/home/yukidama/JL/toolchain/toolchain/jieli-linux-toolchains-20250324.1}
CC="$TOOLCHAIN/pi32v2/bin/cc"
OBJDUMP="$TOOLCHAIN/common/bin/objdump"

python3 "$ROOT/scripts/extract_ota_loader.py"
python3 "$ROOT/scripts/extract_binary_strings.py" \
    "$OUT/usb_hid_ota.bin" "$OUT/strings_raw.txt"

(
    cd "$OUT"
    printf '\t.section .fw,"ax",@progbits\n_fw:\n\t.incbin "usb_hid_ota.bin"\n' \
        > usb_hid_ota.wrap.S
    "$CC" -c usb_hid_ota.wrap.S -o usb_hid_ota.o
    "$OBJDUMP" -D usb_hid_ota.o > usb_hid_ota_objdump.txt
    rm -f usb_hid_ota.wrap.S usb_hid_ota.o
)

python3 "$ROOT/scripts/build_funcdb.py" \
    "$OUT/usb_hid_ota_objdump.txt" "$OUT/strings_raw.txt" \
    --base 0x01C0A800 --entry 0x01C0A800 --out-dir "$OUT"

echo "Vendor loader artifacts regenerated in $OUT"
echo "Run scripts/run_ghidra_loader.sh separately for the corroborative Ghidra listing."
