# 02 — Disassembly, function entries, byte-identical reassembly

## Tooling

- **Ghidra** (public release) + **[kagaimiq/ghidra-jieli](https://github.com/kagaimiq/ghidra-jieli)**
  SLEIGH processor module, which provides `pi32`, `pi32v2`, and `q32s` specs.
- The module's `pi32v2` support is officially "very early stage", yet it decodes
  the vast majority of this image correctly (see numbers below). Its main
  limitation is *flow-following*, not *decoding*.

Import parameters: raw binary, language `pi32v2:LE:32:default`, base
`0x02000000`, entry `0x020000A0`.

## Why linear sweep, not auto-analysis

Ghidra auto-analysis follows control flow. On this image it stalls almost
immediately — the first unimplemented opcode truncates the trace, so recursive
analysis found only **10 functions / 159 instructions** across all 583 KB, and
every decompiled function was `WARNING: bad instruction data`.

A **linear sweep** (disassemble at every 2-byte boundary not already covered)
sidesteps flow-following and recovers **162 848 instructions**. The startup code
decodes perfectly (it yielded the memory map in doc 01), confirming decode
quality is high; only flow reconstruction is weak.

Artifacts:
- `analysis/disassembly/app_pi32v2_linear.asm` — full linear listing (`addr  bytes  mnemonic`).
- `analysis/disassembly/app_pi32v2_annotated.asm` — same, with `FUNC_xxxx (called Nx)` headers.

## Instruction vocabulary (top mnemonics)

```
mov 34626   add 15940   lw 10601   call 9365   nop 9253   jz 7403
goto 6735   lb.z 6330   sw 4937    lh.z 4686   jnz 4318   lsl 3567
rep 3120    pop 3040    sh 2591    movz 2505   sti 2367   push 2348
```

Calling convention: `call 0xADDR` (9 365 sites) pushes the return-address
register `rets`; prologues are `push rets` / `push {regbits}`; returns are
`pop pc` / `pop {pc,…}` / `rts` (leaf). Zero-overhead loops use `rep n,rN`.

## Function-entry identification

Every `call` target is, by definition, a function entry. Harvesting them
(`scripts/harvest_entries.py`):

| Metric | Count |
|---|---|
| Unique `call` targets | 1 956 |
| Targets landing on a decoded instruction | 1 706 |
| …of which start with a `push` prologue | 1 305 |
| Function entries created in Ghidra | 1 960 |

Outputs:
- `analysis/disassembly/functions_ranked.csv` — entries ranked by inbound call count.
- `analysis/disassembly/function_entries.txt` — entries with prologue flag + first instruction.

The 250 targets that don't land on a decoded instruction are linear-sweep
*misalignments* (a preceding data byte-run was mis-decoded as a wrong-length
instruction that straddles the entry); force-disassembling at each target
realigns them.

Most-called functions (likely runtime hot paths / library helpers):

```
0x02007a20  261x    0x020847da  115x    0x0201e724   99x
0x0208478a   82x    0x0203560c   73x    0x02012c54   66x
0x02000292   63x    0x0200843c   61x    0x02007e50   49x
```

## Round-trip: byte-identical reassembly

SLEIGH is bidirectional — Ghidra's `Assembler` can assemble instruction text
back to bytes with the *same* spec. Re-assembling every decoded instruction and
comparing to the original bytes (`ghidra/scripts/RoundTrip.java`):

```
total=162848  match=162480  mismatch=368  err=0   match_pct=99.77
```

**0 hard errors.** The 368 mismatches (0.23 %) are SLEIGH-module encoding
*asymmetries*, not wrong disassembly — the mnemonic is right, only sub-field
bits differ:

| Class | Count | Cause |
|---|---|---|
| `mov rX_rY,rA_rB` / `clr rX_rY` (64-bit reg-pair) | ~209 | disassembler drops a reg-select bit the assembler zeroes |
| `swi 0xN` | 157 | `swi` immediate field decoded lossily |
| `mov r2,#0x0` long form | 2 | compiler emitted redundant 6-byte encoding; assembler picks 2-byte form |

Rebuilding the whole image (`ghidra/scripts/ReassembleFirmware.java`) —
assembled bytes where they match, original bytes for the 368 known-asymmetric
cases — produces `analysis/reassembly/app_reassembled.bin`, which is **byte-for-byte identical**
to the original:

```
73f37ac3db15f5e70ae718dac43ab30055a0e27f659ae1b3eeb4c51a39b1616a  app.bin
73f37ac3db15f5e70ae718dac43ab30055a0e27f659ae1b3eeb4c51a39b1616a  app_reassembled.bin
```

### Toward a 100 %-from-text reassembly

The only thing standing between "99.77 % from text + 368 verbatim" and a pure
text→binary rebuild is three `pi32v2` SLEIGH constructor fixes (reg-pair
`mov`/`clr`, `swi` immediate, prefer-long `mov #imm`). These are bounded,
well-characterized edits to `pi32v2_ins_move.sinc` / the `swi` constructor.
With the real JieLi `as`/`clang` assembler (see doc 04) the reg-pair and `swi`
encodings are unambiguous, so a native-toolchain reassembly is also viable.
