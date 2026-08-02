#!/usr/bin/env python3
"""Build a function database from the authoritative vendor objdump listing.

objdump annotates every in-section reference as `<_fw+0xHEX>`:
  - branch instructions (call/goto/gotoss/if..goto): HEX is a PC-relative *file offset*
    -> firmware addr = (0x02000000 + signext(HEX)) & 0xffffffff  (can land in RAM)
  - immediate loads (rN = <imm>): HEX is the *absolute value* loaded
    -> a pointer iff it falls in flash [0x02000000..CODE_END] or RAM [0x01c00000..]

Emits analysis/function_db.json and analysis/func_index.csv.
"""
import re, json, sys, os
from collections import defaultdict

BASE = 0x02000000
OBJ = sys.argv[1] if len(sys.argv) > 1 else "analysis/disassembly/app_pi32v2_objdump.txt"
STR = sys.argv[2] if len(sys.argv) > 2 else "analysis/strings_raw.txt"
OUT = "analysis"
CODE_END = 0x0208e59a + 4
RAM_LO, RAM_HI = 0x01c00000, 0x01c20000

BRANCH = re.compile(r'\b(call|goto|gotoss|jmp)\b')
line_re = re.compile(r'^\s*([0-9a-f]+):\s+((?:[0-9a-f]{2} )+)\s*\t(.*)$')
ann_re  = re.compile(r'<_fw\+0x([0-9a-fA-F]+)')

# ---- load strings (addr -> text), keep only plausibly-real ones for xref naming
strings = {}
for ln in open(STR, errors='replace'):
    m = re.match(r'^0x([0-9a-f]+)\t(.*)$', ln.rstrip('\n'))
    if m:
        strings[BASE + int(m.group(1), 16)] = m.group(2)

# ---- parse instructions
insns = []  # (addr, nbytes, mnemonic, text, [ref_targets])
for ln in open(OBJ, errors='replace'):
    m = line_re.match(ln)
    if not m:
        continue
    off = int(m.group(1), 16)
    nbytes = len(m.group(2).split())
    addr = BASE + off
    text = m.group(3).rstrip()
    mnem = text.split(None, 1)[0] if text else ''
    refs = []
    for hx in ann_re.findall(text):
        v = int(hx, 16)
        if BRANCH.search(text):
            tgt = (BASE + v) & 0xffffffff        # file offset (may wrap to RAM)
        else:
            tgt = v & 0xffffffff                 # absolute value
        refs.append(tgt)
    insns.append((addr, nbytes, mnem, text, refs))

insns.sort()
addr_index = {a: i for i, (a, *_ ) in enumerate(insns)}
last = insns[-1]
code_end = last[0] + last[1]

# ---- function entries: call targets (in flash) + entry point
callcnt = defaultdict(int)
for a, nb, mn, tx, refs in insns:
    if mn == 'call':
        for t in refs:
            callcnt[t] += 1
entries = set(t for t in callcnt if BASE <= t < code_end)
entries.add(0x020000A0)
# also RAM-resident call targets (functions executing from RAM)
ram_entries = set(t for t in callcnt if RAM_LO <= t < RAM_HI)

entries = sorted(entries)
# ---- segment flash functions: [entry, next_entry)
func = {}
for i, e in enumerate(entries):
    nxt = entries[i + 1] if i + 1 < len(entries) else code_end
    func[e] = {"addr": e, "end": nxt, "size": nxt - e,
               "callers": [], "callees": [], "calls_ram": [],
               "str_refs": [], "code_ptr_refs": [], "ram_refs": [],
               "ninsn": 0, "name": None, "note": None}

def owner(addr):
    # binary search entry <= addr
    import bisect
    i = bisect.bisect_right(entries, addr) - 1
    if i >= 0:
        e = entries[i]
        if e <= addr < func[e]["end"]:
            return e
    return None

# ---- walk instructions, attribute refs to owning function
for a, nb, mn, tx, refs in insns:
    o = owner(a)
    if o is None:
        continue
    f = func[o]
    f["ninsn"] += 1
    for t in refs:
        if mn == 'call':
            if BASE <= t < code_end:
                f["callees"].append(t)
                if o != t:
                    func[t]["callers"].append(a)  # record call-site addr
            elif RAM_LO <= t < RAM_HI:
                f["calls_ram"].append(t)
        elif BRANCH.search(tx):
            pass  # local goto; ignore for xref
        else:
            if BASE <= t < code_end:
                if t in strings:
                    f["str_refs"].append(t)
                else:
                    f["code_ptr_refs"].append(t)
            elif RAM_LO <= t < RAM_HI:
                f["ram_refs"].append(t)

# dedupe + counts
for e, f in func.items():
    f["callees"] = sorted(set(f["callees"]))
    f["callers_addrs"] = sorted(set(f["callers"]))
    f["ncallers"] = len(set(owner(c) for c in f["callers"] if owner(c) is not None))
    f["callers"] = sorted(set(o for o in (owner(c) for c in f["callers"]) if o is not None))
    f["calls_ram"] = sorted(set(f["calls_ram"]))
    f["str_refs"] = sorted(set(f["str_refs"]))
    f["code_ptr_refs"] = sorted(set(f["code_ptr_refs"]))
    f["ram_refs"] = sorted(set(f["ram_refs"]))

os.makedirs(OUT, exist_ok=True)
db = {
    "base": BASE, "code_end": code_end,
    "n_instructions": len(insns),
    "n_functions": len(func),
    "n_ram_entries": len(ram_entries),
    "strings_count": len(strings),
    "functions": {f"0x{e:08x}": f for e, f in func.items()},
    "ram_entries": sorted(f"0x{a:08x}" for a in ram_entries),
}
json.dump(db, open(f"{OUT}/function_db.json", "w"))
# strings kept separately (addr-keyed) for the doc agents
json.dump({f"0x{a:08x}": t for a, t in sorted(strings.items())},
          open(f"{OUT}/strings.json", "w"), ensure_ascii=False)

# index csv
with open(f"{OUT}/func_index.csv", "w") as f:
    f.write("addr,size,ninsn,ncallers,ncallees,nstr,first_str\n")
    for e in entries:
        d = func[e]
        s0 = strings.get(d["str_refs"][0], "").replace(",", " ")[:40] if d["str_refs"] else ""
        f.write(f'0x{e:08x},{d["size"]},{d["ninsn"]},{d["ncallers"]},'
                f'{len(d["callees"])},{len(d["str_refs"])},"{s0}"\n')

print(f"instructions={len(insns)}  functions={len(func)}  ram_entries={len(ram_entries)}")
print(f"code range 0x{BASE:08x}..0x{code_end:08x}")
tot_str = sum(1 for f in func.values() if f['str_refs'])
print(f"functions with >=1 string xref: {tot_str}")
print("wrote analysis/function_db.json, strings.json, func_index.csv")
