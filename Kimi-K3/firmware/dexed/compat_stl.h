/* Compatibility shim for the JieLi pi32v2 toolchain, which ships newlib C
 * headers but no libc++. Provides the tiny std:: subset Synth_Dexed uses. */
#ifndef DEXED_COMPAT_STL_H
#define DEXED_COMPAT_STL_H

#include <stdlib.h>
#include <math.h>

namespace std {
  template <typename T> inline const T& min(const T& a, const T& b) { return a < b ? a : b; }
  template <typename T> inline const T& max(const T& a, const T& b) { return a > b ? a : b; }
}

#endif
