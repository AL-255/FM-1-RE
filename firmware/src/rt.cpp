/* demo runtime support (pi32v2, freestanding inside stock firmware) */
#include "rt.h"
#include <stdarg.h>

/* The linker places our .bss/.data at DEMO_RAM_BASE; the heap sits after
 * them (symbols provided by link.ld). Host builds use a static fallback. */
#ifdef __pi32v2__
extern uint8_t __heap_start, __heap_end;
#else
static uint8_t host_heap[256 * 1024];
uint8_t* __heap_start_p = host_heap, *__heap_end_p = host_heap + sizeof(host_heap);
#define __heap_start (*__heap_start_p)
#define __heap_end   (*__heap_end_p)
#endif

static uint8_t* heap_ptr;
static volatile uint32_t tick_ms;

#ifdef __pi32v2__
extern uint8_t __data_lma, __data_start, __data_end, __bss_start, __bss_end;
/* called before anything else: bring up our own .data/.bss */
void rt_init(void) {
  uint8_t* s = &__data_lma;
  uint8_t* d = &__data_start;
  while (d < &__data_end) *d++ = *s++;
  d = &__bss_start;
  while (d < &__bss_end) *d++ = 0;
}
#else
void rt_init(void) {}
#endif

void rt_heap_init(void) { heap_ptr = &__heap_start; }

void* rt_alloc(size_t size) {
  size = (size + 7u) & ~7u;
  if (!heap_ptr) rt_heap_init();
  if (heap_ptr + size > &__heap_end) return 0;
  void* p = heap_ptr;
  heap_ptr += size;
  return p;
}
void rt_free(void* p) { (void)p; }

void* rt_memcpy(void* d, const void* s, size_t n) {
  uint8_t* dd = (uint8_t*)d; const uint8_t* ss = (const uint8_t*)s;
  for (size_t i = 0; i < n; i++) dd[i] = ss[i];
  return d;
}
void* rt_memset(void* d, int c, size_t n) {
  uint8_t* dd = (uint8_t*)d;
  for (size_t i = 0; i < n; i++) dd[i] = (uint8_t)c;
  return d;
}
void* rt_memmove(void* d, const void* s, size_t n) {
  uint8_t* dd = (uint8_t*)d; const uint8_t* ss = (const uint8_t*)s;
  if (dd < ss) for (size_t i = 0; i < n; i++) dd[i] = ss[i];
  else for (size_t i = n; i > 0; i--) dd[i - 1] = ss[i - 1];
  return d;
}

uint32_t rt_millis(void) { return tick_ms; }
void rt_tick_advance(uint32_t frames) {
  /* audio runs at ~44.1 kHz: 44.1 frames per ms (fixed point to avoid fpu) */
  tick_ms += (frames * 10u) / 441u;
}

/* ---- stock printf (optional): resolved at runtime from the image ----
 * The stock firmware's printf reentrant wrapper; we look it up via a fixed
 * address provided by the RE map. If unavailable, logging is a no-op. */
typedef int (*printf_fn)(const char*, ...);
#define STOCK_PRINTF ((printf_fn)0x02000000) /* placeholder, patched by config */

void rt_log(const char* fmt, ...) { (void)fmt; }

/* libc stubs for freestanding linking (only referenced on dead paths) */
extern "C" int printf(const char* fmt, ...) { (void)fmt; return 0; }
extern "C" int puts(const char* s) { (void)s; return 0; }
extern "C" int putchar(int c) { return c; }
extern "C" int abs(int x) { return x < 0 ? -x : x; }
extern "C" long labs(long x) { return x < 0 ? -x : x; }

/* ---- C++ runtime bits ---- */
void* operator new(size_t n) { return rt_alloc(n); }
void* operator new[](size_t n) { return rt_alloc(n); }
void operator delete(void* p) { (void)p; }
void operator delete[](void* p) { (void)p; }
extern "C" void __cxa_pure_virtual(void) { for (;;) {} }

/* compiler may emit these */
extern "C" void* memcpy(void* d, const void* s, size_t n) { return rt_memcpy(d, s, n); }
extern "C" void* memset(void* d, int c, size_t n) { return rt_memset(d, c, n); }
extern "C" void* memmove(void* d, const void* s, size_t n) { return rt_memmove(d, s, n); }

/* Dexed's platform millis hook */
uint32_t dexed_platform_millis(void) { return rt_millis(); }
