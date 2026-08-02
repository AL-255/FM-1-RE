#!/bin/sh
set -eu

SCRIPT_DIR=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
REPO=$(CDPATH= cd -- "$SCRIPT_DIR/../../.." && pwd)

python3 "$REPO/3rd-party/jl-misctools/firmware/fwunpack_newfw.py" \
  "$SCRIPT_DIR/FM-1.fwsc"
