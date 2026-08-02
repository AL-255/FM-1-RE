// Host test for the basic synth: plays a phrase through all 4 presets -> WAV.
#include "../src/synth.h"
#include <cstdio>
#include <cstdint>

static const uint32_t SR = 44100;

int main(int argc, char** argv) {
  const char* wavp = argc > 1 ? argv[1] : "host/synth_test.wav";
  synth_init(SR);
  FILE* w = fopen(wavp, "wb");
  uint32_t total = SR * 12;
  uint8_t hdr[44] = {
    'R','I','F','F',0,0,0,0,'W','A','V','E','f','m','t',' ',16,0,0,0,1,0,1,0,
    (uint8_t)SR,(uint8_t)(SR>>8),(uint8_t)(SR>>16),(uint8_t)(SR>>24),
    (uint8_t)(SR*2),(uint8_t)((SR*2)>>8),(uint8_t)((SR*2)>>16),(uint8_t)((SR*2)>>24),
    2,0,16,0,'d','a','t','a',0,0,0,0 };
  *(uint32_t*)(hdr+4) = 36 + total*2; *(uint32_t*)(hdr+40) = total*2;
  fwrite(hdr, 1, 44, w);
  int16_t buf[256];
  uint32_t done = 0;
  static const int notes[][3] = {{60,64,67},{62,65,69},{64,67,71},{65,69,72}};
  for (int p = 0; p < 4; p++) {
    synth_set_preset(p);
    for (int c = 0; c < 4; c++) {
      for (int k = 0; k < 3; k++) synth_note_on(notes[c][k], 110);
      uint32_t end = done + SR * 6 / 10;
      while (done < end) { synth_render(buf, 256); fwrite(buf, 2, 256, w); done += 256; }
      for (int k = 0; k < 3; k++) synth_note_off(notes[c][k]);
      end = done + SR * 3 / 10;
      while (done < end) { synth_render(buf, 256); fwrite(buf, 2, 256, w); done += 256; }
    }
  }
  fclose(w);
  printf("wrote %s\n", wavp);
  return 0;
}
