#!/usr/bin/env python3
"""Match app functions against toolchain library signatures.

Signature = canonical instruction sequence (immediates/annotations masked).
A hit requires exact sequence equality and len >= MINLEN instructions.
Emits analysis/lib_hits.json and updates analysis/db.json in place.
"""
import re, json, os, sys
from collections import defaultdict

HERE = os.path.dirname(os.path.abspath(__file__))
ROOT = os.path.dirname(HERE)
DB = os.path.join(ROOT, "analysis", "db.json")
LIBDIS = os.path.join(ROOT, "analysis", "libdis")
OUT = os.path.join(ROOT, "analysis", "lib_hits.json")
MINLEN = 6

line_re = re.compile(r'^\s*([0-9a-f]+):\s+((?:[0-9a-f]{2} )+)\s*\t(.*)$')
func_re = re.compile(r'^([A-Za-z_][A-Za-z0-9_$]*):\s*$')
ann_re  = re.compile(r'<[^>]*>')
num_re  = re.compile(r'(0x[0-9a-fA-F]+|-?\d+)')

def canon(text):
    t = ann_re.sub('', text)
    t = num_re.sub('#', t)
    return re.sub(r'\s+', ' ', t).strip()

def lib_sigs(path):
    name, cur = None, []
    for ln in open(path, errors='replace'):
        fm = func_re.match(ln)
        if fm:
            if name and cur:
                yield name, "\n".join(cur)
            name, cur = fm.group(1), []
            continue
        m = line_re.match(ln)
        if m and name is not None:
            cur.append(canon(m.group(3)))
    if name and cur:
        yield name, "\n".join(cur)

def main():
    db = json.load(open(DB))
    sig2names = defaultdict(set)
    name_src = {}
    for fn in sorted(os.listdir(LIBDIS)):
        if not fn.endswith(".txt"):
            continue
        variant_lib = fn[:-4]
        for name, sig in lib_sigs(os.path.join(LIBDIS, fn)):
            if sig.count("\n") + 1 >= MINLEN:
                sig2names[sig].add(name)
                name_src.setdefault(name, variant_lib)

    hits = {}
    for addr, f in db["functions"].items():
        c = f.get("canon", "")
        if not c or c.count("\n") + 1 < MINLEN:
            continue
        names = sig2names.get(c)
        if names:
            name = sorted(names)[0]
            hits[addr] = dict(name=name, names=sorted(names),
                              src=name_src.get(name), ninsn=f["ninsn"])
            f["lib_name"] = name
            f["lib_src"] = name_src.get(name)
            f["conf"] = "exact-sig"
    json.dump(hits, open(OUT, "w"), indent=1)
    json.dump(db, open(DB, "w"))
    print(f"lib hits: {len(hits)} / {db['n_functions']}")
    from collections import Counter
    print(Counter(h['src'] for h in hits.values()).most_common(10))

if __name__ == "__main__":
    main()
