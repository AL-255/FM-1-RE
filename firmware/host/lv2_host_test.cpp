// Minimal LV2 host harness: loads fm1_dexed.so, feeds it a MIDI note phrase,
// renders audio to a WAV. Validates the plugin without a DAW.
#include <dlfcn.h>
#include <cstdio>
#include <cstdint>
#include <cstring>
#include <cmath>
#include "lv2/core/lv2.h"
#include "lv2/atom/atom.h"
#include "lv2/urid/urid.h"
#include "lv2/midi/midi.h"

static LV2_URID map_uri(LV2_URID_Map_Handle, const char* uri) {
  if (!strcmp(uri, LV2_MIDI__MidiEvent)) return 1001;
  if (!strcmp(uri, LV2_ATOM__Sequence)) return 1002;
  return 0;
}
static LV2_URID_Map test_map = { nullptr, map_uri };

int main(int argc, char** argv) {
  const char* so = argc > 1 ? argv[1] : "host/lv2/fm1_dexed.so";
  const char* wavp = argc > 2 ? argv[2] : "host/lv2_test.wav";
  void* lib = dlopen(so, RTLD_NOW);
  if (!lib) { fprintf(stderr, "dlopen: %s\n", dlerror()); return 1; }
  auto desc_fn = (const LV2_Descriptor*(*)(uint32_t))dlsym(lib, "lv2_descriptor");
  if (!desc_fn) { fprintf(stderr, "no lv2_descriptor\n"); return 1; }
  const LV2_Descriptor* d = desc_fn(0);
  if (!d) { fprintf(stderr, "no descriptor 0\n"); return 1; }

  const LV2_Feature map_feature{ LV2_URID__map, &test_map };
  const LV2_Feature* features[] = { &map_feature, nullptr };
  uint32_t rate = 44100;
  LV2_Handle h = d->instantiate(d, rate, "/tmp", features);
  if (!h) { fprintf(stderr, "instantiate failed\n"); return 1; }

  // MIDI event buffer (atom sequence, empty-ish then we inject events)
  static uint8_t evbuf[4096];
  auto* seq = (LV2_Atom_Sequence*)evbuf;
  float out[1024];
  float patch_ctl = 0.0f;
  d->connect_port(h, 0, seq);
  d->connect_port(h, 1, out);
  d->connect_port(h, 2, &patch_ctl);

  auto push_note = [&](int on, int note, int vel, uint32_t frame) {
    LV2_Atom_Event* ev = (LV2_Atom_Event*)((char*)seq + sizeof(LV2_Atom) + sizeof(LV2_Atom_Sequence_Body) + seq->atom.size - sizeof(LV2_Atom_Sequence_Body));
    ev->time.frames = frame;
    ev->body.type = 1001;
    ev->body.size = 3;
    uint8_t* m = (uint8_t*)(ev + 1);
    m[0] = on ? 0x90 : 0x80; m[1] = (uint8_t)note; m[2] = (uint8_t)vel;
    seq->atom.size += sizeof(LV2_Atom_Event) + ((3 + 7u) & ~7u);
  };

  seq->atom.type = 1002; seq->atom.size = sizeof(LV2_Atom_Sequence_Body);
  seq->body.unit = 0; seq->body.pad = 0;

  FILE* w = fopen(wavp, "wb");
  uint32_t total = rate * 4;
  uint8_t hdr[44] = {
    'R','I','F','F',0,0,0,0,'W','A','V','E','f','m','t',' ',16,0,0,0,3,0,1,0,
    (uint8_t)rate,(uint8_t)(rate>>8),(uint8_t)(rate>>16),(uint8_t)(rate>>24),
    (uint8_t)(rate*4),(uint8_t)((rate*4)>>8),(uint8_t)((rate*4)>>16),(uint8_t)((rate*4)>>24),
    4,0,32,0,'d','a','t','a',0,0,0,0 };
  *(uint32_t*)(hdr+4) = 36 + total*4; *(uint32_t*)(hdr+40) = total*4;
  fwrite(hdr, 1, 44, w);

  uint32_t done = 0;
  push_note(1, 60, 100, 0); push_note(1, 64, 100, 0); push_note(1, 67, 100, 0);
  while (done < total) {
    if (done == rate * 3) { patch_ctl = 1.0f; }
    if (done == rate * 3 + 100) { seq->atom.size = sizeof(LV2_Atom_Sequence_Body); push_note(0, 60, 0, 0); push_note(0, 64, 0, 0); push_note(0, 67, 0, 0); }
    d->run(h, 256);
    fwrite(out, 4, 256, w);
    done += 256;
  }
  fclose(w);
  d->cleanup(h);
  dlclose(lib);
  printf("wrote %s\n", wavp);
  return 0;
}
