# 07 — Input: key matrix, rotary encoder, pitch/mod wheels (ADC)

Target: M-Vave FM-1, JieLi AC791N/WL82 (pi32v2), firmware image base `0x02000000`.
All addresses are flash VMAs unless noted. RAM global base used throughout: `0x01C0E670`
(the "app/IO state" struct — tick counters, event queue, ADC tables, key state all live
inside it). Confidence tags: **high** = proven from disassembly, **med** = strong
inference, **low** = hypothesis.

Primary evidence: `analysis/shards/shard_02022c7a_02027292.txt` (key/encoder scan cluster,
app main task), `analysis/shards/shard_020000a0_020020de.txt` (ADC scan),
`analysis/shards/shard_02003b7c_02005bb2.txt` (GPIO drivers, board_init).

> **Shard caveat (med):** the disassembler merges the whole scan cluster
> `0x0202423C..0x02024876` into one `FUNC 0x0202423c` record. It really contains four
> routines: `adc_value_get` (`0x0202423C`), the wheel/battery tick (`0x02024358`), the
> key-matrix scan (`0x020244A2`) and the encoder poll (`0x020247AA`). Timer-callback
> addresses registered in `board_init` point *inside* this cluster, so exact per-entry
> boundaries are ± a few words.

---

## 1. GPIO access layer

All pin access goes through dispatchers that split the pin number space into three
ranges (from `gpio_set_direction` `0x02003F78`, shard_02003b7c_02005bb2.txt):

| Pin range | How driven | Evidence | conf |
|---|---|---|---|
| `0..144` | port table `0x020559D0`, `base = table[pin >> 4]`, 16 pins/port; set/clear via `[base+8]` under a per-bank lock byte at `0x01C0E670+656+(pin>>4)` | `gpio_port_base` `0x020038EC`, `gpio_set_direction` `0x02003F78` | high |
| `144..147` | mapped to P33 index `(pin+112)&0xFF` (= pin−144); access via mask-ROM services `0xFFC00EEA` (P33 read) / `0xFFC00F2E` (P33 write), id `0x809A` | `0x02003C52` (`if (r4 > 1) return -22`), `0x02003904` | high |
| `148,149` | SFR `0x51000`, bit `1 << (pin-146)` (pins 148/149 → bits 2/3) | `0x020039BE` (`r2 = r0 & ~1; if (r2 != 148) return`) | high |
| `150,151` | USB DP/DM — not bit-bangable through the same path (consumed by the USB macro); SFR `0x16A0C` appears in USB glue | db.json USB funcs | low |

Useful GPIO front-ends (all PERIPH, conf high from db.json):

| addr | name | notes |
|---|---|---|
| `0x02003F78` | `gpio_set_direction` | r0=pin, r1=1 input / 0 output; dispatches the ranges above |
| `0x02003F3C` | `gpio_input_pullup` | input + pull-up (used for key/encoder pins in `board_init`) |
| `0x02004014` | `gpio_config_output` | push-pull output, pulls off, die on |
| `0x02004058` | `gpio_config_input_hiz` | high-Z input, no pulls, die off |
| `0x02003B7C` | `gpio_set_hd` | enable high-drive current on a pin |
| `0x02003A9E` | `gpio_set_direction` (dispatching) | same range split, alternate entry |

GPIO writes are SMP-safe: the SoC is dual-core (`cnum`/`lockset`/`lockclr` instructions);
the shared counters at `0x01C09534` / `0x01C0953C` implement the outer lock seen around
every GPIO/event-queue write (`0x02003FAC`).

---

## 2. Key matrix scan

**Scanner: `0x020244A2`** (inside FUNC `0x0202423c`, shard_02022c7a_02027292.txt), driven
by a system timer — `board_init` `0x0200417E` registers five timers through
`sys_timer_add` `0x02004036` → `sys_timer_add_internal` `0x020021FC`:

