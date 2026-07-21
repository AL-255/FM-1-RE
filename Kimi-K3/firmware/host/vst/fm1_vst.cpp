// FM-1 synth — VST2 instrument plugin (basic poly synth, same code as the
// on-device demo). MIDI in -> mono audio out. A float "patch" parameter
// selects SAW LEAD/SQ BASS/SYNC PAD/PLUCK (0-3). Built for Linux DAWs.
#include <cmath>
#include <cstdlib>
#include <cstring>
#include "vestige.h"
#include "synth.h"

#define PLUGIN_ID   CCONST('F','M','1','S')
#define PLUGIN_VER  1000

enum { PARAM_PATCH = 0, PARAM_COUNT };

struct FM1VST {
  AEffect* effect;
  audioMasterCallback master;
  float sampleRate;
  int curPatch;
  float patchParam;
  int16_t scratch[4096];
};

static void applyPatch(FM1VST* v, int p) {
  p = p < 0 ? 0 : (p >= SYNTH_N_PRESETS ? SYNTH_N_PRESETS - 1 : p);
  if (p == v->curPatch) return;
  synth_set_preset(p);
  v->curPatch = p;
}

static VstIntPtr dispatcher(AEffect* effect, VstInt32 opcode, VstInt32 index,
                            VstIntPtr value, void* ptr, float opt) {
  FM1VST* v = (FM1VST*)effect->object;
  (void)index; (void)value; (void)opt;
  switch (opcode) {
    case effOpen:
      synth_init(v->sampleRate > 0 ? v->sampleRate : 44100.0f);
      v->curPatch = -1;
      applyPatch(v, (int)(v->patchParam + 0.5f));
      return 0;
    case effClose:
      return 0;
    case effGetVendorString:
      strcpy((char*)ptr, "Kimi-K3");
      return 1;
    case effGetProductString:
      strcpy((char*)ptr, "FM-1 Dexed");
      return 1;
    case effGetVendorVersion:
      return PLUGIN_VER;
    case effCanDo:
      if (!strcmp((const char*)ptr, "receiveVstEvents") ||
          !strcmp((const char*)ptr, "receiveVstMidiEvent"))
        return 1;
      return 0;
    case effProcessEvents: {
      VstEvents* evs = (VstEvents*)ptr;
      for (VstInt32 i = 0; evs && i < evs->numEvents; i++) {
        VstEvent* e = evs->events[i];
        if (e && e->type == kVstMidiType) {
          VstMidiEvent* m = (VstMidiEvent*)e;
          uint8_t st = m->midiData[0] & 0xF0;
          if (st == 0x90) {
            if (m->midiData[2]) synth_note_on(m->midiData[1], m->midiData[2]);
            else synth_note_off(m->midiData[1]);
          } else if (st == 0x80) {
            synth_note_off(m->midiData[1]);
          } else if (st == 0xC0) {
            applyPatch(v, m->midiData[1]);
          }
        }
      }
      return 0;
    }
    case effSetSampleRate:
      v->sampleRate = opt;
      synth_init(opt);
      return 0;
    case effMainsChanged:
      if (value) applyPatch(v, (int)(v->patchParam + 0.5f));
      return 0;
    default:
      return 0;
  }
}

static void processReplacing(AEffect* effect, float** inputs, float** outputs,
                             VstInt32 sampleFrames) {
  (void)inputs;
  FM1VST* v = (FM1VST*)effect->object;
  float* out = outputs[0];
  VstInt32 done = 0;
  while (done < sampleFrames) {
    VstInt32 chunk = sampleFrames - done;
    if (chunk > 4096) chunk = 4096;
    synth_render(v->scratch, chunk);
    for (VstInt32 i = 0; i < chunk; i++)
      out[done + i] = v->scratch[i] / 32768.0f;
    done += chunk;
  }
}

static void setParameter(AEffect* effect, VstInt32 index, float parameter) {
  FM1VST* v = (FM1VST*)effect->object;
  if (index == PARAM_PATCH) {
    v->patchParam = parameter;
    applyPatch(v, (int)(parameter * (SYNTH_N_PRESETS - 1) + 0.5f));
  }
}

static float getParameter(AEffect* effect, VstInt32 index) {
  FM1VST* v = (FM1VST*)effect->object;
  if (index == PARAM_PATCH) return v->patchParam;
  return 0.0f;
}

extern "C" __attribute__((visibility("default"))) AEffect* VSTPluginMain(audioMasterCallback cb);

AEffect* VSTPluginMain(audioMasterCallback cb) {
  if (!cb) return nullptr;

  FM1VST* v = (FM1VST*)calloc(1, sizeof(FM1VST));
  if (!v) return nullptr;
  v->master = cb;
  v->sampleRate = 44100.0f;
  v->patchParam = 0.0f;

  AEffect* e = (AEffect*)calloc(1, sizeof(AEffect));
  if (!e) { free(v); return nullptr; }

  e->magic = kEffectMagic;
  e->dispatcher = dispatcher;
  e->process = nullptr;
  e->setParameter = setParameter;
  e->getParameter = getParameter;
  e->numPrograms = 1;
  e->numParams = PARAM_COUNT;
  e->numInputs = 0;
  e->numOutputs = 1;
  e->flags = effFlagsCanReplacing | effFlagsIsSynth;
  e->processReplacing = processReplacing;
  e->processDoubleReplacing = nullptr;
  e->object = v;
  e->uniqueID = PLUGIN_ID;
  e->version = PLUGIN_VER;
  v->effect = e;

  return e;
}

// Some hosts look for "main" instead of "VSTPluginMain".
extern "C" __attribute__((visibility("default"))) AEffect* main_plugin(audioMasterCallback cb);
AEffect* main_plugin(audioMasterCallback cb) { return VSTPluginMain(cb); }
