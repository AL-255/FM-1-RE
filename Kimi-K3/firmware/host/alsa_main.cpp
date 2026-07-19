// FM-1 synth — host-native standalone app.
// Dexed/msfa engine with ALSA MIDI input (any MIDI keyboard, including the
// FM-1 itself over USB-MIDI) and ALSA audio output. Same engine + patches
// as the on-device demo (firmware/src/voices.cpp).
//
// usage:
//   fm1_synth -l                      list MIDI input ports
//   fm1_synth [-m CLIENT:PORT] [-p 0..3] [-d hw:0,0] [-r rate]
//     -m  connect to this MIDI source (default: first available)
//     -p  initial patch (0 E.PIANO, 1 BASS, 2 BRASS, 3 LEAD)
//     -d  ALSA playback device (default "default")
//     -r  sample rate (default 44100)
#include <alsa/asoundlib.h>
#include <cstdio>
#include <cstdlib>
#include <cstring>
#include <csignal>
#include <cmath>
#include <pthread.h>
#include <unistd.h>
#include "synth.h"

static volatile int running = 1;
static void on_sigint(int) { running = 0; }

static pthread_mutex_t synth_lock = PTHREAD_MUTEX_INITIALIZER;
static int cur_patch = 0;

static void engine_note(int on, int note, int vel) {
  pthread_mutex_lock(&synth_lock);
  if (on && vel) synth_note_on(note, vel);
  else synth_note_off(note);
  pthread_mutex_unlock(&synth_lock);
}
static void engine_patch(int p) {
  pthread_mutex_lock(&synth_lock);
  synth_set_preset(p);
  pthread_mutex_unlock(&synth_lock);
  cur_patch = p % SYNTH_N_PRESETS;
  printf("patch %d: %s\n", cur_patch, synth_preset_name(cur_patch));
  fflush(stdout);
}

/* ---------- ALSA MIDI ---------- */
static int list_midi_ports(void) {
  snd_seq_t* seq;
  if (snd_seq_open(&seq, "default", SND_SEQ_OPEN_INPUT, 0) < 0) {
    fprintf(stderr, "cannot open ALSA sequencer\n");
    return 1;
  }
  snd_seq_client_info_t* cinfo;
  snd_seq_port_info_t* pinfo;
  snd_seq_client_info_alloca(&cinfo);
  snd_seq_port_info_alloca(&pinfo);
  printf("MIDI input ports:\n");
  snd_seq_client_info_set_client(cinfo, -1);
  while (snd_seq_query_next_client(seq, cinfo) >= 0) {
    int client = snd_seq_client_info_get_client(cinfo);
    snd_seq_port_info_set_client(pinfo, client);
    snd_seq_port_info_set_port(pinfo, -1);
    while (snd_seq_query_next_port(seq, pinfo) >= 0) {
      unsigned caps = snd_seq_port_info_get_capability(pinfo);
      if ((caps & SND_SEQ_PORT_CAP_READ) && (caps & SND_SEQ_PORT_CAP_SUBS_READ))
        printf("  %d:%d  %s - %s\n", client, snd_seq_port_info_get_port(pinfo),
               snd_seq_client_info_get_name(cinfo), snd_seq_port_info_get_name(pinfo));
    }
  }
  snd_seq_close(seq);
  return 0;
}

static void midi_event(const snd_seq_event_t* ev) {
  switch (ev->type) {
    case SND_SEQ_EVENT_NOTEON:  engine_note(1, ev->data.note.note, ev->data.note.velocity); break;
    case SND_SEQ_EVENT_NOTEOFF: engine_note(0, ev->data.note.note, 0); break;
    case SND_SEQ_EVENT_PGMCHANGE: engine_patch(ev->data.control.value); break;
    case SND_SEQ_EVENT_KEYPRESS: break;
  }
}

/* ---------- ALSA audio ---------- */
struct audio_args { snd_pcm_t* pcm; uint32_t rate; unsigned period; };

static void* audio_thread(void* argp) {
  audio_args* a = (audio_args*)argp;
  int16_t buf[1024];
  while (running) {
    pthread_mutex_lock(&synth_lock);
    synth_render(buf, (int)a->period);
    pthread_mutex_unlock(&synth_lock);
    snd_pcm_sframes_t w = snd_pcm_writei(a->pcm, buf, a->period);
    if (w == -EPIPE) snd_pcm_prepare(a->pcm);
  }
  return nullptr;
}

