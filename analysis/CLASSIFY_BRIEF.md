# FM-1 firmware function classification brief

You are classifying functions from a full disassembly of the **M-Vave FM-1**
firmware (`app.bin`, pi32v2 ISA, loaded at flash VMA `0x02000000`). The FM-1 is a
Yamaha-DX7-compatible 6-op FM synthesizer on a **JieLi BR22 / AC693N** Bluetooth-audio
SoC. The synth engine is a port of **Google msfa (Dexed/MicroDexed)**; the OS is
JieLi's soundbox SDK (small RTOS: tasks, messages, timers).

## Your task

Read the shard file given to you. It contains every firmware function in an
address range, in address order, as:

```
===== FUNC 0x0203e962 size=434B ninsn=157 callers=0 callees=2 KNOWN_LIB=memmove =====
  callee-libs: 0x02042642=memmove, 0x02042f08=memset
  strings: 0x0204f0cb:'FM-1 Midi'
  data-refs: 0x01c0953c, 0x01c0e670
    0203e962: [--sp] = {rets, r10-r4}
    ...
```

For **every** `FUNC` produce one JSON object:

```json
{"addr":"0x0203e962","subsystem":"SYNTH_FM","name":"dx7voice_process","purpose":"per-voice operator compute loop over 6 ops","conf":"high"}
```

Rules:
- `subsystem`: one of the taxonomy values below (string, uppercase).
- `name`: snake_case suggested symbol (use the KNOWN_LIB name verbatim when present).
- `purpose`: ≤ 12 words, concrete ("crc16 over buffer", not "helper function").
- `conf`: `high` (certain from evidence), `med` (strong inference), `low` (guess).
- If a FUNC has KNOWN_LIB set, copy it (`subsystem` MEMLIB/MATHLIB as appropriate,
  `conf` high) and move on — do not spend analysis effort on it.
- If you truly cannot tell, use `"subsystem":"UNKNOWN", "name":"sub_<addr>", conf:"low"`.
  Keep UNKNOWNs under ~25% of your output; use `med`/`low` inferences liberally.
- Trailing instructions after a function's return often belong to an unnamed
  adjacent function — classify by the dominant body.
- Write ONLY the JSON array to your output file. No markdown, no commentary.

## Subsystem taxonomy

| Tag | Meaning |
|---|---|
| SYS | boot/CRT, exceptions, clock/power init, chip config |
| RTOS | task scheduler, msg queues, timers, semaphores, idle, interrupt mgmt |
| MEMLIB | memcpy/memset/str*/stdio-ish C library |
| MATHLIB | libm, softfloat, 64-bit arith, CRC/checksums, fixed-point helpers |
| SYNTH_FM | msfa/Dexed engine: operators, envelopes, LFO, algorithms, voice mgmt, patch unpack |
| AUDIO_OUT | DAC driver, audio DMA ring, sample-rate conv, mixer, volume, audio task |
| MIDI | MIDI byte parser/serializer, note/CC routing to synth, sysex handling, arpeggiator/sequencer note sources |
| USB | USB device stack, descriptors, endpoints, USB-MIDI/audio class drivers |
| UI_MENU | menu tree, parameter pages, value editing, encoder handling at logic level |
| UI_DISPLAY | LCD/OLED/seg driver, frame buffer, text rendering, backlight |
| INPUT | key matrix scan, button debounce, encoder GPIO, ADC (pitch/mod wheel) reading |
| FX | reverb/chorus/phaser/filters applied to mixed audio |
| STORAGE_FS | nor flash driver, FAT/jlfs filesystem, file IO |
| STORAGE_PATCH | DX7 bank/patch load/save, sysex bank dump, preset mgmt |
| BT | Bluetooth stack/app glue, BLE-MIDI, OTA, A2DP/AVRCP/HFP |
| POWER | battery, charge, LDO, sleep/wakeup, low-power |
| PERIPH | GPIO/UART/SPI/I2C/timer/PWM/ADC low-level drivers, pin mux |
| SECURITY | crypto, hash, firmware sig/CRC check |
| APP | top-level app state machine, mode switching, glue not fitting elsewhere |
| UNKNOWN | cannot determine |

