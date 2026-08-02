# FM-1 — The FM Synth Engine (msfa / Dexed port)

Target: M-Vave FM-1 firmware `app.bin` (pi32v2, JieLi BR22/AC693N).
Audience: engineers building a custom synth on this hardware. Every claim
carries a firmware address; confidence **[high]** / **[med]** / **[low]**.
Disassembly quotes cite shards in `analysis/shards/`. The reference
source is Google **msfa** (`reference/dexed/Source/msfa/`) and
**Synth_Dexed** (`reference/Synth_Dexed/src/`) — where the firmware
and the source agree, it is stated explicitly (that raises the claim to
*proven*).

---

## 1. Proof recap: the engine *is* msfa

Byte-exact msfa data tables found in `app.bin` (re-verified by dumping the
binary; values from `msfa/dx7note.cc`, `env.cc`, `pitchenv.cc`):

| msfa table | Source | Firmware addr | Check |
|---|---|---|---|
| `pitchmodsenstab[8]` u8 = 0,10,20,33,55,92,153,255 | dx7note.cc:143 | `0x0204EB90` | byte-exact ✓ |
| `ampmodsenstab[4]` u32 = 0,4342338,7171437,16777216 | dx7note.cc:148 | `0x0204EF4C` | byte-exact ✓ |
| `velocity_data[64]` u8 = 0,70,86,97,106,… | dx7note.cc:81 | `0x0204F760` | byte-exact ✓ |
| `exp_scale_data[32]` u8 = 0,1,2,3,4,5,6,7,8,9,11,… | dx7note.cc:111 | `0x0204F44C` | byte-exact ✓ |
| `levellut[20]` = 0,5,9,13,17,20,23,25,… | env.cc:28 | `0x0204F0B5` | byte-exact ✓ |
| `pitchenv_tab[99]` s8 = −128,−116,−104,−95,… | pitchenv.cc:34 | `0x0204FB7C` | byte-exact ✓ |
| `pitchenv_rate[99]` u8 = 1,2,3,3,4,4,5,5,… | pitchenv.cc:23 | `0x0204FBE0` | byte-exact ✓ |
| `coarsemul[32]` i32 = −16777216,0,16777216,… | dx7note.cc:31 | `0x0204FC44` | all 32 byte-exact ✓ |

Plus formula-level matches (see §4): the logfreq base constant **50857777**
(`0x3080731`, dx7note.cc:40) in note-on at `0x0201F826`, the LFO constant
**25190424** (`0x1806018`, lfo.cc:54) in `dx7_lfo_params_compute 0x0201DA10`,
`ScaleCurve`'s `* 329 >> 12/15` at `0x0201F948`, `ScaleVelocity`'s `−239`
at `0x0201F8AC`, `ScaleRate`'s `(sens*x)>>3` at `0x0201F984`, and the
`(4+(q&3)) << (2+(q>>2))` envelope increment in `env_release 0x0201F3FC`
matching `Env::advance` (env.cc:152, modulo the `LG_N` fold, see §4.3).

> **Reading note (shard quirk):** table lookups in the shards use a base
> pointer printed as `0x204EA00`, but the byte-exact tables sit **288 bytes
> (0x120) lower** — the effective table base is **`0x204E8E0`**. Verified
> for five independent lookups: `base+2005` = levellut `0x0204F0B5`,
> `base+2924` = exp_scale_data `0x0204F44C`, `base+3712` = velocity_data
> `0x0204F760`, `base+4476` = pitchenv_tab `0x0204FB7C`, `base+4576` =
> pitchenv_rate `0x0204FBE0`. When you read shard code, subtract 0x120
> from any `0x204EA00`-based table address. (Sin-table refs with the same
> literal resolve to `0x2050FAC`, see §2.) This is believed to be a shard
> literal-reconstruction artifact, not two real bases.

More engine rodata (from db.json classification + binary dump):

| What | Addr | Conf | Notes |
|---|---|---|---|
| quarter-wave sine LUT (u32, Q24, amp 2^24, sin(i·π/512)) | `0x2050FAC` | high | 257+ entries; used by the LFO sine path (interpolated) |
| `sf_sin_tab1` region | `0x02050BAC` | med | additional sin/param LUT data |
| `rodata_sin_freqlut` | `0x02051372` | med | sin tail + freqlut log2 table (db) |
| `rodata_freqlut_exp2` | `0x020514D4` | med | freqlut body + exp2 float table (db); u32 rising geometric 6072408, 6145866, … |
| FX coefficient LUTs | `0x02051C2A`–`0x02053484` | med | float/int DSP coefficient data incl. ramp/exp-decay curves |
| has_contents init `{1,0,0}` | `0x02045FC0` | high | 3 bytes loaded by `fm_core_render` — matches fm_core.cc:96 |
| FX dispatch table (12 B/entry, init@+0, process@+8) | `0x02045FC4` | high | used by `fx_chain_process 0x02087A26` |

