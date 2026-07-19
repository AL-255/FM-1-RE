/* Trampoline into the demo, patched over usr_app_task's first 6 bytes by the
 * image builder. Executes the two relocated instructions, preserves the
 * argument registers, runs demo_install(), then resumes usr_app_task+6.
 * Relocated insns (verified against app.bin @0x02022CFE):
 *   10 04          [--sp] = rets
 *   50 ed 00 22    r2 = h[r0+32] (u)
 */
    .section .text.demo_tramp, "ax", @progbits
    .global __tramp_usr_app_task
    .extern demo_install
__tramp_usr_app_task:
    [--sp] = rets
    r2 = h[r0+32] (u)
    [--sp] = {r3-r0}
    call demo_install
    {r3-r0} = [sp++]
    r6 = 0x02022d04
    goto r6

/* MIDI hook trampoline, patched over midi_msg_dispatch's first 6 bytes
 * (0x0201F5F4). Runs our parser, then resumes midi_msg_dispatch+6 — the
 * stock handler keeps working after us (no chaining needed).
 * Relocated insns (verified against app.bin @0x0201F5F4):
 *   7f 04          [--sp] = {rets, r15-r4}
 *   (2 bytes)      sp += -84
 *   (2 bytes)      r5 = b[r1+0] (u)
 */
    .global __tramp_midi
    .extern demo_midi_parse
__tramp_midi:
    [--sp] = {rets, r15-r4}
    sp += -84
    r5 = b[r1+0] (u)
    [--sp] = {r3-r0}
    call demo_midi_parse
    {r3-r0} = [sp++]
    r6 = 0x0201f5fa
    goto r6
