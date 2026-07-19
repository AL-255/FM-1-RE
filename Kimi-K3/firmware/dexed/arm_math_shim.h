/* Minimal portable replacement for the CMSIS-DSP subset used by Synth_Dexed.
 * Plain C, no SIMD — for pi32v2 (JieLi) and host builds.
 * Only what dexed.cpp / compressor.h actually references.
 */
#ifndef ARM_MATH_SHIM_H
#define ARM_MATH_SHIM_H

#include <stdint.h>
#include <string.h>

typedef int16_t q15_t;
typedef float float32_t;
typedef bool boolean;

typedef struct {
  int numStages;
  float *pCoeffs;
  float *pState;
} arm_biquad_casd_df1_inst_f32;

static inline void arm_fill_f32(float v, float *dst, uint32_t n) {
  for (uint32_t i = 0; i < n; i++) dst[i] = v;
}

static inline void arm_float_to_q15(const float *src, q15_t *dst, uint32_t n) {
  for (uint32_t i = 0; i < n; i++) {
    float x = src[i] * 32768.0f;
    if (x > 32767.0f) x = 32767.0f;
    if (x < -32768.0f) x = -32768.0f;
    dst[i] = (q15_t)(x + (x >= 0 ? 0.5f : -0.5f));
  }
}

static inline void arm_scale_f32(const float *src, float s, float *dst, uint32_t n) {
  for (uint32_t i = 0; i < n; i++) dst[i] = src[i] * s;
}

static inline void arm_mult_f32(const float *a, const float *b, float *dst, uint32_t n) {
  for (uint32_t i = 0; i < n; i++) dst[i] = a[i] * b[i];
}

static inline void arm_offset_f32(const float *src, float o, float *dst, uint32_t n) {
  for (uint32_t i = 0; i < n; i++) dst[i] = src[i] + o;
}

static inline void arm_sub_f32(const float *a, const float *b, float *dst, uint32_t n) {
  for (uint32_t i = 0; i < n; i++) dst[i] = a[i] - b[i];
}

static inline void arm_biquad_cascade_df1_init_f32(
    arm_biquad_casd_df1_inst_f32 *S, int numStages, float *pCoeffs, float *pState) {
  S->numStages = numStages;
  S->pCoeffs = pCoeffs;
  S->pState = pState;
  memset(pState, 0, sizeof(float) * 4 * numStages);
}

static inline void arm_biquad_cascade_df1_f32(
    const arm_biquad_casd_df1_inst_f32 *S, float *src, float *dst, uint32_t n) {
  const float *coeff = S->pCoeffs;
  float *state = S->pState;
  for (int st = 0; st < S->numStages; st++) {
    float xn1 = state[0], xn2 = state[1], yn1 = state[2], yn2 = state[3];
    float b0 = coeff[0], b1 = coeff[1], b2 = coeff[2], a1 = coeff[3], a2 = coeff[4];
    for (uint32_t i = 0; i < n; i++) {
      float xn = src[i];
      float yn = b0 * xn + b1 * xn1 + b2 * xn2 - a1 * yn1 - a2 * yn2;
      xn2 = xn1; xn1 = xn; yn2 = yn1; yn1 = yn;
      dst[i] = yn;
    }
    state[0] = xn1; state[1] = xn2; state[2] = yn1; state[3] = yn2;
    src = dst;
    coeff += 5;
    state += 4;
  }
}

#endif /* ARM_MATH_SHIM_H */
