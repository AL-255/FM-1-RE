/* Basic polyphonic synthesizer — see synth.h. */
#include "synth.h"
#include <math.h>
#include <string.h>

/* ---------------- voice model ---------------- */

typedef enum { ST_IDLE, ST_ATTACK, ST_DECAY, ST_SUSTAIN, ST_RELEASE } EnvStage;

typedef struct {
  uint8_t  active;
  uint8_t  note;
  uint8_t  vel;
  EnvStage stage;
  float    env;          /* 0..1 */
  float    phase1;       /* 0..1 main osc */
  float    phase2;       /* 0..1 second osc (detune) */
  float    freq;         /* Hz */
  float    vel_gain;
  float    fl, fh;       /* Chamberlin filter state */
  uint32_t age;          /* for voice stealing */
} Voice;

typedef struct {
  const char* name;
  uint8_t osc1_wave;      /* 0 saw, 1 square, 2 sine */
  uint8_t osc2_wave;
  int8_t  osc2_detune;    /* semitone offset */
  uint8_t sub_level;      /* 0..255 sub osc mix */
  float   attack, decay, sustain, release;   /* seconds, sustain=level 0..1 */
  float   cutoff;         /* Hz */
  float   resonance;      /* 0..1 */
  float   osc2_level;
} Preset;

static const Preset PRESETS[SYNTH_N_PRESETS] = {
  /* name        w1 w2 dt sub  A      D     S    R      cutoff res   osc2 */
  { "SAW LEAD", 0, 0, 0, 64,  0.004f, 0.18f, 0.75f, 0.22f, 6500.f, 0.15f, 0.0f },
  { "SQ BASS",  1, 1, -12, 200, 0.003f, 0.12f, 0.9f, 0.12f, 900.f, 0.25f, 0.4f },
  { "SYNC PAD", 0, 0, 7, 0,   0.25f, 0.4f, 0.85f, 0.6f,  3800.f, 0.3f, 0.55f },
  { "PLUCK",    0, 1, 0, 96,  0.002f, 0.22f, 0.0f, 0.18f, 5200.f, 0.35f, 0.25f },
};

static Voice  voices[SYNTH_N_VOICES];
static float  sample_rate_ = 44100.f;
static int    preset_idx_;
static const Preset* preset_;
static float  env_a_coef, env_d_coef, env_r_coef;
static float  filt_f, filt_q;
static uint32_t age_ctr;

static float note_freq(int note) {
  /* 440 Hz at note 69; exp2f only at note-on, not per-sample */
  return 440.f * exp2f((note - 69) / 12.f);
}

/* polyblep anti-alias helper */
static inline float polyblep(float t, float dt) {
  if (t < dt)        { t /= dt; return t + t - t * t - 1.f; }
  if (t > 1.f - dt)  { t = (t - 1.f) / dt; return t * t + t + t + 1.f; }
  return 0.f;
}

static float osc_sample(int wave, float phase, float dt) {
  float v;
  switch (wave) {
    case 1: /* square */
      v = phase < 0.5f ? 1.f : -1.f;
      v += polyblep(phase, dt);
      v -= polyblep(phase < 0.5f ? phase + 0.5f : phase - 0.5f, dt);
      return v;
    case 2: /* sine */
      return sinf(phase * 6.28318530718f);
    default: /* saw */
      v = 2.f * phase - 1.f;
      v -= polyblep(phase, dt);
      return v;
  }
}

static void preset_apply(void) {
  preset_ = &PRESETS[preset_idx_ % SYNTH_N_PRESETS];
  env_a_coef = 1.f / (preset_->attack * sample_rate_ + 1.f);
  env_d_coef = 1.f / (preset_->decay * sample_rate_ + 1.f);
  env_r_coef = 1.f / (preset_->release * sample_rate_ + 1.f);
  /* Chamberlin: f = 2*sin(pi*fc/fs), clamp for stability */
  float f = 2.f * sinf(3.14159265f * preset_->cutoff / sample_rate_);
  filt_f = f > 1.2f ? 1.2f : f;
  filt_q = 1.6f - preset_->resonance * 1.4f;   /* 1.6 .. 0.2 */
}

