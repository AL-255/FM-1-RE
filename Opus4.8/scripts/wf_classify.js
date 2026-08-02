export const meta = {
  name: 'fm1-classify-functions',
  description: 'Classify every FM-1 firmware function into a subsystem with a one-line purpose',
  phases: [
    { title: 'Classify', detail: 'one agent per disassembly shard (~40 funcs each)' },
  ],
}

let _a = args
if (typeof _a === 'string') { try { _a = JSON.parse(_a) } catch (e) { _a = {} } }
const shards = (_a && _a.shards) || []
if (!shards.length) throw new Error('no shards provided in args')
const CTX = `You are reverse-engineering the M-Vave FM-1 firmware: a DX7-style 6-operator FM
synthesizer running on a JieLi JL-BR22 / AC693N Bluetooth-audio SoC (custom
pi32v2 CPU, Blackfin-derived). The synth engine is a port of Dexed / MicroDexed
(Google music-synthesizer-for-android "msfa"). Firmware built on the JieLi
fw-AC63_BT_SDK. Code runs XIP from flash at 0x02000000; RAM at 0x01c00000.

pi32v2 assembly cheat-sheet (algebraic/Blackfin-style):
  rN = X            move/load immediate         rA_rB          64-bit register pair
  rX = [rN+off]     load word                   [rN+off] = rX  store word
  b[..](u|s)  byte load (zero/sign ext)         h[..]  halfword    d[..] 64-bit
  rN += rM / rN -= / rN *= / rN >>= / <<=        arithmetic
  call TARGET       function call (";-> name" annotates known callees)
  goto / gotoss     branch;  if (cond) goto / ifs(cond){..}  conditional
  [--sp]={..}  push    {pc,..}=[sp++] / rts     return
  sti/cli lockclr/testset  interrupt & atomics;  idle  wait;  csync/pfetch  sync
  SFR/peripheral access appears as loads/stores to fixed addresses (0x0006xxxx range etc.)

Subsystem codes (pick the best single one):
  SYS_BOOT   reset/startup/crt/clock init
  SYS_RTOS   task scheduler, os hooks, semaphores/queues, timers
  SYS_IRQ    interrupt/exception vectors & dispatch
  MEMLIB     memcpy/memset/string/alloc/list/printf-style utilities
  MATHLIB    integer/float math, div, fixed-point, tables
  AUDIO_OUT  DAC/DAC-DMA/I2S/audio-clock/output ring buffer, sample-rate
  AUDIO_DSP  mixing, resample, volume, generic DSP blocks
  SYNTH_FM   FM operators/env/lfo/pitch/voice-alloc/note-on-off (msfa/Dexed core)
  FX         reverb/filter/phaser/chorus/effects
  MIDI       MIDI parse/build/route, sysex, DX7 voice (un)pack
  USB        USB device / USB-MIDI / audio class / CDC
  UI_MENU    menu tree/navigation/parameter editing/resource text
  UI_DISPLAY screen/framebuffer/segment/LED driver
  INPUT      keys/buttons/encoder/pitch&mod wheel/ADC scan
  STORAGE_FS flash driver, FAT/jlfs filesystem, file I/O
  STORAGE_PATCH  patch/bank save-load, preset management
  BT         bluetooth: controller/HCI/A2DP/AVRCP/HFP/BLE/GATT/OTA glue
  POWER      power/charge/battery/LDO/sleep
  PERIPH     GPIO/UART/SPI/IIC/PWM/timer low-level drivers
  MISC       small helper/wrapper you can place loosely
  UNKNOWN    genuinely cannot tell

Use: (1) the "calls:" line (known libc names reveal purpose), (2) "strings:" if
present, (3) instruction patterns (SFR addresses, ring buffers, table lookups,
64-bit MAC for DSP). Prefer a specific code; use UNKNOWN only if truly unclear.`

const SCHEMA = {
  type: 'object',
  required: ['functions'],
  properties: {
    functions: {
      type: 'array',
      items: {
        type: 'object',
        required: ['addr', 'subsystem', 'purpose', 'confidence'],
        properties: {
          addr: { type: 'string', description: 'e.g. 0x02001234, copied from the FUNC header' },
          subsystem: { type: 'string', description: 'one subsystem code from the list' },
          purpose: { type: 'string', description: 'concise one-line purpose (<=140 chars)' },
          confidence: { type: 'string', enum: ['low', 'medium', 'high'] },
        },
      },
    },
  },
}

phase('Classify')
const results = await parallel(shards.map((sf) => () =>
  agent(
    CTX +
    `\n\nRead this shard file with the Read tool: ${sf}\n` +
    `It contains many blocks starting with "===== FUNC 0x........ ... =====".\n` +
    `Classify EVERY FUNC block. Return one record per function with its exact addr ` +
    `(from the header), the best subsystem code, a one-line purpose, and confidence.\n` +
    `You may grep other shards or read reference sources under ` +
    `Opus4.8/reference (dexed/Synth_Dexed msfa core, jielie docs) ` +
    `if it helps identify SYNTH_FM/AUDIO code. Do not skip any function.`,
    { schema: SCHEMA, label: 'classify:' + sf.split('/').pop().replace('shard_', '').replace('.txt', ''), phase: 'Classify' }
  ).then((r) => (r && r.functions) ? r.functions : [])
))

const all = results.filter(Boolean).flat()
return { total: all.length, functions: all }