---

## 2. Engine layout: RAM residency, config block, polyphony

The hot code is copied from the `.data` flash image (`0x02084824`+,
→ RAM `0x01C00000`+) and runs from RAM:

| Function | Flash addr | Conf | msfa equivalent |
|---|---|---|---|
| `fm_op_chain3_kernel` | `0x02085824` | med | unrolled 3-op cascade (`FmOpKernel::compute` ×3) |
| `fm_core_render` | `0x02085A28` | **high** | `FmCore::render` (fm_core.cc:93) |
| `dx7note_compute_block` | `0x020862FA` | **high** | `Dx7Note::compute` + `Dexed::getSamples` block loop fused |
| env per-op process | `0x0204860A8` (flash; called per op from the RAM renderer) | med | `Env::getsample` |
| `fx_chain_process` | `0x02087A26` | med | `fx.process()` + effect slots |
| engine task pump loop | `0x02086AD6` | high | `Dexed::getSamples` outer loop |
| `audio_stream_frame_fsm` | `0x0208B736` | low | stream open/run/fade pump |

Working LUTs in RAM: sin at **`0x1C06678`** (u16, quadrant-folded),
exp2 at **`0x1C05E78`** (u16) — both used by all three render kernels
**[high]**. The freqlut is **computed at boot** into **`0x1C138B0`**
(1025 × u32) by `board_init 0x0200417E` — the `if (r6 != 1025)` loop at
`0x02044A2` writes `pow()`-based entries one by one, exactly like
`Freqlut::init` (freqlut.cc:35: `y = 2^44/fs; y *= 2^(1/1024)`) **[high]**.
A 4 KiB table is also copied from flash data to `0x01C128B0` at
`0x02042C6` **[med]**. The 32×6-byte **algorithm table** (msfa
`FmCore::algorithms`, fm_core.cc:29) lives in RAM at **`0x01C07D6C`**
(boot-copied; writable — `fm_core_render` patches entry bytes for
algorithms 3/5 at `0x02085A7C`) **[high]**.

The engine config block (160 B) at `[0x01C0E670+252]`, built by
`board_init 0x020044BC` (full field table in doc 03 §5.2):

- `[+0]` = **44118** Hz, `[+4]` = float 1/44118
- `[+8]` = **64**-sample blocks
- `[+12]` = **12 voices** — polyphony **[high]**: `board_init` allocates
  **5616 = 12 × 468** bytes of voice array at `0x020044DE`, and both the
  render loop (`b[r12+12]` at `0x0208644E`) and the MIDI allocator cap at
  this count.
- `[+16]` = → voice array (12 × 468 B), `[+24]` = mix buffer,
  `[+28]` = 8192-byte FX arena, `[+32]` = LFO phase, `[+36]` = LFO delta,
  `[+40]` = LFO waveform, `[+44..+52]` = LFO delay state,
  `[+56]` = master tune, `[+60..]` = controllers, `[+120]` = op-switch
  bitmask byte (per-op bit tested at `0x0208665E`).

---

## 3. msfa unit → firmware map

