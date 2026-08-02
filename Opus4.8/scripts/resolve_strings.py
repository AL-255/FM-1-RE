#!/usr/bin/env python3
"""Resolve indirect string references (pointer tables / struct arrays in rodata).

Menu-driven firmware references strings through tables of pointers, so functions
rarely load a string address directly. Strategy:
  1. Build the set of real string addresses.
  2. Scan app.bin for 4-aligned LE words that point at a string -> pointer sites.
     Group nearby pointer sites into "table regions".
  3. For each function's flash data refs (code_ptr_refs), if a ref lands in/near a
     table region, attach that region's strings to the function.
Also emits, per function, any directly-referenced strings.
"""
import re, json, struct, sys, os
from collections import defaultdict

BASE = 0x02000000
HERE = os.path.dirname(os.path.abspath(__file__))
OPUS = os.path.dirname(HERE)
REPO = os.path.dirname(OPUS)
ANALYSIS = os.path.join(OPUS, "analysis")
APP = sys.argv[1] if len(sys.argv) > 1 else \
    os.path.join(REPO, "firmware-images", "v13", "raw_fw",
                 "FM-1.fwsc_unpack", "files", "app.bin")

data = open(APP, "rb").read()
code_end = BASE + len(data)

# ---- real strings (printable, len>=3), addr-keyed
strings = {}
srx = re.compile(rb'[\x20-\x7e]{3,}')
for m in srx.finditer(data):
    strings[BASE + m.start()] = m.group().decode('ascii', 'replace')
straddrs = sorted(strings)
strset = set(straddrs)
# also allow pointer to land inside a string's start byte only (exact starts)

# ---- scan for pointer words that reference a string start
ptr_sites = []  # (loc_addr, target)
for off in range(0, len(data) - 3, 4):
    w = struct.unpack_from("<I", data, off)[0]
    if w in strset:
        ptr_sites.append((BASE + off, w))

# group pointer sites into table regions (gap <= 48 bytes)
regions = []
cur = []
for loc, tgt in ptr_sites:
    if cur and loc - cur[-1][0] > 48:
        regions.append(cur); cur = []
    cur.append((loc, tgt))
if cur: regions.append(cur)

def region_of(addr):
    for i, r in enumerate(regions):
        if r[0][0] - 8 <= addr <= r[-1][0] + 8:
            return i
    return None

# ---- attach to functions
db = json.load(open(os.path.join(ANALYSIS, "function_db.json")))
funcs = db["functions"]
attach = defaultdict(set)
for key, f in funcs.items():
    seen = set()
    # direct string refs
    for s in f.get("str_refs", []):
        if s in strings: seen.add(s)
    # indirect via pointer-table regions the function points into
    for ref in f.get("code_ptr_refs", []):
        ri = region_of(ref)
        if ri is not None:
            for loc, tgt in regions[ri]:
                seen.add(tgt)
    if seen:
        attach[key] = seen

out = {k: sorted(strings[a] for a in v)[:40] for k, v in attach.items()}
json.dump(out, open(os.path.join(ANALYSIS, "func_strings.json"), "w"), ensure_ascii=False)

# region summary
reg_summary = []
for r in regions:
    if len(r) >= 3:
        reg_summary.append({
            "start": f"0x{r[0][0]:08x}", "n": len(r),
            "sample": [strings[t] for _, t in r[:6]]
        })
json.dump(reg_summary, open(os.path.join(ANALYSIS, "string_tables.json"), "w"),
          ensure_ascii=False, indent=1)

print(f"real strings: {len(strings)}")
print(f"pointer sites: {len(ptr_sites)}  table regions: {len(regions)} (>=3 entries: {len(reg_summary)})")
print(f"functions with attached strings: {len(attach)}")
# biggest tables
for rs in sorted(reg_summary, key=lambda x: -x['n'])[:8]:
    print(f"  table {rs['start']}  {rs['n']} ptrs  e.g. {rs['sample'][:4]}")
