// FM-1 synth — JACK standalone.
// Basic synth engine with JACK audio + MIDI input. Low-latency alternative
// to the ALSA standalone; works with any JACK-aware MIDI source.
//
// usage:
//   fm1_jack [-m client:port] [-p 0..3]
//     -m  connect MIDI input to this JACK port (default: auto-connect first readable MIDI port)
//     -p  initial patch (0 SAW LEAD, 1 SQ BASS, 2 SYNC PAD, 3 PLUCK)
//
// Controls while running:
//   Ctrl-C  quit
//
#include <jack/jack.h>
#include <jack/midiport.h>
#include <jack/types.h>
#include <cstdio>
#include <cstdlib>
#include <cstring>
#include <csignal>
#include <cmath>
#include "synth.h"

static volatile int running = 1;
static void on_sigint(int) { running = 0; }

static jack_client_t* client;
static jack_port_t* audio_out;
static jack_port_t* midi_in;
static int cur_patch = 0;

static const char* note_name(int n) {
  static const char* names[] = { "C","C#","D","D#","E","F","F#","G","G#","A","A#","B" };
  static char buf[16];
  snprintf(buf, sizeof(buf), "%s%d", names[n % 12], (n / 12) - 1);
  return buf;
}

static void engine_note(int on, int note, int vel) {
  if (on && vel) {
    synth_note_on(note, vel);
    printf("NOTE ON  %-3s (midi %d) vel %d  [voices %d]\n",
           note_name(note), note, vel, synth_active_voices());
  } else {
    synth_note_off(note);
    printf("NOTE OFF %-3s (midi %d)          [voices %d]\n",
           note_name(note), note, synth_active_voices());
  }
  fflush(stdout);
}

static void engine_patch(int p) {
  synth_set_preset(p);
  cur_patch = p % SYNTH_N_PRESETS;
  printf("PATCH %d: %s\n", cur_patch, synth_preset_name(cur_patch));
  fflush(stdout);
}

static void handle_midi(jack_nframes_t nframes) {
  void* buf = jack_port_get_buffer(midi_in, nframes);
  if (!buf) return;
  jack_nframes_t nev = jack_midi_get_event_count(buf);
  for (jack_nframes_t i = 0; i < nev; i++) {
    jack_midi_event_t ev;
    if (jack_midi_event_get(&ev, buf, i) != 0) continue;
    if (ev.size < 3) continue;
    uint8_t st = ev.buffer[0] & 0xF0;
    uint8_t ch = ev.buffer[0] & 0x0F;
    uint8_t d1 = ev.buffer[1];
    uint8_t d2 = ev.size > 2 ? ev.buffer[2] : 0;
    (void)ch;
    switch (st) {
      case 0x90: engine_note(d2 != 0, d1, d2); break;
      case 0x80: engine_note(0, d1, 0); break;
      case 0xC0: engine_patch(d1); break;
    }
  }
}

static int process_callback(jack_nframes_t nframes, void*) {
  handle_midi(nframes);
  jack_default_audio_sample_t* out = (jack_default_audio_sample_t*)jack_port_get_buffer(audio_out, nframes);
  static int16_t tmp[4096];
  if (nframes > sizeof(tmp)/sizeof(tmp[0])) nframes = sizeof(tmp)/sizeof(tmp[0]);
  synth_render(tmp, (int)nframes);
  for (jack_nframes_t i = 0; i < nframes; i++) out[i] = (jack_default_audio_sample_t)tmp[i] * (1.0f / 32768.0f);
  return 0;
}

static int samplerate_callback(jack_nframes_t rate, void*) {
  synth_init((float)rate);
  synth_set_preset(cur_patch);
  printf("sample rate %d Hz\n", (int)rate);
  return 0;
}

static void list_midi_ports(void) {
  const char** ports = jack_get_ports(client, nullptr, JACK_DEFAULT_MIDI_TYPE, JackPortIsOutput);
  printf("JACK MIDI output ports (sources):\n");
  if (ports) {
    for (int i = 0; ports[i]; i++) printf("  %s\n", ports[i]);
    jack_free(ports);
  }
}

int main(int argc, char** argv) {
  const char* midi_src = nullptr;
  int init_patch = 0;
  for (int i = 1; i < argc; i++) {
    if (!strcmp(argv[i], "-l")) { /* list handled after client open */ }
    else if (!strcmp(argv[i], "-m") && i + 1 < argc) midi_src = argv[++i];
    else if (!strcmp(argv[i], "-p") && i + 1 < argc) init_patch = atoi(argv[++i]);
    else { fprintf(stderr, "unknown option %s\n", argv[i]); return 1; }
  }

  signal(SIGINT, on_sigint);

  jack_status_t status;
  client = jack_client_open("fm1_jack", JackNoStartServer, &status);
  if (!client) {
    fprintf(stderr, "cannot open JACK client (status 0x%x)\n", status);
    return 1;
  }

  if (argc > 1 && !strcmp(argv[1], "-l")) {
    list_midi_ports();
    jack_client_close(client);
    return 0;
  }

  audio_out = jack_port_register(client, "out", JACK_DEFAULT_AUDIO_TYPE, JackPortIsOutput, 0);
  midi_in   = jack_port_register(client, "midi_in", JACK_DEFAULT_MIDI_TYPE, JackPortIsInput, 0);
  if (!audio_out || !midi_in) {
    fprintf(stderr, "cannot register JACK ports\n");
    return 1;
  }

  jack_set_process_callback(client, process_callback, nullptr);
  jack_set_sample_rate_callback(client, samplerate_callback, nullptr);

  cur_patch = init_patch % SYNTH_N_PRESETS;
  if (jack_activate(client)) {
    fprintf(stderr, "cannot activate JACK client\n");
    return 1;
  }

  synth_init((float)jack_get_sample_rate(client));
  synth_set_preset(cur_patch);
  printf("FM-1 JACK synth running (patch %d: %s). Ctrl-C to quit.\n",
         cur_patch, synth_preset_name(cur_patch));

  if (midi_src) {
    if (jack_connect(client, midi_src, "fm1_jack:midi_in"))
      fprintf(stderr, "warning: could not connect %s -> fm1_jack:midi_in\n", midi_src);
  } else {
    const char** ports = jack_get_ports(client, nullptr, JACK_DEFAULT_MIDI_TYPE, JackPortIsOutput);
    if (ports && ports[0]) {
      if (jack_connect(client, ports[0], "fm1_jack:midi_in"))
        fprintf(stderr, "warning: auto-connect to %s failed\n", ports[0]);
      else
        printf("auto-connected MIDI: %s\n", ports[0]);
    } else {
      printf("no JACK MIDI source found; connect one manually to fm1_jack:midi_in\n");
    }
    if (ports) jack_free(ports);
  }

  while (running) sleep(1);

  jack_deactivate(client);
  jack_client_close(client);
  return 0;
}