| msfa unit (file) | Firmware | Conf | Where they agree |
|---|---|---|---|
| `Dx7Note::compute` (dx7note.cc:221) | `dx7note_compute_block 0x020862FA` | **high** | LFO→pitch/amp mod→per-op freqlut/env→`core->render`→mix; structure identical (§4) |
| `FmCore::render` (fm_core.cc:93) | `fm_core_render 0x02085A28` | **high** | 32×6 algorithm table `0x01C07D6C`; `(flags & 0xc0) == 0xc0` feedback test at `0x02085C1C`; `has_contents[3]={1,0,0}` from `0x02045FC0`; `phase += freq << 6` at `0x020862E4` |
| `FmOpKernel::compute*` (fm_op_kernel.cc) | kernels inside `0x02085A28`, `0x02085824` | **high** | phase `>>12`, quadrant sin decode (`& 0xC00`), sin LUT `0x1C06678`, exp2 LUT `0x1C05E78` with `uextra(p:10,l:5)` shift, sign via `|0x70000 ^ 0xFFFF` |
| `Env` (env.cc) | `env_release 0x0201F3FC`, per-op process `0x0204860A8`, init inline in `0x0201F5F4` | **high** | 36-byte env struct; `scaleoutlevel` via levellut `0x0204F0B5`; `−4256` clamp 16; `(rate*41)>>6`; `(4+(q&3))<<(2+(q>>2))` |
| `PitchEnv` (pitchenv.cc) | keyoff in `0x0201F46C`, getsample in `0x020862FA` | **high** | `pitchenv_tab[l] << 19` (`0x0204FB7C`); `pitchenv_rate[r] * unit` (`0x0204FBE0`) |
| `Lfo` (lfo.cc) | init `0x0201DA10`, sample in `0x020862FA` | **high** | 25190424 constant; delay `(16+(a&15))<<(1+(a>>4))`, `& 0xFF80` min 0x80; all 6 waveforms incl. s&h `rand*179+17` (as `*−77+17`, ≡ mod 256) and `^0x80 <<16` |
| `Freqlut::lookup` (freqlut.cc:46) | inline in `0x020862FA` (`0x02086686`–`0x020866C6`) | **high** | `ix = (logfreq>>14)`, frac 14 bits, RAM table `0x1C138B0`, `y >> (20 − (logfreq>>24))` — exact |
| `Sin::lookup` / `Exp2::lookup` | in every kernel | **high** | `h[0x1C06678 + (p&1023)*2]` with quadrant fold; exp2 `(h[0x1C05E78 + (~x&1023)*2] + 4096) >> (x>>10 & 31)` |
| `Controllers` matrix (controllers.h) | `dx7_mod_update 0x0201F4EA` | **high** | per-destination `smax` combine of wheel/breath/foot/aftertouch into mod amounts |
| `unpackProgram` / pack (dx7note.cc) | unpack `0x0201D69C`, pack `0x0201D532` | **high** | identical bit packing, 21 B/op VCED ↔ 17 B/op VMEM (§5) |
| `Dexed::getSamples` (dexed.cpp:180) | `0x020862FA` + pump `0x02086B16` | **high** | 64-sample blocks, LFO once per block, per-voice sum, `>> 4` shift at `0x0208695C` |
| voice alloc/steal (dexed.cpp:256+) | `midi_msg_dispatch 0x0201F5F4` | **high** | round-robin cursor `b[midi+20]`, steal oldest, sustain handling |

---

## 4. Render flow (one 64-sample block)

Entry: `dx7note_compute_block 0x020862FA` (shard_02084824_0208c3b4.txt),
called by the engine task pump (§6). Source ground truth:
`Dexed::getSamples` + `Dx7Note::compute` — the firmware fuses them; step by
step:

1. **Gate**: writes 0 to perf counter `0x10904`; skips if
   `b[dev+19] > 1` (suspended) or `[dev+252] == 0` (no engine).
2. **Zero mix buffer**: `memset([engine+28], 0, 256)` — 64 × s32
   (`0x02086330`).
3. **LFO**: `[engine+32] += [engine+36]` (phase); waveform select
   `tbb [b[engine+40]]` — all six msfa waveforms verified:
   triangle (`x>>7 ^ sign`, `& 0xFFFFFF`), saw down (`(~p^1<<31)>>8`),
   saw up, square (`(~p>>7) & 1<<24`), sine (interpolated quarter-wave
   `0x2050FAC` + `(1<<23)`), s&h (`rand = rand*179+17` ≡ `*−77+17` mod 256,
   `(rand^0x80 + 1) << 16`) — lfo.cc:82–100, exact **[high]**.
   LFO delay: two-segment accumulator at `[engine+44]` vs
   `[engine+48]/[engine+52]` — `Lfo::getdelay` (lfo.cc:105) **[high]**.
