/*
   Copyright 2019 Jean Pierre Cimalando.

   Licensed under the Apache License, Version 2.0 (the "License");
   you may not use this file except in compliance with the License.
   You may obtain a copy of the License at

        http://www.apache.org/licenses/LICENSE-2.0

   Unless required by applicable law or agreed to in writing, software
   distributed under the License is distributed on an "AS IS" BASIS,
   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
   See the License for the specific language governing permissions and
   limitations under the License.
*/

#include <math.h>
#include "porta.h"
#include "synth.h"

bool Porta::initDone = false;
void Porta::init_sr(FRAC_NUM sampleRate)
{
  if (initDone)
    return;

  initDone = true;
  
  // compute portamento for CC 7-bit range

  float sps = 350.0f;                       /* 2^(-0.062*i) iteratively */
  const float ratio = 0.9578262952214897f;    /* 2^(-0.062) */
  const int32_t step = (1 << 24) / 12;
  for (uint8_t i = 0; i < 128; ++i) {
    float spf = sps / sampleRate;             /* per frame */
    float spp = spf * _N_;                    /* per period */
    rates[i] = (int32_t)(0.5f + step * spp);  /* to pitch units */
    sps *= ratio;
  }
}

TABLE_MEM int32_t Porta::rates[128];
