// Minimal VST2 plugin API definitions (vestige-style).
// This is a subset of the VST2 SDK interfaces needed for a simple instrument.

#ifndef VESTIGE_H
#define VESTIGE_H

#include <stdint.h>

#ifdef __cplusplus
extern "C" {
#endif

#define CCONST(a,b,c,d) (((int32_t)(a) << 24) | ((int32_t)(b) << 16) | \
                         ((int32_t)(c) << 8) | (int32_t)(d))

enum {
  kAudioEffectClass = 0,
  kVstVersion = 2400,
  kEffectMagic = CCONST('V','s','t','P'),

  effOpen = 0,
  effClose = 1,
  effSetProgram = 2,
  effGetProgram = 3,
  effSetProgramName = 4,
  effGetProgramName = 5,
  effGetParamLabel = 6,
  effGetParamDisplay = 7,
  effGetParamName = 8,
  effSetSampleRate = 10,
  effSetBlockSize = 11,
  effMainsChanged = 12,
  effEditGetRect = 13,
  effEditOpen = 14,
  effEditClose = 15,
  effProcessEvents = 25,
  effCanBeAutomated = 26,
  effGetChunk = 28,
  effSetChunk = 29,
  effGetVendorString = 47,
  effGetProductString = 48,
  effGetVendorVersion = 49,
  effCanDo = 51,
  effGetTailSize = 52,
  effStartProcess = 71,
  effStopProcess = 72,

  effFlagsHasEditor = 1 << 0,
  effFlagsCanReplacing = 1 << 4,
  effFlagsProgramChunks = 1 << 5,
  effFlagsIsSynth = 1 << 8,

  kVstTransportChanged = 1,
  kVstTempoValid = 1 << 1,

  kVstMidiType = 1,

  kVstMaxProgNameLen = 24,
  kVstMaxParamStrLen = 8,
  kVstMaxVendorStrLen = 64,
  kVstMaxProductStrLen = 64,
  kVstMaxEffectNameLen = 32
};

typedef intptr_t VstIntPtr;
typedef int32_t  VstInt32;

typedef struct AEffect {
  VstInt32 magic;
  VstIntPtr (*dispatcher)(struct AEffect* effect, VstInt32 opCode, VstInt32 index,
                          VstIntPtr value, void* ptr, float opt);
  void (*process)(struct AEffect* effect, float** inputs, float** outputs, VstInt32 sampleFrames);
  void (*setParameter)(struct AEffect* effect, VstInt32 index, float parameter);
  float (*getParameter)(struct AEffect* effect, VstInt32 index);
  VstInt32 numPrograms;
  VstInt32 numParams;
  VstInt32 numInputs;
  VstInt32 numOutputs;
  VstInt32 flags;
  VstIntPtr resvd1;
  VstIntPtr resvd2;
  VstInt32 initialDelay;
  VstInt32 realQualities;
  VstInt32 offQualities;
  float ioRatio;
  void* object;
  void* user;
  VstInt32 uniqueID;
  VstInt32 version;
  void (*processReplacing)(struct AEffect* effect, float** inputs, float** outputs, VstInt32 sampleFrames);
  void (*processDoubleReplacing)(struct AEffect* effect, double** inputs, double** outputs, VstInt32 sampleFrames);
  char future[56];
} AEffect;

typedef struct VstEvent {
  VstInt32 type;
  VstInt32 byteSize;
  VstInt32 deltaFrames;
  VstInt32 flags;
  char data[16];
} VstEvent;

typedef struct VstEvents {
  VstInt32 numEvents;
  void* reserved;
  VstEvent* events[2];
} VstEvents;

typedef struct VstMidiEvent {
  VstInt32 type;
  VstInt32 byteSize;
  VstInt32 deltaFrames;
  VstInt32 flags;
  VstInt32 noteLength;
  VstInt32 noteOffset;
  char midiData[4];
  char detune;
  char noteOffVelocity;
  char reserved1;
  char reserved2;
} VstMidiEvent;

#define audioMasterAutomate 4
#define audioMasterVersion 6
#define audioMasterCurrentId 9
#define audioMasterIdle 10
#define audioMasterPinConnected 12
#define audioMasterWantMidi 16
#define audioMasterGetTime 17
#define audioMasterProcessEvents 18
#define audioMasterSetTime 19
#define audioMasterTempoAt 20
#define audioMasterGetNumAutomatableParameters 21
#define audioMasterGetParameterQuantization 22
#define audioMasterIOChanged 23
#define audioMasterNeedIdle 35
#define audioMasterSizeWindow 42
#define audioMasterGetSampleRate 48
#define audioMasterGetBlockSize 49
#define audioMasterGetInputLatency 50
#define audioMasterGetOutputLatency 51
#define audioMasterGetPreviousPlug 52
#define audioMasterGetNextPlug 53
#define audioMasterWillReplaceOrAccumulate 54
#define audioMasterGetCurrentProcessLevel 59
#define audioMasterGetAutomationState 60
#define audioMasterOfflineStart 61
#define audioMasterOfflineRead 62
#define audioMasterOfflineWrite 63
#define audioMasterOfflineGetCurrentPass 64
#define audioMasterGetVendorString 68
#define audioMasterGetProductString 69
#define audioMasterGetVendorVersion 70
#define audioMasterVendorSpecific 71
#define audioMasterCanDo 77
#define audioMasterGetLanguage 79
#define audioMasterGetDirectory 82

typedef VstIntPtr (*audioMasterCallback)(AEffect* effect, VstInt32 opcode, VstInt32 index,
                                         VstIntPtr value, void* ptr, float opt);

#ifdef __cplusplus
}
#endif

#endif
