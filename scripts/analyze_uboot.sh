#!/bin/sh
set -eu

ROOT=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
OUT="$ROOT/analysis/device/uboot"
IMAGE="$ROOT/firmware-images/v14/raw_fw/FM-1.fwsc_unpack/top/uboot.boot"
SDK=${AC79_SDK:-/home/yukidama/JL/fw-AC79_AIoT_SDK}
SDK_TAG=${AC79_SDK_TAG:-AC79NN_SDK_V1.1.9_2023-08-01}
TOOLCHAIN=${JIELI_TOOLCHAIN:-/home/yukidama/JL/toolchain/toolchain/jieli-linux-toolchains-20250324.1}
CC="$TOOLCHAIN/pi32v2/bin/cc"
OBJDUMP="$TOOLCHAIN/common/bin/objdump"

mkdir -p "$OUT"
python3 "$ROOT/scripts/extract_binary_strings.py" \
    "$IMAGE" "$OUT/strings_raw.txt"

(
    cd "$OUT"
    printf '\t.section .fw,"ax",@progbits\n_fw:\n\t.incbin "%s"\n' "$IMAGE" \
        > uboot.wrap.S
    "$CC" -c uboot.wrap.S -o uboot.o
    "$OBJDUMP" -D uboot.o > uboot_objdump.txt
    rm -f uboot.wrap.S uboot.o
)

python3 "$ROOT/scripts/build_funcdb.py" \
    "$OUT/uboot_objdump.txt" "$OUT/strings_raw.txt" \
    --base 0x01C02000 --entry 0x01C02000 --out-dir "$OUT"

TAG_HASH=$(git -C "$SDK" show "$SDK_TAG:cpu/wl82/tools/uboot.boot" | sha256sum | cut -d' ' -f1)
IMAGE_HASH=$(sha256sum "$IMAGE" | cut -d' ' -f1)
if [ "$TAG_HASH" != "$IMAGE_HASH" ]; then
    echo "ERROR: $SDK_TAG UBOOT does not match stock FM-1 UBOOT" >&2
    exit 1
fi

DEBUG="$OUT/debug"
mkdir -p "$DEBUG"
git -C "$SDK" show "$SDK_TAG:cpu/wl82/tools/uboot.boot_debug" \
    > "$DEBUG/uboot_debug.bin"
python3 "$ROOT/scripts/extract_binary_strings.py" \
    "$DEBUG/uboot_debug.bin" "$DEBUG/strings_raw.txt"
(
    cd "$DEBUG"
    printf '\t.section .fw,"ax",@progbits\n_fw:\n\t.incbin "uboot_debug.bin"\n' \
        > uboot_debug.wrap.S
    "$CC" -c uboot_debug.wrap.S -o uboot_debug.o
    "$OBJDUMP" -D uboot_debug.o > uboot_debug_objdump.txt
    rm -f uboot_debug.wrap.S uboot_debug.o uboot_debug.bin
)
python3 "$ROOT/scripts/build_funcdb.py" \
    "$DEBUG/uboot_debug_objdump.txt" "$DEBUG/strings_raw.txt" \
    --base 0x01C02000 --entry 0x01C02000 --out-dir "$DEBUG"

echo "Stock and paired-debug UBOOT artifacts regenerated in $OUT"
