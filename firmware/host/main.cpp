// Host validation for the pi32v2-bound Dexed/msfa port.
// Loads a DX7 32-voice bulk dump (.syx), plays a short phrase, renders a WAV.
#include <cstdio>
#include <cstdint>
#include <cstring>
#include <cmath>
#include "dexed.h"

static const uint32_t SR = 44100;

uint32_t dexed_platform_millis(void) {
  static uint32_t t;
  return t += 2; /* good enough for key-press timers in the render loop */
}

int main(int argc, char** argv) {
  const char* syx_path = argc > 1 ? argv[1] : "host/test.syx";
  const char* wav_path = argc > 2 ? argv[2] : "host/out.wav";
  FILE* f = fopen(syx_path, "rb");
  if (!f) { fprintf(stderr, "cannot open %s\n", syx_path); return 1; }
  uint8_t syx[4104];
  size_t n = fread(syx, 1, sizeof(syx), f);
  fclose(f);
  if (n != 4104) { fprintf(stderr, "bad syx size %zu\n", n); return 1; }

  Dexed* synth = new Dexed(8, SR);
  // validate the bank ourselves (upstream checkSystemExclusive reads the
  // checksum at the single-voice offset 161 instead of 4102 for bank dumps)
  int cks = 0;
  for (int i = 6; i < 4102; i++) cks -= syx[i];
  if ((cks & 0x7f) != syx[4102]) { fprintf(stderr, "bank checksum bad\n"); return 1; }

  // load voice 0 from the bank payload (128-byte packed -> 156-byte unpacked)
  uint8_t unpacked[156];
  if (!synth->decodeVoice(unpacked, syx + 6)) { fprintf(stderr, "decodeVoice failed\n"); return 1; }
  synth->loadVoiceParameters(unpacked);
  synth->doRefreshVoice();

  // WAV out
  FILE* w = fopen(wav_path, "wb");
  if (!w) { fprintf(stderr, "cannot write %s\n", wav_path); return 1; }
  uint32_t seconds = 4;
  uint32_t total = ((SR * seconds) + 511) & ~511u;  /* getSamples needs 64-multiples */
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

  // a little phrase: C major arpeggio then a chord
  static const struct { float t_on, t_off; uint8_t note, vel; } phrase[] = {
    {0.0f, 0.45f, 60, 100}, {0.2f, 0.65f, 64, 100}, {0.4f, 0.85f, 67, 100},
    {0.6f, 1.10f, 72, 110}, {1.2f, 3.50f, 60, 100}, {1.2f, 3.50f, 64, 100},
    {1.2f, 3.50f, 67, 100}, {1.2f, 3.50f, 72, 100},
  };
  const int NEV = sizeof(phrase) / sizeof(phrase[0]);
  int16_t buf[512];
  uint32_t done = 0;
  while (done < total) {
    float t = (float)done / SR;
    for (int i = 0; i < NEV; i++) {
      float tq = (float)done / SR;
      if ((int)(phrase[i].t_on * SR) == (int)done) synth->keydown(phrase[i].note, phrase[i].vel);
      if ((int)(phrase[i].t_off * SR) == (int)done) synth->keyup(phrase[i].note);
      (void)t; (void)tq;
    }
    uint32_t chunk = total - done < 512 ? total - done : 512;
    synth->getSamples(buf, (uint16_t)chunk);
    fwrite(buf, 2, chunk < 512 ? chunk : 512, w);
    done += chunk;
  }
  fclose(w);
  printf("wrote %s (%u samples, voice0 %.10s)\n", wav_path, total, (char*)(syx + 6 + 118));
  delete synth;
  return 0;
}
