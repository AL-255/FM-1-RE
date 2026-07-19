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

#pragma once

#include "fm_op_kernel.h"
#include "aligned_buf.h"
#include "controllers.h"
#include "fm_core.h"

class EngineMsfa : public FmCore {
  public:
    EngineMsfa() {};
    ~EngineMsfa() {};
    void render(int32_t *output, FmOpParams *params, int32_t algorithm, int32_t *fb_buf, int32_t feedback_gain) override;
};
