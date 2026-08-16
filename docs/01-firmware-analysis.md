# 01 — Firmware characterization

## Package

`FM-1.fwsc` is a JieLi "new firmware" container, unpacked with
[`kagaimiq/jl-misctools`](https://github.com/kagaimiq/jl-misctools)
(`3rd-party/jl-misctools/firmware/fwunpack_newfw.py`). `jlfw.yaml` from the unpack:

```yaml
app-files: [files/app.bin, files/cfg_tool.bin]
res-files: [files/cfg]
entry-point: 33554720          # 0x020000A0
chip-key: 38927                # 0x980F
spl: { file: top/uboot.boot, compressed: false }
```

Components:

| File | Role | Nature |
|---|---|---|
| `top/uboot.boot` | SPL / secondary bootloader ("UBOOT2.00") | **vendor blob** |
| `files/app.bin` (583 068 B) | main application | **CPU code — disassembled here** |
| `files/cfg_tool.bin` | config-tool descriptor | vendor blob |
| `files/cfg` | packed resources (EQ, tone cfg, UI) | vendor blob / resource |

`app.bin` is the main pi32v2 executable analyzed by the two function-mapping
pipelines. The SPL and nested OTA loader are separate pi32v2 executables with
focused analyses under `analysis/device/`; configuration and UI files are data
resources rather than application code.

## SoC / CPU

The package header and configuration identify the target as **JieLi
AC791N/WL82**. The stock SPL also byte-matches the AC79 SDK lineage documented
in `analysis/device/uboot/README.md`. Strings in `app.bin` (`JL-BR22`, `br22xx`,
`JL_A2DP`, `INCLUDE_BTSTACK-$ac3ebaf`) come from linked Bluetooth-library
lineage and are not authoritative SoC identification. The physical part is
marked **`C156211-11B8`** (LQFP48); JieLi laser markings are house codes rather
than catalog part numbers. Per
[kagaimiq/jielie](https://github.com/kagaimiq/jielie), the BR2x generation uses
the **pi32v2** CPU (custom, Blackfin-derived, 32-bit, 16-bit little-endian
instruction words). This was confirmed empirically: importing `app.bin` with the
`pi32v2` SLEIGH spec decodes cleanly, while `pi32` stalls almost immediately
(159 vs 26 instructions followed from the entry point).

## Memory map (derived from the reset vector)

The first bytes of `app.bin` are the reset vector and C-runtime startup. The
disassembly reads directly:

```
02000000  goto 0x02000004            ; reset
02000004  mov  sp,#0x1c14bb4         ; stack pointer  -> RAM top
0200000a  mov  ssp,#0x1c15bb4        ; system stack
02000016  mov  r3,#0x1c09e7c         ; \
0200001e  mov  r2,#0x17380           ;  > zero-fill BSS (size/4 words)
02000026  rep ...; sw r1,[r3++=4]    ; /
0200002c  mov  r4,#0x1c00000         ; \  copy .data: RAM dest
02000032  mov  r1,#0x2084820         ;  > source = flash LMA
02000038  mov  r2,#0x9e7c            ;  > size
02000040  rep ...; lw/sw [++=4]      ; /
```

Resulting map:

| Region | Address | Size |
|---|---|---|
| Code / rodata (XIP flash) | `0x02000000` … `0x0208e59a` | ~583 KB |
| Entry point | `0x020000A0` | — |
| `.data` LMA (init image in flash) | `0x02084820` | `0x9e7c` |
| RAM base / `.data` VMA | `0x01c00000` | `0x9e7c` |
| `.bss` | `0x01c09e7c` | `0x17380` |
| Stack top | `0x01c14bb4` | — |

So RAM sits at `0x01c00000` and code executes in place from flash at
`0x02000000`. `.data` is copied flash→RAM at boot; `.bss` is zeroed.

## SDK lineage

Build-stamp strings show a modified JieLi Bluetooth SDK
(`fw-AC63_BT_SDK`-style): `INCLUDE_BTSTACK-$ac3ebaf`, `JL_A2DP`, `JL-BR22`,
`UPDATE-*modified*-…`, `DRIVER-*modified*-…`. The application links JieLi's
BTStack, A2DP, and update subsystems — all of which are vendored (see
`04-toolchain-and-vendoring.md`).