4. **Per voice** (loop var `r3`, `stride 0x1D4 = 468` over `[engine+16]`,
   count `b[engine+12]` = 12; skip if `b[voice+4] == 0`):
   - pitch-env/portamento advance at voice+420/+424, direction flag at
     +436, glissando flag `b[voice+437]` (msfa `porta.cpp`/`pitchenv.cc`
     state) **[med]**;
   - pitch mod matrix: 64-bit products of `pitchmoddepth × lfo_delay`
     (`>> 39`), `ctrls->pitch_mod × senslfo` (`>> 14`), `abs()`, `max()`
     — matches dx7note.cc:223–230 instruction-for-instruction **[high]**;
   - amp mod: `(ampmoddepth × lfo_delay) >> 8`, `× lfo_val >> 24`,
     `ctrls->amp_mod × lfo_val >> 7`, `max()` — dx7note.cc:273–281 **[high]**;
   - per op (6×, env struct 36 B at voice+44+op·36, op state 16 B at
     voice+260+op·16):
     - op-switch bit test from `b[engine+120]` (`& 1<<op`) —
       `ctrls->opSwitch[op]` **[high]**;
     - `level_in = gain_out` shift at voice+260+op·16 **[med]**;
     - **freqlut**: `logfreq = [voice+356+op·4] (basepitch) + pitch_base
       (bend+tune) + pitch_mod`; lookup in RAM table `0x1C138B0`:
       `ix = (logfreq >> 12) & 4092`, `frac = logfreq & 16383`,
       `y0 + (y1−y0)·frac >> 14`, `>> (20 − (logfreq>>>24))` —
       freqlut.cc:46–54, **exact** **[high]**; phase increment →
       `[voice+268+op·16]` (= op-state `freq`, op stride 16 via `r13+4`)**[high]**;
     - env process `0x0204860A8(env = voice+44+op·36)` → op-state
       `level_in` **[med]**;
     - feedback level `[voice+380+op·4]` scaled by fb shift **[med]**.
   - **fm_core_render** `0x020867D4`:
     `fm_core_render(mixbuf = [engine+24], opstate = voice+260,
       algo = [voice+452], fb_regs = voice+440,
       stack: fb_shift = [voice+448], 64)` — `ctrls->core->render(buf,
       params_, algorithm_, fb_buf_, fb_shift_)` (dx7note.cc:336) **[high]**;
   - per-voice output **gain ramp**: float state machine at voice+16..+40
     (stage counter, current/target gain, step; constants 1.0/4.9/0.35/
     0.107/0.05/0.075) — 5-stage fade in/out anti-click envelope **[med]**;
   - **mix**: `mix[j] += signed_saturate(voice_out[j] >> 4)` —
     `audiobuf.get()[j] >> 4` (dexed.cpp:216) **[high]**.
5. **Output**: 64-frame s32 mix → 16-bit stereo into the ping-pong at
   `0x01C0E670 + 0x2024 + phase*256` (`0x01C10694`/`0x01C10794`), phase
   `b[dev+20]` toggles 0/1 (`0x020869AC`–`0x02086AA4`) **[high]**.
6. Perf counter `0x10904` compared against 1001 (budget check) at
   `0x02086AC6`.

Then `audio_stream_frame_fsm 0x0208B736` (fade) and `fx_chain_process
0x02087A26` run the block through the **6 FX slots** (ids at
`0x01C0E670+5791+i*3`, enable/param at `+5792+id*3`, dispatch table
`0x02045FC4` 12 B/entry: init@+0 called by patch load, process@+8 called as
`fn(buf, frames)`; reverb network + modulated kernels inside the
`0x02087A26` span) **[med]**, and `pcm_mix_to_dac 0x02088FC2` feeds the DAC
accumulator (see doc 03 §5.3).

### 4.1 `fm_core_render 0x02085A28(out, opstate, algo, fb_regs, fb_shift, n)`

(shard_02084824_0208c3b4.txt) — `FmCore::render` **[high]**:

- algorithm entry `b[0x01C07D6C + algo*6 + op]`, decoded as:
  `r4 = flags & ~3` (buffer index ×4), bits 0–1 = output select, bit 2 =
  feedback-in flag, bits 4–5 = input bus — msfa's per-op packing
  `(in<<2 | fb<<1 | out)` (fm_core.cc:29–62) **[high]**;
- `(flags & 0xC0) == 0xC0` → feedback path when `fb_shift < 16` —
  fm_core.cc:114, exact **[high]**;
- per-op 16-byte state `{level_in(+0), gain_out(+4), freq(+8), phase(+12)}`;
  gain smoothing `gain1 = gain_out`, threshold ≈ 16284/16285 (msfa
  `kLevelThresh = 1120` — different internal units here) **[med]**;
- `phase += freq << 6` per 64-block (`0x020862E4`) — fm_core.cc:133 with
  `LG_N = 6` **[high]**;
- specialized cascades: algorithms 3, 5, 31 (0-based) get unrolled chains —
  the 3-op cascade calls **`fm_op_chain3_kernel 0x02085824`** (three
  sin/exp2 ops serially over 64 samples, out as s32) **[med]**;
- a 2-op cascade kernel is inlined at `0x02085F32` **[med]**.

### 4.2 The operator kernel (all copies)

