// MIDI injection test: connects to a target ALSA seq port and plays notes.
// usage: midi_blaster CLIENT:PORT [patch]
#include <alsa/asoundlib.h>
#include <cstdio>
#include <cstdlib>
#include <cstring>
#include <unistd.h>

int main(int argc, char** argv) {
  if (argc < 2) { fprintf(stderr, "usage: midi_blaster CLIENT:PORT [patch]\n"); return 1; }
  int dc = 0, dp = 0; sscanf(argv[1], "%d:%d", &dc, &dp);
  int patch = argc > 2 ? atoi(argv[2]) : 0;

  snd_seq_t* seq;
  if (snd_seq_open(&seq, "default", SND_SEQ_OPEN_OUTPUT, 0) < 0) { fprintf(stderr, "no seq\n"); return 1; }
  int port = snd_seq_create_simple_port(seq, "blaster", SND_SEQ_PORT_CAP_READ, SND_SEQ_PORT_TYPE_MIDI_GENERIC);
  snd_seq_addr_t dest{(unsigned char)dc, (unsigned char)dp};
  if (snd_seq_connect_to(seq, port, dc, dp) < 0) { fprintf(stderr, "connect failed to %d:%d\n", dc, dp); return 1; }

  snd_seq_event_t ev;
  snd_seq_ev_clear(&ev);
  snd_seq_ev_set_source(&ev, port);
  snd_seq_ev_set_subs(&ev);
  snd_seq_ev_set_direct(&ev);

  auto send = [&]() { snd_seq_event_output_direct(seq, &ev); };
  // program change
  ev.type = SND_SEQ_EVENT_PGMCHANGE; ev.data.control.value = patch; send();
  usleep(100000);
  static const int scale[] = {60, 62, 64, 65, 67, 69, 71, 72};
  for (int r = 0; r < 2; r++)
    for (int i = 0; i < 8; i++) {
      ev.type = SND_SEQ_EVENT_NOTEON; ev.data.note.note = scale[i]; ev.data.note.velocity = 100; send();
      usleep(150000);
      ev.type = SND_SEQ_EVENT_NOTEOFF; ev.data.note.note = scale[i]; ev.data.note.velocity = 0; send();
      usleep(50000);
    }
  // final chord
  for (int i = 0; i < 3; i++) { ev.type = SND_SEQ_EVENT_NOTEON; ev.data.note.note = 60 + i * 4; ev.data.note.velocity = 110; send(); }
  usleep(800000);
  for (int i = 0; i < 3; i++) { ev.type = SND_SEQ_EVENT_NOTEOFF; ev.data.note.note = 60 + i * 4; ev.data.note.velocity = 0; send(); }
  snd_seq_close(seq);
  printf("blasted notes to %d:%d (patch %d)\n", dc, dp, patch);
  return 0;
}
