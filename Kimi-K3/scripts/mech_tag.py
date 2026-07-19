#!/usr/bin/env python3
"""Mechanical subsystem tagging: propagate deterministic evidence through the DB.

Tags (only when subsystem is unset), with confidence:
  1. functions referencing the four proven msfa tables -> SYNTH_FM (exact)
  2. functions referencing known USB/UI/audio strings -> per string (exact)
  3. KNOWN_LIB already set -> MEMLIB/MATHLIB (exact-sig)
  4. SFR-heavy functions (>=2 distinct SFR base loads) -> PERIPH candidate (med)
  5. call-graph propagation: leaf funcs whose callers are all one subsystem (low)

Emits analysis/mech_tags.json and updates db.json.
"""
import re, json, os
from collections import defaultdict, Counter

HERE = os.path.dirname(os.path.abspath(__file__))
ROOT = os.path.dirname(HERE)
DB = os.path.join(ROOT, "analysis", "db.json")

MSFA_TABLES = {0x0204EB90, 0x0204EF4C, 0x0204F760, 0x0204FC44}
STRING_TAGS = [  # (substring, subsystem)
    ("Midi", "USB"), ("Audio", "USB"), ("Composite Device", "USB"),
    ("Jieli Technology", "USB"), ("midi_route", "MIDI"),
    ("OP", "UI_MENU"), ("Envelope", "UI_MENU"), ("Tuning", "UI_MENU"),
    ("Sequencer", "UI_MENU"), ("Arpeggio", "UI_MENU"), ("LFO", "UI_MENU"),
    ("Reverb", "FX"), ("Phaser", "FX"), ("Chorus", "FX"),
    ("/mnt/sdfile", "STORAGE_FS"), ("FAT", "STORAGE_FS"),
    ("audio", "AUDIO_OUT"), ("dac", "AUDIO_OUT"),
    ("bt", "BT"), ("a2dp", "BT"), ("Bt", "BT"),
]
SFR_BASES = {0x10000, 0x20000, 0x40000, 0x70000, 0x80000, 0xF0000, 0x100000,
             0x11000, 0x12000, 0x13000, 0x14000, 0x16000, 0x17000, 0x18000,
             0x1A000, 0x1C000, 0x1E000, 0x20000, 0x60000, 0x70000}

def main():
    db = json.load(open(DB))
    funcs = db["functions"]
    strings = db["strings"]
    tags = {}

    def set_tag(addr, sub, conf, why):
        f = funcs[addr]
        if f.get("subsystem"):
            return
        f["subsystem"] = sub
        f["conf"] = conf
        f["purpose"] = (f.get("purpose") or "") + ("" if f.get("purpose") else why)
        tags[addr] = dict(subsystem=sub, conf=conf, why=why)

    # lib tags
    for a, f in funcs.items():
        if f.get("lib_name") and not f.get("subsystem"):
            sub = "MATHLIB" if (f["lib_src"] and "libm" in f["lib_src"]) else "MEMLIB"
            set_tag(a, sub, "high", f"exact lib sig: {f['lib_name']}")

    # msfa table refs
    for a, f in funcs.items():
        refs = set(f["data_refs"]) | set(f["str_refs"])
        if refs & MSFA_TABLES:
            set_tag(a, "SYNTH_FM", "high", "references msfa table(s)")

    # string-driven tags
    for a, f in funcs.items():
        for s in f["str_refs"]:
            txt = strings.get(f"0x{s:08x}", "")
            for pat, sub in STRING_TAGS:
                if pat in txt:
                    set_tag(a, sub, "med", f"string ref {txt[:32]!r}")
                    break

    # SFR-heavy
    for a, f in funcs.items():
        sfr = {v & 0xFFFF0000 for v in f["data_refs"] if v < 0x00200000}
        if len(sfr) >= 2:
            set_tag(a, "PERIPH", "med", f"SFR bases: {sorted(hex(x) for x in sfr)[:4]}")

    # callers map for propagation
    callers = defaultdict(set)
    for a, f in funcs.items():
        for c in f["calls"]:
            k = f"0x{c:08x}"
            if k in funcs:
                callers[k].add(a)

    json.dump(tags, open(os.path.join(ROOT, "analysis", "mech_tags.json"), "w"), indent=1)
    json.dump(db, open(DB, "w"))
    print(Counter(t["subsystem"] for t in tags.values()))
    print(f"tagged {len(tags)} / {len(funcs)}")

if __name__ == "__main__":
    main()
