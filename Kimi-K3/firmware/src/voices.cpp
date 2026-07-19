/* Shared demo voices — see voices.h. Field offsets follow dexed.h enums. */
#include "voices.h"

#define OP(i)        ((i) * 21)
#define OP_R1        0
#define OP_L1        4
#define OP_LEV_BRK   8
#define OP_SCL_LDEP  9
#define OP_SCL_RDEP  10
#define OP_RATE_SCL  13
#define OP_AML       14
#define OP_KVS       15
#define OP_OL        16
#define OP_MODE      17
#define OP_COARSE    18
#define OP_FINE      19
#define OP_DETUNE    20
#define V_ALGO       134
#define V_FEEDBACK   135
#define V_OSCSYNC    136
#define V_LFO_SPEED  137
#define V_LFO_PMD    139
#define V_NAME       145

static uint8_t init_voice[156];

void voices_capture_init(const uint8_t init156[156]) {
  memcpy(init_voice, init156, 156);
}

static void set_op(uint8_t* v, int op, int r1, int r2, int r3, int r4,
                   int ol, int coarse, int detune) {
  uint8_t* o = v + OP(op);
  o[OP_R1 + 0] = (uint8_t)r1; o[OP_R1 + 1] = (uint8_t)r2;
  o[OP_R1 + 2] = (uint8_t)r3; o[OP_R1 + 3] = (uint8_t)r4;
  o[OP_L1 + 0] = 99; o[OP_L1 + 1] = 99; o[OP_L1 + 2] = 99; o[OP_L1 + 3] = 0;
  o[OP_OL] = (uint8_t)ol;
  o[OP_COARSE] = (uint8_t)coarse;
  o[OP_DETUNE] = (uint8_t)detune;
  o[OP_MODE] = 0;                       /* ratio mode */
  o[OP_KVS] = 2;
  o[OP_AML] = 0;
  o[OP_RATE_SCL] = 0;
}

static void build(uint8_t* v, const char* name, int algo, int fb,
                  int lfo_speed, const int ops[6][7]) {
  memcpy(v, init_voice, 156);
  for (int i = 0; i < 6; i++) {
    set_op(v, i, ops[i][0], ops[i][1], ops[i][2], ops[i][3], 0, 1, 7);
    v[OP(i) + OP_OL] = (uint8_t)ops[i][4];
    v[OP(i) + OP_COARSE] = (uint8_t)ops[i][5];
    v[OP(i) + OP_DETUNE] = (uint8_t)ops[i][6];
  }
  v[V_ALGO] = (uint8_t)algo;
  v[V_FEEDBACK] = (uint8_t)fb;
  v[V_OSCSYNC] = 1;
  v[V_LFO_SPEED] = (uint8_t)lfo_speed;
  v[V_LFO_PMD] = 0;
  memset(v + V_NAME, ' ', 10);
  for (int i = 0; name[i] && i < 10; i++) v[V_NAME + i] = (uint8_t)name[i];
}

/* algorithm 4 stacks [1->2] [3->4] [5->6]; carriers are ops idx 1,3,5 */
static void make_epiano(uint8_t* v) {
  static const int ops[6][7] = {
    {95, 50, 30, 60, 60, 14, 7}, {95, 70, 50, 60, 95, 1, 7},
    {0, 0, 0, 0, 0, 1, 7}, {0, 0, 0, 0, 0, 1, 7},
    {0, 0, 0, 0, 0, 1, 7}, {0, 0, 0, 0, 0, 1, 7},
  };
  build(v, "E.PIANO", 4, 6, 0, ops);
}
static void make_bass(uint8_t* v) {
  static const int ops[6][7] = {
    {99, 60, 30, 70, 70, 1, 7}, {99, 80, 40, 70, 99, 1, 7},
    {0, 0, 0, 0, 0, 1, 7}, {0, 0, 0, 0, 0, 1, 7},
    {0, 0, 0, 0, 0, 1, 7}, {0, 0, 0, 0, 0, 1, 7},
  };
  build(v, "BASS", 4, 5, 0, ops);
}
static void make_brass(uint8_t* v) {
  static const int ops[6][7] = {
    {70, 75, 50, 65, 75, 1, 7}, {70, 85, 60, 65, 90, 1, 7},
    {70, 70, 40, 65, 60, 1, 7}, {70, 80, 55, 65, 70, 1, 7},
    {0, 0, 0, 0, 0, 1, 7}, {0, 0, 0, 0, 0, 1, 7},
  };
  build(v, "BRASS", 4, 4, 0, ops);
}
static void make_lead(uint8_t* v) {
  static const int ops[6][7] = {
    {85, 65, 45, 60, 80, 2, 7}, {85, 80, 55, 60, 99, 1, 7},
    {0, 0, 0, 0, 0, 1, 7}, {0, 0, 0, 0, 0, 1, 7},
    {0, 0, 0, 0, 0, 1, 7}, {0, 0, 0, 0, 0, 1, 7},
  };
  build(v, "LEAD", 4, 7, 35, ops);
}

typedef void (*make_fn)(uint8_t*);
static make_fn const MAKES[DEMO_N_PATCHES] = { make_epiano, make_bass, make_brass, make_lead };
static const char NAMES[DEMO_N_PATCHES][10] = { "E.PIANO  ", "BASS     ", "BRASS    ", "LEAD     " };

void voices_build(int idx, uint8_t v[156]) { MAKES[idx % DEMO_N_PATCHES](v); }
const char* voices_name(int idx) { return NAMES[idx % DEMO_N_PATCHES]; }
