# FM-1 RTOS (JieLi OS, FreeRTOS-derived SMP port)

Reverse-engineered from `app.bin` (pi32v2, flash XIP VMA `0x02000000`). Every
claim carries the function address it was read from; `[high|med|low]` marks
confidence. Code citations name the
enriched shard the disassembly was taken from. The sibling BR23 soundbox SDK
(`reference/ac695n_soundbox_sdk`) was used to cross-check API signatures; where the
FM-1 binary diverges from the SDK headers, the binary wins and the divergence is
flagged.

The kernel is JieLi's in-house OS ("os_*" API) layered on a **FreeRTOS-derived SMP
scheduler** for the two pi32v2 cores. It is not stock FreeRTOS — lists, TCB fields
and priority-inheritance were reworked — but the task model, state lists and tick
machinery are recognizably FreeRTOS (`tasks.c`) with SMP additions.

---

## 1. Kernel identity — evidence

| Evidence | Where | Confidence |
|---|---|---|
| `xTaskIncrementTick` (tick++, overflow list swap, wake delayed, timeslice every 5 ticks) | `0x02058CC2` (`shard_02051c2a_02058e6c.txt`) | high |
| `vTaskSwitchContext` (clz on ready bitmap, `31 - clz` = highest ready prio, pxIndex walk, store next TCB) | `0x02058E6C` | high |
| `uxListRemove` / `vListInsertEnd` (FreeRTOS `List_t`/`ListItem_t` layouts: `+4 pxNext, +8 pxPrev, +16 pxContainer`) | `0x02058C0E` / `0x02058C88` | high |
| Ready lists: 31 priorities × 20-byte `List_t` at `0x01C20318` (init loop runs 31×20 = 620 bytes) | `__os_task_ready_insert 0x0205A1BA` (`shard_02058f26_0205b036.txt`) | high |
| Delayed/overflow lists, pending-ready list, waiting-termination list | `0x0205A1BA`, `os_task_del 0x0205B8D8`, `__os_sched_process 0x0205900C` | high |
| `xEventListItem` initialized with `xItemValue = 31 - prio` (FreeRTOS idiom) | `__os_task_tcb_init 0x0205A120` | high |
| Task stack filled with `0xA5`, 76-byte initial context frame | `0x0205A120` | high |
| SMP: per-cpu `pxCurrentTCB[2]`/`pxNextTCB[2]`, `lockset`/`lockclr` hw mutex, per-cpu context-switch SWI | throughout; `task_switch_trigger 0x0205BD9E` | high |

## 2. Scheduler state map

All addresses verified in the disassembly of the functions cited.

| Address | Meaning | Seen in |
|---|---|---|
| `0x01C09738` | OS-tick accumulator (20 units per OS tick) | `os_tick_update 0x0205C5B8` |
| `0x01C0973C` | `uxTaskNumber` (task count) | `0x0205A1BA`, `0x0205B8D8` |
| `0x01C09740` | `pxCurrentTCB[2]` (per-cpu) | `xTaskGetCurrentTaskHandle 0x02058A66` |
| `0x01C09744` | `xSchedulerRunning` | `os_start 0x0205A6B6` |
| `0x01C09748` | `uxTCBNumber` (serial counter → TCB+124) | `0x0205A1BA` |
| `0x01C0974C` | `uxTopReadyPriority` (ready bitmap, 31 bits) | `vTaskSwitchContext 0x02058E6C` |
| `0x01C09750` | `pxNextTCB[2]` (per-cpu) | `task_switch_trigger 0x0205BD9E`, `os_task_del 0x0205B8D8` |
| `0x01C09754` | `uxDeletedTasksWaitingCleanUp` | `0x0205B8D8`, idle `0x0205BE12` |
| `0x01C09758` | `uxSchedulerSuspended` | `vTaskSuspendAll 0x02058B82` |
| `0x01C0975C` | `xNextTaskUnblockTime` | `prvResetNextTaskUnblockTime 0x02058C9E` |
| `0x01C09760` | `xYieldPending` | `0x02058E6C`, `__os_waitlist_wake 0x020593AC` |
| `0x01C09764` | `uxPendedTicks` | `0x02058CC2`, `0x0205900C` |
| `0x01C09768` | `xTickCount` (low 32) | `0x02058CC2`, `os_time_get 0x02059B74` |
| `0x01C0976C` | `xNumOfOverflows` (high 32) | `0x02058CC2`, `0x02059B74` |
| `0x01C09774` | tickless-idle enable (u8) | idle `0x0205BE12` |
| `0x01C09778` | OS-running flag (u8; set by `os_init`) | `os_init 0x0205A10A`, `os_mutex_pend 0x0205AE98` |
| `0x01C20318` | `pxReadyTasksLists[31]` (31 × `List_t` 20 B) | `0x0205A1BA`, `0x02058E6C` |
| `0x01C20584` / `0x01C20598` | delayed-task lists 1/2 | `0x0205A1BA` |
| `0x01C205E8` / `0x01C205EC` | `pxDelayedTaskList` / `pxOverflowDelayedTaskList` (pointers) | `0x02058CC2` |
| `0x01C205AC` | `xPendingReadyList` | `__os_sched_process 0x0205900C` |
| `0x01C205C0` | `xWaitingTerminationList` | `os_task_del 0x0205B8D8` |
| `0x01C205D4` | suspended-task list | `os_task_get_handle 0x020590FC` |
| `0x01C20B6C` | task-queue registry list head | `__os_task_register 0x0205A440` |
| `0x01C20B74` | auto task-name counter (u8) | `os_task_create 0x0205B1D0` |
| `0x01C08FF0` | tick/timer globals: `+4` raw OS tick count, `+16/+24/+32` timer list heads | `timer_tick_isr`, timer scan tasks |

