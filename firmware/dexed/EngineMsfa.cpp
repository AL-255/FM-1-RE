/*
   Copyright 2012 Google Inc.

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

//using namespace std;

#include "synth.h"
#include "exp2.h"
#include "fm_op_kernel.h"
#include "EngineMsfa.h"

void EngineMsfa::render(int32_t *output, FmOpParams *params, int32_t algorithm, int32_t *fb_buf, int32_t feedback_shift) {
  const int32_t kLevelThresh = 1120;
  const FmAlgorithm alg = algorithms[algorithm];
  bool has_contents[3] = { true, false, false };
  for (uint8_t op = 0; op < 6; op++) {
    int32_t flags = alg.ops[op];
    bool add = (flags & OUT_BUS_ADD) != 0;
    FmOpParams &param = params[op];
    int32_t inbus = (flags >> 4) & 3;
    int32_t outbus = flags & 3;
    int32_t *outptr = (outbus == 0) ? output : buf_[outbus - 1].get();
    int32_t gain1 = param.gain_out;
    int32_t gain2 = Exp2::lookup(param.level_in - (14 * (1 << 24)));
    param.gain_out = gain2;

    if (gain1 >= kLevelThresh || gain2 >= kLevelThresh) {
      if (!has_contents[outbus]) {
        add = false;
      }
      if (inbus == 0 || !has_contents[inbus]) {
        // todo: more than one op in a feedback loop
        if ((flags & 0xc0) == 0xc0 && feedback_shift < 16) {
          // cout << op << " fb " << inbus << outbus << add << endl;
          FmOpKernel::compute_fb(outptr, param.phase, param.freq,
                                 gain1, gain2,
                                 fb_buf, feedback_shift, add);
        } else {
          // cout << op << " pure " << inbus << outbus << add << endl;
          FmOpKernel::compute_pure(outptr, param.phase, param.freq,
                                   gain1, gain2, add);
        }
      } else {
        // cout << op << " normal " << inbus << outbus << " " << param.freq << add << endl;
        FmOpKernel::compute(outptr, buf_[inbus - 1].get(),
                            param.phase, param.freq, gain1, gain2, add);
      }
      has_contents[outbus] = true;
    } else if (!add) {
      has_contents[outbus] = false;
    }
    param.phase += param.freq << LG_N;
  }
}