| handler addr | period | role (conf med) |
|---|---|---|
| `0x02024478` | 2 ms | input tick (wheel/battery, inside scan cluster) |
| `0x020245C2` | 20 ms | key scan, inside scan cluster |
| `0x020248CA` | 50 ms | UI housekeeping (lands in `menu_page_event_handlers` cluster) |
| `0x02021108` | 2 ms | app/UI tick (not input) |
| `0x02021356` | 2 ms | app/UI tick (not input) |

### 2.1 Key map and debounce

The scan loop (`0x0202456E..0x020247A2`) iterates **41 key positions** (`i = 0..40`,
loop bound `0x290000`):

- Key-map table: **`0x02046254`**, one byte per position: `byte = (gpio_port_byte << 4) | pin_bit`.
  The port byte indexes a shadow GPIO-input bitmap via the pointer at `[0x01C0E670+320]`;
  the low nibble selects the bit (`0x02024588..0x0202459E`). Who refreshes that shadow
  bitmap is not visible in the captured call graph (**low**).
- Per-key state: 2 bytes at `0x01C0E670+2836+i*2` — `b+0` = debounce counter,
  `b+1` = state (0 released / 1 pressed / 2 held).
- Thresholds (in scan ticks): **3** ticks to confirm a press or release edge,
  **41** ticks for long-press (`0x020245B0`, `0x0202462E`, `0x02024726`).

### 2.2 Key events

On state transitions the scanner pushes a 32-bit event word into the input event queue
(Section 5). Encoding observed (**med**):

```
event = (key_id << 16) | code        class 0x00 (top byte 0)
code: 0 = press confirmed  1 = release/short-press  2 = long-press  3 = hold-repeat
```

Evidence: `0x020245D2` posts `r4-3` = `(i<<16)|0`; `0x02024650` posts `(i<<16)|1`;
`0x02024748` posts `(i<<16)|2` after 41 ticks; `0x020246D6` posts `(i<<16)|3`
(state 2 hold). 

Special combo (**high**): if the state bytes for scanner slots 0 and 1
(`0x01C0E670+2837` and `+2839`) are both 1, the scanner first writes
`0x64006400` over the two state records, then posts the synthetic triplet
`0x00000064`, `0x00010064`, `0x06000001`
(`0x020244A2..0x02024546`). The first two words are code `0x64` for key slots
0 and 1; the last is class 6.

This is not a hidden factory/debug entry. Class 6 reaches `0x02023114`, which
clears signed state bytes `ENG+4779` and `ENG+4780`, then refreshes the current
UI label. Those bytes are the octave and semitone shifts used in the note
calculation documented in `05-midi.md`. V14 preserves the same sequence at
`0x02024B7C` and the same handler behavior at `0x0202334A` (shifted globals
`ENG+5099/+5100`). The physical labels for scanner slots 0 and 1 remain
unmapped, but the chord's software effect is an octave/semitone reset (**high**).

---

## 3. Rotary encoder

**Poll: `0x020247AA`** (same cluster). Seven encoder slots, 20-byte records at
`0x01C0E670+4496+i*20`, `i = 0..6` (loop bound 140):

| offset | meaning (conf med) |
|---|---|
| `+0` (byte) | shift/divisor — `board_init` sets it to 1 for all 7 slots (`0x020042CE..0x020042FA`) |
| `+4` (word) | current raw count (written by whoever reads the encoder pins — likely a GPIO-edge IRQ, **low**) |
| `+8` (word) | reference count |
| `+12` (word) | accumulated remainder |

Logic (`0x020247C2..0x02024872`): `delta = cur − ref; steps = |delta| >> shift;`
if non-zero, post **`0x07000000 | (enc_id << 16) | ±steps`** and advance the reference.
The app-task dispatcher subtracts 2 from the encoder id (`uextra(r6,16,8) - 2`,
`0x02023812`), so the wired encoder(s) use ids ≥ 2 — i.e. slots exist for up to 7
encoders, FM-1 uses only a subset (**med**).