`os_time_get 0x02059B74` reads the 64-bit tick `{hi=0x1C0976C, lo=0x1C09768}` into
a caller buffer `[high]`.

### 2.1 Context-switch path

1. `os_sched 0x02058F26` — critical enter → `vTaskSwitchContext 0x02058E6C`; if a
   higher-prio task is ready it updates runtime accounting (`h[TCB+144]`,
   `h[TCB+146]`, timestamp from `tick_count_x10_get 0x0200083A`) and pends the
   context-switch SWI: iterates the per-cpu `pxCurrentTCB`/`pxNextTCB` slots and
   sets `[0x1EEF1A0] |= 1 << bit` (bit 7 seen; the loop shape implies per-cpu
   bits 7/6) `[med]`.
2. `task_switch_trigger 0x0205BD9E` (the SWI handler path): `pxCurrentTCB[cpu] =
   pxNextTCB[cpu]`; triggers the SWI via `[0x1EEF1A4] = 1 << (7 - cpu)`; programs
   the **hardware stack-guard registers** from the new TCB:
   `[0x1EEF0E0 + cpu*0x200] = TCB+120 (pxStack)`,
   `[0x1EEF0DC + cpu*0x200] = TCB+120 + TCB+8 (stack limit)` `[high]`.
   (Note: immediates like `0x7BBC38` in the disassembly are word-indexed SFR
   addresses — `0x7BBC38 * 4 = 0x1EEF0E0`; same for `0x7BBC6A * 4 = 0x1EEF1A8`,
   the per-cpu exception-state register read in mutex/IPC paths.)
3. `vTaskSwitchContext 0x02058E6C`: if `uxSchedulerSuspended != 0` → sets
   `xYieldPending` and returns 0. Else: `prio = 31 - clz(uxTopReadyPriority)`,
   walks `pxReadyTasksLists[prio].pxIndex` to the next task (round-robin within a
   priority), stores its TCB to `pxNextTCB[cpu]` `[high]`.
4. `__os_sched_process 0x0205900C` (= `xTaskResumeAll`): moves
   `xPendingReadyList` tasks to ready, replays `uxPendedTicks` through
   `xTaskIncrementTick`, yields if needed `[high]`.

The per-cpu context-switch SWI is IRQ `0x7F - cnum` (127 cpu0, 126 cpu1), handler
`0x020419DA`, registered by `os_start` with prio 0 `[high]`.

### 2.2 Tick

- OS tick IRQ is **IRQ3, prio 1**, handler installed by `os_start` at
  `0x0205BE92` `[high]`. The ISR tail (visible at `0x0205BD72`,
  `shard_0205b19c_0205df56.txt`): bumps `[0x1C08FF0+4]`, calls
  `xTaskIncrementTick 0x02058CC2`, calls `os_sched` when it returns 1.
- The tick hardware: control block at `0x1EEF0EC` (`b[+0]` enable flags,
  `[+4]` counter clear, `[+8]` = `clk_hz/100` written by `os_start` from
  `clk_get(...)/100`). `os_tick_update 0x0205C5B8` converts the hardware count at
  `0x1EEF0F0` into 20 accumulator units per OS tick; evidence points to a
  **10 ms nominal OS tick (100 Hz)** — `os_time_dly_ms 0x0205B7E2` converts
  `ms → ticks` as `round(ms/10)`, minimum 1 `[med]`.
- `xTaskIncrementTick 0x02058CC2`: pends when `uxSchedulerSuspended` (increments
  `uxPendedTicks`); else `xTickCount++`, on overflow swaps
  `pxDelayedTaskList`/`pxOverflowDelayedTaskList` and `xNumOfOverflows++`; wakes
  delayed tasks whose `TCB+76` (xItemValue/wake tick) ≤ now into the ready lists;
  **timeslice: yields every 5th tick** when the current priority has > 1 ready
  task (`tick % 5 == 0` path) `[high]`.
- `os_tick_get_half 0x0205C610` = `os_tick_update() >> 1` — the accumulator runs
  at 20 units/tick, so this returns **milliseconds**; it is the time base the
  sys/usr timers compare against `[med]`.

### 2.3 Idle

`os_idle_task 0x0205BE12` (`shard_0205b19c_0205df56.txt`): cleans up
`xWaitingTerminationList` when `uxDeletedTasksWaitingCleanUp != 0`
(vTaskSuspendAll/`uxListRemove(TCB+76)`/`uxTaskNumber--`/xTaskResumeAll); yields
(`os_sched`) when another priority-0 task is ready; executes the **`idle`
instruction** (pi32v2 wait-for-interrupt, seen at `0x0205BF74`); when the
tickless flag `b[0x1C09774]` is set it computes expected idle time
(`xNextTaskUnblockTime - xTickCount`, helper head at `0x0205BE12`), requires
≥ 2 ticks, then enters the low-power sleep path gated by module votes
(`os_module_prepare_poll 0x020308EA`, `os_module_ready_vote 0x0203091C`, inhibit
counter at `b[0x1C0E670+52]`) `[med]`.

