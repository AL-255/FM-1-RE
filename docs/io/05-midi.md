# FM-1 MIDI I/O

Reverse-engineered from `app.bin` (pi32v2, flash VMA `0x02000000`). Every claim
carries the function address it was read from; `[high|med|low]` marks
confidence. Code citations name the enriched shard the
disassembly was taken from (e.g. `shard_020000a0_020020de.txt`).

Terminology used below:

- **MIDI engine struct** — the large app-global state block at `0x01C0E670` (≈8 KB,
  shared by MIDI, USB, arp/seq and patch code). Written `ENG` in tables.
- **Route** — one MIDI input source (UART DIN, USB-MIDI, BLE-MIDI, internal). Each route
  owns a power-of-two ring buffer plus a 12-byte parser context.
- **CIN** — USB-MIDI Cable-IN code (4-bit). The byte-stream parser's return values are
  CIN codes; see §3.4.

---

## 1. Architecture at a glance

```
 UART RX DMA ─┐
 USB EP4 OUT ─┼─> route ring buffers ─> midi_stream_parser 0x02000C48
 BLE-MIDI ────┘        (per route)            │ complete messages
                                              v
                              serial_midi_task 0x02027AF4 ("c04"/"04" taskq)
                                              v
                              midi_message_handler 0x02023EA0
                                │ DX7 sysex → patch store (0x01C118B0)
                                │ notes/CC ──> b[ENG+25]==2 ? note_on/off_route
                                │                            (arp/seq capture)
                                └────────────> midi_msg_dispatch 0x0201F5F4
                                                 │ voice alloc (468B stride)
                                                 v
                                           msfa/Dexed synth ctx [ENG+252]

 synth/arp/seq ─> midi_note_on_inject 0x02020552 ─┬─> midi_msg_dispatch (play)
                                                 └─> midi_out_fifo_push 0x0201FDDE
                                                     (running-status serializer,
                                                      out ring ENG+912..920)
```

Out-bound paths: UART TX DMA (`0x12114/0x12118`), USB EP4 IN (`usb_ep_write`
`0x02005D86`), BLE GATT notify (`att_server_notify` `0x020801A4`). A route-merge pump
(`midi_route_input_poll` `0x020279A8`) merges route input into the UART TX DMA buffer
`0x01C0F574` (≤125 bytes/pass) — this is the MIDI-thru path.

---

## 2. The three transports

### 2.1 UART MIDI (DIN)

| What | Address / location | Notes |
|---|---|---|
| UART RX/timeout IRQ | `uart_rx_irq_handler` `0x02027DD0` (body `0x02027E2E`) [high] | SFR status `0x12100`: bit `0x4000` = RX-pending, bit `0x800` = timeout; ack with `\|0x80`, `\|0x1000/0x400/0x2000` |
| RX DMA byte count | `h[0x12128]` (SFR `0x12100+40`) | read inside IRQ |
| RX staging buffer | `ENG+3972` (128 B), count `h[ENG+102]` | drains into route ring on 128 B wrap |
| Ring push helper | `0x02027DD0` (head) [med] | writes `ENG+928`(wr)/`ENG+932`(mask)/`ENG+936`(base) ring, posts taskq msg **128** to `"c04"` (`0x0204EE96`) via `os_taskq_post_msg` `0x02059A68` |
| Serial MIDI task | `serial_midi_task` `0x02027AF4` (main loop `0x02027B06`) [high] | pends on taskq (`__os_taskq_pend` `0x0205B520`), msg id 13 + sub-ids 1..19, ids 128..148 |
| UART TX DMA kick | entry `0x02027AF4` [high] | `[0x12114] = 0x01C0F574; h[0x12118] = r0(len)` |
| TX DMA staging buffer | `0x01C0F574` (= `ENG+3844`) | filled by `midi_route_input_poll` |

Task-loop specifics (`shard_02027346_02028fc6.txt`):

- On wakeup it repairs per-route ring links (`ENG+824` index table, count `b[ENG+836]`),
  resets route lock `b[ENG+837] = 0xFF`, then pumps:
  - `midi_route_input_poll` `0x020279A8`; if it merged >0 bytes, kicks TX DMA via
    `0x02027AF4` (thru path).
  - Output hooks `[ENG+400]` and `[ENG+412]` (function pointers; USB-MIDI installs
    `[ENG+400] = 0x02005FAC` at open, §2.2); each is called once per loop with
    dedup bits in `r15`.
  - Per-route parse: for route `i` (< `b[ENG+836]`), context at
    `ENG + b[ENG+824+i]*12 + 4632`, calls `midi_stream_parser` with mode flag
    `r2 = (b[ENG+837] != i)` (route-lock arbitration, `b[ENG+837]`).
