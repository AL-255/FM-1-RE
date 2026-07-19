#!/usr/bin/env python3
"""Harvest function entries from a pi32v2 linear disassembly listing.

Usage: harvest_entries.py <linear.asm> <out_dir>
Emits: function_entries.txt, functions_ranked.csv, call_targets.txt,
       and app_pi32v2_annotated.asm (listing with FUNC headers).
Method: every `call 0xADDR` target is a function entry (authoritative).
"""
import re, sys, os
from collections import Counter

asm, outdir = sys.argv[1], sys.argv[2]
os.makedirs(outdir, exist_ok=True)

insns, addr_txt = [], {}
for ln in open(asm):
    m = re.match(r'^([0-9a-f]{8})  (\S+)\s+(.*)$', ln.rstrip('\n'))
    if not m:
        continue
    a = int(m.group(1), 16)
    insns.append((a, ln.rstrip('\n'), m.group(3).strip()))
    addr_txt[a] = m.group(3).strip()

callcount = Counter()
for _, _, txt in insns:
    m = re.match(r'call\s+0x([0-9a-f]+)', txt)
    if m:
        callcount[int(m.group(1), 16)] += 1

entries = sorted(set(callcount) | {0x020000A0})
entryset = set(entries)

with open(f'{outdir}/call_targets.txt', 'w') as f:
    f.write('\n'.join(f'{t:08x}' for t in sorted(callcount)))

with open(f'{outdir}/function_entries.txt', 'w') as f:
    f.write(f"# {len(entries)} function entries; base 0x02000000\n")
    for t in entries:
        pl = 'PROLOGUE' if addr_txt.get(t, '').startswith('push') else '        '
        f.write(f"0x{t:08x}  {pl}  {addr_txt.get(t,'<undecoded>')}\n")

with open(f'{outdir}/functions_ranked.csv', 'w') as f:
    f.write("address,call_count,has_prologue,first_insn\n")
    for t in sorted(entries, key=lambda x: -callcount[x]):
        pl = int(addr_txt.get(t, '').startswith('push'))
        f.write(f'0x{t:08x},{callcount[t]},{pl},"{addr_txt.get(t,"<undecoded>")}"\n')

with open(f'{outdir}/app_pi32v2_annotated.asm', 'w') as out:
    out.write("; FM-1 app.bin full linear disassembly (JieLi pi32v2)\n")
    out.write("; base=0x02000000 entry=0x020000A0\n\n")
    for a, ln, _ in insns:
        if a in entryset:
            out.write(f"\n;===== FUNC_{a:08x}  (called {callcount.get(a,0)}x) =====\n")
        out.write(ln + "\n")

print(f"{len(insns)} instructions, {len(entries)} function entries")
