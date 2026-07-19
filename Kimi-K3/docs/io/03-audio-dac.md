# FM-1 — Audio Output Path & DAC

Target: M-Vave FM-1 firmware `app.bin` (pi32v2, flash VMA `0x02000000`,
JieLi BR22/AC693N). Audience: engineers building a custom synth on this
hardware. Every claim carries the function address it was read from; confidence
is marked **[high]** (direct disassembly evidence), **[med]** (strong
inference), **[low]** (guess). Disassembly quotes cite the shard file in
`Kimi-K3/analysis/shards/`.

The end-to-end chain, with the addresses that implement each stage:

```
MIDI / UI / arp
      │  (messages)
      ▼
engine task 0x02022E32 (created by board_init 0x0200417E)
      │  dx7note_compute_block 0x020862FA  — 64-sample blocks @ 44118 Hz
      ▼
synth ping-pong buffer 0x01C10694 (2 × 256 B = 64 stereo frames 16-bit)
      │  audio_stream_frame_fsm 0x0208B736 (fade in/out)
      ▼
fx_chain_process 0x02087A26  (buffer swap + 6 FX slots)
      ▼
staging buffer 0x01C0FEF8 (dev+6296) → pcm_mix_to_dac 0x02088FC2
      ▼
DAC DMA ring (allocated by audio_dac_open 0x02040602)
      │  DMA engine 0x12F00 / 0x12F40, IRQ vectors 11 & 12
      ▼
DAC digital hub 0x119C4…0x119E8 → ADDA codec (analog) → HP out
```

A parallel, generic path exists for everything that is not the FM synth
(Bluetooth audio, USB audio, system tones): the **jlstream** node pipeline
(`0x02038702`–`0x0203C0AE`) feeding the same DAC device block. Both paths
terminate in the same DAC device struct at `0x01C0E670`.

---

## 1. Hardware register blocks

SFRs are identified from disassembly; bit meanings cross-checked against
`Opus4.8/reference/jielie/periph/audio-br21.md` (BR21 sibling codec — the
BR22 block is a superset; where the two disagree, the disassembly wins).

| Block | Address range | Seen in | What it controls |
|---|---|---|---|
| DAC digital hub | `0x119C4`–`0x119E8` | `audio_dac_open 0x02040602` | multi-channel DAC interface: enables, channel-count fields, per-subchannel config, mode bits |
| DAC analog/DAA | `0x11904`, `0x11908`, `0x1190C`, `0x1191C` | `audio_dac_analog_init 0x02083B72`, `audio_dac_dcc_set 0x0208434E`, `audio_dac_trim_write_1191c 0x02083E8A` | analog control, DC-offset (dcc) trim, trim codes |
| Codec misc | `0x11920` | `audio_adc_con_rmw 0x02083EA0` | ADC/DAC control RMW |
| Clock gate | `0x119CC` bit 14 | `audio_dac_open` head `0x02040602` | DAC clock gate enable |
| DAC DMA ch A | `0x12F00`–`0x12F1C` | `audio_dac_irq_handler 0x020413FA`, `audio_dac_dma_stop 0x0203F6E0` | DMA control/address/length + IRQ pending |
| DAC gain | `0x12F20`, `0x12F24` | `audio_dac_set_digital_volume 0x0203F018` | per-channel digital gain (16-bit fields) |
| DAC DMA ch B | `0x12F40`–`0x12F54` | `audio_dac_open 0x02040BBA` | second DMA descriptor (the one `audio_dac_open` actually programs) |
| Audio chan cfg | `0x12B00` | `audio_dac_channel_init 0x0203C9CE`, `audio_dac_deinit 0x0203CD70` | channel enable bits, IRQ routing |
| Audio chan cfg 2 | `0x12D00`, `0x12E04` | helpers `0x02041876`, `0x0204189A` | status mirrors (`& 0x11`, `& 0x3332` poll) |
| Synth PCM DMA | `0x12E00`–`0x12E0C` | `audio_dac_dma_irq 0x02088F06`, init `0x020050E0` | the DMA engine the FM synth is pumped through: `h[+0]` flags, `b[+8]` status/IRQ flags, `b[+12]` channel enables |
| HW SRC | `0x14300`–`0x1431C` | `audio_src_feed_dac 0x0203A7D8` | asynchronous sample-rate converter |
| Timer/aux DMA | `0x11D00`–`0x11D10` | `0x02087BE4` (in fx_chain), `usr_app_task 0x02022F2E` | timer block used by aux audio |
| LCD/PIO DMA | `0x11E00` | `board_init 0x02004386` | not audio (kept here for disambiguation) |
| IOMC | `0x5101C`, `0x51020`, `0x51030` | pin-map helper `0x0203C92A`, `board_init 0x02004342` | peripheral pin mapping (`0x100000<<pin` output enable, group select at `+0x14`) |
| ADDA serial port | `0x3101C` | `audio_adda_reg_write 0x02083B00`, `audio_adda_reg_read 0x02083CF4` | codec analog register access (see §6) |
| ADDA DMA | `0x30F04` | `audio_adda_link_write 0x02083ACA` | DMA aux channel for the codec serial link |
| Audio clock | `0x10014`, `0x119A8` | `audio_sample_rate_set 0x0203E03C` | audio clock source/divider select |
| Chip ID | `0x10200` (== `0x6F00`) | `audio_dac_open 0x020407B2` | silicon rev check |

