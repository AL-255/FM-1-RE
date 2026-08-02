#!/usr/bin/env python3
"""Aggregate per-shard classifications into db.json and emit the function index.

Outputs:
  analysis/db.json           (updated in place: subsystem/name/purpose/conf per func)
  analysis/function_index.csv
  docs/function-index.md     (full index grouped by subsystem)
"""
import json, glob, os, csv
from collections import Counter, defaultdict

HERE = os.path.dirname(os.path.abspath(__file__))
ROOT = os.path.dirname(HERE)
DB = os.path.join(ROOT, "analysis", "db.json")

def main():
    db = json.load(open(DB))
    funcs = db["functions"]

    n = 0
    for p in sorted(glob.glob(os.path.join(ROOT, "analysis", "classified", "*.json"))):
        for e in json.load(open(p)):
            a = e["addr"].lower()
            f = funcs.get(a)
            if not f:
                continue
            f["subsystem"] = e.get("subsystem", "UNKNOWN")
            f["purpose"] = e.get("purpose", "")
            f["conf"] = e.get("conf", "low")
            if e.get("name"):
                f["name"] = e["name"]
            n += 1
    print(f"merged {n} classifications")

    # callers count
    callers = Counter()
    for a, f in funcs.items():
        for c in f["calls"]:
            callers[f"0x{c:08x}"] += 1

    rows = []
    for a, f in sorted(funcs.items(), key=lambda kv: int(kv[0], 16)):
        rows.append(dict(addr=a, name=f.get("name") or f.get("lib_name") or "",
                         subsystem=f.get("subsystem") or "UNKNOWN",
                         conf=f.get("conf") or "", size=f["size"], ninsn=f["ninsn"],
                         callers=callers.get(a, 0), purpose=f.get("purpose", "")))

    with open(os.path.join(ROOT, "analysis", "function_index.csv"), "w", newline="") as g:
        w = csv.DictWriter(g, fieldnames=list(rows[0]), lineterminator="\n")
        w.writeheader()
        w.writerows(rows)

    subs = defaultdict(list)
    for r in rows:
        subs[r["subsystem"]].append(r)

    order = ["SYS", "RTOS", "PERIPH", "INPUT", "UI_MENU", "UI_DISPLAY", "MIDI",
             "USB", "SYNTH_FM", "FX", "AUDIO_OUT", "STORAGE_FS", "STORAGE_PATCH",
             "BT", "POWER", "SECURITY", "MEMLIB", "MATHLIB", "APP", "UNKNOWN"]
    out = ["# FM-1 function index (2062 functions)",
           "",
           "Generated from the full-disassembly classification pipeline "
           "(analysis). `callers` = static call sites in the image.",
           "",
           "| subsystem | functions |",
           "|---|---|"]
    for s in order:
        if subs.get(s):
            out.append(f"| {s} | {len(subs[s])} |")
    out.append("")
    for s in order:
        rs = subs.get(s)
        if not rs:
            continue
        out += [f"## {s} ({len(rs)})", "",
                "| addr | name | conf | callers | purpose |", "|---|---|---|---|---|"]
        for r in rs:
            nm = r["name"] or "—"
            out.append(f"| `{r['addr']}` | {nm} | {r['conf']} | {r['callers']} | {r['purpose']} |")
        out.append("")
    doc = os.path.join(ROOT, "docs", "function-index.md")
    os.makedirs(os.path.dirname(doc), exist_ok=True)
    open(doc, "w").write("\n".join(out))
    json.dump(db, open(DB, "w"))
    print(f"-> docs/function-index.md, analysis/function_index.csv")
    print(Counter(r["subsystem"] for r in rows).most_common())

if __name__ == "__main__":
    main()
