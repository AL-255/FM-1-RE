/* FM-1 custom synthesizer demo — basic poly synth + on-device display UI.
 *
 *  - demo_install()   : called once from the boot trampoline; brings up the
 *                       synth, the LCD overlay, a 120 ms UI timer, and the
 *                       DAC/MIDI hooks.
 *  - demo_render()    : fills the DAC DMA halves with synth PCM (IRQ ctx).
 *  - demo_midi_note() : note on/off from the patched MIDI dispatch
 *                       (USB-MIDI / UART-MIDI / BLE-MIDI / stock keybed).
 *  - demo_midi_pc()   : program change 0..3 selects synth presets.
 *
 * Display (bottom 56 px of the 240x240 panel, refreshed at ~8 Hz):
 *   line 1: "FM-1 SYNTH DEMO"  + preset name
 *   line 2: KEY  — physical key ids currently held (from the scanner's
 *            per-key state array at 0x01C0E670+2836+i*2)
 *   line 3: MIDI — last note received through midi_msg_dispatch
 */
#include "rt.h"
#include "synth.h"
#include "lcd.h"

#define N_KEYS 41

static uint8_t last_note = 60, last_vel, last_on;
static uint8_t ui_dirty;

extern "C" __attribute__((section(".text.demo_entry"), used))
void demo_install(void) {
  rt_init();
  synth_init(44118.f);                    /* FM-1 DAC rate */
  lcd_ovl_init();
  ui_dirty = 1;
  demo_ui_timer_install(120);             /* ~8 Hz UI refresh (task ctx) */
  demo_hooks_install();                   /* swap DAC feed to our engine */
  rt_log("FM-1 synth demo installed\n");
}

extern "C" __attribute__((section(".text.demo_entry"), used))
void demo_midi_note(int on, uint8_t note, uint8_t vel) {
  if (on && vel) { synth_note_on(note, vel); last_note = note; last_vel = vel; last_on = 1; }
  else { synth_note_off(note); last_on = 0; last_note = note; }
  ui_dirty = 1;
}

extern "C" __attribute__((section(".text.demo_entry"), used))
void demo_midi_pc(uint8_t program) {
  synth_set_preset(program);
  ui_dirty = 1;
}

extern "C" __attribute__((section(".text.demo_entry"), used))
void demo_render(int16_t* buf, int nframes) {
  synth_render(buf, nframes);
  rt_tick_advance((uint32_t)nframes);
}

/* ---------------- the on-device UI ---------------- */

static const char* note_name(int n, char* out) {
  static const char* const NAMES = "C C#D D#E F F#G G#A A#B";
  out[0] = NAMES[(n % 12) * 2];
  out[1] = NAMES[(n % 12) * 2 + 1];
  if (out[1] == ' ') { out[1] = 0; return out; }
  out[2] = 0;
  return out;
}

static void draw_ui(void) {
  char line[32];
  lcd_ovl_clear();

  /* line 1: title + preset */
  lcd_ovl_text(4, 2, "FM-1 SYNTH DEMO", COL_ACCENT);
  lcd_ovl_text(OVL_W - 12 * 8, 2, synth_preset_name(synth_get_preset()), COL_NOTE);

  /* line 2: physical keys held */
  int x = 4;
  lcd_ovl_text(x, 20, "KEY", COL_FG); x += 4 * 8;
  int shown = 0;
  for (int i = 0; i < N_KEYS && shown < 12; i++) {
    if (demo_key_state(i)) {
      line[0] = '0' + (i / 10); line[1] = '0' + (i % 10); line[2] = 0;
      lcd_ovl_text(x, 20, line, COL_NOTE); x += 3 * 8;
      shown++;
    }
  }
  if (!shown) lcd_ovl_text(x, 20, "--", COL_FG);

  /* line 3: last MIDI event + voices */
  x = 4;
  lcd_ovl_text(x, 38, "MIDI", COL_FG); x += 5 * 8;
  char nn[3];
  note_name(last_note, nn);
  line[0] = nn[0]; line[1] = nn[1]; line[2] = 0;
  lcd_ovl_text(x, 38, line, COL_NOTE); x += 3 * 8;
  /* octave + velocity + on/off */
  {
    int oct = last_note / 12 - 1;
    line[0] = '0' + oct; line[1] = ' '; line[2] = last_on ? '>' : '.';
    line[3] = '0' + (last_vel / 100); line[4] = '0' + ((last_vel / 10) % 10); line[5] = '0' + (last_vel % 10); line[6] = 0;
    lcd_ovl_text(x, 38, line, COL_FG); x += 7 * 8;
  }
  /* active voices */
  {
    int av = synth_active_voices();
    line[0] = 'V'; line[1] = '0' + av; line[2] = 0;
    lcd_ovl_text(OVL_W - 4 * 8, 38, line, COL_ACCENT);
  }
}

extern "C" void demo_ui_tick(void* priv) {
  (void)priv;
  /* event-driven refresh + 1.2 s heartbeat to heal stock-UI overdraw */
  static int hb;
  if (ui_dirty) hb = 0;
  else if (++hb < 10) return;
  hb = 0;
  draw_ui();
  lcd_ovl_flush();
  ui_dirty = 0;
}
