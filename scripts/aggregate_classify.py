#!/usr/bin/env python3
"""Aggregate the classification workflow's per-function results (from journal.jsonl)
into the master index and emit the function-map documents.
"""
import json, sys, os, re
from collections import defaultdict, Counter

if len(sys.argv) != 2:
    raise SystemExit(f"usage: {sys.argv[0]} JOURNAL.jsonl")

JOURNAL = sys.argv[1]
master = json.load(open("analysis/master_index.json"))
valid = set(master)

records = {}
for ln in open(JOURNAL, errors='replace'):
    try:
        e = json.loads(ln)
    except Exception:
        continue
    if e.get("type") != "result":
        continue
    res = e.get("result") or {}
    for f in (res.get("functions") or []):
        a = f.get("addr", "").strip().lower()
        m = re.match(r'0x0*([0-9a-f]+)', a)
        if not m:
            continue
        a = f"0x{int(m.group(1),16):08x}"
        if a in valid:
            records[a] = {
                "subsystem": f.get("subsystem", "UNKNOWN"),
                "purpose": f.get("purpose", "").strip(),
                "confidence": f.get("confidence", "low"),
            }

# first pass: direct LLM + exact lib matches
for a, m in master.items():
    r = records.get(a)
    if r:
        m["subsystem"] = r["subsystem"]; m["purpose"] = r["purpose"]
        m["confidence"] = r["confidence"]; m["method"] = "llm"
    elif m["lib_name"]:
        src = m["lib_src"] or ""
        m["subsystem"] = "MATHLIB" if src == "libm" else "MEMLIB"
        m["purpose"] = f'library: {m["lib_name"]}'
        m["confidence"] = "high"; m["method"] = "lib-sig"
    else:
        m["subsystem"] = None; m["purpose"] = ""; m["confidence"] = "none"; m["method"] = None

# second pass: locality interpolation for the remainder.
# Firmware modules are contiguous, so an unclassified function usually shares the
# subsystem of its immediate classified neighbours (within the same module, i.e.
# not across a large rodata gap).
ent = sorted(int(a, 16) for a in master)
key = {e: f"0x{e:08x}" for e in ent}
def classified(e):
    m = master[key[e]]
    return m["method"] in ("llm", "lib-sig")
GAP = 2048  # bytes; don't interpolate across a bigger gap (likely module edge)
for i, e in enumerate(ent):
    m = master[key[e]]
    if m["subsystem"] is not None:
        continue
    # nearest classified neighbour on each side within GAP
    left = None
    j = i - 1
    while j >= 0:
        if ent[i] - ent[j] > GAP: break
        if classified(ent[j]): left = master[key[ent[j]]]["subsystem"]; break
        j -= 1
    right = None
    j = i + 1
    while j < len(ent):
        if ent[j] - ent[i] > GAP: break
        if classified(ent[j]): right = master[key[ent[j]]]["subsystem"]; break
        j += 1
    if left and right and left == right:
        ss = left
    elif left and not right:
        ss = left
    elif right and not left:
        ss = right
    elif left and right:
        ss = left  # straddling a boundary; take the preceding module
    else:
        ss = None
    if ss:
        m["subsystem"] = ss; m["confidence"] = "locality"; m["method"] = "locality"
        m["purpose"] = "(subsystem inferred by address locality; not individually analysed)"

# anything still unknown
for a, m in master.items():
    if m["subsystem"] is None:
        m["subsystem"] = "UNCLASSIFIED"; m["method"] = "none"

json.dump(master, open("analysis/master_classified.json", "w"), ensure_ascii=False)

# stats
by_ss = Counter(m["subsystem"] for m in master.values())
print(f"classified functions: {len(records)} / {len(master)}")
print("subsystem histogram:")
for ss, n in by_ss.most_common():
    print(f"  {n:5d}  {ss}")

# per-subsystem function lists
os.makedirs("analysis/subsystems", exist_ok=True)
ss_funcs = defaultdict(list)
for a, m in sorted(master.items(), key=lambda kv: int(kv[0], 16)):
    ss_funcs[m["subsystem"]].append((a, m))
