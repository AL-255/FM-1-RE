#!/usr/bin/env python3
"""Merge all signals into a master function index + call-graph clustering.

Inputs: function_db.json, lib_matches.json, func_strings.json
Output: analysis/master_index.json, analysis/master_index.csv,
        analysis/callgraph.json (adjacency), and a segmented vendor listing
        analysis/app_functions.asm (per-function headers with best-known label).
"""
import json, re, os, bisect
from collections import defaultdict, deque

BASE = 0x02000000
db = json.load(open("analysis/function_db.json"))
libm = json.load(open("analysis/lib_matches.json"))
fstr = json.load(open("analysis/func_strings.json"))
funcs = db["functions"]
entries = sorted(int(a, 16) for a in funcs)

# ---- undirected call-graph components (weak clustering)
adj = defaultdict(set)
for k, f in funcs.items():
    e = int(k, 16)
    for c in f["callees"]:
        adj[e].add(c); adj[c].add(e)
seen = set(); comp_id = {}; comps = []
for e in entries:
    if e in seen: continue
    q = deque([e]); seen.add(e); members = []
    while q:
        x = q.popleft(); members.append(x)
        for y in adj[x]:
            if y not in seen: seen.add(y); q.append(y)
    cid = len(comps); comps.append(members)
    for m in members: comp_id[m] = cid

# ---- merge labels
master = {}
for k, f in funcs.items():
    e = int(k, 16)
    lm = libm.get(k)
    ss = fstr.get(k, [])
    # keep only "cleanish" attached strings (alnum-ish, len>=3)
    clean = [s for s in ss if re.search(r'[A-Za-z]{3,}', s)][:12]
    master[k] = {
        "addr": k, "size": f["size"], "ninsn": f["ninsn"],
        "ncallers": f["ncallers"], "ncallees": len(f["callees"]),
        "callers": [f"0x{c:08x}" for c in f["callers"]][:30],
        "callees": [f"0x{c:08x}" for c in f["callees"]][:60],
        "calls_ram": [f"0x{c:08x}" for c in f["calls_ram"]],
        "n_ram_refs": len(f["ram_refs"]),
        "lib_name": lm["name"] if lm else None,
        "lib_src": lm["src"] if lm else None,
        "strings": clean,
        "component": comp_id[e],
    }

json.dump(master, open("analysis/master_index.json", "w"), ensure_ascii=False)

with open("analysis/master_index.csv", "w") as fo:
    fo.write("addr,size,ninsn,ncallers,ncallees,component,lib_name,strings\n")
    for k in sorted(master, key=lambda x: int(x, 16)):
        m = master[k]
        st = "|".join(m["strings"])[:60].replace(",", " ")
        fo.write(f'{k},{m["size"]},{m["ninsn"]},{m["ncallers"]},{m["ncallees"]},'
                 f'{m["component"]},{m["lib_name"] or ""},"{st}"\n')

# component summary
comp_sz = sorted(((len(c), i) for i, c in enumerate(comps)), reverse=True)
print(f"functions={len(master)}  components={len(comps)}")
print(f"lib-labeled={sum(1 for m in master.values() if m['lib_name'])}  "
      f"string-anchored={sum(1 for m in master.values() if m['strings'])}")
print("largest components (id: size):", [(i, n) for n, i in comp_sz[:6]])
json.dump({"components": [[f"0x{m:08x}" for m in c] for c in comps]},
          open("analysis/callgraph.json", "w"))
