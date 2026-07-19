# 03 — DX7 synth-core identification

**Conclusion: the FM engine is Dexed / MicroDexed — i.e. Google's
*music-synthesizer-for-android* (`msfa`) DX7 core.**

## Evidence from the firmware

`app.bin` strings expose a full 6-operator DX7 editing model — exactly the
parameter surface of the Yamaha DX7 / Dexed:

```
1/6  OP1 Envelope     3/6  OP1 Tuning     4/6  OP1 Sens&Lvl
5/6  OP1 Scaling      6/6  OP1 Scaling
1/2  PitchEnvelope    LFO   Lfo Sync      Pitch Sens / Pitch Up / Pitch Dn
Dx7 32 Voice Save To ...   Patches   Preset   Reset All Patches
Arpeggio   Sequencer   Reverb   Filter   midi_route
```

- "OP1…OP6", "Sens&Lvl", "Scaling" (rate/level breakpoint scaling), "Pitch
  Envelope", and per-operator envelopes are the DX7's exact parameter names.
- "**Dx7 32 Voice**" = the classic DX7 32-voice cartridge (VMEM) bank layout.
- Community teardown of the same product family independently reports that the
  factory patches are the **literal Yamaha DX7 ROM1A** cartridge, including
  quirks that glitch on every hardware Dexed clone.

## Lineage

```
Yamaha DX7 (1983)
   │  reverse-engineered algorithms
music-synthesizer-for-android (Google, "msfa", Apache-2.0)
   │  fm_core / fm_op_kernel / env / lfo / pitchenv / freqlut / sin / exp2 / dx7note
Dexed  (asb2m10)                     ← desktop plugin, adds UI + sysex
   │
Synth_Dexed (dcoredump)             ← library port for MCUs (Teensy), engines:
   │                                    EngineMsfa (bit-accurate), EngineMkI, EngineOpl
MicroDexed / MiniDexed              ← embedded hardware synths
   │
M-Vave FM-1 firmware  (this device) ← msfa core on JieLi pi32v2 + product glue
```

The msfa core stays Apache-2.0 specifically so it can be reused across
Dexed/MicroDexed/MiniDexed; that is the code the firmware's synth section
corresponds to.

## Consequence for reconstruction

The DSP core does **not** need to be recovered by disassembly — it is
open-source. `reference/Synth_Dexed` (embeds `EngineMsfa`) is the drop-in
upstream. What is genuinely product-specific and worth recovering from the
binary is the *glue*: patch/bank management, the menu/UI tree (strings above),
MIDI routing (`midi_route`), arpeggiator, sequencer, and the effects
(`Reverb`, `Filter`). See `04-toolchain-and-vendoring.md` and the reconstruction
plan.

## References

- music-synthesizer-for-android: https://github.com/google/music-synthesizer-for-android
- Dexed: https://github.com/asb2m10/dexed
- Synth_Dexed: https://codeberg.org/dcoredump/Synth_Dexed
- MicroDexed: https://codeberg.org/dcoredump/MicroDexed
- SMK-37 Pro community notes: https://gist.github.com/probonopd/18b3ed65a69d0229eb630c47d7e316dc
