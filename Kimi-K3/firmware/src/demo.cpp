/* FM-1 custom synthesizer demo — our own Dexed/msfa engine grafted onto the
 * stock firmware's audio path (see Kimi-K3/docs/architecture.md).
 *
 *  - demo_install()   : called once from the boot trampoline; builds the
 *                       engine (8 voices) and loads our 4 demo patches.
 *  - demo_render()    : called from the stock audio path to fill s16 mono PCM
 *                       at 44118 Hz. Renders our engine.
 *  - demo_midi_note() : note on/off from the patched MIDI dispatch (USB-MIDI,
 *                       UART-MIDI, BLE-MIDI, stock keybed).
 *  - demo_midi_pc()   : program change 0..3 selects our demo patches.
 *  - After ~4 s without external notes, a short demo melody loops so the
 *    unit makes sound on its own.
 *
 * Voice patches are shared with the host app (src/voices.cpp).
 */
#include "rt.h"
#include "dexed.h"
#include "voices.h"

static Dexed* synth;
static int16_t render_buf[256];
static uint32_t last_note_ms;
static uint8_t demo_patch;
static int melody_idx;
static uint32_t melody_next_ms;
static uint8_t melody_note_on;

static void load_patch(uint8_t idx) {
  uint8_t v[156];
  demo_patch = idx % DEMO_N_PATCHES;
  voices_build(demo_patch, v);
  synth->loadVoiceParameters(v);
  synth->doRefreshVoice();
}

/* short demo melody: (note, beats) — 0 = rest */
static const struct { uint8_t note; uint8_t beats; } MELODY[] = {
  {60,1},{64,1},{67,1},{72,2},{67,1},{64,1},{62,1},{65,1},{69,1},{74,2},
  {72,1},{69,1},{67,2},{0,1},{65,1},{69,1},{72,1},{77,2},{76,1},{72,2},
};
#define MELODY_LEN (sizeof(MELODY) / sizeof(MELODY[0]))
#define BPM 96
#define BEAT_MS (60000u / BPM)

extern "C" __attribute__((section(".text.demo_entry"), used))
void demo_install(void) {
  uint8_t init156[156];
  rt_init();
  rt_heap_init();
  synth = new Dexed(8, 44118);          /* FM-1 DAC rate */
  synth->loadInitVoice();
  synth->getVoiceData(init156);
  voices_capture_init(init156);
  load_patch(0);
  last_note_ms = 0;
  melody_idx = 0;
  melody_next_ms = 4000;
  melody_note_on = 0;
  rt_log("FM-1 custom synth demo installed\n");
  demo_hooks_install();                 /* swap DAC feed to our engine */
}

extern "C" __attribute__((section(".text.demo_entry"), used))
void demo_midi_note(int on, uint8_t note, uint8_t vel) {
  if (!synth) return;
  if (on && vel) { synth->keydown(note, vel); last_note_ms = rt_millis(); }
  else synth->keyup(note);
}

extern "C" __attribute__((section(".text.demo_entry"), used))
void demo_midi_pc(uint8_t program) { load_patch(program); }

extern "C" __attribute__((section(".text.demo_entry"), used))
void demo_render(int16_t* buf, int nframes) {
  if (!synth) { rt_memset(buf, 0, (size_t)nframes * 2); return; }
  rt_tick_advance((uint32_t)nframes);

  uint32_t now = rt_millis();
  if (now - last_note_ms > 4000) {      /* idle -> autoplay demo melody */
    if (melody_note_on && now >= melody_next_ms) {
      synth->keyup(MELODY[melody_idx].note);
      melody_note_on = 0;
      melody_idx = (melody_idx + 1) % (int)MELODY_LEN;
      melody_next_ms = now + BEAT_MS / 2;
    } else if (!melody_note_on && now >= melody_next_ms) {
      uint8_t n = MELODY[melody_idx].note;
      if (n) { synth->keydown(n, 100); melody_note_on = 1; }
      melody_next_ms = now + (uint32_t)MELODY[melody_idx].beats * BEAT_MS;
    }
  }

  while (nframes > 0) {                 /* engine needs 64-sample blocks */
    int chunk = nframes > 256 ? 256 : nframes;
    chunk &= ~63;
    if (!chunk) chunk = 64;
    synth->getSamples(render_buf, (uint16_t)chunk);
    rt_memcpy(buf, render_buf, (size_t)chunk * 2);
    buf += chunk;
    nframes -= chunk;
  }
}