### DAC_CON bit mapping (cross-check with audio-br21.md)

`audio_dac_dma_stop 0x0203F6E0` (shard_0203e962_02042e76.txt) operates on
`0x12F00` exactly like BR21 `DAC_CON`:

```
[0x12F00+32] = 0 ; [0x12F00+36] = 0          ; stop descriptors
while ([0x12F00] & 0x800) ;                  ; wait DMA busy/pending (bit 11)
[0x12F00] &= ~0x20                           ; bit 5  = IE  (interrupt enable)  ✓ br21
[0x12F00] |=  0x40                           ; bit 6  = CPND (clear pending)    ✓ br21
```

and the IRQ handler at `0x020414AA` gates on `[0x12F00] & 0x20` (IE) **and**
`[0x12F00] & 0x80` (PND, bit 7 ✓ br21), then clears with `|= 0x40` (CPND).
So: bit4 = EN, bit5 = IE, bit6 = CPND, bit7 = PND — matches br21 `DAC_CON`
**[high]**. The buffer flag BUFF (bit 8) and sample-rate field DACSR (bits 3:0)
exist on BR21; on BR22 the sample rate is instead programmed by clock dividers
(`0x10014`/`0x119A8`, see §3.4) plus the rate field written by
`audio_dac_set_sample_rate 0x0203F730` **[med]**.

DMA engine register layout (both `0x12F00` and `0x12F40`, from
`audio_dac_open 0x02040BBA` and the IRQ at `0x02041478`):

| Offset | Meaning |
|---|---|
| `+0x00` | CON: bit5 IE, bit6 CPND, bit7 PND, bit 9 (`0x200`) and bit 11 (`0x800`) DMA mode/state, bits 12–15 channel mask (`0xE…`) |
| `+0x04` | ADR — buffer base address |
| `+0x08` | LEN — total buffer length (h, in frames) |
| `+0x0C` | half length / current position (read by IRQ as position) |
| `+0x10` | secondary position/counter (zero at open) |
| `+0x14` | current DMA read position (frames; IRQ multiplies by ch×2 → byte offset) |
| `+0x18` | position write-back / ack |

---

## 2. The DAC device struct at `0x01C0E670`

Almost every audio function receives or reconstructs a pointer into this
~4.3 KiB device/state struct. Field offsets seen in code:

