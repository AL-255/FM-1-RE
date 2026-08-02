/*
 * Copyright 2013 Google Inc.
 * 
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 * 
 *      http://www.apache.org/licenses/LICENSE-2.0
 * 
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

#define _USE_MATH_DEFINES
#include <math.h>

#include "synth.h"
#include "exp2.h"

//#include <stdio.h>

#ifdef _MSC_VER
#define exp2(arg) pow(2.0, arg)
#endif

TABLE_MEM int32_t exp2tab[EXP2_N_SAMPLES << 1];

bool Exp2::initDone = false;
void Exp2::init() {
  if (initDone)
    return;

  initDone = true;

  const FRAC_NUM inc = 1.0006771306663823f; /* 2^(1/1024), was libm exp2() */
  FRAC_NUM y = 1 << 30;
  for (int i = 0; i < EXP2_N_SAMPLES; i++) {
    exp2tab[(i << 1) + 1] = (int32_t)floorf(y + 0.5f);
    y *= inc;
  }
  for (int i = 0; i < EXP2_N_SAMPLES - 1; i++) {
    exp2tab[i << 1] = exp2tab[(i << 1) + 3] - exp2tab[(i << 1) + 1];
  }
  exp2tab[(EXP2_N_SAMPLES << 1) - 2] = (1U << 31) - exp2tab[(EXP2_N_SAMPLES << 1) - 1];
}


TABLE_MEM int32_t tanhtab[TANH_N_SAMPLES << 1];

static FRAC_NUM dtanh(FRAC_NUM y) {
  return 1 - y * y;
}

bool Tanh::initDone = false;
void Tanh::init() {
  if (initDone)
    return;

  initDone = true;
  
  FRAC_NUM step = 4.0f / TANH_N_SAMPLES;
  FRAC_NUM y = 0;
  for (int i = 0; i < TANH_N_SAMPLES; i++) {
    tanhtab[(i << 1) + 1] = (int32_t)((1 << 24) * y + 0.5f);
    //printf("%d\n", tanhtab[(i << 1) + 1]);
    // Use a basic 4th order Runge-Kutte to compute tanh from its
    // differential equation.
    FRAC_NUM k1 = dtanh(y);
    FRAC_NUM k2 = dtanh(y + 0.5f * step * k1);
    FRAC_NUM k3 = dtanh(y + 0.5f * step * k2);
    FRAC_NUM k4 = dtanh(y + step * k3);
    FRAC_NUM dy = (step / 6.0f) * (k1 + k4 + 2.0f * (k2 + k3));
    y += dy;
  }
  for (int i = 0; i < TANH_N_SAMPLES - 1; i++) {
    tanhtab[i << 1] = tanhtab[(i << 1) + 3] - tanhtab[(i << 1) + 1];
  }
  int32_t lasty = (1 << 24) * y + 0.5;
  tanhtab[(TANH_N_SAMPLES << 1) - 2] = lasty - tanhtab[(TANH_N_SAMPLES << 1) - 1];
}
