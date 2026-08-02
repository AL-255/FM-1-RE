/* Shared demo voices (firmware demo + host app). Builds 156-byte unpacked
 * Dexed voices from a captured init-voice template, so both targets produce
 * identical sounds. See dexed.h for the 156-byte layout (DexedVoiceOPParameters
 * / DexedVoiceParameters enums). */
#ifndef DEMO_VOICES_H
#define DEMO_VOICES_H

#include <stdint.h>
#include <string.h>

#define DEMO_N_PATCHES 4

/* capture the init-voice template once (from the engine) */
void voices_capture_init(const uint8_t init156[156]);

/* build patch idx (0..DEMO_N_PATCHES-1) into v (156 bytes) */
void voices_build(int idx, uint8_t v[156]);

/* name of patch idx (10 chars, not NUL-terminated) */
const char* voices_name(int idx);

#endif
