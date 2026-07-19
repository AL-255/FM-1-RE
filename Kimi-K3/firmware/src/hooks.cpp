/* Hook functions patched into the stock firmware (see docs/architecture.md).
 *
 * Two hooks:
 *  1. DAC render hook (RAM pointer swap at install): the DAC channel struct
 *     at ENG+4228 = 0x01C0F6F4 calls [chan+36](priv=[chan+32], buf, nbytes)
 *     from the DAC DMA half-buffer IRQ (0x02041478). We take that over.
 *  2. MIDI hook (image patch of the 5 midi_msg_dispatch call sites): note /
 *     program events forwarded to our engine, then chained to stock.
 */
#include "rt.h"

#ifdef __pi32v2__

/* ---- stock firmware addresses (from the RE map) ---- */
#define ENG_BASE        0x01C0E670u
#define DAC_CHAN        (ENG_BASE + 4228)   /* DAC channel struct (0x01C0F6F4) */
#define CHAN_NCH_OFF    15                  /* b[chan+15] = channel count */
#define CHAN_PRIV_OFF   32                  /* [chan+32] = priv (arg0) */
#define CHAN_CB_OFF     36                  /* [chan+36] = fill callback */
#define ENG_SYNTH_EN    (ENG_BASE + 19)     /* stock synth compute enable */
#define STOCK_MIDI_DISPATCH 0x0201F5F4u     /* midi_msg_dispatch(ctx, msg) */

static volatile unsigned* const chan = (volatile unsigned*)DAC_CHAN;
static int dac_nch = 1;

/* DAC DMA half-buffer callback (IRQ context): fill `buf` with `nbytes`
 * (channels*frames*2) of our synth PCM. */
extern "C" __attribute__((section(".text.demo_entry"), used))
void demo_dac_cb(void* priv, int16_t* buf, unsigned nbytes) {
  (void)priv;
  if (dac_nch <= 1) {
    demo_render(buf, (int)(nbytes / 2));
  } else {
    /* stereo interleaved: render mono then duplicate */
    int frames = (int)(nbytes / 2 / (unsigned)dac_nch);
    static int16_t mono[512];
    if (frames > 512) frames = 512;
    demo_render(mono, frames);
    for (int i = 0; i < frames; i++) {
      int16_t s = mono[i];
      for (int c = 0; c < dac_nch; c++) buf[i * dac_nch + c] = s;
    }
  }
}

/* MIDI parse hook: called from the __tramp_midi trampoline (patched over
 * midi_msg_dispatch's entry). Same ABI: (ctx r0, msg r1); msg = raw MIDI
 * bytes. The stock handler resumes right after us. */
extern "C" __attribute__((section(".text.demo_entry"), used))
void demo_midi_parse(void* ctx, unsigned char* msg) {
  (void)ctx;
  unsigned char st = msg[0] & 0xF0;
  if (st == 0x90) {                       /* note on (vel>0) / off (vel=0) */
    demo_midi_note(msg[2] != 0, msg[1], msg[2]);
  } else if (st == 0x80) {                /* note off */
    demo_midi_note(0, msg[1], 0);
  } else if (st == 0xC0) {                /* program change */
    demo_midi_pc(msg[1]);
  }
}

/* install-time wiring (called from demo_install in demo.cpp) */
extern "C" void demo_hooks_install(void) {
  dac_nch = *(volatile unsigned char*)(DAC_CHAN + CHAN_NCH_OFF);
  if (dac_nch < 1 || dac_nch > 2) dac_nch = 1;
  chan[CHAN_PRIV_OFF / 4] = 0;
  chan[CHAN_CB_OFF / 4] = (unsigned)&demo_dac_cb;   /* write callback LAST */
  *(volatile unsigned char*)ENG_SYNTH_EN = 0;       /* stop stock synth compute */
}

#else  /* host build: no hardware hooks */
extern "C" void demo_hooks_install(void) {}
#endif
