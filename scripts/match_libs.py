#!/usr/bin/env python3
"""Match app functions against toolchain library signatures.

Signature = canonical instruction sequence (immediates/annotations masked).
A hit requires exact sequence equality and len >= MINLEN instructions.
Updates the current `db.json`/`lib_hits.json` pair and regenerates the
independent pipeline's `lib_matches.json` from `function_db.json`.
"""
import bisect
import json
import os
import re
from collections import Counter, defaultdict

HERE = os.path.dirname(os.path.abspath(__file__))
ROOT = os.path.dirname(HERE)
DB = os.path.join(ROOT, "analysis", "db.json")
LIBDIS = os.path.join(ROOT, "analysis", "libdis")
OUT = os.path.join(ROOT, "analysis", "lib_hits.json")
INDEPENDENT_DB = os.path.join(ROOT, "analysis", "function_db.json")
LISTING = os.path.join(ROOT, "analysis", "disassembly", "app_pi32v2_objdump.txt")
INDEPENDENT_OUT = os.path.join(ROOT, "analysis", "lib_matches.json")
BASE = 0x02000000
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

def load_signatures(files):
    sig2names = defaultdict(set)
    name_src = {}
    for fn in files:
        variant_lib = fn[:-4]
        for name, sig in lib_sigs(os.path.join(LIBDIS, fn)):
            if sig.count("\n") + 1 >= MINLEN:
                sig2names[sig].add(name)
                name_src.setdefault(name, variant_lib)
    return sig2names, name_src


def match_current():
    db = json.load(open(DB))
    files = sorted(fn for fn in os.listdir(LIBDIS) if fn.endswith(".txt"))
    sig2names, name_src = load_signatures(files)

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
    json.dump(hits, open(OUT, "w"), indent=1)
    json.dump(db, open(DB, "w"))
    print(f"lib hits: {len(hits)} / {db['n_functions']}")
    print(Counter(h['src'] for h in hits.values()).most_common(10))


def match_independent():
    baseline = {
        "base_libc.txt": "libc",
        "base_libcompiler-rt.txt": "libcompiler-rt",
        "base_libm.txt": "libm",
        "base_libg.txt": "libg",
    }
    sig2names, _ = load_signatures(baseline)
    name_src = {}
    for filename, source in baseline.items():
        for name, _ in lib_sigs(os.path.join(LIBDIS, filename)):
            name_src[name] = source

    db = json.load(open(INDEPENDENT_DB))
    entries = sorted(int(addr, 16) for addr in db["functions"])

    def owner(addr):
        index = bisect.bisect_right(entries, addr) - 1
        if index < 0:
            return None
        entry = entries[index]
        if addr < db["functions"][f"0x{entry:08x}"]["end"]:
            return entry
        return None

    app_lines = defaultdict(list)
    for line in open(LISTING, errors="replace"):
        match = line_re.match(line)
        if not match:
            continue
        entry = owner(BASE + int(match.group(1), 16))
        if entry is not None:
            app_lines[entry].append(canon(match.group(3)))

    matches = {}
    for entry, lines in app_lines.items():
        if len(lines) < MINLEN:
            continue
        names = sig2names.get("\n".join(lines))
        if names and len(names) == 1:
            name = next(iter(names))
            matches[f"0x{entry:08x}"] = {
                "name": name,
                "src": name_src.get(name, "?"),
                "ninsn": len(lines),
            }

    json.dump(matches, open(INDEPENDENT_OUT, "w"), indent=1)
    print(f"independent lib matches: {len(matches)} / {len(app_lines)}")


def main():
    match_current()
    match_independent()

if __name__ == "__main__":
    main()