Phase: `p = phase_acc + fb_reg`; `ix = p >> 12`; quadrant `ix & 0xC00`
selects fold/sign over `sin_u16[ix & 1023]` at `0x1C06678`
(`^ 0x3FE` for odd quadrants, `| 0xFFFF8000` for negative) — a
quadrant-folded quarter-wave sine, u16 **[high]**.

Level: `x = sin_out + level`; `y = (exp2_u16[~x & 1023] + 4096) >>
uextra(x, p:10, l:5)`; sign restored with `(y | 0x70000) ^ 0xFFFF` when
`x < 0`; result `<< 13` — this is `Exp2::lookup` applied to
`sin + level_in`, i.e. the msfa operator output **[high]**.

### 4.3 `Env` — 36-byte struct at voice+44+op·36

Fields (from `env_release 0x0201F3FC`, note-on init in `0x0201F5F4`):

| Off | Type | msfa field |
|---|---|---|
| +0..3 | u8 | `rates_[4]` |
| +4..7 | u8 | `levels_[4]` |
| +8 | i32 | `outlevel_` |
| +12 | i32 | `rate_scaling_` |
| +16 | i32 | `level_` |
| +20 | i32 | `targetlevel_` |
| +24 | u32 | `ix_` (stage) |
| +28 | i32 | `inc_` |
| +32 | u8 | `rising_` |
| +33 | u8 | `down_` / retrigger flag |

`env_release` = `Env::keydown(false)` → `advance(3)`: stage ← 3, target
from `levellut` (`scaleoutlevel(L) >> 1 << 6 + outlevel − 4256`, clamp 16,
`<< 16`), direction, `inc = (4+(q&3)) << (2+(q>>2))` with
`q = (rate*41)>>6 + rate_scaling`, clamp 63 — env.cc:118–156 **[high]**.
(The firmware's shift is `(q>>2)+2`; msfa has `(q>>2)+2+LG_N` — the
`LG_N = 6` fold is accounted for by the firmware's per-sample vs per-block
scaling elsewhere; treat the exact constant as **[med]**.)

### 4.4 Voice struct — 468 bytes (`0x1D4`)

Stride proven three ways: render loop `r2 += 468` (`0x0208698A`),
allocator `r6 = r0 * 0x1D4` (`0x0201F686`), `5616 = 12×468` alloc.

| Off | Conf | Meaning |
|---|---|---|
| +0 | high | MIDI note (b) |
| +1 | high | MIDI channel (b) |
| +2 | high | allocated/active flag (b) |
| +3 | high | sustained/held flag (b) |
| +4 | high | sounding flag (b) — render gate |
| +16..+40 | med | output gain-ramp float state (stage, current, target, step, param links) |
| +44 | **high** | 6 × 36 B op env structs (+44..+260) — `dx7voice_state_copy` copies this 320 B block |
| +260 | **high** | 6 × 16 B fm op states `{level_in, gain_out, freq, phase}` |
| +356 | high | 6 × u32 `basepitch_` (per-op logfreq from note-on) |
| +368 | high | pitch env (ix at +16, inc/level/target; flags at +392/+393) |
| +380 | med | 6 × u32 feedback levels |
| +412..+415 | med | pitch-env levels bytes |
| +416..+419 | med | pitch-env rates bytes |
| +420/+424/+428/+436/+437 | med | portamento/pitch-glide state (current, target, stage, direction, glissando flag) |
| +440 | high | `fb_regs` (2 × u32, fm_core arg3) |
| +448 | high | `fb_shift` (u32) |
| +452 | high | algorithm (u32) |
| +464 | med | per-voice pitch offset (scaled by LFO pitch mod) |

### 4.5 LFO params — `dx7_lfo_params_compute 0x0201DA10`

(shard_02019e9e_0201f07e.txt) — matches `Lfo::init`+`Lfo::reset`
(lfo.cc:52–76) **[high]**:

- `unit = 25190424 * [engine+8] / [engine+0]` (the `0x1806018` constant);
- rate: `speed = b[dev+5745]`; `r = speed*165 >> 6` (0xA5 = 165 ✓, same as
  `(patch[139]*165)>>6` for depth); `if (r ≥ 10240) rate = 11 + ((r−160)>>4)
  else rate = 11`;
- delay: `a = 99 − b[dev+5746]`; if `a == 99` → `delayinc = delayinc2 =
  ~0u` (0xFFFFFFFF ✓); else `v = (16+(a&15)) << (1+(a>>4))`, `[engine+48] =
  v*unit`, `[engine+52] = max(v & 0xFF80, 0x80) * unit` — exact;