---

## 4. Wheels and battery: the SARADC path

### 4.1 ADC driver

- **SARADC base `0x13100`** (`CON` +0, `RES` +4; jielie `adc.md`). 10-bit result.
- **`adc_channel_scan` `0x0200053A`** (shard_020000a0_020020de.txt), called from the
  input tick:
  - skipped while `[0x13100] & 0x10` (ADC_EN still armed) and gated by
    `[0x01C0E670+3000] != -1`;
  - round-robins a **10-slot channel table**, 8-byte records at `0x01C0E670+2920+i*8`:
    `+0` = channel id (word), `+4` = latest value (halfword);
  - programs `CON = 0xF06E | (ch << 8)` then `|= 0x10` (EN) and `|= 0x40` (CPND)
    (`0x02000640..0x0200066C`): WAIT_TIME=15, IE on, analog enable, clock div 6
    (≤1 MHz per `adc.md`);
  - channel id **15** takes a special path (ROM service `0xFFC00F6C`, analog mux SFR
    `0x11900` bit 14 — internal rail, **med**);
  - watchdog: `h[0x01C07D40]` counts ticks; >100 without progress re-runs the
    3-state re-init at `b[0x01C0E670+0]` (`0x0200059C..0x020006AC`).
- **`adc_add_sample_ch` `0x0200407A`**: registers a channel id into the first free
  (`-1`) slot of the 10-slot table, initial value 1.
- **`adc_value_get` `0x0202423C`** (head of the merged cluster):
  - `arg == 15` → returns `h[0x01C0E670+66]`;
  - `arg == 0x5000E` → returns the average of the **20-sample ring** at
    `0x01C0E670+1472` (ring index at `0x01C0E670+112`) — used for battery (**med**);
  - otherwise → linear search of the 10-slot table, returns `h[slot+4]`.

### 4.2 What FM-1 wires to it

`board_init` `0x0200417E` (`0x020043F8..0x02004400`):

```text
adc_add_sample_ch(3);    // SARADC ch3
adc_add_sample_ch(4);    // SARADC ch4
```

These are the **pitch and mod wheels** (per the project classification); which
channel is pitch versus mod remains unverified.

The wheel/battery tick `0x02024358`:

- every tick: `adc_value_get(4)` → `h[0x01C0E670+100]`; **edge detect** against the
  previous latched value `h[0x01C08FF0+2]`: if `|new − old| ≥ 13` for 10 consecutive
  ticks, post **`0x04000000 | (value bits 3..15)`** (class-4 analog event,
  `0x02024416..0x02024460`);
- every tick: `adc_value_get(3)` accumulated into `[0x01C0E670+324]`;
- every **256** ticks: drive GPIO **149** high, read `[0x51004] >> 1 & 1` → charger /
  USB-present flag at `b[0x01C0E670+37]`, convert the 256-sample average
  (`acc >> 8`) into a 0..3 battery level (raw thresholds ≈ 520/531/550/591,
  `0x020243BA..0x020243E8`) → `b[0x01C08FF0+0]`, then GPIO 149 low.

> **Reconciliation note (low):** the code shows ch3 feeding the battery/level path and
> ch4 feeding the wheel-event path, while the project brief labels both 3 and 4 as the
> wheels. The likely hardware truth is that ch3 is *shared* between the battery divider
> and one wheel through an analog mux switched by GPIO 149 (a common JieLi board trick);
> treat exact assignment as unverified until traced on a schematic.

**Wheel-calibration UI evidence (low/med):** the settings-menu string block contains
`'Pitch Up'` `0x0204ECA9` and `'Pitch Dn'` `0x0204ECB2` (alongside `'Note Chn'`
`0x0204ECA0`, `'Effect Chn'` `0x0204ED61`, `'Save'` `0x0204ED72`) — consistent with a
"move wheel fully up / fully down" calibration page in the settings menu. The
calibration routine itself was not separately identified (probably folded into the
settings edit handler `0x02018958`, see 08-display.md).

