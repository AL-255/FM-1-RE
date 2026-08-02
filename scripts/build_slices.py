#!/usr/bin/env python3
"""Emit enriched per-function disassembly shards for analysis agents.

Each function gets a header (addr, size, ninsn, lib label, attached strings,
callers, callees-with-labels) followed by its instruction listing with call
targets annotated by known label. Functions are grouped into shard files of
~40 functions so an agent can read one shard at a time.
"""
import json, re, os, bisect
from collections import defaultdict

BASE = 0x02000000
DATA_LMA = 0x02084820
master = json.load(open("analysis/master_index.json"))
db = json.load(open("analysis/function_db.json"))
funcs = db["functions"]
entries = sorted(int(a, 16) for a in funcs)
real = [e for e in entries if e < DATA_LMA]

def label(addr):
    k = f"0x{addr:08x}"
    m = master.get(k)
    if m and m["lib_name"]:
        return m["lib_name"]
    return k

# parse objdump instructions once, bucket by owner
line_re = re.compile(r'^\s*([0-9a-f]+):\s+((?:[0-9a-f]{2} )+)\s*\t(.*)$')
def owner(addr):
    i = bisect.bisect_right(real, addr) - 1
    if i >= 0:
        e = real[i]
        end = funcs[f"0x{e:08x}"]["end"]
        if e <= addr < end:
            return e
    return None

body = defaultdict(list)
for ln in open("analysis/disassembly/app_pi32v2_objdump.txt", errors='replace'):
    m = line_re.match(ln)
    if not m:
        continue
    addr = BASE + int(m.group(1), 16)
    o = owner(addr)
    if o is None:
        continue
    text = m.group(3).rstrip()
    # annotate call target with label
    cm = re.match(r'call\s+', text)
    ann = re.search(r'<_fw\+0x([0-9a-fA-F]+)', text)
    if cm and ann:
        tgt = (BASE + int(ann.group(1), 16)) & 0xffffffff
        lb = label(tgt)
        if not lb.startswith("0x"):
            text += f"   ; -> {lb}"
    body[o].append(f"    {addr:08x}: {text}")

os.makedirs("analysis/raw-shards", exist_ok=True)
SHARD = 40
shard_idx = []
for si in range(0, len(real), SHARD):
    chunk = real[si:si+SHARD]
    fn = f"analysis/raw-shards/shard_{chunk[0]:08x}_{chunk[-1]:08x}.txt"
    with open(fn, "w") as fo:
        for e in chunk:
            k = f"0x{e:08x}"; m = master[k]
            fo.write(f"\n===== FUNC {k}  size={m['size']}B  ninsn={m['ninsn']}  "
                     f"callers={m['ncallers']} callees={m['ncallees']}"
                     + (f"  LIB={m['lib_name']}" if m['lib_name'] else "") + " =====\n")
            if m["strings"]:
                fo.write("  strings: " + " | ".join(m["strings"]) + "\n")
            if m["callees"]:
                cl = ", ".join(label(int(c,16)) for c in m["callees"][:24])
                fo.write("  calls: " + cl + "\n")
            for line in body.get(e, []):
                fo.write(line + "\n")
    shard_idx.append({"file": fn, "start": f"0x{chunk[0]:08x}", "end": f"0x{chunk[-1]:08x}", "n": len(chunk)})

json.dump(shard_idx, open("analysis/shard_index.json", "w"), indent=1)
print(f"wrote {len(shard_idx)} shards covering {len(real)} functions into analysis/raw-shards/")
print("sample shard:", shard_idx[0]["file"])
