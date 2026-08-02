#!/usr/bin/env python3
"""Build the FM-1 function database from the vendor objdump listing.

Parses Opus4.8/decomp/app_pi32v2_objdump.txt (file-offset based) plus
function_entries_vendor.csv (VMA based) and emits analysis/db.json:

{
  base, code_end,
  functions: { "0x020...": {addr,end,size,ninsn,call_count,
                            insns:[[vma,text],...],
                            canon:"sig string",
                            calls:[vma,...], data_refs:[vma,...],
                            lib_name,lib_src,subsystem,purpose,conf} },
  strings: { "0x020...": "text" }
}
"""
import re, json, os, sys
from collections import defaultdict

HERE = os.path.dirname(os.path.abspath(__file__))
ROOT = os.path.dirname(HERE)
REPO = os.path.dirname(ROOT)
OPUS = os.path.join(REPO, "Opus4.8")
LISTING = os.path.join(OPUS, "decomp", "app_pi32v2_objdump.txt")
ENTRIES = os.path.join(OPUS, "decomp", "function_entries_vendor.csv")
APPBIN = os.path.join(REPO, "firmware-images", "v13", "raw_fw",
                      "FM-1.fwsc_unpack", "files", "app.bin")
OUT = os.path.join(ROOT, "analysis", "db.json")

BASE = 0x02000000

line_re = re.compile(r'^\s*([0-9a-f]+):\s+((?:[0-9a-f]{2} )+)\s*\t(.*)$')
cont_re = re.compile(r'^\s+(.*)$')          # continuation lines (rep-block braces)
ann_val_re = re.compile(r'<_fw\+0x([0-9A-Fa-f]+)')
ann_re  = re.compile(r'<[^>]*>')
num_re  = re.compile(r'(0x[0-9a-fA-F]+|-?\d+)')

def canon(text):
    t = ann_re.sub('', text)
    t = num_re.sub('#', t)
    return re.sub(r'\s+', ' ', t).strip()

def main():
    data = open(APPBIN, "rb").read()
    code_end = BASE + len(data)

    # ---- strings in the binary
    strings = {}
    for m in re.finditer(rb'[\x20-\x7e]{4,}', data):
        strings[BASE + m.start()] = m.group().decode('ascii', 'replace')

    # ---- function entries
    entries = []
    with open(ENTRIES) as f:
        next(f)
        for ln in f:
            ln = ln.strip()
            if not ln:
                continue
            a, c = ln.split(",")[:2]
            entries.append((int(a, 16), int(c)))
    entries.sort()
    fmap = {}
    for i, (a, c) in enumerate(entries):
        end = entries[i + 1][0] if i + 1 < len(entries) else code_end
        fmap[a] = dict(addr=a, end=end, size=end - a, call_count=c,
                       insns=[], calls=[], data_refs=[], str_refs=[],
                       lib_name=None, lib_src=None, subsystem=None,
                       purpose=None, conf=None)

    # ---- parse listing
    cur = None          # current function dict
    cur_off = None
    with open(LISTING, errors='replace') as f:
        for ln in f:
            m = line_re.match(ln)
            if not m:
                # continuation of a rep-block: attach to previous insn text
                if cur is not None and cur["insns"] and ln.strip() in ("}",):
                    pass
                continue
            off = int(m.group(1), 16)
            vma = BASE + off
            text = m.group(3).rstrip()
            # find owning function: greatest entry <= vma
            if cur is None or not (cur["addr"] <= vma < cur["end"]):
                cur = None
                # binary search would be nicer; entries count is small enough
                lo, hi = 0, len(entries) - 1
                while lo <= hi:
                    mid = (lo + hi) // 2
                    if entries[mid][0] <= vma:
                        lo = mid + 1
                    else:
                        hi = mid - 1
                if hi >= 0:
                    cand = entries[hi][0]
                    if cand <= vma < fmap[cand]["end"]:
                        cur = fmap[cand]
            if cur is None:
                continue
            # call target?
            cm = re.match(r'call\s+([0-9]+)', text)
            if cm:
                tgt = BASE + int(cm.group(1))
                cur["calls"].append(tgt)
            # absolute annotation refs
            for am in ann_val_re.finditer(text):
                v = int(am.group(1), 16)
                if BASE <= v < code_end or 0x01C00000 <= v < 0x01D00000:
                    if not cm:  # calls recorded separately
                        cur["data_refs"].append(v)
                if v in strings:
                    cur["str_refs"].append(v)
            cur["insns"].append([vma, text])

    for f in fmap.values():
        f["ninsn"] = len(f["insns"])
        f["canon"] = "\n".join(canon(t) for _, t in f["insns"])
        f["calls"] = sorted(set(f["calls"]))
        f["data_refs"] = sorted(set(f["data_refs"]))
        f["str_refs"] = sorted(set(f["str_refs"]))
        del f["insns"]  # keep db small; re-parse on demand

    out = dict(base=BASE, code_end=code_end,
               n_functions=len(fmap), n_strings=len(strings),
               functions={f"0x{a:08x}": f for a, f in fmap.items()},
               strings={f"0x{a:08x}": s for a, s in strings.items()})
    os.makedirs(os.path.dirname(OUT), exist_ok=True)
    json.dump(out, open(OUT, "w"))
    print(f"functions={len(fmap)} strings={len(strings)} -> {OUT}")

if __name__ == "__main__":
    main()