- `b[engine+40] = waveform (dev+5748)`, key-sync at `b[engine+42]`.

---

## 5. Voice flow & management

### 5.1 MIDI → voice — `midi_msg_dispatch 0x0201F5F4`

(shard_0201f0d0_020223ba.txt) Central channel-voice handler (2026 B)
**[high]**. Args: `r0` = MIDI state struct, `r1` = 3-byte message.
Layout of the state struct (offsets seen): `[+12]` voice count,
`[+16]` → voice array, `[+20]` alloc cursor, `[+21]` sustain flag,
`[+62]` (h, at `r0+40+22`) pitch-bend 14-bit, CC destinations:
CC1 wheel → `[+72]`, CC2 breath → `[+76]`, CC3 → `[+84]`, CC4 foot →
`[+80]` (stores at `0x0201F79E`/`0x0201F6D2`/`0x0201F6D8`/`0x0201F7A4`),
note transpose at `0x1C0E670+5752`.

- **Note off** (`0x8n`): scan voices for matching note
  (`b[voice+0] == note+transpose−24`) and clear `b[voice+2]`
  (`0x0201F63C`); sustain (`b[midi+21]`) defers to release.
- **Note on** (`0x9n`, vel > 0): range-check `note+transpose−24 ≤ 127`;
  find free voice round-robin from cursor `b[midi+20]` (`b[voice+2] == 0`),
  else **steal** at cursor and wrap (`0x0201F7D8`); write note/ch/flags;
  logfreq base `(note << 24) / 12 + 50857777` — the msfa base constant
  (dx7note.cc:40) **[high]**; then full per-op init from the working VCED
  (21 B/op at `0x1C0E670+5624+op*21`): `ScaleLevel` (`(offset±1)/3`,
  curve via exp_scale_data `0x0204F44C`, `* 329 >> 12/15` — exact),
  `scaleoutlevel`, `outlevel << 5`, `ScaleVelocity` (`velocity_data −239`,
  `((sens*v + 7) >> 3) << 4` — exact), `ScaleRate` (`(sens*x)>>3`, `x =
  min(31, note/3 − 7)` — exact), env init, `osc_freq` fields
  (mode/coarse/fine/detune at VCED `off+17..20`; the fixed-frequency path
  `(4458616 * ((coarse&3)*100 + fine)) >> 3` and
  `detune > 7 ? 13457*(detune−7) : 0` — dx7note.cc:75–76, exact, at
  `0x0201FAB4`/`0x0201FAC4`; `coarsemul[coarse & 31]` indexed load at
  `0x0201FB4A`), `basepitch` →
  voice+356+op·4, `ampmodsens = ampmodsenstab[VCED[off+14] & 3]`,
  algorithm/feedback/LFO apply — this is `Dx7Note::init`
  (dx7note.cc:163–213) **[high]**.
- **CC** (`0xBn`): CC1 wheel → `[+72]`, CC2 breath → `[+76]`, CC3 →
  `[+84]`, CC4 foot → `[+80]`, CC64 sustain → `[+21]` flag + all-notes
  release loop calling `dx7voice_keyoff 0x0201F46C` per held voice
  (`0x0201F6F6`), then `dx7_mod_update 0x0201F4EA` (the `smax`
  controller matrix).
- **Program change** (`0xCn`): stored via the `tbb` switch case;
  **Pitch bend** (`0xEn`) → 14-bit at `[+62]` (`0x0201F6AA`).

`dx7voice_keyoff 0x0201F46C(voice+44)`: `env_release` × 6 (36 B stride)
then pitch-env release (`pitchenv_tab[l] << 19` from `0x0204FB7C`,
`pitchenv_rate[r] * scale` from `0x0204FBE0`) — `Dx7Note::keyup`
(dx7note.cc:339) **[high]**.

`dx7voice_state_copy 0x0201F368(dst+44, src+44)`: copies the 320-byte voice
param/state block (6 × 36 B op blocks + globals) — used for
legato/mono voice transfer (`Dx7Note::transferState`, dx7note.cc:415)
**[high]**.

### 5.2 Patch handling — DX7 VMEM/VCED

Working patch = **155-byte VCED** at `0x1C0E670+5608` (op `i` at
`+5624+i*21`, globals at `+5734`…, layout identical to msfa's
`patch[156]` used by `Dx7Note::init`) **[high]**.