- Vendor sysex magic `F0 35 59 … F7`: messages are accumulated in the 254-byte staging
  area `ENG+6552` (index `[ENG+396]`). A 7-byte frame `F0 35 59 xx xx xx F7` sets
  `b[ENG+6555] |= 0x80` (arms the M-Vave vendor channel) and is swallowed; other
  complete frames go to `midi_message_handler`. (`0x02027D6A-0x02027D98`) [high]
- Two syscmd receive records converge here. USB-MIDI's 8-to-7 unpacker uses
  `ENG+812` (ready state `b[ENG+813]`, bit length `h[ENG+816]`, data pointer
  `[ENG+820]`) and calls `0x02026BC4(..., transport=0)`. Bluetooth event
  `0x72` uses state `b[ENG+648]`, data at `ENG+9876`, and end pointer
  `[ENG+652]`, then calls the same dispatcher with `transport=1`. See §5.4 and
  `11-ota-protocol.md`. [high]
- msg 128-ish sub-handler at `0x02027C56` sends a fixed 16-byte packet loaded from
  `0x0204EA00+1884` (= `0x0204F15C`) through `0x02083458` (BLE/notify-side send). [low]

### 2.2 USB-MIDI (bulk EP4)

Full USB-side detail is in `06-usb.md` §5; the MIDI-relevant facts:

| What | Address | Notes |
|---|---|---|
| EP open | `usb_midi_ep_open` `0x02005BB2` [med] | EP4 bulk 64 B IN (`0x84`, DMA buf `0x01C20E1C`) + OUT (`0x04`, buf `0x01C20EA4`); TX cb `0x020061E4`, RX cb `0x0200685C`; installs `[ENG+400] = 0x02005FAC` (USB route output hook); posts taskq msg **18** to `"c04"` |
| RX parse | `usb_midi_rx_parse` `0x02006384` [high] | 64 B packet = 16 × 4-byte USB-MIDI events; CIN/event filter `b0 ≤ 31 && (b0 & 0xE) != 0`; running-status squashing via `b[ENG+956]`; pushes merged bytes to ring `ENG+944/948/952`; posts msg **128** to task `"04"` (`0x0204EE97`) |
| Vendor binary reassembly | same function [high] | three consecutive USB-MIDI CIN-4 events initialize `ENG+812`, then 7-bit→8-bit unpack into `ENG+9876`; completion sets the receive record ready for syscmd with transport 0. A separate 6-byte magic + `0x7D/0x7F` + `F7` trailer enters loader mode (mask-ROM call `0xFFC02532`) — firmware-update trigger [med] |
| TX sysex engine | `usb_midi_sysex_engine` `0x02005D86` (EP writer) + body `0x02005E8C` [high] | frames 64 B USB-MIDI packets: CIN 4 start/continue, CIN 5/6/7 end (1/2/3 bytes), zero-pad; DX7 dumps are re-packed 8→7 bit; suppresses looped-back `F0 35 59 … F7` (12-byte check at `ENG+800..811`); merges other routes' messages via `midi_stream_parser` (return value = CIN written to packet byte 0) |
| Route output hook | `0x02005FAC` [med] | mid-function entry into the TX engine; called from `serial_midi_task` through `[ENG+400]` |

### 2.3 BLE-MIDI (GATT notify)

