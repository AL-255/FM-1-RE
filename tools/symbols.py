#!/usr/bin/env python3
"""Emit demo.map.json: demo entry-point addresses for the image builder."""
import json, re, sys

nm_path, out_path = sys.argv[1], sys.argv[2]
syms = {}
for ln in open(nm_path, errors='replace'):
    m = re.match(r'^([0-9a-fA-F]+)\s+[tTdDrRbB]\s+(\S+)$', ln.strip())
    if m:
        syms[m.group(2)] = int(m.group(1), 16)
want = ["demo_install", "demo_render", "demo_midi_note", "demo_midi_pc",
        "demo_dac_cb", "demo_midi_parse", "demo_hooks_install",
        "__tramp_usr_app_task", "__tramp_midi",
        "__data_lma", "__data_start", "__data_end", "__bss_start", "__bss_end"]
out = {w: syms.get(w) for w in want}
missing = [w for w, v in out.items() if v is None]
if missing:
    sys.exit(f"missing symbols: {missing}")
json.dump(out, open(out_path, "w"), indent=1)
print("entry symbols:", {k: hex(v) for k, v in out.items() if v})