Idle tasks are created per cpu by `os_start` (entry `0x0205BFCE`, name strings at
`0x0205C030`/`0x0205C036` per cpu, stksize 256 words) `[med]`.

## 3. Tasks

### 3.1 TCB layout (156 bytes)

Verified by `__os_task_tcb_init 0x0205A120` cross-checked against
`__os_task_ready_insert 0x0205A1BA`, `xTaskIncrementTick`, `os_task_del
0x0205B8D8`, `task_switch_trigger 0x0205BD9E`. Allocation: `malloc(156)` in
`__os_task_create_alloc 0x0205A580`.

| Off | Size | Field | Confidence |
|---|---|---|---|
| +0 | 4 | `pxTopOfStack` — pointer to the 76-byte saved context frame | high |
| +8 | 4 | stack size in bytes (top − base; used for the hw stack-limit register) | high |
| +12 | 64 | `pcTaskName` (max 63 chars + NUL) | high |
| +75 | 1 | u8 flag (cleared at init) | med |
| +76 | 20 | `xStateListItem` (`ListItem_t`: +0 wake tick, +4 pxNext, +8 pxPrev, +12 pvOwner=TCB, +16 pxContainer) | high |
| +96 | 20 | `xEventListItem` (xItemValue init `31 - prio`) | high |
| +116 | 4 | `uxPriority` (clamped to ≤ 30 at create) | high |
| +120 | 4 | `pxStack` — malloc'd stack base | high |
| +124 | 4 | `uxTCBNumber` (serial from `0x1C09748`) | high |
| +132 | 4 | `uxBasePriority` (priority-inheritance restore) | med |
| +136 | 4 | PI budget/nesting (init 0; consumed by `__os_q_push 0x0205924E`) | med |
| +140 | 4 | flag word: 1 = task started (trampoline `0x0205C4D2`); also the delete-request flag (`os_task_del_req 0x0205C470`, `__os_timeout_check 0x02059B94`) | med |
| +144 | 2+2 | runtime accounting u16s (timestamp / accumulated, `os_sched 0x02058F26`) | med |
| +148 | 1 | u8 (0 at create) | med |
| +149 | 1 | u8 (0 at init) | med |

### 3.2 Task creation

**`os_task_create 0x0205B1D0`** `[high]` — the public create used everywhere.
This build's ABI differs from the stock SDK header (`os_task_create(task, arg,
prio, stksize, qsize, name)`); reconstructed from the body and the two observed
call sites (`board_init` at `0x02004570`, and `0x02004FF4`):

```
r0 = name        (NULL → auto-generates a name via _diprintf_r 0x020030F8
                  (format at 0x0205C6CC, counter at b[0x1C20B74]); if the name
                  is found in the static task-info table 0x0204DE74 the entry
                  supplies prio/stksize/qsize/static-TCB)
