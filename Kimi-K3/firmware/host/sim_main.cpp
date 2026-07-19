// Host simulation of the FM-1 demo firmware: runs demo_install/demo_render/
// demo_midi_note exactly as the patched stock firmware would, writes a WAV.
#include "../src/rt.h"
#include <cstdio>
#include <cstdint>
#include <cstring>

static const uint32_t SR = 44118;

int main(int argc, char** argv) {
  const char* wav_path = argc > 1 ? argv[1] : "host/demo.wav";
  demo_install();

  FILE* w = fopen(wav_path, "wb");
  if (!w) { fprintf(stderr, "cannot write %s\n", wav_path); return 1; }
  uint32_t seconds = 10;
  uint32_t total = ((SR * seconds) + 255) & ~255u;
  uint32_t data_bytes = total * 2;
  uint8_t hdr[44] = {
    'R','I','F','F', 0,0,0,0, 'W','A','V','E','f','m','t',' ',
    16,0,0,0, 1,0, 1,0,
    (uint8_t)(SR & 0xff), (uint8_t)(SR >> 8), (uint8_t)(SR >> 16), (uint8_t)(SR >> 24),
    (uint8_t)((SR*2) & 0xff), (uint8_t)((SR*2) >> 8), (uint8_t)((SR*2) >> 16), (uint8_t)((SR*2) >> 24),
    2,0, 16,0, 'd','a','t','a', 0,0,0,0 };
  *(uint32_t*)(hdr + 4) = 36 + data_bytes;
  *(uint32_t*)(hdr + 40) = data_bytes;
  fwrite(hdr, 1, 44, w);

  int16_t buf[256];
  uint32_t done = 0;
  int pc_sent = 0;
  while (done < total) {
    uint32_t now = rt_millis();
    /* simulate a user playing a chord at t=2s, releasing at t=3.5s */
    if (now >= 2000 && now < 2000 + 256) {
      demo_midi_note(1, 48, 110); demo_midi_note(1, 55, 110); demo_midi_note(1, 64, 110);
    }
    if (now >= 3500 && now < 3500 + 256) {
      demo_midi_note(0, 48, 0); demo_midi_note(0, 55, 0); demo_midi_note(0, 64, 0);
    }
    /* switch patch at t=6s */
    if (!pc_sent && now >= 6000) { demo_midi_pc(1); pc_sent = 1; }
    demo_render(buf, 256);
    fwrite(buf, 2, 256, w);
    done += 256;
  }
  fclose(w);
  printf("wrote %s (%u samples)\n", wav_path, total);
  return 0;
}
