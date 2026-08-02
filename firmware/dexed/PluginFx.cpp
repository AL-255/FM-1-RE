/* Lean gain-only PluginFx for the size-constrained FM-1 demo build.
 * Implements the exact public API dexed.cpp uses; the full filter version
 * is kept at PluginFx.cpp.orig (re-enable for the host/VST build). */
#include "PluginFx.h"
#include <math.h>

PluginFx::PluginFx() {
  Cutoff = 1.0;
  Reso = 0.0;
  Gain = 1.0;
  aGain = 1.0;
  sampleRate = 44100;
  sampleRateInv = 1.0f / 44100.0f;
  ramp_dt = 0.0f;
}

void PluginFx::init(FRAC_NUM rate) {
  sampleRate = rate;
  sampleRateInv = 1.0f / rate;
  /* gain-ramp time constant ~5 ms */
  ramp_dt = 1.0f - expf(-1.0f / (0.005f * rate));
  resetState();
}

void PluginFx::resetState() { aGain = Gain; }

void PluginFx::process(float *work, uint16_t sampleSize) {
  if (Gain == 1.0f && aGain == 1.0f) return;
  float g = aGain;
  float dt = ramp_dt;
  for (uint16_t i = 0; i < sampleSize; i++) {
    g += (Gain - g) * dt;
    work[i] *= g;
  }
  aGain = g;
}

float PluginFx::getGain(void) { return Gain; }
