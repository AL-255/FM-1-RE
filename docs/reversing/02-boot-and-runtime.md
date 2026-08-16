# 02 — Boot flow & runtime (decoded from disassembly)

All addresses are firmware/XIP addresses (`app.bin` offset + `0x02000000`).
This is decoded directly from the authoritative vendor `objdump` listing.

## Reset & C-runtime startup (`0x02000000`)

```
0x02000000  goto 0x02000004                 ; reset vector (skips the rts at 0x02)
0x02000004  sp  = 0x01c14bb4                 ; set stack pointer (RAM top)
0x0200000a  ssp = 0x01c15bb4                 ; set system/exception stack
0x02000010  call 0x020000c6                  ; copy boot params from SPL (see below)
0x02000016  ── zero .bss:  0x01c09e7c, len 0x17380
0x0200002c  ── copy .data: RAM 0x01c00000 <- flash 0x02084820, len 0x9e7c
0x02000048  ── init overlay region at 0x04000120 (fast/cache-locked RAM),
              memmove (0x02042642) from flash, then zero-fill
0x0200007e  call 0x01c00d68                  ; RAM-resident early init (runs from RAM)
0x02000084  call 0x02058a64                  ; system init (clocks/PLL/power)
0x0200008a  call 0x020053de                  ; further init
0x02000090  r6 = 0x02001c24 ; goto r6        ; tail-jump into clock/sample-rate setup
```

`0x04000120` is a special low-address window (fast RAM / cache-locked code area);
the startup copies an overlay there from the flash `.data` image so hot code/data
runs from RAM. `0x02001c24` (jumped to, not `call`ed) is **clock / sample-rate
configuration**: it divides a base of `1,000,000` by chip config fields to derive
peripheral/audio clocks (`r0 = r7 / r0`, `r0 = r0 / r3`), reading chip straps at
`0x02040204 / 0x02040400`.

### Boot-param copier `0x020000c6`
Reads a struct pointer passed by the SPL (`uboot.boot`) in `r0` and copies fields
into a global **system-info struct at RAM `0x01c7fd50`** (flash/RAM sizes, chip
id byte, clock words). Treat `0x01c7fd50` as the "boot info / sdk hw-info" block.

## Exception / interrupt path (`0x020000a0`–`0x020000c4`)

```
0x020000a0  reti = 0x01c023d6 ; rti          ; a specific exception return stub
0x020000ac  trigger                          ; software-interrupt trigger
0x020000b0  [--sp] = {sp,ssp,usp,icfg,psr,rets,retx,rete,reti}  ; full context save
0x020000b4  [--sp] = {r15-r0}                 ; save all GPRs
0x020000b8  r0 = sp
0x020000bc  call 0x020002a2                   ; C interrupt dispatcher (r0 = frame ptr)
0x020000c2  goto 0x020000c2                   ; (should not return) spin
```

So **`0x020002a2` is the C-level interrupt/exception dispatcher**; the vectors
save the full pi32v2 context (`sp/ssp/usp/icfg/psr/rets/retx/rete/reti` plus
`r0..r15`) and pass a pointer to the saved frame.

## Top-level structure: tasks, ISRs, callbacks

The firmware is event-driven on a JieLi RTOS (SDK task scheduler + software
timers + message queues). **112 indexed functions have no direct caller** — they are
reached indirectly as ISR vectors, scheduler task entries, or callbacks
registered through vtables/function pointers. The largest zero-caller roots are
the main dispatchers / task loops; see the "Top-level entry points" table in
`09-function-index.md`. Notable roots include `0x02022cfe` (out-degree 54),
`0x02070bac`, `0x0200457a`, and the audio/DAC and BT task loops in the
`0x0203xxxx` / `0x0206xxxx–0x0208xxxx` bands. To trace a feature, start from its
subsystem anchor (docs 03/04) and follow `callees` in
`analysis/master_classified.json`.

## Register/stack model (pi32v2)

- `sp` (r15 role) main stack, `ssp` system/exception stack, `usp` user stack.
- Special regs saved on exception: `icfg, psr, rets, retx, rete, reti`.
- `rets` = subroutine return address (`[--sp]=rets` / `{pc,..}=[sp++]` = call/ret).
- 64-bit values use register pairs `rA_rB` and `d[addr]` (double) load/stores.

## RAM layout (consolidated)

| Region | Address | Notes |
|---|---|---|
| `.data` (init from flash `0x02084820`) | `0x01c00000` | len `0x9e7c` |
| `.bss` (zeroed) | `0x01c09e7c` | len `0x17380` |
| system-info struct | `0x01c7fd50` | filled from SPL boot params |
| main stack top | `0x01c14bb4` | grows down |
| system stack top | `0x01c15bb4` | exception context |
| RAM-resident code (overlay) | around `0x01c00d68` | called from reset |
| fast/locked window | `0x04000120` | overlay dest |

## Key anchor addresses

| Address | Role |
|---|---|
| `0x02000000` | reset vector |
| `0x020000a0` | exception return stub / vector area |
| `0x020000b0` | IRQ common entry (context save) |
| `0x020002a2` | **C interrupt/exception dispatcher** |
| `0x020000c6` | boot-param → sysinfo copier |
| `0x02058a64` | system init (clock/power) |
| `0x02001c24` | clock / sample-rate configuration |
| `0x01c7fd50` | system-info / hw-info RAM struct |

> Note: some boot targets are reached by computed `goto` (e.g. `goto r6`) and by
> calls into RAM (`0x01c00d68`), so they are not all in the call-target-derived
> function list; they are documented here from the linear/boot trace.
