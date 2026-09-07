#!/bin/sh
# Download the V15 package from M-VAVE's CDN and verify it. The URL is not
# versioned; this refuses anything but the 2026-07-30 file described in ../README.md.
set -eu

URL="https://yms-file-store.oss-cn-hongkong.aliyuncs.com/software/firmware/FM-1.fwsc"
SHA="db1642b2b6fa5c2cccb11ffd13878068bb28601678d3644049f99dc40e7edb8a"
SCRIPT_DIR=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
OUT="$SCRIPT_DIR/FM-1.fwsc"

curl -fsSL -o "$OUT.download" "$URL"
if command -v sha256sum >/dev/null 2>&1; then
    got=$(sha256sum "$OUT.download" | cut -d' ' -f1)
else
    got=$(shasum -a 256 "$OUT.download" | cut -d' ' -f1)
fi
if [ "$got" != "$SHA" ]; then
    echo "downloaded file has SHA-256 $got, not the V15 package this directory documents" >&2
    rm -f "$OUT.download"
    exit 1
fi
mv "$OUT.download" "$OUT"
echo "wrote $OUT (SHA-256 verified)"