int main(int argc, char** argv) {
  const char* midi_src = nullptr;
  const char* pcm_name = "default";
  uint32_t rate = 44100;
  int init_patch = 0;
  for (int i = 1; i < argc; i++) {
    if (!strcmp(argv[i], "-l")) return list_midi_ports();
    else if (!strcmp(argv[i], "-m") && i + 1 < argc) midi_src = argv[++i];
    else if (!strcmp(argv[i], "-p") && i + 1 < argc) init_patch = atoi(argv[++i]);
    else if (!strcmp(argv[i], "-d") && i + 1 < argc) pcm_name = argv[++i];
    else if (!strcmp(argv[i], "-r") && i + 1 < argc) rate = (uint32_t)atoi(argv[++i]);
    else { fprintf(stderr, "unknown option %s\n", argv[i]); return 1; }
  }

  signal(SIGINT, on_sigint);
  synth_init((float)rate);
  engine_patch(init_patch);

  /* audio out */
  snd_pcm_t* pcm;
  if (snd_pcm_open(&pcm, pcm_name, SND_PCM_STREAM_PLAYBACK, 0) < 0) {
    fprintf(stderr, "cannot open ALSA playback %s\n", pcm_name); return 1;
  }
  unsigned period = 256;
  snd_pcm_set_params(pcm, SND_PCM_FORMAT_S16_LE, SND_PCM_ACCESS_RW_INTERLEAVED,
                     1, rate, 1, 20000);
  audio_args aargs{pcm, rate, period};
  pthread_t ath;
  pthread_create(&ath, nullptr, audio_thread, &aargs);

  /* MIDI in */
  snd_seq_t* seq;
  if (snd_seq_open(&seq, "default", SND_SEQ_OPEN_INPUT, 0) < 0) {
    fprintf(stderr, "cannot open ALSA sequencer\n"); return 1;
  }
  int port = snd_seq_create_simple_port(seq, "fm1_synth",
      SND_SEQ_PORT_CAP_WRITE | SND_SEQ_PORT_CAP_SUBS_WRITE, SND_SEQ_PORT_TYPE_MIDI_GENERIC);
  snd_seq_port_subscribe_t* sub;
  snd_seq_port_subscribe_alloca(&sub);

  int src_client = -1, src_port = -1;
  if (midi_src) { sscanf(midi_src, "%d:%d", &src_client, &src_port); }
  else {
    /* first available input port that isn't ours */
    snd_seq_client_info_t* cinfo; snd_seq_port_info_t* pinfo;
    snd_seq_client_info_alloca(&cinfo); snd_seq_port_info_alloca(&pinfo);
    snd_seq_client_info_set_client(cinfo, -1);
    while (snd_seq_query_next_client(seq, cinfo) >= 0 && src_client < 0) {
      int cl = snd_seq_client_info_get_client(cinfo);
      if (cl == 0 || cl == snd_seq_client_id(seq)) continue;  /* skip System + self */
      snd_seq_port_info_set_client(pinfo, cl);
      snd_seq_port_info_set_port(pinfo, -1);
      while (snd_seq_query_next_port(seq, pinfo) >= 0) {
        unsigned caps = snd_seq_port_info_get_capability(pinfo);
        if ((caps & SND_SEQ_PORT_CAP_READ) && (caps & SND_SEQ_PORT_CAP_SUBS_READ)) {
          src_client = cl; src_port = snd_seq_port_info_get_port(pinfo);
          printf("auto-connected to %d:%d (%s - %s)\n", cl, src_port,
                 snd_seq_client_info_get_name(cinfo), snd_seq_port_info_get_name(pinfo));
          break;
        }
      }
    }
  }
  if (src_client >= 0) {
    snd_seq_addr_t sender{(unsigned char)src_client, (unsigned char)src_port};
    snd_seq_addr_t dest{(unsigned char)snd_seq_client_id(seq), (unsigned char)port};
    snd_seq_port_subscribe_set_sender(sub, &sender);
    snd_seq_port_subscribe_set_dest(sub, &dest);
    if (snd_seq_subscribe_port(seq, sub) < 0)
      fprintf(stderr, "warning: MIDI subscribe failed\n");
  } else {
    printf("no MIDI input found — run with -l to list ports, -m CLIENT:PORT to choose\n");
  }

  printf("FM-1 synth running (%s). Ctrl-C to quit.\n", synth_preset_name(cur_patch));
  while (running) {
    snd_seq_event_t* ev;
    snd_seq_event_input(seq, &ev);
    if (ev) { midi_event(ev); snd_seq_free_event(ev); }
  }

  running = 0;
  pthread_join(ath, nullptr);
  snd_pcm_close(pcm);
  snd_seq_close(seq);

  return 0;
}