r1 = prio        (clamped ≤ 30; 0 → inherit current task's priority [med])
r2 = stksize     (in 32-bit WORDS — stack malloc is stksize*4 bytes;
                  0 → inherit current task's stack size from TCB+8 [med])
r3 = qsize       (task-queue depth; 0 = no queue)
[sp]   = arg / handle-out (stored at taskobj+72; if nonzero receives the task obj)
[sp+4] = task entry point
[sp+8] = reserved (0)
```

Behavior: `strlen(name) < 64` else -1; allocates one block via `mspace_malloc`
(`244 + stksize*4` bytes when qsize is 0; a larger size including the queue ring
when qsize > 0 — exact split `[low]`); the block holds the name (strcpy), the
TCB (156 B), the queue node and the stack; registers the task by
`__os_task_ready_insert 0x0205A1BA`; queue (if any) via `__os_q_create
0x02059AB2` (item size 4) + `__os_task_register 0x0205A440`. The task's first
run goes through the trampoline **`0x0205C4D2`** (all tasks share it; it drops
the create-time locks, sets `TCB+140 = 1`, and dispatches into the real entry)
`[med]`. Returns 0 ok / -1 fail.

Static-task-info node (table `0x0204DE74`, used by `clk_node_find 0x02001A74`
and `task_info_get_current 0x0205C618`): `{name+0, prio+4 (u8), stksize+6 (u16),
qsize+8 (u16), staticTCB+12}` — from the way `os_task_create` unpacks it `[med]`.
The raw table also shows the name `"flash_powerup_ok"` at `0x0204DE80` and
`(prio, hash16)` records `[low]`.

**`__os_task_tcb_init 0x0205A120`** `[high]` — fills the stack with `0xA5`
(`memset(pxStack, 0xA5, stksize*4)`), copies the name (≤ 64 B) to TCB+12, clamps
prio ≤ 30, sets TCB+116/132 = prio, TCB+96 = 31 − prio, links `pvOwner = TCB`
into both list items (TCB+88, TCB+108), zeroes TCB+112/136/140/148/149, builds
the **initial 76-byte frame** at the stack top:

```
frame+0  = task entry        (popped first: {r0} → moved to rets)
frame+4  = psr (0)
frame+8  = rets (0)
frame+12 = task argument     (r0 on first run)
frame+16..+72 = r1..r15      (left as 0xA5A5A5A5)
```

**`os_start 0x0205A6B6`** `[high]` — creates the per-cpu idle task
(`__os_task_create_alloc 0x0205A580`), on cpu0 sets `xNextTaskUnblockTime = -1`,
`xSchedulerRunning = 1`, `xTickCount = 0`, `uxSchedulerSuspended = 0`; registers
the context-switch SWI (`request_irq(0x7F - cnum, 0, 0x020419DA, cnum)`); on cpu0
also the OS tick IRQ3 (`0x0205BE92`, prio 1) and the tick-timer scale
(`[0x1EEF0F4] = clk/100`); then `lockset`, loads `pxCurrentTCB[cpu]->pxTopOfStack`
into `sp` and restores the first context exactly matching the frame above:

```
sp = [pxCurrentTCB[cnum]+0]
{r0}          = [sp++]        ; → rets (the task entry)
{psr, rets}   = [sp++]
rets = r0
{r15-r0}      = [sp++]
usp = sp
lockclr
rts                           ; into the trampoline 0x0205C4D2
```

**`os_task_del 0x0205B8D8`** `[high]` — `os_task_del(name)`: purges the task's
timers/events (walks the lists under the `0x1C0E670+50/51` lock bytes), waits
(with `__os_time_dly(1)`) until the victim is not `pxCurrentTCB`/`pxNextTCB` on
any core, `uxListRemove(TCB+76)` (clears the ready-bitmap bit if its ready list
empties), removes `xEventListItem` (TCB+96) if linked, then: self-delete → insert
into `xWaitingTerminationList 0x01C205C0` (+`uxDeletedTasksWaitingCleanUp`) and
`os_sched`; other-delete → `uxTaskNumber--`, `task_list_remove 0x0205B86E`,
`prvResetNextTaskUnblockTime`. Finally unregisters the task queue
(`__os_taskq_lookup 0x02059174`, unlink from `0x01C20B6C`, free node+72 via
`mspace_free`, `os_q_del 0x0205B89A`).

**`os_task_del_req 0x0205C470`** `[med]` — cooperative delete request: takes the
delete mutex `0x0205C5F0` region (`0x1C205F0`), sets `TCB+140 = 1` on the target,
spins on `os_time_dly(2)` until acknowledged.

**`os_task_get_handle 0x020590FC`** `[med]` — `find_tcb_by_name`: scans all 31
ready lists, both delayed lists, suspended list and termination list
(`find_tcb_by_name 0x02058BBE` compares 64 bytes at TCB+12). Returns TCB or 0.

**`xTaskGetCurrentTaskHandle 0x02058A66`** `[med]` — returns
`pxCurrentTCB[cnum]` under the standard critical section.

**`pcTaskGetName_current 0x02058B0C`** `[low]` — returns `pxCurrentTCB[cnum] + 12`
(asserts if none). Used by every assert path (166 call sites).

### 3.3 Task queues and messages

Each task may own a message queue (created when `qsize > 0`). Queue node layout
(registered in `0x01C20B6C`): `{+0/+4 list links, +8 owner TCB, +12 queue object}`.
`__os_taskq_lookup 0x02059174` maps TCB → `node+12` `[med]`.

**Message wire format** `[high]` (from `__os_taskq_post_type 0x02059580` and
`__os_taskq_pend 0x0205B520`):

```
word0      = (type << 8) | argc
word1..N   = argv[0..argc-1]        (argc ≤ 18, clamped)
```

- On receive, `__os_taskq_pend` stores `cmd = word0 >> 8` to `argv_out[0]` and
  the argv words after it.
- **Types** (the high bits of the type field): `0x100000` = `Q_MSG`
  (`os_taskq_post_msg 0x02059A68` — varargs collected then posted) `[high]`;
  `0x300000` = deferred-callback — `__os_taskq_pend` **calls argv[0] as a
  function** in the receiving task's context (with `r0 = argv[2]`, and
  post-completion semaphore signaling when bit 9 of the type field is set);
  this is how `sys_timer` callbacks execute `[high]`; `0x400000`/`0x400001` =
  system/IPC messages (`os_taskq_post_type_retry 0x0205E036`) `[med]`.

**`os_taskq_post_type 0x020596EC` → core `0x02059580`** `[med]`:
`(name, type, argc, argv)` — resolves the task (`os_task_get_handle`), its queue,
checks free slots (`[q+60] - [q+56] >= argc+1`), pushes header + argv via
`__os_q_put 0x020594D6`, wakes a blocked reader (`__os_waitlist_wake
0x020593AC`), reschedules if the woken task outranks the current one. Return
codes seen: 0 ok, 4 no queue, 14 no such task, 21 queue full.

**`__os_taskq_pend 0x0205B520`** `[med]` — `(argv_out, timeout_ticks)`: blocking
receive loop (`__os_q_pend 0x0205A922`, retry on spurious wakeup), pops the
header word and `argc` argv words (`taskq_msg_pop 0x0205B4E0`), dispatches
deferred-callback messages (type `0x300000`) inline, returns 13 (message
delivered) / 22 (timeout). `os_taskq_pend 0x0205B690` = `(argv, -1)` wait
forever.

**Retry wrappers** `[med]`: `os_taskq_post_type_retry 0x0205E036` posts
`(type 0x400001)` and `os_taskq_post_msg_retry 0x0205E110` posts
`(type = r0, argc ≤ 15)` to a fixed system task whose name is the **8-byte
binary tag at `0x020558E9`** (`FF×7, 03` — not ASCII; identity of the task
`[low]`); on queue-full (21) they `os_time_dly(2)` and retry unless called from
ISR/exception context (detected via `icfg`).

### 3.4 Blocking primitives

**Queue object** (built by `__os_q_create 0x02059AB2`, 76–80 bytes) `[high]`:

| Off | Field |
|---|---|
| +0 | ring base (or self-ptr for token queues) |
| +4 | ring end |
| +8 | write slot |
| +12 | read slot |
| +16 | wait-list 1 (readers), 20 B `List_t` |
| +36 | wait-list 2 (writers), 20 B |
| +56 | count |
| +60 | max (depth) |
| +64 | item size (4 for task queues, 0 for token queues) |
| +68/+69 | u8 wait markers (255 = none) |
| +70 | u8 flags |
| +76 | u8 tag (low byte of queue ptr) |

`__os_q_pend 0x0205A922` blocks on wait-list 1 with timeout and **priority
inheritance boost**; `__os_q_post 0x02059E76` blocks while the ring is full
(wait-list 2); `__os_q_get 0x0205A89A` / `__os_q_push 0x0205924E` move items in
and out of the ring; `os_q_pend 0x0205B19C` is the public wrapper (ISR check,
timeout remap: 0 ↔ -1 conventions, returns 0/3/11) `[med]`.

**Semaphore** `[med]`: `os_sem_create 0x0205A7C2` = depth-255 token queue;
`os_sem_post 0x0205A7E0` (ISR-safe inline path when `(icfg & 0xFF) != 0`, else
`__os_q_post`; wakes a waiter and `os_sched` if the woken task outranks);
`os_sem_pend` goes through `os_q_pend 0x0205B19C`.

**Mutex** `[high]`: `os_mutex_create 0x0205A09C` = depth-1 token queue + unlock
token posted. Object: `+0` queue core, `+4` owner TCB, `+12` nesting count.
`os_mutex_pend 0x0205AE98` (returns 0 ok / 3 OS-not-running / 11 error; nesting
increments on re-entry); `os_mutex_post 0x0205B036` (nesting--, releases at 0).
Both fatal-assert when called from exception context
(`(icfg & 0x300) == 0x300 && [0x1EEF1A8 + cpu*0x200] != 7`).

## 4. Lists and timers

### 4.1 List primitives

Intrusive doubly-linked lists; node = `{+0 next, +4 prev}`.

| Function | Address | Notes | Conf |
|---|---|---|---|
| `__list_add` | `0x02002154` | insert after given node | high |
| `list_add_after` | `0x020264B8` / `0x0203657A` / `0x02036D1E` | | high |
| `__list_del` | `0x02031AD0` | unlink between prev/next | high |
| `list_del_init` | `0x020264FC` / `0x020369D2` / `0x02036E68` | unlink + self-reinit | high |
| `list_insert_before` | `0x0203B39E` | | high |
| `list_unlink` | `0x0203B58E` | | high |
| `list_pop_head_locked` | `0x020369E0` | dequeue head under SMP critical | high |
| `list_add_locked` | `0x02036842` / `0x02073404` | insert head under SMP critical | high |
| `uxListRemove` (FreeRTOS) | `0x02058C0E` | scheduler list item | high |
| `vListInsertEnd` (FreeRTOS) | `0x02058C88` | | high |
| `__os_waitlist_init` | `0x02059AA0` | self-linked sentinel + count 0 | high |
| `__os_waitlist_insert` | `0x020596F8` | sorted by wake tick, -1 (forever) last | high |
| `__os_waitlist_wake` | `0x020593AC` | wake first waiter → ready or pending list | med |

### 4.2 Timer node (32 bytes) `[high]`

Static pool: 15 nodes × 32 B at `0x01C0E184` (`b[+31]` = in-use); overflow
allocates 32 B from the heap. Fields (from `sys_timer_add_internal 0x020021FC`,
`usr_timer_add_internal 0x020023F8`, and the scan tasks):

| Off | Field |
|---|---|
| +0/+4 | list links |
| +8 | callback `func` |
| +12 | `priv` argument |
| +16 | target task name (sys_timer; from caller, or current task, or a fallback when added from IRQ) |
| +20 | expiry time (ms, vs `os_tick_get_half`) |
| +24 | period in low 24 bits; bit 25 = periodic (sys) |
| +27 | flags (bit0 delete-pending, bit1 one-shot) |
| +28 | u16 unique id (counter at `h[0x1C0E670+104]`, skips 0, deduped) |
| +30/+31 | busy / pool-in-use bytes |

### 4.3 sys_timer vs usr_timer `[high for mechanism, med for signature detail]`

| | sys_timer | usr_timer |
|---|---|---|
| Public add | `sys_timer_add 0x02004036` `(priv, func, msec)` — tags the **current task** | `usr_timer_add 0x020023F8` core `(priv, func, msec, priority)` |
| Internal | `0x020021FC` (list `0x01C09000`) | same function family; inserts into per-priority tick lists `0x1C0EA50` (prio 0) / `0x1C0EA58` (prio 1) |
| Expiry engine | `sys_timer_scan_task 0x02031AF4` (task; sleeps in `os_q_pend` on the sem at `0x1C0E670+2036` with timeout = time-to-next-expiry) | `timer_tick_isr 0x020330B4` (ISR body at `0x02033142`) plus `usr_timer_scan_task 0x02031E70` |
| Callback context | **the registering task's context**, via a type-`0x300000` deferred-call message (argv = `{func, 1, priv}`) | **direct call**: `func(...)` in the timer task / tick ISR context (`r1 = [node+8]; call r1`) |
| Repeat | periodic unless one-shot bit; reschedule `expiry = os_tick_get_half() + period` | same |
| ID | u16 id for later cancel (`timer_modify_by_id 0x020350EE`) | same |

Cross-check with the BR23 SDK `timer.h`: `u16 sys_timer_add(void *priv, void
(*func)(void *priv), u32 msec)` and `u16 usr_timer_add(void *priv, void
(*func)(void *priv), u32 msec, u8 priority)` — argument order matches the
register usage in both add paths.

**`timer_tick_isr 0x020330B4`** (ISR entry `0x02033142`,
`shard_02030942_02033964.txt`): full register save; clears the timer IRQ at SFR
`0x10500` (`|= 0x4000`); lp-timer compensation at `0x1C0E670+452`; walks both
tick lists, runs expired callbacks **in ISR context**, reposts/deletes;
recomputes next expiry (`timer_next_expiry_get 0x020020DE`), rearms the hardware
(`0x020021CE`), and `os_sem_post`s the semaphore at `0x1C0E670+2036` to wake the
sys_timer task `[med]`.

**`timer_lib_init 0x02031DFE`** `[med]` — list heads (`0x1C09008`, `0x1C09010`),
pool link, and a 100 ms periodic timer that runs `lp_timer_calibrate 0x02031FA8`.

## 5. Memory management

### 5.1 Heap — dlmalloc mspace `[high]`

`mspace_malloc 0x0205672E` (4452 B) and `mspace_free 0x0205789A` are dlmalloc
(`dlmalloc`/`dlfree`) verbatim: smallbin map, treebins (the
`compute_tree_index` constant sequence `0xFFF00/0x7F000/0x3C000` at
`0x02056836`+), `top` handling, consolidation on free, and `CORRUPTION_ERROR`
traps as `goto -2` infinite loops. Public wrappers: `malloc 0x02057892`,
`free 0x02057F96` (both tail-call the mspace core), `zalloc 0x02036CDE` /
`zalloc_checked 0x02036D0A` (hangs on failure).

- The mspace state lives inside the big app-global block at `0x01C0E670`:
  smallbin map at `+0xB20`, bins at `+0x1C70`, treebins at `+0x1D78`, lock flags
  at `+0x1E04`/`+0x1E08` `[med]`.
- Locking: dlmalloc `USE_LOCK` path = the standard SMP critical section plus a
  "malloc busy" byte (`b[0x1C0E670+0x1E08]`) — safe from any core and from
  task context. **Do not call malloc/free from ISRs** (the lock path can block)
  `[med, from the lock structure]`.
- Chunk sizing: requests `< 27` → 32 B minimum; otherwise `align32(req + 35)`
  — the +35 hides per-chunk metadata/guard overhead `[med]`.

### 5.2 Fixed-block pools — mem_pool `[med]`

`mem_pool_init 0x02036586` (aligns the buffer, stores capacity at `h[pool+24]`,
self-links the free list), `mem_pool_alloc 0x0203675E` (first-fit with block
split; 16-byte block headers: links +0/+4, size `h[+8]`, tag `h[+12]`; returns
`block+16`), `mem_pool_free 0x02036906` (address-ordered reinsertion with
adjacent-block coalescing). `sys_pool_alloc 0x0203681C` allocates from the
default system pools at `0x01C0E670+560/+564`. All under the SMP critical
section — ISR-safe in principle but keep ISRs short.

### 5.3 Guard magics

`os_obj_init_register 0x02036478` writes **`0x98765431`** (materialized as
`0x87654320 + 0x11111111`) at `+0` and `+36` of its 40-byte guarded object, with
alignment recorded at `b[+21]`, id at `h[+22]`, size at `+24`; the mempool
acquire helpers (`mempool_block_acquire 0x0203B3B6`, `mempool_free_coalesce
0x0203B594`) validate those magics before returning a payload `[med]`.
dlmalloc's own corruption checks trap to `goto -2` loops (`0x020567FC` etc.) —
a hang here means heap corruption `[high]`.

### 5.4 cbuf

Lock-protected circular buffers for stream I/O: `cbuf_init 0x020007A8`,
`cbuf_write 0x020006AE`, `cbuf_read 0x02026374`, `cbuf_clear 0x020007C2`,
`cbuf_data_avail 0x0203A6CC`, `cbuf_commit_advance 0x0203A75C` — all wrapped in
the SMP critical section `[high]`.

## 6. SMP locking idioms (exact patterns)

Two counters, one hardware lock, one byte spinlock:

| Address | Meaning |
|---|---|
| `0x01C09534` | `cpu_lock_cnt[2]` — per-core nesting for the `lockset`/`lockclr` hardware mutex |
| `0x01C0953C` | `irq_lock_cnt[2]` — per-core `cli` nesting |
| `0x01C09544` | byte spinlock for `testset` |
| `0x01C20160` | spinlock debug/timeout state (`spin_lock_timeout 0x020309B4`) |

**Pattern A — kernel critical section** (seen verbatim in ~40 functions, e.g.
`vTaskSwitchContext 0x02058E6C`, `uxListRemove 0x02058C0E`,
`xTaskGetCurrentTaskHandle 0x02058A66`, `shard_02051c2a_02058e6c.txt`):

```
enter:                              exit:
  cli                                 csync
  r0 = cnum                           r0 = cnum
  r0 = r0 << 2                        r1 = [0x01C09534 + r0*4]
  r0 += 0x01C0953C                    r1 += -1
  [r0] += 1                           [0x01C09534 + r0*4] = r1
  csync                               if (r1 != 0) skip
  r0 = cnum                             lockclr
  r1 = [0x01C09534 + r0*4]            r0 = cnum
  r2 = r1 + 1                         r1 = [0x01C0953C + r0*4]
  [0x01C09534 + r0*4] = r2            r1 += -1
  if (r1 != 0) skip                   [0x01C0953C + r0*4] = r1
    lockset                           if (r1 != 0) skip
  csync                                 csync
                                        sti
```

`lockset`/`lockclr` are pi32v2 hardware inter-core mutex instructions; `csync`
is the pipeline/memory barrier. Reproduce this **exactly** — order (irq counter
first, hw lock second on entry; reverse on exit) and the `csync` placement are
what make the kernel's assumptions hold. If your code runs with the stock
kernel, prefer calling the same wrappers instead of open-coding.

**Pattern B — byte spinlock** (`spinlock_enter_critical 0x020856A0`, runs from
RAM at `0x01C00E80`; `spinlock_leave_critical 0x020856E2`):

```
  cli
  r0 = cnum << 2
  [0x01C0953C + r0] += 1
  csync
  csync
L: testset b[0x01C09544]
  ifeq goto L
  csync

leave: csync; b[0x01C09544] = 0; decrement irq_lock_cnt; if 0 → csync; sti
```

`cpu_critical_enter 0x02030942` / `cpu_critical_exit 0x02031A18` additionally
maintain the per-cpu debug flags at `0x1C20160`; `spin_lock_timeout 0x020309B4`
adds a timeout trap (returns -22 on expiry, records timestamps at
`0x1C20160+40/44`) `[med]`.

**ISR-context detection idiom** (used by `os_sem_post`, `os_q_pend`,
`sys_timer_add_internal`): `(icfg & 0xFF) != 0` → running in interrupt context.
Deeper: `(icfg & 0x300) == 0x300 && [0x1EEF1A8 + cnum*0x200] != 7` →
exception/fault context (assert trigger in mutex paths).

## 7. Device framework

Two layers exist in the image; both are used.

### 7.1 Registry + drivers `[med]`

`device_register 0x02028D8A` (`shard_02027346_02028fc6.txt`):

- Optionally opens a parent device first, then allocates a **160-byte device
  struct**, sets `[dev+12] = parent`, `b[dev+156] = 1`, refcount `[dev+72] = 1`,
  creates the device mutex at `dev+76` (`os_mutex_create 0x0205A09C`).
- Walks the **driver table `0x020836AC..0x0208388C`** (120-byte entries), matches
  the driver name (`strcmp 0x02042730`), calls the probe/init fn at `[entry+4]`
  with `(dev, priv)`. On success: `[dev+8] = driver entry`, `[dev+4] = name`,
  links the node at `dev+64` into the **device registry list `0x01C07E34`**
  (under testset byte `b[0x1C0E670+47]`).

`dev_open 0x020033C4` (`shard_02002154_02003b52.txt`): walks the registry list
matching names (`strlen`/`memcmp`), takes the device mutex at `dev+76`, grabs a
handle (8 static slots at `0x1C0E670+4084`, overflow `malloc(16)`), calls the
driver's **open** op, bumps `[dev+72]`, returns the handle (0 on failure).
`dev_close 0x020035F4`: refcount-- under the SMP critical section; at zero it
unlinks the node, calls the close op, frees the struct.
`dev_ioctl 0x020035E4`: dispatches `[ops+24]` (returns -22 `-EINVAL` when the op
is absent). There are also mutex-locked vtable wrappers `dev_read 0x020280E4`,
`dev_seek 0x02028136`, `dev_write 0x02028186`, `dev_ioctl 0x020281D8` `[low]`.

Ops vtable (cross-checked against BR23 SDK `device.h` `struct
device_operations`): `+0 online, +4 init, +8 open, +12 read, +16 write, +20
seek, +24 ioctl, +28 close` `[med]`.

### 7.2 Alternate open/close `[med]`

`dev_open 0x02028C7C` matches a wildcard-name table at `0x0208392C..0x02083944`
(12-byte entries `{name, dev, arg}` — the same table `main` runs as the module
init table), calls `[dev+8]` as open with `(dev, &handle, arg)`, refcount at
`[handle+0]`, ops pointer at `[handle+8]`. `dev_close 0x02028D1E`: refcount--,
calls `[ops+28]` (close) at zero.

## 8. syscfg key/value store `[high for mechanism]`

`syscfg_read 0x02002612` / `syscfg_write 0x020032B8`
(`shard_02002154_02003b52.txt`): walk an ops table `0x020838C8..0x0208391C`
(28-byte entries; match fn at `+4`, read fn at `+8`, write fn at `+12`; first
match wins). Table has 3 entries in this image.

Known IDs:

| ID | Meaning | Where |
|---|---|---|
| 102 | **BT MAC** (6 B) | special-cased inside `syscfg_read`: validated + returned from hwinfo `0x01C7FD50+32` with crc16 over the 6 bytes at `+38` (hardware CRC `chip_crc16 0x020025DA`, byte-reversed compare) — never hits the ops table `[high]` |

`boot_record_load 0x020053DE` also reads a 78-byte record at `0x01C7FD88`
(crc16-checked) into `[0x1C0E670+140]` during boot `[low]`.

## 9. Recovered RTOS ABI and service entry points

**ABI** (pi32v2, JieLi toolchain):

- Args in `r0..r3`, then on the stack at `[sp+0]`, `[sp+4]`, … (the callee's
  prologue pushes callee-saved regs, so it reads them at a fixed positive
  offset from its own `sp`).
- Return value in `r0`.
- Callee-saved: `r4..r15` (functions push what they use, e.g.
  `[--sp] = {rets, r10-r4}`); `rets` = link register.
- 64-bit values in adjacent register pairs (`r3_r2`), `d[addr]` double
  load/store.
- Beware the vendor objdump's fused listings: lines ending in `#` are one
  parallel-issue pair — the second slot reads the **old** register values.

The following service addresses and signatures are recovered from the stock
image:

| Service | Address | Signature |
|---|---|---|
| task create | `0x0205B1D0` | `(name, prio, stksize_words, qsize, arg, entry, reserved)` — see §3.2 |
| task delete | `0x0205B8D8` | `os_task_del(name)` |
| current task | `0x02058A66` | `() -> TCB` |
| delay (ticks) | `0x02059A62` | `os_time_dly(ticks)` |
| delay (ms) | `0x0205B7E2` | `os_time_dly_ms(ms)` |
| 64-bit tick | `0x02059B74` | `os_time_get(u64 *out)` |
| ms timebase | `0x0205C610` | `os_tick_get_half()` |
| sem create/post | `0x0205A7C2` / `0x0205A7E0` | `(sem)` — object is a queue struct |
| mutex create | `0x0205A09C` | `os_mutex_create(mutex)` |
| mutex pend/post | `0x0205AE98` / `0x0205B036` | `(mutex)`; pend returns 0/3/11 |
| taskq post | `0x020596EC` | `os_taskq_post_type(name, type, argc, argv)` |
| taskq post (Q_MSG) | `0x02059A68` | `os_taskq_post_msg(name, argc, ...)` |
| taskq pend | `0x0205B690` | `(argv_out)` wait forever → 13 msg / 22 timeout |
| sys timer | `0x02004036` | `sys_timer_add(priv, func, msec)` → u16 id |
| usr timer | `0x020023F8` | `usr_timer_add(priv, func, msec, prio)` → id |
| heap | `0x02057892` / `0x02057F96` | `malloc` / `free` |
| pool alloc/free | `0x0203675E` / `0x02036906` | `(pool, size)` / `(ptr)` |
| IRQ register | `0x020016D2` | `request_irq(index, prio, handler, cpu)` |
| IRQ master off/on | `0x0200167E` / `0x0200168A` | `icfg` bit 8 |
| device open/close/ioctl | `0x020033C4` / `0x020035F4` / `0x020035E4` | `(name, arg)` / `(handle)` / `(handle, cmd, arg)` |
| syscfg read/write | `0x02002612` / `0x020032B8` | `(id, buf, len)` |

Observed constraints:

1. Blocking APIs check `(icfg & 0xFF)` in interrupt context and either return
   status 3 or assert. `os_sem_post 0x0205A7E0` contains a separate ISR path.
2. Shared-state helpers use the Pattern-A critical section (§6) or locked
   primitives such as `atomic_inc_locked 0x02037438`,
   `atomic_refcount_inc 0x0203C8B2`, `atomic_refcount_dec 0x0203CCB2`,
   `list_add_locked 0x02036842`, and `list_pop_head_locked 0x020369E0`.
3. Task priorities span 0–30; 31 is clamped. Stack size is expressed in words,
   and trampoline `0x0205C4D2` constructs the standard frame described in §3.2
   before calling the entry point with its argument in `r0`.
4. The ready bitmap has 31 usable bits. Task names are unique, shorter than 64
   bytes, and used as lookup keys by `os_task_get_handle 0x020590FC`.
5. The common interrupt entry at `0x020000B0` saves full context before calling
   `irq_c_dispatch 0x020002A2`; handlers registered through `request_irq` are
   invoked from that dispatch path.

## 10. Quick map of the kernel image

| Range | Content |
|---|---|
| `0x02058A64`–`0x0205900B` | scheduler core (tick, switch, suspend/resume) |
| `0x0205900C`–`0x02059B93` | wait lists, queues, blocking, time |
| `0x02059B94`–`0x0205A6B5` | timeout check, queue internals, mutex/sem create, task create, os_start |
| `0x0205A6B6`–`0x0205B1D0` | os_start, sem, q pend/post public, task create public |
| `0x0205B1D0`–`0x0205C617` | task create/del, taskq pend/post, idle, tick update, task-info |
| `0x0205C618`–`0x0205DF56` | task-info, chip bring-up (`chip_hw_init 0x0205CC6E`), IPC |
| `0x0205E036`–`0x0205E1CF` | retry wrappers (system-task post) |
| `0x02030942`–`0x02033964` | critical sections, spinlocks, timer scan tasks, tick ISR |
| `0x0203645C`–`0x02037438` | pools, object registry, list helpers, atomics |
| `0x0205672E`–`0x0205789A` | dlmalloc mspace |
| `0x020021FC`–`0x02004036` | timer adds, syscfg, dev framework, sys_timer_add |