| Function | Addr | Conf | Purpose |
|---|---|---|---|
| `dx7voice_pack_store` | `0x0201D532` | **high** | pack 155 B VCED → 128 B DX7 VMEM, write flash at `slot*128` |
| `dx7patch_load_or_store` | `0x0201D69C` | med | load/unpack bank slots from flash; persist edited slots (59 B settings at flash `+0xC000 + slot*59`) |
| `dx7patch_select_apply` | `0x0201DAB8` | med | select patch: load, apply params, show name, recompute LFO |
| `dx7_global_params_apply` | `0x0201D99C` | med | apply four table-indexed params (`0x02045F20` tables) into synth state |
| `dx7_lfo_params_compute` | `0x0201DA10` | **high** | LFO rate/delay from patch bytes (§4.5) |
| bank loader | `0x0201DB0A` | med | copy 4 KiB bank (32 × 128 B VMEM) flash → `0x01C118B0` |
| `midi_message_handler` | `0x02023EA0` | **high** | MIDI in parse incl. **DX7 sysex dumps** (bulk dump receive) |
| `serial_midi_task` | `0x02027AF4` | med | serial MIDI RX parse, vendor sysex, TX DMA |
| `usb_midi_sysex_engine` | `0x02005D86` | med | USB-MIDI DX7 sysex pack/stream engine |

**Packing** (`0x0201D532`, shard_02019e9e_0201f07e.txt): per op, 21 VCED
bytes → 17 VMEM bytes with the exact DX7 bit packing —
`b0 = R1 | (R2&3)<<2`, `b1 = R3 | (R4&0xF)<<3`, `b2 = L1 | (L2&7)<<2`,
`b3 = L3`, `b4 = L4 | (KRS&0x1F)<<1`, …, loop guard `if (off != 126)`
(6 × 21); globals: pitch-env rates/levels, `ALG | (FB&1)<<3`, LFO
speed/delay/PMD/AMD, sync/pitch-sens byte, transpose, 10-char name —
**exactly `unpackProgram`'s inverse** (msfa dx7note.cc) **[high]**. Flash
write: base from `[dev+256]` (+ counter diff `0x02003712`), offset
`slot << 7`, via flash IO `0x020037B4`.

**Unpacking** (`0x0201D69C`, same shard): the inverse field extraction
(`uextra(p:2,l:2)` for the packed rate pairs, `>>3`/`&7` splits — visually
identical to `unpackProgram`), into the VCED buffer, then applies
algorithm byte (`b[dev+5822]` → `[engine+22]`) and re-inits the 6 FX slots
through the `0x02045FC4` table's init entry `[+0]` **[med]**.

### 5.3 The synth audio task / render pump

The DMA-half event (doc 03 §5.3: `0x12E00` IRQ → `audio_dac_dma_irq
0x02088EEE`) wakes the pump. The pump body is RAM-resident at
`0x02086AD6`–`0x02086B42` (shard_02084824_0208c3b4.txt):

```
b[0x1C1FF08] = 1
call 0x020485EB6 / 0x020485F78        ; RAM: event wait/signal pair
loop:
  if (b[0x1C16EC0] == 5) audio_buf_state_init 0x020857FE  ; reset counters, zero 512B ping-pong
  if (b[0x1C16EC0] == 2) dx7note_compute_block 0x020862FA ; render one 64-frame block
```

So rendering is **pumped by the DAC DMA half interrupts**: each half/full
event renders one 64-sample block into the free ping-pong half **[high]**.
Block cadence: 64 / 44118 Hz ≈ 1.45 ms.

---

## 6. Reusing this engine / replacing it

### 6.1 Reuse as-is

The engine is a faithful msfa port — you can drive it exactly like Dexed:

- **Patches**: write a 155 B VCED block to `0x1C0E670+5608` and call the
  apply path (`dx7patch_select_apply 0x0201DAB8` with a slot, or the apply
  pieces: `dx7_global_params_apply 0x0201D99C` + `dx7_lfo_params_compute
  0x0201DA10`) **[med]**; or inject MIDI program change / sysex through
  `midi_message_handler 0x02023EA0`.
- **Notes**: call `midi_msg_dispatch 0x0201F5F4(midi_state, msg3)` with
  standard 3-byte MIDI — allocation, steal, controllers, bend are all
  handled **[high]**.
- **Parameters**: master tune at `[engine+56]`, volume/gain byte via
  `audio_dac_set_digital_volume 0x0203F018`, FX slots via the
  `0x02045FC4` table (12 B/entry: `{params…, init@+0, process@+8}`).

### 6.2 Swap in your own engine (e.g. your own Dexed build)