| Offset | Seen in | Meaning |
|---|---|---|
| `+19` | `0x02086312` | engine busy/suspend counter (render skips when > 1) |
| `+20` | `0x02087A40` | ping-pong phase (0/1) of the synth buffer |
| `+21` | `0x02086316` | block counter (wraps at 2) |
| `+63`,`+64` | `0x0204149E` | IRQ spinlock bytes |
| `+110`,`+111` | `0x0203EA34` | channel-dispatch lock bytes |
| `+248` | `0x0208656A`, `0x0201F4C6` | engine enable flag (set by `board_init` to 1; envelope scale = 1143 when set) |
| `+252` | `0x02086318` | → synth engine config block (160 B — fields in §5.2 below and doc 04 §2) |
| `+256` | `0x0201D702` | → flash data base handle (patch/flash read offset base) |
| `+260` | `0x020041A4` | flash data base shadow |
| `+280` | `0x0200437C` | misc device cfg (IRQ/timer shadow of `0x11E00`) |
| `+392` | `0x02088F64` | → audio output descriptor (buffer ptr at `[+0]`, event at `[+4]`, counters `[+12]`,`[+24]`) |
| `+400`,`+412` | `0x02005C10`, `0x020009D6` | task notification hooks (function pointers `0x02005FAC`, `0x02000FEE`) |
| `+612` | `0x020406AA` | → channel cfg block |
| `+624` | `0x02040750` | → active DAC cfg struct (layout below) |
| `+628` | `0x02040BB2` | → DAC DMA ring buffer (malloc'd, `mspace_malloc 0x0205672E`) |
| `+632` | `0x0204156A` | → provider list for refill |
| `+1636` | `0x0203C9D6` | DAC channel device node (ops `0x0203E6FC`/`0x0203E8CE` at `+24`) |
| `+1676`,`+1678` | `0x0203CA52` | frame count (default 160) / bytes-per-frame |
| `+1740`,`+1808` | `0x0204063A`, `0x020415A4` | two DAC "device" sub-structs (0x44 B each): `[+8]` name, `[+12]` ops, `[+44]` cfg, `[+48]` priv, `[+52]` data callback |
| `+3228` | `0x0203E980`, `0x0203E04A` | per-channel array (stride 0x38): descriptor ptr at `+48`, countdown `+4`, half-len `+2`, cbs at `+12/+16` and `+20/+24` |
| `+4228` | `0x0203F710` | **DAC DMA ring descriptor** (below) |
| `+4234` | `0x0203F062` | current volume gain byte |
| `+4235` | `0x0203F02A` | volume table max index |
| `+4236`,`+4243` | `0x0203F086` | channel mode / device id for gain packing |
| `+4242` | `0x0203F6E4` | DAC run state (2 = running) |
| `+4268` | `0x0203F01A` | → custom volume table (0 = default `0x0204DFC0`) |
| `+4778` | `0x0201D63A` | current patch slot index |
| `+4783`/`+4784` | `0x0201DAE2` | FX related globals |
| `+4890` | `0x020042A8` | flash bank index (<<11 & 0x7F000 = bank offset) |
| `+5084`,`+5246` | `0x0200446E` | two 162-byte 0xFF-filled maps (voice/key state) |
| `+5608` | `0x0201D54A` | **working DX7 patch: 155 B VCED edit buffer** (ops at `+5624`, 21 B/op) |
| `+5734` | `0x0201D848` | VCED global tail (pitch env rates/levels at `+5734..+5741`) |
| `+5745`–`+5750` | `0x0201DA16` | LFO speed/delay/wave/sync (from VCED) |
| `+5763` | `0x0201D542` | patch dirty flag (63) |
| `+5764` | `0x0201D71C` | 59-byte per-slot settings block |
| `+5791` | `0x02087A9E` | **6 FX slots**, 3 B each at `+5791…+5808`: `{effect id, …}`; enable/variant at `+5792+id*3` |
| `+5822` | `0x0201D7CA` | current algorithm byte (copied to engine `[+22]`) |
| `+6296` | `0x02088F76` | 256-byte staging buffer (PCM to DAC) |

**DAC DMA ring descriptor (dev+4228)**, as used by `audio_dac_dma_stop`
and the IRQ:

| Field | Meaning |
|---|---|
| `[+0]` | ring buffer base |
| `[+4]` (h) | frames per half |
| `[+15]` (b) | channel count (2 = stereo) |
| `[+32]` | **priv** — 1st arg of the render callback |
| `[+36]` | **render callback** — THE hook, see §4 |
| `[+10]`,`[+14]` (b) | state bytes (set to 255/3 on stop) |

---

## 3. DAC driver functions

| Function | Addr | Conf | Purpose |
|---|---|---|---|
| `audio_dac_open` | `0x02040602` | med | open DAC device: hub regs `0x119C4–0x119E8`, alloc DMA ring, program DMA `0x12F40`, route analog |
| `audio_dac_channel_route` | `0x02040074` | med | per-channel analog routing / mux registers |
| `audio_dac_set_analog_gain` | `0x020404AE` | med | volume 0–100 → 4/5-bit analog gain per channel |
| `audio_dac_output_enable` | `0x0204055A` | med | enable/route DAC output channels |
| `audio_dac_output_open` | `0x02040DF0` | med | FIFO config, sample-rate switch, output open/close/ioctl |
| `audio_dac_fifo_config` | `0x0203F79A` | med | DAC FIFO thresholds and channel enables |
| `audio_dac_fifo_reset` | `0x02040CFC` | med | clear DAC FIFO and DMA config when running |
| `audio_dac_set_digital_volume` | `0x0203F018` | **high** | volume 0–100 → gain table → `0x12F20`/`0x12F24` |
| `audio_dac_gain_mode_set` | `0x0203F0B0` | med | dispatch DAC analog gain by mode (async message) |
| `audio_dac_gain_broadcast` | `0x02040D2E` | med | write gain nibbles to all enabled channels |
| `audio_dac_dma_stop` | `0x0203F6E0` | **high** | stop DAC DMA, wait pending clear, zero buffer |
| `audio_dac_set_sample_rate` | `0x0203F730` | med | map rate via 12-entry table, write DAC rate field |
| `audio_sample_rate_set` | `0x0203E03C` | **high** | program clock dividers for 8 k–192 k rates |
| `audio_dac_channel_init` | `0x0203C92A` | med | pin map via IOMC, alloc DMA buffer, program descriptors |
| `audio_dac_channel_config` | `0x0203DBB4` | med | multi-channel routing bits, gains, DMA descriptors |
| `audio_dac_device_ops` | `0x0203CE06` | med | DAC device block: subscriber notify, channel config, DMA IRQ, PCM convert |
| `audio_dac_dma_refill` | `0x0203D97A` | med | compute half offsets, invoke per-channel refill callback |
| `audio_dac_deinit` | `0x0203CD70` | med | restore `0x12B00` defaults, free DMA buffer |
| `audio_channel_irq_dispatch` | `0x0203E962` | med | per-channel callback dispatch from DAC IRQ handlers |
| `audio_channel_open/close` | `0x0203EB14` / `0x0203EDBA` | med | alloc/free channel node, link into device list |
| `audio_channel_start/stop/reset` | `0x0203E2A8` / `0x0203E376` / `0x0203E438` | med | channel bitmask start/stop, descriptor reset |
| `audio_dac_power_down` | `0x0205DE4A` | med | disable DAC analog block, gate audio clock |
| `pcm_deinterleave_format_convert` | `0x0203E720` | med | de-interleave 2–4 ch PCM, expand 16/24-bit for DAC |

### 3.1 `audio_dac_open 0x02040602` (shard_0203e962_02042e76.txt)

(The function's first 6 instructions are a separate tiny helper that sets bit
14 of `0x119CC` — the DAC clock gate — the open body starts at `0x0204061A`.)

Flow:

1. `strcmp(name, …)` against the device-name strings (`"spdif"`, `"plnk0"`,
   `"plnk1"`, `"timer"` at `0x0204EB04`…) to pick the sub-device slot
   (dev+1740 or dev+1808); the name is taken from the open-args struct `[+32]`.
2. Reads chip ID `[0x10200] == 0x6F00` (BR22 rev gate) **[high]**.
3. Programs the DAC digital hub:
   - `[0x119E0]` (`0x119C4+28`): clears bits 31/30/29/27/25/24, sets bit 28
     (`0x10000000`) — master config;
   - `[0x119CC]` (`+8`): inserts channel count at bits 11–12
     (`(ch & ~3) << 11`), sets bit 10, per-subchannel polarity bits 17–27;
   - `[0x119E4]` (`+32`): bit 0 enable, channel-mode fields at bits 30–31,
     `0x20000000`, `0x8000000`;
   - `[0x119E8]` (`+36`): per-subchannel enable bits 0–3, mode fields;
   - `[0x119C8]` (`+4`): per-mode bits cleared.
4. `audio_dac_channel_route 0x02040074` + `audio_dac_set_analog_gain
   0x020404AE` + `audio_dac_output_enable 0x0204055A` /
   `audio_adc_channel_enable 0x020405C0` for the analog side.
5. Allocates the DMA ring: `mspace_malloc(frames_total × bytes)` at
   `0x02040BAC`, stored at `[dev+628]`.
6. Programs DMA engine **`0x12F40`**: `[0x12F40]=0`,
   `[0x12F44]=buf`, `h[0x12F48]=len`, `h[0x12F4C]=len/2`,
   `h[0x12F50]=h[0x12F54]=0`, then `[0x12F40] |= 0x40` (CPND),
   `&= ~0x200`, `|= 0x800`, channel mask bits 12–15 = `0xE…`.
7. Sets `b[dev+1662] = 1` (DMA armed) — `0x02040BEE`.

Defaults if the cfg half-length field is 0: **320** (`0x0204076A`).

### 3.2 Volume — `audio_dac_set_digital_volume 0x0203F018` **[high]**

(shard_0203e962_02042e76.txt)

```
table = [dev+4268];  maxidx = b[dev+4235]
if (table && maxidx)  idx = min(vol * (maxidx-1) / 100, maxidx-1)
else                  idx = min(vol * 32 / 100, 32);  table = 0x0204DFC0
gain  = h[table + idx*4 + 2]             ; gain field of 4-byte entry
b[dev+4234] = gain
[0x12F20] = ([0x12F20] & 0xFFFF0000) | gain
[0x12F24] = ([0x12F24] & 0xFFFF0000) | gain
if (b[dev+4236] == 4 && b[dev+4243] == 5)      ; mono mode
    keep low halves
else
    [0x12F20] |= gain << 16 ; [0x12F24] |= gain << 16
```

Default gain table `0x0204DFC0`: 32 × u32, **473 (0x1D9) down to 411
(0x19B)**, step −2/entry (verified in `app.bin`). Products can override with
their own table at `[dev+4268]`.

### 3.3 `audio_dac_dma_stop 0x0203F6E0` **[high]**

Shown in §1 (register quote). Only acts when `b[dev+4242] == 2` (running);
then stops the DMA descriptors at `0x12F20/0x12F24`, waits for the busy bit
(bit 11) to clear, disables IE (bit 5), clears pending (bit 6), and
`memset(0x02042F08)`s the ring buffer (`frames × ch × 2` bytes).

### 3.4 Sample rate — `audio_sample_rate_set 0x0203E03C` **[high]**

(shard_0203967c_0203e720.txt) Signature: `(rate_hz, channel)`.

Supported rates, matched by literal compare:
**8000, 11025, 12000, 16000, 22050, 24000, 32000, 44100, 48000, 64000,
88200, 96000, 176400, 192000** ✓ (all 14 present as immediates).

Per rate it:
- sets/clears bit 25 (`0x2000000`) of `[0x119A8]` (audio-clock config),
- sets/clears bits 8/10 of `[0x10014]` (clock source select: `|= 0x100` /
  `|= 0x400` for the 44.1 k family & high rates, `&= ~0x100` / `&= ~0x400`
  for 11.025/22.05/44.1/88.2 k), bits 9/11 cleared at exit,
- writes a divider code into `b[cfg + 12]` of the per-channel clock entry
  (values 0/4/32/64/96/128 by rate — the prescaler index),
- requires channel state `b[chan+3228] | 2 == 3` (running) and caches the
  rate at `[chan + 3236]`.

`audio_dac_set_sample_rate 0x0203F730` is the device-level variant that maps
the rate through a 12-entry table into the DAC rate field **[med]**.

The **synth path runs at 44118 Hz**, not 44100: `board_init 0x0200417E`
stores `44118 (0xAC56)` and its reciprocal `0x37BE23E8` (float
2.2665e-5 = 1/44118.0 ✓ verified) as a u32/f32 pair at engine `[+0]/[+4]`
(shard_02003b7c_02005bb2.txt:828). `0x1C1D234` is also set to 44118 at
`0x020050B6`. (44118 Hz is the nominal rate after the DAC clock-trim
correction — see `audio_dac_sr_calc 0x0205CBBC`, which computes the exact
rate with double math.)

---

## 4. The DMA ring + IRQ — THE render hook

Three cooperating IRQ-side pieces exist; all run in IRQ context with the
standard pi32v2 prologue (`[--sp] = {psr, rets, reti}`, `cli`, per-CPU
nesting counter at `0x01C0953C`, `testset` spinlocks).

### 4.1 `audio_dac_irq_handler 0x020413FA` (4458 B, shard_0203e962_02042e76.txt)

Two parts:

**Feed helper `0x020413FA(dac_dev, src, len)`** — converts/interleaves mono
sources into the stereo ring (16-bit duplicate loop when cfg channels == 1
and width == 1), then calls `audio_dac_device_ops 0x0203CE06(dac_dev+12, 0,
&frame)` for the subscriber chain, and finally, if `[dac_dev+52]` is set:
`call [dac_dev+52] ( [dac_dev+48] priv, src, len )` — a per-device
"data consumed / need more" notification **[high]**.

**IRQ body `0x02041478`** — the actual vector:

```
if ([0x12F00] & 0x20 /*IE*/ && [0x12F00] & 0x80 /*PND*/) {
    pos  = h[0x12F0C]            ; current half position
    half = h[0x12F14]            ; half size in frames
    ch   = b[dac+4228+15]
    cb   = [dac+4228+36]         ; ← render callback
    cb( [dac+4228+32] /*priv*/,
        [dac+4228+0] + half*ch*2 /*buf + half_off*/,
        pos*ch*2 /*half_len*/ )
    h[0x12F18] = pos             ; write back
    [0x12F00] |= 0x40            ; CPND
}
if ([0x12F40] & 0x80 && [0x12F40] & 0x20) {   ; second DMA engine
    … countdown at h[0x1C0E660]; on expiry:
      demux/de-interleave the interleaved buffer into per-device halves
      and call the feed helper 0x020413FA once per device
      (dev+1740 and dev+1808), then [0x12F40] |= 0x40
}
```

So the **half/full-buffer render callback** is `[dac+4228+36]`, ABI
**(priv = [dac+4228+32], buf+half_off, half_len_bytes)** — this is *the*
classic JieLi `dac_irq_handler` → `fill_buffer()` hook **[high]**.

### 4.2 `audio_channel_irq_dispatch 0x0203E962` (shard_0203e962_02042e76.txt)

Per-channel dispatcher for the 4 sub-channels of one DAC device
(`stride 0x38` at `0x01C0E670`):

- descriptor at `[chan*0x38 + 3276]`, active when `h[desc] & 0x800`;
- per sub-channel `i` (0–3): pending bits `1<<(i+4)` in `b[desc+8]`, set/clear
  bits `1<<i`;
- countdown at `[chan+3228+4]` in half-frames (`h[chan+3230]` per half);
- on expiry picks the half selected by `h[desc] & (1<<(i+12))` and calls
  `cb(priv=[+12], buf=[+32+i*4] (+ half_off), half_len<<2, i)` from one of
  the two `{priv, cb}` pairs at `+12/+16` and `+20/+24` **[med]**.

Two vector entries: `0x0203EA10` (channel 0) and `0x0203EA6A` (channel 1) —
standard IRQ prologue, spinlock at `dev+110/111`, tail `rti`.

### 4.3 `audio_dac_dma_refill 0x0203D97A` (shard_0203967c_0203e720.txt)

Per-channel refill for the jlstream-side DAC node (stride `0x28` at
`0x01C0E670`): descriptor at `[ch*0x28 + 2784]`, active while
`h[desc] & 0x100` and sign-bit set; computes
`buf = [ch+2756] (+ half_off if h[desc] & 0x200)` and calls
`cb = [ch+2780]` with `(priv = [ch+2776], &bufptrs)` **[med]**.
Vector entries: `0x0203DA24` (ch 0), `0x0203DA78` (ch 1).

IRQ vectors **11 and 12** are registered by the channel-device init at
`0x0203DB18/0x0203DB60` (`request_irq 0x020016D2`) with handlers
`0x0203EB30` / `0x0203EB8A` **[med]**. A further `request_irq(11, …)` with a
RAM-resident handler (`0x1C04806`) happens in the audio server init
`0x02005114` **[med]** — the FM synth's DMA (block `0x12E00`, see §5.3) is
serviced from RAM.

---

## 5. jlstream pipeline & the audio_server task

### 5.1 jlstream node framework

| Function | Addr | Conf | Purpose |
|---|---|---|---|
| `jlstream_object_create` | `0x02038702` | med | name-keyed node/pipeline create & destroy |
| `jlstream_node_open` | `0x02038EE2` / `0x02039DE8` | med | instantiate node: bind ops, alloc buffers, subscribe |
| `jlstream_node_command_dispatch` | `0x0203972C` | med | node command dispatcher: start/stop/link/param via jump table (data ref `0x0203A6F0`) |
| `jlstream_node_start/stop/flush` | `0x0203A1E2` / `0x0203A21E` / `0x0203967C` | med | node state transitions + ioctls |
| `jlstream_pipeline_task` | `0x020389CE` | med | node event messages; pipeline data-pump worker loop |
| `jlstream_task_loop` | `0x0203A288` | med | framework message loop, node close/destroy |
| `jlstream_node_process` | `0x0203AAC0` | med | pull cbuf data, run node handler, push to DAC output |
| `jlstream_node_data_fill` | `0x0203A5EE` | low | fill node output from cbuf, memset silence on underrun |
| `jlstream_pipeline_destroy` | `0x0203C0AE` | med | walk children, close/free ops, unlink |
| `jlstream_cbuf_block_xfer` | `0x0203C19A` | low | 32-byte block copies via cbuf + subscriber events |
| `stream_bufmgr_ioctl_dispatch` | `0x0203B6F4` | med | buffer-manager ioctl dispatcher |
| `audio_src_feed_dac` | `0x0203A7D8` | med | feed PCM through HW SRC `0x14300` into DAC ring |

The jlstream pipeline task entry is `0x0203ACA2` (inside the classified span
of `jlstream_node_process`; created by `jlstream_node_open 0x020395B2`,
prio 27, stack 1024, name built on stack — `os_task_create 0x0205B1D0`) **[med]**.

**cbuf primitives** (both in shard_0203967c_0203e720.txt, **[high]**):

- `cbuf_data_avail 0x0203A6CC(cbuf, &avail)` — spinlock at `cbuf+32`;
  `avail = [cbuf+4] - [cbuf+12]` (write − read), wrapped against
  `[cbuf+24]/[cbuf+28]`; returns read pointer.
- `cbuf_commit_advance 0x0203A75C(cbuf, n)` — advances `[cbuf+12]/[cbuf+16]`
  and `[cbuf+24]/[cbuf+20]` by `n` under the same lock.

**HW SRC at `0x14300`** (`audio_src_feed_dac`, **[med]**): per call it pulls
up to 640 bytes from the node cbuf and programs:
`[0x14300] = (frames-1) | ch_cfg<<8 | mode<<26`,
`[0x14304/0x14308/0x1430C] = in/out rate pairs (16-bit each)`,
`[0x14310]/[0x14318] = in/out addresses`, `[0x14314]/[0x1431C] = in/out
lengths`, kicks with `|= 0x40 | 0x8`, waits on a semaphore
(`os_q_pend 0x0205B19C` on `0x01C0F044+80`, posted by the SRC IRQ), then
reads back consumed/produced counts and a rate-ratio status from `[0x14300]`
bits 8–24 and 26–30. Buffered-level thresholds 960/1280 nudge the nominal
rate ±4 per call — a drift-correcting ASRC servo **[med]**.

### 5.2 The audio_server task and 44118 Hz setup

`board_init 0x0200417E` (SYS, shard_02003b7c_02005bb2.txt) creates the audio
engine task:

```
os_task_create(name = "" (rodata 0x0204EF79, empty string),
               prio = 5, stack = 1024, arg = 0,
               [sp] = 0, [sp+4] = entry 0x02022E32)      ; at 0x02004570
```

(`os_task_create 0x0205B1D0` ABI verified: r0 = name (strlen-checked,
≤ 63), r1 = prio, r2 = stack, r3 = arg, caller `[sp]`/`[sp+4]`/`[sp+8]` go
to TCB+72/+228/+224.) The entry `0x02022E32` sits inside the address span
the classifier assigned to `usr_app_task 0x02022CFE` — the splitter merges
the engine task body into that span; treat `0x02022E32` as the engine task's
real entry **[med]**.

Right before the create, `board_init` builds the engine config block (160 B,
`zalloc 0x02057F9E`) — the block that lives at `[dev+252]`:

| Offset | Value | Meaning |
|---|---|---|
| `[+0]` u32 | **44118** | engine sample rate |
| `[+4]` f32 | `0x37BE23E8` ≈ 2.2665e-5 | 1/44118 |
| `[+8]` | **64 (0x40)** | block size in samples |
| `[+12]` b | **12** | voice count (polyphony — see doc 04) |
| `[+16]`,`[+24]` | 256 | buffer sizes (64 fr × 2 ch × 2 B) |
| `[+28]` | 8192 | large buffer size (delay/reverb arena) |
| `[+60]` b | 12 | secondary voice count |
| `[+62]` h | 8192 | pitch-bend centre/2? (h; `h[+62]` read as signed in render) |
| `[+68]` b | 127 | master level |
| `[+120]` b | 63 | init marker |
| `[+140]` f32 | `0x3F7F44D4` ≈ 0.99692 | feedback/smoothing coefficient |

It also computes the 1025-entry freqlut into RAM `0x01C138B0` (loop at
`0x02044A2`, `if (r6 != 1025)`) and copies a 4 KiB table from flash data to
`0x01C128B0` — see doc 04 §2.

The big sibling `0x0200457A` (3684 B, `callers=0` — a task/work function
reached only indirectly, **[med]** the *audio server work body*) allocates
the audio buffers (64 B / 512 B / 2048 B), sets `[0x1C1D234] = 44118`,
programs the synth DMA block `0x12E00` (`h[+0]`, `b[+8]`, `b[+12] |= 3`,
`|= 256`, GPIO for pins 32/33/34/38), registers `request_irq(11, prio 3,
handler 0x1C04806 /*RAM*/, 0)` at `0x02005114`, then runs a message loop
(`os_taskq_pend 0x0205B690`; message type 13/arg 32 handled) **[med]**.

Task-queue posts to the audio server use `os_taskq_post_msg(name_ptr
0x0204EE97, 1, msg_id)` — e.g. msg 19 from `midi_engine_reset 0x02000992`,
msg 18 from `0x02005C14`, msg 17 from `0x02022E44`, msg 2 from `0x020060C6`.
The lookup `__os_taskq_lookup 0x02059174` matches by **name pointer
identity** (`[node+8] == name_ptr`), so the queue is registered with this
exact rodata pointer **[high]**. The human-readable string `"audio_server"`
sits at `0x0204EE9A` — note the pointer used is `0x0204EE97`, three bytes
earlier (inside the preceding `"c02c08c04"` string); empirically that is the
pointer all six post sites use.

### 5.3 The synth DMA block `0x12E00` (RAM-side)

`audio_dac_dma_irq 0x02088F06` (shard_02084824_0208c3b4.txt) — the RAM
IRQ for the synth path:

```
r4 = 0x12E00
if (b[r4+8] & 0x10)  b[r4+8] |= 1        ; ack half IRQ
if (b[r4+8] & 0x20)  b[r4+8] |= 2        ; ack full IRQ
if (b[r4+8] & 0x40)  b[r4+8] |= 4
if (b[r4+8] & 0x80)  audio_dac_dma_irq((h[r4+0] >> 15) ^ 1)  ; half index
```

`audio_dac_dma_irq 0x02088EEE(half)` stores the half index to
`b[0x1C1CA10]` and posts an event (`0x0204DF000` on `0x1C1C9BC`) — this is
what wakes the render pump **[high]**. A sibling IRQ at `0x02088F54` moves
256 B from the output descriptor buffer into the staging buffer dev+6296
(or memsets it when the descriptor says underrun) and posts
`[descriptor+4]`'s event. `pcm_mix_to_dac 0x02088FC2(dst32, n, gain)` then
mixes 16-bit stereo PCM from dev+6296 into the 32-bit DAC accumulator with
per-call gain **[high]**.

---

## 6. Codec (ADDA) analog

### 6.1 Serial-port register access **[high]**

`audio_adda_reg_write 0x02083B00(reg, val)` (shard_02082d14_0208478a.txt):

```
while ([0x3101C] & 0x20000) ;          ; wait not-busy (bit 17)
[0x3101C] = val | (reg << 8) | 0xA0000 ; bits 17+19: write strobe + go
```

`audio_adda_reg_read 0x02083CF4(reg)`: issues `(0x90000 | reg<<8)` then
`(0xB0000 | reg<<8)` through `audio_adda_link_write 0x02083ACA` (direct:
`[addr+0x30000] = v`; DMA path via `0x30F04` when addr = 0), returns
`[0x3101C].b0`.

Windowed extended registers: `adda_win200_write 0x02083B5A` /
`adda_win208_write 0x02083B42` (index via regs 200–202 / 208–210) and
`adda_win212_read/write` (`0x02083F48`, `0x02084564`…).

### 6.2 Init tables

| Function | Addr | Conf | Purpose |
|---|---|---|---|
| `audio_adda_init_seq` | `0x02083B1E` | med | codec analog init register write sequence |
| `audio_adda_power_seq` | `0x02083D7A` | low | run init seq, set analog reg 25 |
| `audio_dac_analog_init` | `0x02083B72` | med | init DAC analog regs (213/214/212…), poll trim, program DAA |
| `audio_analog_init_mode` | `0x02035258` | med | write two-mode analog register init table |
| `audio_codec_init` | `0x02035630` | med | full codec register + coefficient init sequence |
| `audio_coeff_table_upload` | `0x02034C68` | low | upload 256-entry 64-bit coefficient table |
| `audio_gain_table_init` | `0x020361CE` | low | upload 128-entry gain table + output stage config |
| `audio_dac_analog_mode_set` | `0x0208392C` | med | DAC analog register fields for modes 1–4 |
| `audio_dac_analog_mute` | `0x02083D3C` | low | clear enable bits in analog regs 64/65/4 |

The two big table-driven inits (`0x02035630`, 2914 B; `0x02035258`, 756 B)
stream register/value pairs through the primitives above **[med]**.

### 6.3 Trim calibration

Three cooperating routines:

- **`audio_dac_trim_calibrate 0x02034B2C`** (shard_02033978_02036448.txt) —
  47-step analog trim sweep building a midpoint table, using
  `trim_code_lookup 0x02034B04` and the analog status read
  `0x02034AEE` **[med]**.
- **`audio_dac_trim_calibrate 0x02083FE0`** (878 B,
  shard_02082d14_0208478a.txt) — the factory sweep: codec init
  (`audio_adda_init_seq 0x02083B1E`), windowed writes, then for each of 128
  trim codes (written via `audio_dac_trim_write_1191c 0x02083E8A` →
  `[0x1191C]` bits 8–14, 7-bit) it measures the DAC output **power** through
  the codec's measurement ADC (regs 129–140 read via `adda_win212_read
  0x02083F48`; squares and sums two channel pairs), keeping the argmin
  (loops at `0x02084156`, `0x02084192`, `0x020841E0`, `0x0208421A`,
  `0x0208426E`). Additional sweeps cover `audio_trim_dac4/6_set`
  (10-bit, `0x02083DAC`/`0x02083DD0`) and `audio_trim_dac8/9_set`
  (`0x02083E40`/`0x02083E64`) **[med]**.
- **`audio_dac_dcc_trim_calibrate 0x0208437C`** — binary-searches the
  DC-offset (dcc) trim: `audio_dac_dcc_set 0x0208434E` writes a signed
  9-bit value to `[0x11908]` bits 17–25 with sign at bit 26; results stored
  per config, `audio_dac_trim_config_load 0x02083EB2`,
  `audio_dac_trim_config_autoselect 0x02083FB0` **[med]**.

Persistent trim: `dac_trim_save 0x0205CB5E` writes 6 bytes to VM slot 110;
`dac_trim_get 0x0205CB9C`, `dac_trim_adjust 0x0205CBA8`.

---

## 7. How to feed your own samples

Two practical hook points, both verified in disassembly.

### 7.1 Hook the DAC half-buffer callback (recommended)

This is the JieLi-native render hook — everything downstream (FIFO, gain,
analog) keeps working.

1. Open the DAC the way the firmware does, or reuse the running device
   struct at `0x01C0E670`. The DMA ring descriptor is at `0x01C0E670+4228`.
2. Install your renderer:
   ```c
   struct dac_ring *ring = (void *)0x01C0E670 + 4228;
   ring->priv = my_state;              // [+32]
   ring->cb   = my_render;             // [+36]
   ```
   Callback ABI (from the IRQ at `0x020414DE`):
   `void my_render(void *priv, int16_t *buf, int half_len_bytes)` —
   called from IRQ at both half and full DMA events; `buf` already points at
   the half that must be refilled; interleaved stereo s16 at the DAC's
   current rate (44118 Hz for the synth device).
3. Keep `b[dev+4242] == 2` (run state) and don't touch `[0x12F00]` bits
   4–7 — the IRQ clears PND itself.

Caveats: the callback runs in IRQ context (prologue at `0x02041478`); keep
it short or defer to a task via the same event-post primitive the firmware
uses (`0x0204DF000`-family event post, see `audio_dac_dma_irq 0x02088EEE`).
Sample format note: the feed helper `0x020413FA` can mono→stereo-expand for
you if cfg channels == 1 **[high]**.

### 7.2 Replace the synth node / render body

The FM engine renders 64-sample blocks through this pump:

```
DAC DMA IRQ (0x12E00, handler 0x02088F06)
  → audio_dac_dma_irq 0x02088EEE(half)     ; posts event
  → engine task loop 0x02086B16            ; RAM-resident
      while (state == 2) dx7note_compute_block 0x020862FA
  → ping-pong 0x01C10694 (2 × 256 B, 64 stereo frames s16)
  → audio_stream_frame_fsm 0x0208B736      ; fade
  → fx_chain_process 0x02087A26            ; swap + 6 FX slots
  → staging 0x01C0FEF8 → pcm_mix_to_dac 0x02088FC2 → DAC ring
```

To plug your own engine in:

- **Easiest**: write your 64-sample stereo s16 blocks into the ping-pong at
  `0x01C0E670 + 0x2024 + phase*256` (`0x01C10694`/`0x01C10794`), toggling
  `b[dev+20]` (phase 0/1). `fx_chain_process 0x02087A26` swaps that half
  with the stream buffer and runs the FX slots — your audio gets the same
  reverb/filter/phaser treatment as the FM engine **[high]**.
- **Cleaner**: replace the body the pump calls: the loop at `0x02086B16`
  (RAM) alternates `audio_buf_state_init 0x020857FE` and
  `dx7note_compute_block 0x020862FA` while `b[0x1C16EC0] == 2`. Point that
  call at your own RAM-resident `render64(void)` — same ABI (no args; write
  256 B into the current ping-pong half).
- **With your own task**: create it exactly like `board_init` does
  (`os_task_create 0x0205B1D0`, prio 5, 1 KiB stack) and wait on the same
  DMA-half event the pump uses.

Buffer sizes for reference: engine block = **64 frames** (`[engine+8] =
0x40`); ping-pong halves = 256 B; DAC ring halves = `h[dac+4228+4]` frames
(default 320 total when cfg is 0, set in `audio_dac_open`).

---

## 8. Quick reference — addresses

| What | Address |
|---|---|
| DAC device struct | `0x01C0E670` |
| DAC DMA ring descriptor | `0x01C0E670 + 4228` |
| Render callback (priv/cb) | `[dac+4228+32]` / `[dac+4228+36]` |
| DAC hub regs | `0x119C4`–`0x119E8` |
| DAC DMA A / gain / DMA B | `0x12F00` / `0x12F20`–`0x12F24` / `0x12F40` |
| Synth DMA block | `0x12E00`–`0x12E0C` |
| HW SRC | `0x14300`–`0x1431C` |
| ADDA serial port / DMA | `0x3101C` / `0x30F04` |
| Audio clock | `0x10014`, `0x119A8` |
| Synth ping-pong (64 fr s16 stereo) | `0x01C10694` / `0x01C10794` |
| PCM staging buffer | `0x01C0E670 + 6296` |
| Default volume table | `0x0204DFC0` (32 × u32, 473→411) |
| Engine sample rate | 44118 Hz (`[engine+0]`, `0x1C1D234`) |
| DAC IRQ vectors | 11, 12 (handlers `0x0203EB30`/`0x0203EB8A`; RAM `0x1C04806`) |
| audio_server taskq name ptr | `0x0204EE97` (string `"audio_server"` at `0x0204EE9A`) |
