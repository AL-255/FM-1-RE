// FM-1 synth — LV2 instrument plugin (basic poly synth, same code as the
// on-device demo). MIDI in -> mono audio out. A float "patch" control selects
// SAW LEAD/SQ BASS/SYNC PAD/PLUCK (0-3). Built for Linux DAWs.
#include <stdint.h>
#include <stdlib.h>
#include <string.h>
#include <math.h>
#include "lv2/core/lv2.h"
#include "lv2/atom/atom.h"
#include "lv2/urid/urid.h"
#include "lv2/midi/midi.h"
#include "synth.h"

#define PLUGIN_URI "https://github.com/fm1-re/fm1-dexed-lv2"

typedef enum { PORT_MIDI_IN = 0, PORT_AUDIO_OUT = 1, PORT_PATCH = 2 } PortIndex;

typedef struct {
  LV2_URID_Map* map;
  LV2_URID midi_event;
  LV2_URID atom_sequence;
  const LV2_Atom_Sequence* midi_in;
  float* audio_out;
  const float* patch_ctl;
  uint32_t rate;
  int cur_patch;
  int16_t* scratch;
} FM1Synth;

static LV2_Handle instantiate(const LV2_Descriptor* d, double rate,
                              const char* path, const LV2_Feature* const* features) {
  (void)d; (void)path;
  FM1Synth* s = (FM1Synth*)calloc(1, sizeof(FM1Synth));
  if (!s) return nullptr;
  s->rate = (uint32_t)rate;
  for (int i = 0; features && features[i]; i++) {
    if (!strcmp(features[i]->URI, LV2_URID__map)) {
      s->map = (LV2_URID_Map*)features[i]->data;
    }
  }
  if (!s->map) { free(s); return nullptr; }
  s->midi_event = s->map->map(s->map->handle, LV2_MIDI__MidiEvent);
  s->atom_sequence = s->map->map(s->map->handle, LV2_ATOM__Sequence);
  synth_init((float)rate);
  s->scratch = (int16_t*)malloc(4096 * sizeof(int16_t));
  s->cur_patch = -1;
  return (LV2_Handle)s;
}

static void connect_port(LV2_Handle h, uint32_t port, void* data) {
  FM1Synth* s = (FM1Synth*)h;
  switch ((PortIndex)port) {
    case PORT_MIDI_IN: s->midi_in = (const LV2_Atom_Sequence*)data; break;
    case PORT_AUDIO_OUT: s->audio_out = (float*)data; break;
    case PORT_PATCH: s->patch_ctl = (const float*)data; break;
  }
}

static void apply_patch(FM1Synth* s, int p) {
  p = p < 0 ? 0 : (p >= SYNTH_N_PRESETS ? SYNTH_N_PRESETS - 1 : p);
  if (p == s->cur_patch) return;
  synth_set_preset(p);
  s->cur_patch = p;
}

static void run(LV2_Handle h, uint32_t n_samples) {
  FM1Synth* s = (FM1Synth*)h;
  if (!s->audio_out) return;

  if (s->patch_ctl) apply_patch(s, (int)floorf(*s->patch_ctl + 0.5f));

  /* process MIDI events */
  LV2_Atom_Sequence* seq = (LV2_Atom_Sequence*)s->midi_in;
  LV2_Atom_Event* next = nullptr;
  uintptr_t seq_end = 0;
  if (seq && seq->atom.type == s->atom_sequence) {
    next = (LV2_Atom_Event*)((char*)seq + sizeof(LV2_Atom) + sizeof(LV2_Atom_Sequence_Body));
    seq_end = (uintptr_t)((char*)seq + sizeof(LV2_Atom) + seq->atom.size);
    if ((uintptr_t)next >= seq_end) next = nullptr;
  }

  float* out = s->audio_out;
  uint32_t done = 0;
  while (done < n_samples) {
    uint32_t upto = done + 256 < n_samples ? done + 256 : n_samples;
    while (next && (uint32_t)next->time.frames < upto) {
      if (next->body.type == s->midi_event) {
        const uint8_t* m = (const uint8_t*)(next + 1);
        uint8_t st = m[0] & 0xF0;
        if (st == 0x90) { if (m[2]) synth_note_on(m[1], m[2]); else synth_note_off(m[1]); }
        else if (st == 0x80) synth_note_off(m[1]);
        else if (st == 0xC0) apply_patch(s, m[1]);
      }
      uintptr_t evnext = (uintptr_t)next + sizeof(LV2_Atom_Event) + ((next->body.size + 7u) & ~7u);
      next = (evnext < seq_end) ? (LV2_Atom_Event*)evnext : nullptr;
    }
    uint32_t chunk = upto - done;
    if (chunk) {
      synth_render(s->scratch, (int)chunk);
      for (uint32_t i = 0; i < chunk; i++) out[done + i] = s->scratch[i] / 32768.0f;
      done += chunk;
    } else break;
  }
}

static void cleanup(LV2_Handle h) {
  FM1Synth* s = (FM1Synth*)h;
  free(s->scratch);
  free(s);
}

static const LV2_Descriptor descriptor = {
  PLUGIN_URI, instantiate, connect_port, nullptr, run, nullptr, cleanup, nullptr,
};

LV2_SYMBOL_EXPORT const LV2_Descriptor* lv2_descriptor(uint32_t index) {
  return index == 0 ? &descriptor : nullptr;
}
