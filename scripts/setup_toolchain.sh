#!/usr/bin/env bash
# Set up the JieLi (pi32) Linux toolchain + post-build tools OUTSIDE the git repo.
# Only this script is version-controlled; the downloaded toolchain is not.
#
# Sources (official JieLi package manager redirects):
#   Tool chain (Linux):   https://pkgman.jieliapp.com/s/linux-toolchain
#   Post-build tools:     https://pkgman.jieliapp.com/s/linux-postbuild
#   Docs:                 https://doc.zh-jieli.com/Tools/zh-cn/dev_tools/build_download/index.html
set -euo pipefail

DEST="${1:-/home/yukidama/JL/toolchain}"
TC_URL="https://pkgman.jieliapp.com/s/linux-toolchain"
PB_URL="https://pkgman.jieliapp.com/s/linux-postbuild"

mkdir -p "$DEST/downloads"
cd "$DEST/downloads"

fetch() {  # url -> prints resolved filename on stdout; progress on stderr
  local url="$1"
  local fname
  fname="$(curl -sIL "$url" | awk -F'/' 'tolower($0) ~ /^location:/ {print $NF}' | tr -d "\r" | tail -1)"
  [ -n "$fname" ] || { echo "could not resolve filename for $url" >&2; exit 1; }
  if [ ! -f "$fname" ]; then
    echo ">> downloading $fname" >&2
    curl -fL --retry 3 -o "$fname" "$url" >&2
  else
    echo ">> $fname already present, skipping download" >&2
  fi
  echo "$fname"
}

TC_FILE="$(fetch "$TC_URL")"
PB_FILE="$(fetch "$PB_URL")"

echo ">> extracting toolchain -> $DEST/toolchain"
mkdir -p "$DEST/toolchain"
tar -xf "$TC_FILE" -C "$DEST/toolchain"

echo ">> extracting post-build tools -> $DEST/post-build"
mkdir -p "$DEST/post-build"
tar -xf "$PB_FILE" -C "$DEST/post-build"

echo
echo "== done. Toolchain layout: =="
find "$DEST/toolchain" -maxdepth 3 -type d | head -40
echo
echo "== cross-compiler binaries found: =="
find "$DEST/toolchain" -type f \( -name '*gcc*' -o -name '*clang*' -o -name '*-as' -o -name '*-ld' -o -name 'cc1*' \) | head -40

cat <<NOTE

Add to your shell to use the toolchain:
  export JL_TOOLCHAIN="$DEST/toolchain"
  export PATH="\$JL_TOOLCHAIN/\$(basename \$(find \$JL_TOOLCHAIN -name '*gcc' -printf '%h\n' | head -1)):\$PATH"
NOTE