## pi32v2 reading guide (JieLi Blackfin-derived)

- 16-bit instruction words, LE. `call X` pushes return addr to `rets`? No — calls
  store via link; convention: args in `r0..r3`, return in `r0`. `rets` = return reg.
- Prologue `[--sp] = {rets, r10-r4}` = push registers; epilogue `{pc, r10-r4} = [sp++]`
  = pop + return. `rts` = return.
- `r3_r2 = r2 * r1 (u)` = 64-bit result pair (r3 high). `d[addr]` = 64-bit mem access.
- `b[r1+8] (u)` = unsigned byte load; `h[..]` = halfword; `(s)` = signed.
- `ifs (cond) { ... }` = if-execute block; `rep N rX { ... }` = hardware repeat loop.
- `goto r6` / computed goto = indirect jump (often a switch table or tail call).
- Immediate loads of 0x00010000/0x00020000/0x00040000/0x00070000/0x00080000/
  0x000F0000/0x00100000 (+offsets) = **SFR (peripheral register)** accesses → PERIPH-ish.
- RAM globals live at `0x01C00000..0x01C211FC`; struct base `0x01C7FD50` = boot hwinfo.
- Literal `0x0204xxxx`..`0x0205xxxx` loads in code = rodata pointers (strings/tables).

## Known exact anchors (use as landmarks)

- msfa tables (proven): `pitchmodsenstab 0x0204EB90`, `ampmodsenstab 0x0204EF4C`,
  `velocity_data 0x0204F760`, `coarsemul 0x0204FC44`; more msfa rodata (sin/exp2/
  freqlut/algorithm table) in `0x0204E000..0x02050000`. Code referencing these is
  SYNTH_FM (msfa `dx7note.cpp`, `fm_core.cpp`, `env.cpp`, `lfo.cpp`, `pitchenv.cpp`,
  `freqlut.cpp`, `sin.cpp`, `exp2.cpp`, `fm_op_kernel.cpp`).
- USB descriptors/strings: device desc `0x0204F07D` (VID 0x4C4A PID 0x4155),
  `"FM-1 Midi" 0x0204F0CB`, `"FM-1 Audio" 0x0204F182`, `"Jieli Technology" 0x0204F46F`,
  `"USB Composite Device" 0x0204F573`, `"midi_route" 0x0204ED77`.
- UI: menu strings like `"1/6 OP1 Envelope"`, effects pointer table `0x0204F90C`
  (Preset/Phaser/Low Pass/Band Pass/...).
- Boot: reset `0x02000000`, C dispatcher `0x020002A2`, sys init `0x02058A64`,
  clock config `0x02001C24`, hwinfo struct `0x01C7FD50`.
- libc exact matches are pre-labelled KNOWN_LIB in the shard.
- Band note: `0x02042xxx`..`0x02043xxx` is mostly libc/libm (many KNOWN_LIB).
  `0x02084820..0x0208E59C` is the `.data` flash image: code there is RAM-resident
  (copied to `0x01C00000+` at boot) — often overlay/hot paths (audio IRQ, flash
  erase/write, mask-ROM-call stubs).

## Reference sources you may consult (read-only, on disk)

- msfa (the synth engine — the single best reference for SYNTH_FM):
  `reference/dexed/Source/msfa/`
  and `reference/Synth_Dexed/src/`
- JieLi peripheral docs (register meanings): `reference/jielie/periph/*.md`
- JieLi BR23 soundbox SDK source (sibling chip, same SDK generation — drivers/OS
  structure closely match): `reference/ac695n_soundbox_sdk/`
- DX7 patch format: msfa `dx7note.cc` `unpackProgram()`.