void synth_init(float rate) {
  sample_rate_ = rate > 0.f ? rate : 44100.f;
  memset(voices, 0, sizeof(voices));
  preset_idx_ = 0;
  age_ctr = 0;
  preset_apply();
}

void synth_set_preset(int idx) {
  preset_idx_ = idx;
  preset_apply();
}
int synth_get_preset(void) { return preset_idx_ % SYNTH_N_PRESETS; }
const char* synth_preset_name(int idx) { return PRESETS[idx % SYNTH_N_PRESETS].name; }

void synth_note_on(int note, int vel) {
  int free_i = -1, oldest_i = 0;
  uint32_t oldest = 0xffffffffu;
  for (int i = 0; i < SYNTH_N_VOICES; i++) {
    if (!voices[i].active) { free_i = i; break; }
    if (voices[i].age < oldest) { oldest = voices[i].age; oldest_i = i; }
  }
  int i = free_i >= 0 ? free_i : oldest_i;
  Voice* v = &voices[i];
  v->note = (uint8_t)note;
  v->vel = (uint8_t)vel;
  v->stage = ST_ATTACK;
  v->env = 0.f;
  v->freq = note_freq(note);
  v->vel_gain = (vel / 127.f);
  v->vel_gain *= v->vel_gain;           /* curved */
  v->phase1 = 0.f;
  v->phase2 = 0.f;
  v->fl = v->fh = 0.f;
  v->age = ++age_ctr;
  v->active = 1;
}

void synth_note_off(int note) {
  for (int i = 0; i < SYNTH_N_VOICES; i++) {
    if (voices[i].active && voices[i].note == note && voices[i].stage != ST_RELEASE) {
      voices[i].stage = ST_RELEASE;
      /* keep env level — release from where it is */
    }
  }
}

int synth_active_voices(void) {
  int n = 0;
  for (int i = 0; i < SYNTH_N_VOICES; i++) if (voices[i].active) n++;
  return n;
}

void synth_render(int16_t* out, int nframes) {
  const float fc = filt_f, q = filt_q;
  const float sub_l = preset_->sub_level / 255.f;
  const float osc2_l = preset_->osc2_level;
  for (int s = 0; s < nframes; s++) {
    float mix = 0.f;
    for (int i = 0; i < SYNTH_N_VOICES; i++) {
      Voice* v = &voices[i];
      if (!v->active) continue;

      /* envelope */
      switch (v->stage) {
        case ST_ATTACK:
          v->env += env_a_coef;
          if (v->env >= 1.f) { v->env = 1.f; v->stage = ST_DECAY; }
          break;
        case ST_DECAY:
          v->env -= env_d_coef;
          if (v->env <= preset_->sustain) { v->env = preset_->sustain; v->stage = ST_SUSTAIN; }
          break;
        case ST_SUSTAIN:
          break;
        case ST_RELEASE:
          v->env -= env_r_coef;
          if (v->env <= 0.f) { v->env = 0.f; v->active = 0; v->stage = ST_IDLE; }
          break;
        default: break;
      }
      if (!v->active) continue;

      /* oscillators */
      float dt1 = v->freq / sample_rate_;
      float det = preset_->osc2_detune ? exp2f(preset_->osc2_detune / 12.f) : 1.f;
      float dt2 = dt1 * det;
      v->phase1 += dt1; if (v->phase1 >= 1.f) v->phase1 -= 1.f;
      v->phase2 += dt2; if (v->phase2 >= 1.f) v->phase2 -= 1.f;

      float o = osc_sample(preset_->osc1_wave, v->phase1, dt1);
      o += osc2_l * osc_sample(preset_->osc2_wave, v->phase2, dt2);
      if (sub_l > 0.f) {
        float sp = v->phase1 * 0.5f;
        float sub = sp < 0.5f ? 1.f : -1.f;
        o += sub_l * sub;
      }

      /* Chamberlin SVF lowpass */
      v->fl += fc * (o - v->fl - q * v->fh);
      v->fh += fc * v->fl;

      mix += v->fl * v->env * v->vel_gain;
    }
    /* soft clip + scale */
    mix *= 0.25f;
    mix = tanhf(mix * 1.6f) * 0.9f;
    int32_t x = (int32_t)(mix * 32767.f);
    out[s] = (int16_t)(x > 32767 ? 32767 : (x < -32768 ? -32768 : x));
  }
}
