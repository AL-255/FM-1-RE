#!/usr/bin/env bash
# Fetch reverse-engineering tooling + reference sources into Opus4.8/reference/
# (git-ignored). Reproduces the environment used for disassembly.
set -euo pipefail
HERE="$(cd "$(dirname "$0")/.." && pwd)"
REF="$HERE/reference"
mkdir -p "$REF"
cd "$REF"

# 1. kagaimiq JieLi docs + Ghidra pi32/pi32v2/q32s processor module
[ -d jielie ]       || git clone --depth 1 https://github.com/kagaimiq/jielie.git
[ -d ghidra-jieli ] || git clone --depth 1 https://github.com/kagaimiq/ghidra-jieli.git

# 2. DX7 / msfa reference cores (the firmware's synth engine lineage)
[ -d dexed ]        || git clone --depth 1 https://github.com/asb2m10/dexed.git
[ -d Synth_Dexed ]  || git clone --depth 1 https://codeberg.org/dcoredump/Synth_Dexed.git

# 3. Ghidra (public release)
if [ ! -d ghidra_*_PUBLIC ]; then
  URL=$(curl -sL https://api.github.com/repos/NationalSecurityAgency/ghidra/releases/latest \
        | grep -oE '"browser_download_url": *"[^"]*_PUBLIC_[^"]*\.zip"' | head -1 | cut -d'"' -f4)
  echo ">> downloading $URL"
  curl -fL -o ghidra.zip "$URL"
  unzip -q ghidra.zip
fi
G=$(ls -d "$REF"/ghidra_*_PUBLIC | head -1)

# 4. install + compile the JieLi SLEIGH module
mkdir -p "$G/Ghidra/Processors/JieLi"
cp -r ghidra-jieli/data "$G/Ghidra/Processors/JieLi/"
cp ghidra-jieli/Module.manifest "$G/Ghidra/Processors/JieLi/"
chmod +x "$G/support/sleigh"
"$G/support/sleigh" -a "$G/Ghidra/Processors/JieLi/data/languages"
echo ">> reference environment ready under $REF"
