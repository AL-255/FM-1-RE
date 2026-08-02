/* demo runtime: self-contained support for the pi32v2 Dexed build.
 *
 * Our code runs inside the stock FM-1 firmware (patched image). It gets a
 * private RAM region (see link.ld) and must not depend on the stock heap:
 * we provide our own bump allocator, libc basics, and C++ operators.
 *
 * Stock-firmware services we DO call (fixed addresses, see rt.h) are only
 * the ones needed to install hooks and emit MIDI/debug — all optional at
 * runtime (presence checked by magic address sanity).
 */
#ifndef DEMO_RT_H
#define DEMO_RT_H

#include <stdint.h>
#include <stddef.h>

#ifdef __cplusplus
extern "C" {
#endif

/* --- private heap (bump allocator over our own .bss region) --- */
void  rt_heap_init(void);
void* rt_alloc(size_t size);            /* 8-byte aligned, never freed */
void  rt_free(void* p);                 /* no-op (bump allocator) */
void  rt_init(void);                    /* .data copy + .bss zero (first) */

/* --- libc basics used by the engine/compiler --- */
void* rt_memcpy(void* d, const void* s, size_t n);
void* rt_memset(void* d, int c, size_t n);
void* rt_memmove(void* d, const void* s, size_t n);

/* --- logging via the stock firmware's UART printf (best effort) --- */
void  rt_log(const char* fmt, ...);

/* --- millisecond tick: derived from audio frames rendered (44.1kHz) --- */
uint32_t rt_millis(void);
void     rt_tick_advance(uint32_t frames);

/* demo entry points invoked by the patched-in trampolines */
void demo_install(void);
void demo_midi_note(int on, uint8_t note, uint8_t vel);
void demo_midi_pc(uint8_t program);
void demo_render(int16_t* buf, int nframes);
void demo_hooks_install(void);
void demo_ui_tick(void* priv);
void demo_ui_timer_install(unsigned period_ms);
unsigned char demo_key_state(int i);

#ifdef __cplusplus
}
#endif

#endif