Cleanest hook points, all verified:

1. **Replace the block renderer** — the pump calls
   `dx7note_compute_block 0x020862FA` from `0x02086B3E` (RAM). Patch that
   call (or the whole pump `0x02086AD6`, both copied from the flash image
   `0x02084824+`) to your own `render64(void)`:
   - input: nothing (pull MIDI/controllers yourself, or reuse
     `midi_msg_dispatch` for voice management),
   - output: 64 stereo s16 frames into the ping-pong half at
     `0x01C0E670 + 0x2024 + b[dev+20]*256` (`0x01C10694`/…794),
     then toggle `b[dev+20]` — FX chain, fades, volume and DAC feed all
     keep working **[high]**.
2. **Reuse the engine's config/ABI**: mirror the 160 B config block at
   `[dev+252]` (rate 44118, 64-frame blocks, 12 × 468 B voices) so the
   existing plumbing (`fx_chain_process 0x02087A26`,
   `audio_stream_frame_fsm 0x0208B736`) stays valid **[med]**.
3. **Bypass the engine entirely**: hook the DAC render callback
   `[0x01C0E670+4228+36]` (ABI: `cb(priv, buf+half_off, half_len)` from
   IRQ) — see doc 03 §7.1. Your engine then owns the DAC directly; the
   FM engine must be suspended (`b[dev+19] > 1` gates its render at
   `0x02086312`) **[high]**.
4. **Reuse the RAM LUTs for your own DSP**: freqlut `0x1C138B0`
   (1025 × u32, `2^44/44118` scaled), sin `0x1C06678` (u16
   quarter-wave-folded), exp2 `0x1C05E78` (u16), quarter-wave Q24 sin
   `0x2050FAC` (rodata), plus all the rodata tables of §1.

### 6.3 Known differences from stock msfa (watch these)

- 12 voices (Dexed usually 16) — allocation-proven **[high]**.
- u16 sin/exp2 LUTs (msfa uses s32) and no sin interpolation in the op
  kernels — slightly cheaper/rougher operators; the LFO sine path *is*
  interpolated (`0x2050FAC`) **[high]**.
- fm core gain threshold ≈ 16284 vs msfa `kLevelThresh = 1120` — different
  internal gain units **[med]**.
- `Env::advance` increment lacks the explicit `+ LG_N` in the shift
  (§4.3) **[med]**.
- Writable algorithm table in RAM (`0x01C07D6C`) with runtime patching of
  algorithms 3/5 (`0x02085A7C`) — special-casing the cascade shapes
  **[med]**.
- Sample rate **44118 Hz**, not 44100 (DAC clock-trim-corrected rate;
  `audio_dac_sr_calc 0x0205CBBC` computes the correction) **[high]**.

---

## 7. Quick reference — addresses

| What | Address |
|---|---|
| `dx7note_compute_block` (renderer, RAM) | `0x020862FA` |
| `fm_core_render` | `0x02085A28` |
| `fm_op_chain3_kernel` | `0x02085824` |
| env per-op process | `0x0204860A8` |
| engine pump loop | `0x02086AD6`–`0x02086B42` |
| `midi_msg_dispatch` | `0x0201F5F4` |
| `dx7voice_keyoff` / `env_release` | `0x0201F46C` / `0x0201F3FC` |
| `dx7voice_state_copy` | `0x0201F368` |
| `dx7_mod_update` | `0x0201F4EA` |
| `dx7_lfo_params_compute` | `0x0201DA10` |
| `dx7voice_pack_store` (VCED→VMEM→flash) | `0x0201D532` |
| `dx7patch_load_or_store` / select | `0x0201D69C` / `0x0201DAB8` |
| `fx_chain_process` (6 slots) | `0x02087A26` |
| `audio_stream_frame_fsm` (fade) | `0x0208B736` |
| engine config block (160 B) | `[0x01C0E670+252]` |
| voice array (12 × 468 B) | `[engine+16]` |
| working VCED (155 B) | `0x01C0E670+5608` |
| freqlut (RAM, 1025 × u32) | `0x1C138B0` |
| sin / exp2 working LUTs (RAM, u16) | `0x1C06678` / `0x1C05E78` |
| algorithm table (RAM, 32 × 6 B) | `0x01C07D6C` |
| quarter-wave sin LUT (rodata, u32 Q24) | `0x2050FAC` |
| msfa rodata tables | §1 (base `0x204E8E0`; shards show `0x204EA00`) |
| sample rate / block size / polyphony | 44118 Hz / 64 / 12 |
