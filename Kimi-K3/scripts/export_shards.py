#!/usr/bin/env python3
"""Export enriched per-shard disassembly packets for LLM classification.

Reuses Opus4.8 shard boundaries (analysis/funcs/shard_*.txt). For each shard
range [start,end) emit Kimi-K3/analysis/shards/shard_<start>_<end>.txt with:
  FUNC header: addr, size, ninsn, caller/callee counts
  known lib labels (exact-sig) for the function and its callees
  string refs with contents, RAM/SFR data refs
  disassembly (VMA: text)
Also emits manifest.json listing shards and per-function metadata.
"""
import re, json, os, sys, glob

HERE = os.path.dirname(os.path.abspath(__file__))
ROOT = os.path.dirname(HERE)
OPUS = os.path.join(os.path.dirname(ROOT), "Opus4.8")
LISTING = os.path.join(OPUS, "decomp", "app_pi32v2_objdump.txt")
DB = os.path.join(ROOT, "analysis", "db.json")
OUTDIR = os.path.join(ROOT, "analysis", "shards")

line_re = re.compile(r'^\s*([0-9a-f]+):\s+((?:[0-9a-f]{2} )+)\s*\t(.*)$')

def main():
    db = json.load(open(DB))
    funcs = db["functions"]
    strings = db["strings"]
    os.makedirs(OUTDIR, exist_ok=True)

    # full instruction text map (VMA -> text)
    insn = {}
    with open(LISTING, errors='replace') as f:
        for ln in f:
            m = line_re.match(ln)
            if m:
                insn[db["base"] + int(m.group(1), 16)] = m.group(3).rstrip()

    # callers map
    callers = {}
    for a, f in funcs.items():
        for c in f["calls"]:
            callers.setdefault(f"0x{c:08x}", set()).add(a)

    shard_files = sorted(glob.glob(os.path.join(OPUS, "analysis", "funcs", "shard_*.txt")))
    manifest = []
    # gap shards: entries not covered by any Opus shard
    covered = set()
    for sf in shard_files:
        m = re.search(r'shard_([0-9a-f]{8})_([0-9a-f]{8})\.txt$', sf)
        lo, hi = int(m.group(1), 16), int(m.group(2), 16)
        for k in funcs:
            a = int(k, 16)
            if lo <= a <= hi:
                covered.add(a)
    missing = sorted(a for a in (int(k, 16) for k in funcs) if a not in covered)
    groups = []
    for a in missing:
        if groups and a - groups[-1][-1] < 0x2000:
            groups[-1].append(a)
        else:
            groups.append([a])
    for g in groups:
        shard_files.append(f"gap:{g[0]:08x}_{g[-1]:08x}")

    for sf in shard_files:
        if sf.startswith("gap:"):
            lo, hi = (int(x, 16) for x in sf[4:].split("_"))
        else:
            m = re.search(r'shard_([0-9a-f]{8})_([0-9a-f]{8})\.txt$', sf)
            lo, hi = int(m.group(1), 16), int(m.group(2), 16)
        addrs = sorted(a for a, f in ((int(k, 16), v) for k, v in funcs.items())
                       if lo <= a <= hi)
        lines = []
        meta = []
        for a in addrs:
            f = funcs[f"0x{a:08x}"]
            cal = f["calls"]
            cal_lbl = []
            for c in cal:
                cf = funcs.get(f"0x{c:08x}")
                if cf and cf.get("lib_name"):
                    cal_lbl.append(f"0x{c:08x}={cf['lib_name']}")
            srefs = []
            for s in f["str_refs"]:
                srefs.append(f"0x{s:08x}:{strings.get(f'0x{s:08x}','')[:48]!r}")
            drefs = [f"0x{v:08x}" for v in f["data_refs"]
                     if 0x01C00000 <= v < 0x01D00000 or v < 0x00200000][:12]
            hdr = (f"FUNC 0x{a:08x} size={f['size']}B ninsn={f['ninsn']} "
                   f"callers={len(callers.get(f'0x{a:08x}',[]))} callees={len(cal)}")
            if f.get("lib_name"):
                hdr += f" KNOWN_LIB={f['lib_name']}"
            lines.append(f"===== {hdr} =====")
            if cal_lbl:
                lines.append(f"  callee-libs: {', '.join(sorted(set(cal_lbl)))}")
            if srefs:
                lines.append(f"  strings: {'; '.join(srefs[:6])}")
            if drefs:
                lines.append(f"  data-refs: {', '.join(drefs)}")
            for v in range(a, a + f["size"], 2):
                t = insn.get(v)
                if t is None:
                    continue
                lines.append(f"    {v:08x}: {t}")
            lines.append("")
            meta.append(dict(addr=f"0x{a:08x}", size=f["size"],
                             lib=f.get("lib_name")))
        out = os.path.join(OUTDIR, f"shard_{lo:08x}_{hi:08x}.txt")
        with open(out, "w") as g:
            g.write("\n".join(lines))
        manifest.append(dict(shard=os.path.basename(out), lo=f"0x{lo:08x}",
                             hi=f"0x{hi:08x}", nfuncs=len(addrs)))
    json.dump(manifest, open(os.path.join(OUTDIR, "manifest.json"), "w"), indent=1)
    print(f"{len(manifest)} shards, {sum(m['nfuncs'] for m in manifest)} funcs")

if __name__ == "__main__":
    main()
