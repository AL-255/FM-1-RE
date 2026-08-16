# 03 — Audio output & the FM (DX7/Dexed) synth engine

## Bit-exact proof: the engine is msfa (Dexed / MicroDexed)

The firmware embeds the **exact** DX7 lookup tables from Google's
*music-synthesizer-for-android* (`msfa`), the core inside Dexed / MicroDexed /
Synth_Dexed. These are byte-for-byte matches found by scanning `app.bin` for the
tables in `dx7note.cc`:

| msfa table (dx7note.cc) | Values (first entries) | Found at (firmware addr) |
|---|---|---|
| `pitchmodsenstab[8]` (u8) | `0,10,20,33,55,92,153,255` | **`0x0204eb90`** |
| `ampmodsenstab[4]` (u32) | `0,4342338,7171437,16777216` | **`0x0204ef4c`** |
| `velocity_data[64]` (u8) | `0,70,86,97,106,114,121,126,…` | **`0x0204f760`** |
| `coarsemul[32]` (i32) | `-16777216,0,16777216,26591258,…` | **`0x0204fc44`** |

There is no ambiguity: these constants (e.g. `ampmodsenstab = {0,4342338,…}`)
are unique to the msfa codebase. The FM engine is a port of that code.

## FM note / voice module (located)

Code that references these tables — i.e. the DX7 note module (`dx7note.cc`:
`osc_freq`/`init`/`compute`, using `coarsemul`, `velocity_data`,
`pitchmodsenstab`, `ampmodsenstab`) — clusters at:

```
~0x0203d900 … 0x0203ec00     DX7 note/voice module (msfa dx7note + friends)
  0x0203d97a, 0x0203e720, 0x0203e962, 0x0203eb14   reference pitchmodsenstab
  0x020008b0                                       also references pitchmodsenstab
```

The surrounding functions in `0x0203xxxx` are the rest of the msfa core
(`fm_core` algorithm routing, `fm_op_kernel` operator, `env` envelope,
`lfo`, `pitchenv`, `freqlut`, `exp2`, `sin`). The rodata block around
`0x0204e000–0x02050000` holds their tables (sin/exp2/freqlut in addition to the
four above). Use the msfa source as the reference decompilation for this whole
region — it is the same code.

### DX7 voice-management & control layer (from function analysis)

Above the raw msfa kernel sits the product's voice/patch/note layer at
`0x0201d9xx–0x02022xxx`:

| Address | Role |
|---|---|
| `0x0201f5f4` | **MIDI channel-voice dispatcher** — note on/off, CC (incl. sustain), program change, pitch-bend applied to the FM voices (2 KB, the central handler) |
| `0x0201fe64` | note-off to engine + MIDI out; all-notes-off / panic; parameter/UI refresh |
| `0x02020552` | send NOTE ON (velocity) to a voice, echo to MIDI out |
| `0x0201d99c` | apply patch params (algorithm/feedback/…) from tables into synth state |
| `0x0201da10` | compute LFO / pitch / portamento rates from DX7 patch bytes |
| `0x0201f368` | copy a 6-operator DX7 voice parameter block (per-op + global) |
| `0x0201f3fc` | compute one operator's envelope (EG) rate/level on key state change |
| `0x0201f46c` | advance / key-off envelopes for all 6 operators + pitch EG |
| `0x0201f4ea` | per-operator output level/scaling from the algorithm carrier/mod matrix |

### Arpeggiator & step sequencer

| Address | Role |
|---|---|
| `0x020201dc` | arp/seq transport & mode controller (start/stop, pattern load) |
| `0x02020c0e` | arp/step-seq playback engine (clock steps, trigger note on/off) |
| `0x02020724` | build arp note sequence from held notes (mode/octave/direction) |
| `0x0202058a` | sort held notes by pitch/priority for arp ordering |
| `0x02022106` / `0x02022282` / `0x02022310` | held-note bookkeeping (add/remove, chord latch, min/max range) |

### Reference mapping (msfa → what to expect here)

| msfa unit | Role | Reference decompilation |
|---|---|---|
| `Sin::lookup` | sine table (Q30, interpolated) | `sin.cpp`, table `sintab` (1024) |
| `Exp2::lookup` | exp2 for envelope/level | `exp2.cpp`, `exp2tab` |
| `Freqlut::lookup` | logfreq → phase increment | `freqlut.cpp`, `N_SAMPLES=1024`, `SAMPLE_SHIFT=14` |
| `FmOpKernel::compute[_pure]` | one operator: phase-acc + sine + feedback | `fm_op_kernel.cpp` |
| `FmCore::compute` | routes 6 ops per the 32 algorithms | `fm_core.cpp` (algorithm table) |
| `Env` / `PitchEnv` | DX7 rate/level envelopes | `env.cpp`, `pitchenv.cpp` |
| `Lfo` | LFO (6 waveforms) | `lfo.cpp` |
| `Dx7Note::compute` | sums operators for a note | `dx7note.cpp` |

## Audio output path

The synth renders signed PCM blocks that are pushed to the on-chip **audio DAC**
via a DMA ring buffer (JieLi SDK audio driver). The render is driven from the
audio interrupt/task at the DAC sample rate (set during boot clock config, doc
02; JieLi BR audio DACs run 44.1/48 kHz). For a reuse project you feed
`Dexed::getSamples()` into the same DAC ring buffer.

Concretely (confirmed once classification lands in `09-function-index.md`, subsystem
`AUDIO_OUT`/`SYNTH_FM`): the chain is
`MIDI note → voice allocation → Dx7Note::compute (per active voice) → mix →
volume/effects → DAC DMA ring`.

## Patches

Voices are the standard **DX7 VMEM** format: 128-byte packed voice, 32 per bank
(a DX7 cartridge). Factory banks are the literal DX7 ROM patches. Unpacking to
the 155-byte VCED edit buffer follows msfa `unpackProgram()`. Bank save/load uses
the filesystem (`STORAGE_PATCH`, files under `/mnt/sdfile/app/usr`); the UI
string `"Dx7 32 Voice Save To ..."` drives bank export.

Patch pack/unpack functions (from analysis):
- `0x0201d532` — pack a DX7 single voice (155-byte **VCED → packed VMEM**) to flash.
- `0x0201d69c` — load & unpack DX7 voice(s) from a flash bank into the working VCED.
- `0x0201dab8` — select/load a patch: unpack, apply params+name+LFO, persist index.
- `0x02027af4` — settings/patch persistence task (message loop, flash commit).

The `Synth_Dexed` `EngineMsfa` source is retained as a behavioral reference for
the matching stock DSP routines.
