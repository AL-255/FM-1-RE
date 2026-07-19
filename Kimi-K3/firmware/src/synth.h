/* Basic polyphonic synthesizer — the FM-1 demo engine.
 *
 * Deliberately simple and fully self-contained (shared by the device demo
 * and the host app): 8 voices, per-voice saw+square oscillator pair with
 * polyblep anti-aliasing, a sub-oscillator, linear ADSR, and a Chamberlin
 * state-variable lowpass. Four presets selectable by program change.
 *
 * API is blocking-call oriented: note_on/off from the MIDI hook (task ctx),
 * render from the audio callback (IRQ ctx). Voices are only touched from
 * these two places; a note-on arriving mid-render is safe on this class of
 * core (single CPU, no cross-core shared state besides the voice array
 * guarded by the caller's IRQ/task split).
 */
#ifndef BASIC_SYNTH_H
#define BASIC_SYNTH_H

#include <stdint.h>

#define SYNTH_N_VOICES 8
#define SYNTH_N_PRESETS 4

#ifdef __cplusplus
extern "C" {
#endif

void  synth_init(float sample_rate);
void  synth_note_on(int note, int vel);   /* vel 1..127 */
void  synth_note_off(int note);
void  synth_render(int16_t* out, int nframes);

void        synth_set_preset(int idx);    /* wraps */
int         synth_get_preset(void);
const char* synth_preset_name(int idx);

/* for the UI: number of currently active voices and last note for display */
int synth_active_voices(void);

#ifdef __cplusplus
}
#endif

#endif