| What | Address | Notes |
|---|---|---|
| BT packet-layer context | `[0x01C0CAB8]` | 188 B struct + ring; 24-entry channel table (+0), 8 conn slots (+96, handle = `h[+2]>>6`), TX ring at +128, wr/rd at +152/+156, MTU h[+176] |
| Fragment writer | `bt_pkt_fragment_write` `0x020748A0` [med] | `(con_handle, cid, buf, len, …)`: 6-byte record header `{u16 handle, u16 cid, u16 len\|flags}` per MTU-sized chunk into TX ring; `-93/-95/-97/-98` error codes |
| Free-space probe | `bt_pkt_tx_space` `0x020747E6` [med] | ring free payload in MTU units |
| Layer init | `bt_pkt_layer_init` `0x02074A28` [med] | `(handle_max, ctx, size, mtu)`, ctx zeroed 188 B |
| GATT notify | `att_server_notify` `0x020801A4` [high] | `(con_handle, att_handle, data, len)`; ATT opcode `0x1B` staged at `b[0x01C0C6DC+16]`; PDU built by `0x020375F2`, sent on L2CAP CID 4 via `0x0207D212`; ret 0 ok / 2 no-conn / 87 busy |
| GATT indicate | `att_server_indicate` `0x020801F8` [high] | opcode `0x1D`, arms 30 000 ms confirm timer (`sys_timeout` `0x0207AAAE`, cb `0x02080916`) |
| ATT server setup | `ble_att_server_setup_init` `0x02080104` [med] | ATT state `0x01C0D6F4`; app packet handler registered by `att_server_register_packet_handler` `0x0208015A` → `0x02000B22` (entry inside `midi_control_cmd_dispatch`, §5.3) [low] |
| BLE-MIDI packet build | route pump `0x02000ECE` (inside `midi_stream_parser`'s FUNC) [med] | Apple BLE-MIDI format: header `b[ENG+45]\|0x80` (ms high bits) then per-event `b[ENG+46]\|0x80` timestamp bytes; ≤512 B at `ENG+7716`; posted to BT cmd queue via `btstack_cmd_dispatch` `0x02074B62` (msg 26/5); resumable remainder `[ENG+120]` |
| MIDI engine BLE ctx | `[ENG+568]` = `0x01C0B2E0` (pkt ctx), `[ENG+572]` = MTU %, `[ENG+576]` second pool; init `0x020736E0` | ring region `0x01C0AEE0..0x01C0C2E0` (5 KB) |

BLE control channel (app protocol, not MIDI notes): 4-byte control packets `0xD0/0xD4`
are dispatched by `midi_ctrl_packet_dispatch` `0x02000856` (`0xD0` → `0x0207DF66`,
`0xD4` → `0x0207E006`); single-byte commands `0x3E/0x77/0xB5/0xB6/0xB7/0xE2` go through
`midi_msg_prefilter` `0x02000C1A` → `midi_control_cmd_dispatch` `0x02000A02` [med].

---

## 3. The MIDI byte-stream parser `0x02000C48`

(`shard_020000a0_020020de.txt`, 2614 B enclosing FUNC — the trailing bodies
`0x02000ECE` route pump, `0x02001268` route-table writer, `0x020012BA` tag-strip
dispatch are unnamed adjacent functions.)

### 3.1 ABI

```
r0 = output buffer (≥3 B; up to message length for sysex frags)
r1 = route parser context (12 B):
       +0  running-status byte (persistent across calls)
       +4  read index into the route ring
       +8  → ring descriptor:
             +0  write index        +4  ring size (power of 2)
             +8  ring base pointer  +12 default running status
r2 = mode: 0 = raw byte stream; 1 = packet mode (consume one 3-byte
           USB-MIDI event at a time, early-out on status/F7)
returns r0 (see 3.4)
```

### 3.2 Behaviour

- **Running status**: channel data byte (<0x80) with saved status replays the saved
  status (`b[r1+0]`); a new channel status byte replaces it (`0x02000D5E`). If the
  context status is 0, the ring descriptor's default (`[r10+12]`) seeds it.
- **Length lookup**: expected total length (status + data) is fetched per message type:
  `len = b[0x0204EA00 + 0x70C + (status>>4)]` for channel voice, and
  `b[0x0204EA00 + 0x62C + status]` for system-common (`≥0xF1`). Parse bails out (return
  255) when fewer than `len-1` bytes are available.
- **2- vs 3-byte channel messages**: bitmask `0x7FDC` (bits 8,9,10,11,12,13,14 for
  3-data-byte types) decides whether the copy loop runs after the status byte.
- **System/realtime**: `0xF8..0xFF` are consumed a byte at a time (return 16 → keep
  pumping). `0xF1..0xF7` lengths come from the system table; a `tbb` switch at
  `0x02000E3C` post-processes them.
- **Sysex (`0xF0`)**: enters a fragmenting state machine — emits `F0` + data bytes
  until `0xF7` (or another status byte) terminates the message; a non-terminated chunk
  returns CIN 4 (start/continue), terminated chunks return 5/6/7 (end with 1/2/3
  bytes). The route-level reassembly into a complete `F0…F7` frame happens in the
  callers (`0x02000ECE` pump, `serial_midi_task` staging at `ENG+6552`).

### 3.3 Length tables (and a discrepancy you must know)

Code references: base register `r8/r9 = 0x0204EA00`; channel/CIN lengths at `+0x70C`
(absolute `0x0204F10C`), system lengths at `+0x62C` (absolute `0x0204F62C`).

In the shipped V13 binary the bytes at `0x0204F10C` are an arp/tempo table, **not** a
valid length table, while a spec-perfect 16-entry table sits at **`0x0204EFEC`**:
`00 00 02 03 03 01 02 03 03 03 03 03 02 02 03 01` — exactly the USB-MIDI CIN byte
counts (entries 8–14 = `3,3,3,3,2,2,3`, the channel-voice lengths), immediately
followed by system lengths (`F1:2 F2:3 F3:2 F6:1 F7:1 F8..:1`). Same 0x120-offset
anomaly appears for the CC handler table (§7) and suggests parts of this rodata bank
are (re)written at runtime or were re-linked post-disassembly. **Verify the effective
table address on target before relying on it** [med].

### 3.4 Return values = USB-MIDI CIN codes

| Return | Meaning |
|---|---|
| 4 | sysex start/continue (3-byte fragment) / complete 3-byte message in packet mode |
| 5, 6, 7 | sysex end with 1/2/3 bytes |
| 8–14 | channel message, high nibble of status (8=note-off … 14=pitch bend) |
| 15 | single-byte message (realtime) |
| 16 | byte consumed, keep pumping (realtime interleave) |
| 255 | no data available |

Callers translate the return into a byte count via the same length table (e.g. the
route pump at `0x02001072`, `midi_route_input_poll` `0x020279F0`), or write it directly
as a USB-MIDI CIN (`usb_midi_sysex_engine` at `0x02005FFA`).

### 3.5 Ring buffers

Per-route state lives in two 12-byte-stride tables: route index list `ENG+824`
(count `b[ENG+836]`, used by `serial_midi_task`) and `ENG+838` (count `b[ENG+850]`,
used by `midi_route_input_poll`). Ring descriptors themselves are in the
`0x01C0E9B4..0x01C0EA30` RAM area; the rodata table at `0x0204F008` holds pointers
`0x01C0EA00/0x01C0EA10/0x01C0EA20/0x01C0EA30/0x01C0E9B4`. Route arbitration bytes:
`b[ENG+837]`, `b[ENG+851]`, `b[ENG+865]`, `b[ENG+879]` (0xFF = unlocked).

---

## 4. Message dispatch — `midi_msg_dispatch` `0x0201F5F4`

(`shard_0201f0d0_020223ba.txt`) [high]

```
midi_msg_dispatch(ctx = [ENG+252], msg = r1, len = r2)
```

Switch on `(status>>4) ^ 8` via `tbb` at `0x0201F610` (0=note-off, 1=note-on,
2=poly-AT, 3=CC, 4=program, 5=chan-AT, default→pitch-bend check).

Synth control block (`ctx`, allocated per engine; pointer cached at `[ENG+252]`):

| Off | Content |
|---|---|
| +12 | voice count (b) |
| +16 | voice array base (stride **468 B** = `0x1D4`) |
| +20 | steal cursor (round-robin scan start) |
| +21 | sustain-pedal flag (CC64) |
| +22 | "reuse released voice first" flag |
| +30 | channel/config byte |
| +32 | active-voices hint word (`0x7FFFFFFE` written on note-on) |
| +44 | message-length gate (h; dispatch ignored if `< 3`) [low] |
| +62 | pitch bend, 14-bit `(b3<<7)\|b2` (h) |
| +72 | CC1 mod wheel |
| +76 | CC2 breath |
| +80 | CC4 foot |
| +84 | program change latch |

Note path:

- **Note-on** (`0x90`, vel≠0): transpose `note += b[ENG+5752] - 24`, reject >127.
  Voice search: from `ctx+20` cursor for a free voice (`b[v+2]==0`), else steal cursor
  voice and advance cursor mod count; optional released-voice reuse when `ctx+22`.
  Writes `b[v+0]=note, b[v+1]=channel, b[v+2]=1(active), b[v+3]=sustain`, then a large
  inlined msfa voice-init: per-operator pitch/level/rate computation from the current
  DX7 patch (op params at `ENG+5608+op*21`, pitch-EG at `ENG+5734`, 6 ops), using msfa
  tables `velocity_data 0x0204F760`, `coarsemul 0x0204FC44`, freq constant
  `0x03080730` (= `(note<<24)/12` log-freq base, msfa `freqlut`). Per-voice state:
  DX7 state block at `v+44` (see `dx7voice_state_copy` `0x0201F368`), op phase reset
  `v+264..328` (6 × 16 B op state blocks), per-op words `v+356+op*4`, `v+380+op*4`,
  pitch env `v+412`, flags `v+436/437`. Voice length 468 B.
- **Note-on with velocity 0** is dropped here (exit) — the conversion to note-off is
  done upstream (`midi_message_handler` routes `0x90` vel=0 the same as `0x80` only
  via the arp path; direct path passes it through, and velocity 0 exit) [med].
- **Note-off** (`0x80`): find voice with matching note & `b[v+2]!=0` → `b[v+2]=0`;
  if sustain held (`ctx+21`) set `b[v+3]=1` (deferred release), else
  `dx7voice_keyoff` `0x0201F46C` (6 op envs + pitch env → release) and, if
  `[v+24] != 0`, force `[v+24] = 4`, `[v+32] = 0` (env release stage) [med].
- **CC** (`0xB0`): CC1→`ctx+72`, CC2→`ctx+76`, CC4→`ctx+80`, CC64→sustain flag
  (release 0 runs the deferred `dx7voice_keyoff` sweep over voices with `b[v+3]`).
  All CC writes finish in `dx7_mod_update` `0x0201F4EA` (controller modulation
  recompute). CC64 release loop: `0x0201F6F6..0x0201F732`.
- **Pitch bend** (`0xE0`): 14-bit value → `h[ctx+62]`, then `dx7_mod_update`.
- **Program change** (`0xC0`): value → `ctx+84`, then `dx7_mod_update`.

---

## 5. Message handler & sysex — `midi_message_handler` `0x02023EA0`

(`shard_02022c7a_02027292.txt`) [high]

```
midi_message_handler(msg = r0, len = r1)   // called from serial_midi_task / USB parse
```

State `b[ENG+34]`: 0 = scanning, 1 = DX7 32-voice bulk in progress, 2 = single-voice
dump in progress. Accumulator `h[ENG+92]`; reassembly buffer `0x01C118B0`.

### 5.1 Yamaha DX7 sysex

| Frame | Handling |
|---|---|
| `F0 43 0n 09 20 00 …` (bulk 32-voice, 4096 B) | accept if `len-6 ≤ 4096` → state 1; chunks append until total 4098 (4096 data + checksum + F7). Checksum: `sum(-b) & 0x7F` over 4096 B must equal the checksum byte (implemented as `(byte ^ 0xFF)` accumulate at `0x02023F6E`). On success: `b[ENG+288] = 1` (bank loaded), notify 5 UI/storage slots via `ui_ctx_release` `0x020174EC` on `[[ENG+356]+{0,8,12,16,20}]` |
| `F0 43 0n 00 1B …` (single voice, 155 B) | state 2 (or direct if F7-terminated); complete when total == 158 (155 + cksum + F7); then `dx7voice_pack_store` `0x0201D532` (unpack 155 B VCED → 128 B VMEM, write flash), `ui_show_patch_name` `0x0201D9D0(b[ENG+4778])`, `b[ENG+292] = 1` (patch dirty) |
| `F0 43 10 gg pp vv F7` (7-byte param change) | `addr = (b3<<7)+b4`; `b[ENG+5608+addr] = b5` — direct write into the edit buffer (per-op 21 B × 6 + globals); sets `b[ENG+268] = b[ENG+292] = 1` (dirty flags) |
| `F0 35 59 … F7` vendor | consumed earlier, in `serial_midi_task` (§2.1) and suppressed on USB loopback (§2.2); not seen here |

Channel byte `b2` must be ≤ 0x0F for dumps; param change requires exactly `0x10`.

### 5.2 Channel messages

- Note channel filter: `(status & 0x0F) == b[ENG+4781]`; CC channel filter:
  `(status & 0x0F) == b[ENG+4782]`.
- If `b[ENG+25] == 2` (arp/seq capture mode): `0x80` → `note_off_route` `0x02022310`,
  `0x90` → `note_on_route` `0x02022282`. Otherwise → `midi_msg_dispatch`
  `0x0201F5F4([ENG+252], msg, len)` directly.
- Non-matching channels are dropped.

### 5.3 BLE control commands (for completeness)

`midi_control_cmd_dispatch` `0x02000A02` (called via prefilter `0x02000C1A`): slot
table `h[ENG+74+slot*2]` (active), per-slot state `b[ENG+3+slot]` (2/3/5/32/33),
`b[ENG+2]` current slot; engine reset `midi_engine_reset` `0x02000992` (posts msg 19
to `"c04"`); device-info reply builder `midi_device_info_send` `0x020008B0` (template
`0x0204EB9E`, staged through `btstack_cmd_dispatch` `0x02074B62` types 2/3/4).

### 5.4 Staged vendor/syscmd protocol

The Bluetooth stack packet handler at `0x020012BA` dispatches event IDs
`0x62..0x73`. Event `0x72` accepts a header
`{0x00, 0x59, x, len_lo, len_mid, len_hi}` (`len+7 <= 1046`), copies the
initial fragment to `ENG+9876`, records end `[ENG+652]`, and sets
`b[ENG+648] = 1`. Further `0x72` fragments fill the record; completion sets
state 2 and posts msg 145. `serial_midi_task` then calls syscmd with
`transport=1`. The same record's `+1/+2/+4` fields stage replies back through
the Bluetooth packet layer. [high]

USB-MIDI does not enter through that event handler. `usb_midi_rx_parse`
initializes the distinct `ENG+812` receive record after three CIN-4 events,
unpacks the 7-bit stream into the same `ENG+9876` scratch area, and eventually
posts msg 144. `serial_midi_task` calls syscmd with `transport=0`; the
dispatcher stages USB replies in `ENG+812`, using bit lengths because the TX
path repacks binary bytes into MIDI-safe 7-bit data. [high]

The `0x59` magic mirrors the `F0 35 59` vendor prefix (0x35 59 = "5Y"), but
this command family is separate from the normal-mode OTA trigger and loader
pull protocol documented in `11-ota-protocol.md`.

---

## 6. Arpeggiator & sequencer

### 6.1 Mode control — `arp_seq_mode_control` `0x020201DC`

`mode r0`: 0 = off, 1 = arp, 2 = sequencer; stored `b[ENG+40]`. Off: all-notes-off
sweep over 128 note flags `b[ENG+3716+i]` via `midi_note_off_inject` `0x0201FE64`,
clears scheduler block `ENG+328..344`. Arp: `os_tick_update` `0x0205C5B8`, clears
cursors `b[ENG+41/42]`, scheduler block `ENG+328`: `[ENG+340] = 344`, `b[ENG+344] = 1`.
Related start/stop/toggle helpers follow in the same FUNC (`0x02020264` start,
`0x0202034E` stop, `0x020203E4` mode set with UI lamps via `sys_power_flag_set`
`0x0201E724` ids 12/13/14) [med].

### 6.2 Held-note tracking

- Tables: velocity+flag per note `b[ENG+1132+n]` (bit 7 = latched, low 7 = velocity),
  boolean held table `b[ENG+1186+n]`, held count `b[ENG+22]` (max 27).
- Normalization (`arp_held_note_add` `0x02020BCE` / `_remove` `0x02020B90`):
  `idx = note - 53 - b[ENG+4780] - 12*b[ENG+4779]` — 27-semitone window with user
  semitone/octave shifts `ENG+4779/4780`; sounding note = `idx + 53 + 12*oct + semi`.
- Press-order timestamps: `[ENG+3008+note*4] = [ENG+244]++`
  (i.e. `0x01C0F230[note]`), written by `arp_seq_note_input` `0x02022106` [high].
- `arp_seq_note_input` also drives the panic/reset path: first note after idle clears
  the tables and flushes sounding notes (`ENG+5084` table, 6 B stride).

### 6.3 Pattern builders — `arp_pattern_build` `0x02020724`, `seq_pattern_build` `0x02020C0E`

- Collect active held notes (≤27), then switch on `b[ENG+4786]` (0..6, `tbh`):
  0 = up, 1 = down, 2 = up-down (mirrored append), 3 = down-up, 4 = **random**
  (Fisher-Yates shuffle driven by hardware RNG SFR `[0x13B00]`), 5 = played order
  (`arp_note_order_sort` `0x0202058A` quicksort over the `0x01C0F230` timestamps),
  6 = off (no rebuild).
- Octave expansion `b[ENG+4787]` (repeats with ±12 semitones per octave).
- Output: arp note/velocity pairs at `ENG+6808` (432 B, `0xFF`-cleared), length
  `h[ENG+88]`; seq single-note list at `ENG+5823` (216 B), length `h[ENG+90]`;
  rebuild flag `b[ENG+15]` (arp) / `b[ENG+17]` (seq).

### 6.4 Tick engine — `0x02020FE8` (inside `seq_pattern_build`'s FUNC)

- Note-off phase: `h[ENG+76]` counts down; at 0 sends note-off via
  `midi_note_off_inject` for every entry in the playing table `ENG+5084` (6 B stride:
  note, vel, …; count `b[ENG+11]`).
- Note-on phase: `h[ENG+78]` at 0 → read pattern pairs at cursor `h[ENG+86]` from
  `ENG+6808` (arp) / `ENG+5823` (seq, timers `h[ENG+80/82]`, cursor `h[ENG+84]`,
  playing table `ENG+5246`); non-`0xFF` notes played via
  `midi_note_on_inject` `0x02020552(note, vel, 0)`.
- Timing: step length from `b[ENG+4788..4791]` scaled by gate percent
  (`x*param/100`, direction `b[ENG+16]`); end of pattern wraps cursor and rebuilds.

### 6.5 Sequencer patterns & flash

- RAM banks: `0x01C118B0` (+ `bank*2048 + slot*32`), second bank region `0x01C128B0`;
  per-pattern 32 B record: up to 10 signed note slots (`<0` = rest) at +4096+0..9,
  velocities at +4116.., valid count at +4126, flags at +4127. Scan:
  `seq_pattern_bank_scan` `0x02020042` (16 slots, marks `b[ENG+896+slot]`,
  counts into `b[ENG+4874+bank]`). Bank select `b[ENG+4890]`, slot cursor
  `b[ENG+41]`.
- Flash load: 4096 B from `[ENG+256] + bank*2048 + 0x4000` into `0x01C128B0` via
  flash read `0x020038A2` (address transform `0x02003712`), inside `arp_seq_mode_control`
  start path (`0x02020316`).
- Tempo/timing tables: `h[0x0204DE44 + bank*2]`, per-bank params `ENG+4810/4826/4842`
  (min step 30 ms), swing toggle `b[ENG+42]`.
- Recording: in seq mode, `note_on_route` appends `{note, vel}` into the current
  pattern record (`0x020222BA`); `note_off_route` advances the slot on all-release
  (`0x02022336`) and writes the end marker. Play engine: scheduler at `0x02021236`
  (accumulated-tick scheduling, latch flag `b[ENG+348]`, panic flag `b[ENG+328]`).

---

## 7. CC map (6 slots)

Inside `midi_message_handler` (`0x020240B2..0x0202422E`) [structure high; dispatch
target low]:

- CC accepted only if `(status & 0x0F) == b[ENG+4782]` and `cc ≤ 23`.
- Six slots, configured at 3-byte stride: `b[ENG+5791+i*3]` (i = 0..5) holds the CC
  *group* (`cc>>2`); first matching group wins; matched slot index saved to
  `b[ENG+4777]`, sub-index (`cc & 3` − 1) to `b[ENG+4920]`.
- Per-slot 3-byte value cache at `b[ENG+5764+slot*3+sub]`; latest value cached at
  `b[ENG+5793+slot*3]`; changes-only dispatch.
- On change: `call [0x02045FC4 + slot*12 + 4]` with `r0 = cached value`
  (`0x0202421C-0x0202422E`), then UI notify `dx7patch_load_or_store` `0x0201D69C(0,255)`
  and dirty flags `b[ENG+292/268]`.
- **Caveat**: in the V13 image the `0x02045FC4` table holds float parameter triplets
  (also used by menu/FX code `0x0201D8D4`, `0x0202487E`, `0x02087AB0`) — `{1.0,1.0,
  0.9},{0.8,0.7,0.6},{0.5,0.4,0.3},{0.2,0.1,0},{0.1,0.5,1.0},{2,3,5}`. Calling through
  +4 of those is not viable, so the slot table is either runtime-patched or the field
  doubles as data; verify on target before hooking [low].

---

## 8. Engine struct map (selected offsets, base `0x01C0E670`)

| Off | Use | | Off | Use |
|---|---|---|---|---|
| +2 | current route/slot idx | | +400 | route output hook (USB=`0x02005FAC`) |
| +3..8 | per-slot state bytes | | +412 | route output hook #2 (def `0x02000FEE`) |
| +11/12/13 | arp playing count / state / held count | | +648..652 | staged 512 B dump state/ptr |
| +15/17 | arp / seq pattern-dirty | | +664/672 | per-USB-dev structs |
| +22 | held-note count | | +800..811 | USB vendor-magic staging |
| +25 | note routing mode (2 = via arp/seq) | | +812..820 | DX7 7-bit packer state |
| +34 | DX7 sysex RX state | | +824/836 | route idx table A / count |
| +40/41/42/43 | arp-seq mode / slot / swing / bank | | +838/850 | route idx table B / count |
| +44 | USB staging count | | +852/864 | USB route idx table / count |
| +45/46 | BLE-MIDI ts header/low | | +865/837/851/879 | route locks |
| +74 | slot active halfwords | | +912..920 | MIDI-out ring (wr/mask/base) |
| +76..90 | arp/seq timers & cursors & lens | | +924 | out running-status |
| +92 | DX7 dump byte count | | +928..936 | UART route ring |
| +244 | press-order counter | | +944..952 | USB route ring |
| +248 | global flag (voice gate) | | +956 | USB running status |
| +252 | synth ctx ptr (→ §4) | | +960..968 | sysex ring (idx/size/ptr) |
| +256 | pattern flash base | | +9876 | 512 B staged dump buffer |
| +288/292/268 | bank-loaded / patch-dirty flags | | +3008 | press timestamps (= `0x01C0F230`) |
| +328..352 | arp/seq scheduler block | | +3716 | 128-note active flags |
| +396 | USB staging index | | +4777..4794 | arp params & CC map state |
| +5084/5246 | playing-note tables (6 B stride) | | +4781/4782 | note / CC channel filters |
| +5608..5734 | DX7 edit buffer (6×21 B + globals) | | +5751/5752 | global tune / transpose (−24) |
| +5764..5808 | CC value cache & 6-slot config | | +5791..5806 | CC slot groups (3 B stride) |
| +5823/6808 | seq / arp pattern buffers | | +6552/6555 | vendor sysex staging / arm flag |
| +7716 | BLE-MIDI packet buffer (≤512 B) | | +8740 | parser collect buffer |

---

## 9. Driving MIDI from custom code

### 9.1 Injecting notes into the synth

```c
// note on, velocity vel, r2=0 → also mirror to MIDI-out ring
((void(*)(u8,u8,u8))0x02020552)(note, vel, 0);      // midi_note_on_inject
// note off (fixed release velocity 100), r1=0 → mirror too
((void(*)(u8,u8))0x0201FE64)(note, 0);              // midi_note_off_inject
// raw message straight into the dispatcher (no arp/seq capture):
((void(*)(u32,u8*,u8))0x0201F5F4)(*(u32*)0x01C0E76C, msg, len); // ctx=[ENG+252]
```

Routing flag: set `b[ENG+25] = 2` to force note_on/off through the arp/seq capture
path (`note_on_route`/`note_off_route`), 0 for direct dispatch.

### 9.2 Emitting MIDI bytes (out of the box)

- **All transports (serializer)**: push raw bytes through
  `midi_out_fifo_push` `0x0201FDDE` (db name `midi_rx_fifo_push`): running-status
  compression, writes ring `ENG+912..920`, posts taskq msg to `"c04"`; the serial task
  fans it out to UART DMA / USB EP4 / BLE notify.
- **USB only**: `usb_ep_write(0, 4, len)` at `0x02005D86` after filling the EP4 IN
  DMA buffer `0x01C20E1C` with 4-byte USB-MIDI events (byte0 = CIN).
- **BLE only**: build the Apple-format packet (header `0x80|hi6(ms)`, per-event
  `0x80|lo7(ms)`) and call `att_server_notify` `0x020801A4(con_handle, att_handle,
  buf, len)`; large frames fragment through `bt_pkt_fragment_write` `0x020748A0`.

### 9.3 Consuming incoming MIDI

- Feed any byte stream into a route ring (descriptor: wr/size/base/status), then call
  `midi_stream_parser` `0x02000C48(out3, ctx12, mode)` per message; translate CIN via
  the length table (§3.3), and pass complete frames to
  `midi_message_handler` `0x02023EA0(buf, len)` — you get DX7 sysex, notes, CC and the
  CC map for free.
- To hook note events without replacing the dispatcher: wrap
  `midi_note_on_inject`/`midi_note_off_inject` (single funnel for keyboard, arp, seq,
  BLE and UI notes) or replace the `[ENG+252]` synth ctx pointer with your own engine
  context (layout in §4).
- Route output hooks `[ENG+400]` / `[ENG+412]` are polled by `serial_midi_task` —
  install your own transmitter there (called once per loop iteration; return ≠0 to
  claim the slot, dedup is done with the `r15` bitmask in the loop).

---

## 10. Notes & caveats

- `midi_msg_dispatch`, the note injectors and the arp/seq engine all write the shared
  `ENG` block without locks; call them from the MIDI task context or under the same
  taskq discipline as stock code.
- The `0x0204F10C` length-table anomaly (§3.3) and the `0x02045FC4` CC-table caveat
  (§7) are the two spots where the shipped image does not match the disassembly's
  constant pool; both need one runtime probe (`memdump` over SWD or a debug build)
  before being trusted in a derivative firmware.
- Mask-ROM stubs seen on these paths: `0xFFC02532` (loader entry from USB magic),
  `0xFFC028A0` (IRQ trampoline `0x0200796A/0x0200797E`).
