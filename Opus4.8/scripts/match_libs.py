#!/usr/bin/env python3
"""Signature-match app functions against toolchain libraries to auto-label them.

Signature = tuple of canonicalized instruction texts (immediates/addresses/
annotations masked to '#'), which is invariant to link-time addresses but
specific to a function's structure. A strict match requires the exact same
canonical instruction sequence, length >= MINLEN, and an unambiguous lib name.
"""
import re, json, sys, os
from collections import defaultdict

BASE = 0x02000000
MINLEN = 6
line_re = re.compile(r'^\s*([0-9a-f]+):\s+((?:[0-9a-f]{2} )+)\s*\t(.*)$')
func_re = re.compile(r'^([A-Za-z_][A-Za-z0-9_]*):\s*$')
ann_re  = re.compile(r'\s*<[^>]*>')
num_re  = re.compile(r'(0x[0-9a-fA-F]+|-?\d+)')

def canon(text):
    t = ann_re.sub('', text)
    t = num_re.sub('#', t)
    return re.sub(r'\s+', ' ', t).strip()

def lib_sigs(path):
    """yield (name, sigtuple)"""
    name = None; cur = []
    for ln in open(path, errors='replace'):
        fm = func_re.match(ln)
        if fm:
            if name and cur: yield name, tuple(cur)
            name = fm.group(1); cur = []
            continue
        m = line_re.match(ln)
        if m and name is not None:
            cur.append(canon(m.group(3)))
    if name and cur: yield name, tuple(cur)

# ---- build lib signature -> name(s)
sig2name = defaultdict(set)
name_src = {}
libdir = "analysis/libdis"
for f in ["libc", "libcompiler-rt", "libm", "libg"]:
    p = os.path.join(libdir, f + ".txt")
    if not os.path.exists(p): continue
    for name, sig in lib_sigs(p):
        if len(sig) >= MINLEN:
            sig2name[sig].add(name)
            name_src[name] = f

# ---- app function signatures (from objdump listing, segmented by our entries)
db = json.load(open("analysis/function_db.json"))
entries = sorted(int(a, 16) for a in db["functions"])
import bisect
def owner(addr):
    i = bisect.bisect_right(entries, addr) - 1
    if i >= 0 and entries[i] <= addr < db["functions"][f"0x{entries[i]:08x}"]["end"]:
        return entries[i]
    return None

app_lines = defaultdict(list)  # entry -> [canon lines]
for ln in open("decomp/app_pi32v2_objdump.txt", errors='replace'):
    m = line_re.match(ln)
    if not m: continue
    addr = BASE + int(m.group(1), 16)
    o = owner(addr)
    if o is not None:
        app_lines[o].append(canon(m.group(3)))

matches = {}
for e, lines in app_lines.items():
    sig = tuple(lines)
    if len(sig) < MINLEN: continue
    names = sig2name.get(sig)
    if names and len(names) == 1:
        nm = next(iter(names))
        matches[f"0x{e:08x}"] = {"name": nm, "src": name_src.get(nm, "?"), "ninsn": len(sig)}

json.dump(matches, open("analysis/lib_matches.json", "w"), indent=0)
by_src = defaultdict(int)
for m in matches.values(): by_src[m["src"]] += 1
print(f"app functions: {len(app_lines)}")
print(f"exact lib matches: {len(matches)}  by source: {dict(by_src)}")
print("sample:", [f'{k}={v["name"]}' for k,v in list(matches.items())[:15]])