for ss, lst in ss_funcs.items():
    with open(f"analysis/subsystems/{ss}.txt", "w") as fo:
        for a, m in lst:
            lib = f" [{m['lib_name']}]" if m["lib_name"] else ""
            fo.write(f'{a}  sz={m["size"]:<5} calls_in={m["ncallers"]:<3} '
                     f'out={m["ncallees"]:<3} conf={m["confidence"]:<6}{lib}  {m["purpose"]}\n')

# master function index markdown
with open("docs/reversing/09-function-index.md", "w") as fo:
    nllm = sum(1 for m in master.values() if m['method'] == 'llm')
    nlib = sum(1 for m in master.values() if m['method'] == 'lib-sig')
    nloc = sum(1 for m in master.values() if m['method'] == 'locality')
    nnone = sum(1 for m in master.values() if m['method'] == 'none')
    meth_sym = {'llm': 'llm', 'lib-sig': 'lib', 'locality': 'loc', 'none': '?', None: '?'}
    fo.write("# 09 — Complete function index\n\n")
    fo.write(f"All {len(master)} call-target-derived functions in `app.bin`, grouped by "
             "subsystem. Address = firmware/XIP address; `in`/`out` = call-graph "
             "in/out degree.\n\n")
    fo.write("**Method:** `llm` = read & classified individually; `lib` = exact library "
             "signature match; `loc` = subsystem inferred from address locality "
             "(neighbouring module), not individually analysed; `?` = unresolved.\n\n")
    fo.write(f"- individually analysed (llm): **{nllm}**\n"
             f"- exact library match (lib): **{nlib}**\n"
             f"- locality-inferred (loc): **{nloc}**\n"
             f"- unresolved: **{nnone}**\n\n")
    fo.write("> In the original classification pass, 27 of 51 shards were only partially\n"
             "> reviewed. The `0x0206xxxx-0x0208xxxx` band, mostly Bluetooth and vendor SDK\n"
             "> code, is therefore largely locality-inferred. The\n"
             "> `0x0200xxxx-0x0205xxxx` synth, MIDI, UI, audio, and storage regions received\n"
             "> individual review. Extend the incomplete classifications with\n"
             "> `scripts/wf_classify.js` before relying on leaf-function labels in the upper\n"
             "> address band.\n\n")
    # entry points = zero-caller roots (callback/vtable/ISR/task registered indirectly)
    roots = sorted((m for m in master.values() if m["ncallers"] == 0),
                   key=lambda m: -m["ncallees"])
    fo.write(f"## Top-level entry points ({len(roots)} zero-caller roots)\n\n")
    fo.write("Functions with no direct caller — reached via callback/vtable registration, "
             "ISR vectors, or the task scheduler. Highest out-degree first (major "
             "dispatchers / task loops).\n\n")
    fo.write("| addr | subsystem | out | purpose |\n|---|---|---|---|\n")
    for m in roots[:40]:
        fo.write(f"| `{m['addr']}` | {m['subsystem']} | {m['ncallees']} | "
                 f"{(m['purpose'] or '').replace('|','\\|')[:90]} |\n")
    fo.write("\n## Subsystem summary\n\n| Subsystem | # funcs |\n|---|---|\n")
    for ss, n in by_ss.most_common():
        fo.write(f"| {ss} | {n} |\n")
    for ss, lst in sorted(ss_funcs.items(), key=lambda kv: -len(kv[1])):
        fo.write(f"\n## {ss}  ({len(lst)} functions)\n\n")
        fo.write("| addr | size | in | out | method | name/purpose |\n|---|---|---|---|---|---|\n")
        for a, m in lst:
            nm = (f"**{m['lib_name']}** — " if m["lib_name"] else "")
            purpose = (m["purpose"] or "").replace("|", "\\|")[:120]
            fo.write(f"| `{a}` | {m['size']} | {m['ncallers']} | {m['ncallees']} | "
                     f"{meth_sym.get(m['method'],'?')} | {nm}{purpose} |\n")
print("wrote analysis/master_classified.json, analysis/subsystems/*, docs/reversing/09-function-index.md")