---

## 5. Event flow: scanner → queue → app task

### 5.1 The queue

32-entry ring of 32-bit event words at **`0x01C0E670 + 3588`** (`0x01C0F474`):

| field | addr | conf |
|---|---|---|
| write index (halfword) | `0x01C0E670+96` | high |
| read index (halfword) | `0x01C0E670+98` | high |
| entries | `0x01C0E670+3588 + 4*i`, `i = 0..31`, `-1` = consumed | high |

Producers (key scan, encoder poll, wheel tick, battery) wrap the write index at 31 and
publish under the dual-core lock: `cli`, bump per-core counters `0x01C0953C`/`0x01C09534`,
`lockset` on contention, write, `csync`, unwind, `sti` (canonical sequence at
`0x02024424..0x02024498`).

### 5.2 The consumer: app main task

**`usr_app_task` `0x02022CFE`** (db name, conf high; task name string `'usr_app_task'`
`0x0204EE59`). After hardware/LCD/audio init (see 08-display.md), it runs the event
loop at `0x020237D6`:

1. Pop: `while (read_idx != write_idx) ev = queue[read_idx++]; if (ev == -1) continue;`
   (`0x020237D6..0x020237FC`).
2. **Page handler first**: current page id `b[0x01C0E670+23]` indexes the page-handler
   table at `0x0204EA00+2828` = **`0x0204F50C`**; `handler(ev)` runs before the default
   path, non-zero return = consumed (`0x02023850..0x0202386A`).
3. **Class dispatch**: `tbb [ev >> 24]` jump table, 8 classes 0–7
   (`0x0202386C..0x02023884`). The table bytes are `07 3e 3e 3e 06 3e 05 04`;
   pi32v2 `tbb` branches from the instruction end by twice the selected byte.
   - class `0x00` — fallback key fan-out at `0x02023884`: masks `ev >> 16`,
     accepts values 0..13, and performs an indirect call with `ev & 0xFF`.
     The apparent table location does not contain flat code pointers, so the
     callback representation/reachability remains unresolved. Page handlers
     receive each event first.
   - classes `0x01`, `0x02`, `0x03`, and `0x05` — default drop/end path;
   - class `0x04` — wheel analog value (`0x020230AA`);
   - class `0x06` — octave/semitone reset handler (`0x02023114`); it acts only
     when `(ev >> 16) & 0xFF` is zero, as it is for `0x06000001`;
   - class `0x07` — encoder (`0x0202315E`): id = bits 23:16; ids 2..5 routed to element callbacks
     through the current page's widget list `[0x01C0E670+356]`
     (`0x0202380E..0x02023846`), with `ui_widget_invalidate` `0x02018C9C` and
     `ui_ctx_release` `0x020174EC` around them.

Idle-loop extras: every 40 iterations the battery/charge UI is refreshed
(`0x02023924..0x02023960`, battery level byte `b[0x01C08FF0+0]`, charge flag
`b[0x01C0E670+37]`).

---

## 6. Recovered input interfaces

`adc_add_sample_ch 0x0200407A(channel)` registers a sampled channel, and
`adc_value_get 0x0202423C(channel)` returns its latest approximately 10-bit
value. Channel IDs 0–14 map directly into `CON[11:8]`; ID 15 and `0x5000E` are
reserved for internal and battery paths. Sampling advances only while the
input timers run.

The scanner posts 32-bit event words into a 31-entry ring at `0x01C0F474`.
Head and tail indices are the halfwords at `ENG+96` and `ENG+98`; updates use
the SMP lock counters at `0x01C09534` and `0x01C0953C`. Page handlers are
selected through the 32-bit table at `0x0204F50C`, indexed by page ID. These
locations describe the stock event path and are not established public APIs.
