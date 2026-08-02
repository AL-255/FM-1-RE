# FM-1 function index (2062 functions)

Generated from the full-disassembly classification pipeline (analysis). `callers` = static call sites in the image.

| subsystem | functions |
|---|---|
| SYS | 42 |
| RTOS | 224 |
| PERIPH | 55 |
| INPUT | 3 |
| UI_MENU | 165 |
| UI_DISPLAY | 91 |
| MIDI | 28 |
| USB | 74 |
| SYNTH_FM | 20 |
| FX | 9 |
| AUDIO_OUT | 137 |
| STORAGE_FS | 215 |
| STORAGE_PATCH | 3 |
| BT | 719 |
| POWER | 21 |
| SECURITY | 70 |
| MEMLIB | 103 |
| MATHLIB | 46 |
| APP | 26 |
| UNKNOWN | 11 |

## SYS (42)

| addr | name | conf | callers | purpose |
|---|---|---|---|---|
| `0x020000c4` | nullsub_1 | low | 0 | empty stub, returns immediately |
| `0x020000c6` | boot_hwinfo_save | high | 0 | copy boot parameter struct into hwinfo globals |
| `0x020000f8` | pll_clock_init | high | 0 | program PLL SFRs and switch system clock tree |
| `0x02000292` | fatal_assert_halt | high | 0 | signal fault via ROM then hang forever |
| `0x02000848` | rom_api_f94_128 | low | 0 | wrapper: invoke ROM service 0xC00F94 with id 128 |
| `0x02001758` | cpu_link_irq_init | med | 0 | register core IRQs, program per-core control SFRs and buffers |
| `0x02001970` | rom_api_f2e_128 | low | 0 | wrapper: invoke ROM service 0xC00F2E with id 128 |
| `0x0200197e` | clk_get | high | 0 | get clock frequency by name via string table |
| `0x02001a74` | clk_node_find | med | 0 | find clock/device node by name in table |
| `0x02001ab0` | clock_board_init | high | 0 | PLL and clock-tree init from fuses; clk_set front-end |
| `0x02001fa8` | lp_timer_calibrate | med | 0 | compute tick divisors, program P33 via SPI |
| `0x02002160` | sfr10500_trim_calibrate | low | 0 | calibration sweep programming SFR block 0x10500 registers |
| `0x020021ce` | sfr10500_calib_init | low | 0 | enable SFR block 0x10500 then trigger calibration sweep |
| `0x02002612` | syscfg_read | high | 0 | dispatch config item read via registered ops table |
| `0x020032b8` | syscfg_write | high | 0 | dispatch config item write via registered ops table |
| `0x0200417e` | board_init | med | 0 | board init: keys, spi display, irqs, audio server, table |
| `0x0200457a` | main | med | 0 | system init, run initcalls, create tasks, device msg loop |
| `0x020053de` | boot_record_load | low | 0 | checksum 78-byte boot record, store 32-bit field |
| `0x02026f62` | hang_detect_kick | low | 0 | notify handler 13 when monotonic counter advanced |
| `0x02026f84` | maskrom_call_stub | low | 0 | stub calling mask-ROM entry 0xFFC00476 |
| `0x02027020` | hang_detect_reset | low | 0 | reset watchdog counter pair, notify if stuck |
| `0x020280e4` | dev_read | low | 0 | mutex-locked device vtable read op, len times unit |
| `0x02028136` | dev_seek | low | 0 | mutex-locked device vtable seek op (offset, origin) |
| `0x02028186` | dev_write | low | 0 | mutex-locked device vtable write op, len times unit |
| `0x020281d8` | dev_ioctl | low | 0 | mutex-locked device vtable ioctl op, single argument |
| `0x02028c7c` | dev_open | med | 0 | open device by wildcard name, refcount++ under smp spinlock |
| `0x02028d1e` | dev_close | med | 0 | device refcount-- under spinlock, call close at zero |
| `0x02028d8a` | device_register | med | 0 | alloc device, match driver table, init, link registry list |
| `0x020335f4` | clk_div_ramp_update | low | 0 | ramp 5-bit divider fields in clock SFR |
| `0x020351a8` | chip_id_read_bytes | low | 0 | read bytes from chip ID/efuse SFR block |
| `0x0203661e` | device_register_named | med | 0 | dedupe by name-hash, append node to device list |
| `0x02036f1a` | device_list_poll | low | 0 | call flagged node handlers, compute minimum level |
| `0x02036f66` | device_list_poll_thunk | low | 0 | tail call into device list poll |
| `0x02058a64` | system_init_stub | med | 0 | empty system init stub, single rts |
| `0x0205a0c8` | cpu1_boot_start | med | 0 | release secondary core at 0x20001B8, await ack flag |
| `0x0205cc6e` | chip_hw_init | med | 0 | one-time chip bring-up: xtal detect, RF/baseband, MAC, audio analog trims |
| `0x020848a6` | cache_flushinv_range_call | med | 0 | trampoline into dcache flush-invalidate range routine |
| `0x0208547c` | dcache_flushinv_range | high | 0 | flush+invalidate dcache over address range, 32B lines |
| `0x020854ae` | cache_config_init | med | 0 | flush cache tags, way-lock masks, region enable |
| `0x02089702` | clock_freq_set | med | 0 | PMU writes; recompute PLL/clock dividers, safe switch |
| `0x02089884` | clock_switch_commit | med | 0 | finalize clock source switch, cache-sync, settle delay |
| `0x020898f4` | clock_switch_start | med | 0 | initiate clock source switch with cache sync |

## RTOS (224)

| addr | name | conf | callers | purpose |
|---|---|---|---|---|
| `0x020002a2` | irq_c_dispatch | high | 0 | scan pending IRQ bits, dispatch handlers, wake tasks |
| `0x020004ce` | tick_irq_disable | med | 0 | clear tick-timer IRQ enable bit for current core |
| `0x020006ae` | cbuf_write | high | 0 | spinlocked circular buffer write with wraparound memmove |
| `0x020007a8` | cbuf_init | high | 0 | initialize circular buffer pointers and length |
| `0x020007c2` | cbuf_clear | high | 0 | reset circular buffer under per-core spinlock |
| `0x0200083a` | tick_count_x10_get | med | 0 | return global tick counter scaled by ten |
| `0x0200167e` | irq_master_disable | high | 0 | clear icfg interrupt-enable bit |
| `0x0200168a` | irq_master_enable | high | 0 | set icfg interrupt-enable bit |
| `0x02001696` | irq_mask_arrays_clear | high | 0 | zero per-core interrupt enable arrays |
| `0x020016d2` | request_irq | high | 0 | install IRQ handler with priority and CPU routing |
| `0x02001a60` | irq2_ram_handler_install | med | 0 | register IRQ2 with RAM-resident handler |
| `0x020020de` | timer_next_expiry_get | high | 0 | walk timer lists, return minimum ticks to expiry |
| `0x02002154` | __list_add | high | 0 | insert node into doubly-linked list after given node |
| `0x020021fc` | sys_timer_add_internal | med | 0 | allocate systimer entry, assign unique id, queue to task |
| `0x020023f8` | usr_timer_add_internal | med | 0 | queue hw-timer entry into per-priority expiry-sorted list |
| `0x020031f6` | free_handle_push | med | 0 | push handle object onto free-list head |
| `0x02003210` | module_state_alloc | low | 0 | malloc 292-byte module state, clear 256-byte buffer |
| `0x020033a2` | dev_handle_free | med | 0 | free 16-byte handle from static pool or heap |
| `0x020033c4` | dev_open | med | 0 | find device by name, alloc handle, invoke open op |
| `0x020035d0` | dev_call_op_104 | low | 0 | invoke optional device operation slot 104 if present |
| `0x020035e4` | dev_ioctl | med | 0 | dispatch device ops ioctl, -EINVAL if absent |
| `0x020035f4` | dev_close | med | 0 | drop device refcount, unlink destruct free at zero |
| `0x02003712` | os_counter_diff | low | 0 | compute offset between two kernel counter words |
| `0x02004036` | sys_timer_add | med | 0 | register periodic system timer callback with priv |
| `0x0200e1c8` | tick_ms_elapsed | low | 0 | return current tick minus argument, elapsed time |
| `0x0201e9a4` | os_event_wakeup_by_id | med | 0 | SMP-safe event flag set: walk waiter list, signal, yield |
| `0x0201eb20` | os_event_wakeup | med | 0 | thin wrapper invoking event wakeup 0x0201e9a4 |
| `0x0201ec5e` | os_msg_args_pack | med | 0 | pack varargs into message buffer per format codes |
| `0x0201ede0` | os_msg_fmt_parse | med | 0 | parse message format string into descriptor, pack args |
| `0x0201f07e` | os_taskq_post_msg | med | 0 | alloc message, pack args by format, post to task |
| `0x0201f11c` | sys_timer_add_wrapper | med | 0 | register periodic callback timer, min 3ms period |
| `0x02021444` | deferred_call_schedule | med | 0 | allocate and schedule 50ms deferred callback item |
| `0x02026374` | cbuf_read | med | 0 | circular buffer read with wrap and dual-core lock |
| `0x02026478` | irq_unregister | med | 1 | clear RAM vector slot and ICFG nibble fields |
| `0x020264b8` | list_add_after | high | 0 | doubly-linked list insert after node |
| `0x020264c4` | mempool_chunks_init | med | 0 | split buffer into fixed chunks, link free list |
| `0x020264fc` | list_del_init | high | 0 | unlink node and self-reinitialize its links |
| `0x0202650a` | list_move_locked | med | 0 | move node between lists under dual-core spinlock |
| `0x0202681e` | list_link_pair | med | 0 | link two list nodes together |
| `0x02026870` | list_is_empty | med | 0 | return 1 if global list head self-linked |
| `0x02026886` | list_del_init2 | med | 0 | unlink node and self-reinitialize its links |
| `0x02026894` | list_add_global | med | 0 | push node onto global list at 0x1C08FF0 |
| `0x020268a8` | list_op_locked_stub | low | 0 | spinlocked list op on r0+176 via helper |
| `0x0202799e` | task_create_thunk | low | 0 | thunk to large task-create os primitive |
| `0x020308ea` | os_module_prepare_poll | low | 0 | poll module callback list, min result, zero vetoes |
| `0x0203091c` | os_module_ready_vote | low | 0 | AND results of registered function-table callbacks |
| `0x02030942` | cpu_critical_enter | med | 0 | cli, bump nesting counters, hw lockset, mark per-cpu flags |
| `0x020309b4` | spin_lock_timeout | med | 0 | acquire hw spinlock, assert/panic on timeout |
| `0x02031a18` | cpu_critical_exit | med | 0 | clear per-cpu flags, hw lockclr, sti |
| `0x02031a8a` | spin_unlock | med | 0 | release hw spinlock, timestamp the release |
| `0x02031ad0` | __list_del | high | 0 | unlink list node between prev and next |
| `0x02031ad6` | timer_node_clear | med | 0 | clear flag byte of node in static pool |
| `0x02031af4` | sys_timer_scan_task | med | 0 | expire sys timers, post messages to task queues |
| `0x02031dfe` | timer_lib_init | med | 0 | init timer lists and pool, arm 100ms scan timer |
| `0x02031e70` | usr_timer_scan_task | med | 0 | run usr_timer callbacks, repost or delete expired nodes |
| `0x020330b4` | timer_tick_isr | med | 0 | ISR expiring both timer lists, running callbacks |
| `0x02033a8c` | taskq_post_msg | med | 0 | post typed message into task queue ring buffer |
| `0x02035036` | taskq_post_u8 | low | 0 | post byte payload message type 16 to task queue |
| `0x02035044` | os_queue_drain_locked | low | 0 | wait writer idle then verify lists empty under lock |
| `0x020350e8` | list_link_pair | low | 0 | cross-link two doubly-linked list nodes |
| `0x020350ee` | timer_modify_by_id | med | 0 | find timer by id in list, update expiry |
| `0x020351ba` | list_insert_after | med | 0 | insert node after given doubly-linked list node |
| `0x02036478` | os_obj_init_register | med | 0 | init 40B object with magic guards, link into registry |
| `0x020364e0` | os_msg_alloc_enqueue | med | 0 | alloc 20B node, enqueue onto locked system queue |
| `0x0203657a` | list_add_after | high | 0 | insert node after given list element |
| `0x02036586` | mem_pool_init | med | 0 | init pool free-list with single aligned block |
| `0x02036758` | list_del_pair | high | 0 | unlink node by stitching prev/next pointers |
| `0x0203675e` | mem_pool_alloc | med | 0 | first-fit pool allocation with block splitting |
| `0x0203681c` | sys_pool_alloc | med | 0 | allocate from default system pool descriptor |
| `0x02036842` | list_add_locked | high | 0 | insert node at list head inside critical section |
| `0x020368a8` | atomic_store_locked | med | 0 | store pointer word inside critical section |
| `0x02036906` | mem_pool_free | med | 0 | return block to pool, coalesce adjacent free blocks |
| `0x020369cc` | mem_pool_free_thunk | med | 0 | tail-call wrapper into pool free |
| `0x020369d2` | list_del_init | high | 0 | unlink node and reinit its links to self |
| `0x020369e0` | list_pop_head_locked | high | 0 | dequeue head node under lock, null if empty |
| `0x02036bee` | event_post_by_id_thunk | low | 0 | dispatch event to listener by 16-bit id |
| `0x02036bf8` | obj_ref_inc_link | med | 0 | increment refcount, link node on 0-to-1 transition |
| `0x02036c68` | obj_ref_inc_notify | low | 0 | saturating refcount inc, clear flag, invoke callback |
| `0x02036cde` | zalloc | med | 0 | system malloc followed by memset zero |
| `0x02036d0a` | zalloc_checked | med | 0 | zalloc, hang in panic loop on failure |
| `0x02036d1e` | list_add_after_b | high | 0 | insert node after given list element |
| `0x02036d2a` | event_post_wrap0 | low | 0 | wrapper posting id-0 event via framework dispatcher |
| `0x02036d36` | event_listener_set_data | med | 0 | find listener by 16-bit id, set private field |
| `0x02036dc4` | msg_node_remove_free | med | 0 | unlink node under lock, notify, then free it |
| `0x02036e3e` | list_unlink_free_all | med | 0 | unlink and pool-free every node of list |
| `0x02036e58` | heap_free_thunk | low | 0 | tail call into main free implementation |
| `0x02036e62` | heap_free_thunk2 | low | 0 | second-level tail call into free |
| `0x02036e68` | list_del_init_b | high | 0 | unlink node and reinit its links to self |
| `0x02036e76` | list_del_init_c | high | 0 | unlink node and reinit its links to self |
| `0x02036e84` | list_del_notify_empty | med | 0 | unlink node, call list callback if list emptied |
| `0x02036eaa` | list_free_all_locked | med | 0 | pool-free each node's buffer under critical section |
| `0x02037438` | atomic_inc_locked | high | 0 | increment word at arg inside critical section |
| `0x02037498` | atomic_dec_update_locked | med | 0 | hw-spinlocked refcount decrement and byte-field update helper |
| `0x0203756e` | atomic_or_flags_locked | med | 0 | spinlocked OR of bit 0x8 into object flags |
| `0x02038636` | atomic_inc_return_locked | med | 0 | spinlock-protected object refcount increment |
| `0x0203a6cc` | cbuf_data_avail | high | 0 | irq-safe circular-buffer read pointer and available bytes query |
| `0x0203a75c` | cbuf_commit_advance | high | 0 | irq-safe advance of circular-buffer read/write pointers |
| `0x0203b39e` | list_insert_before | high | 0 | doubly-linked list insert-before helper |
| `0x0203b3aa` | list_insert_before_dup | high | 0 | doubly-linked list insert-before helper, duplicate |
| `0x0203b3b6` | mempool_block_acquire | med | 0 | find guarded pool block by tag bit, validate magics, return payload |
| `0x0203b4a2` | mempool_block_acquire2 | med | 0 | pool block lookup variant returning payload at +28 |
| `0x0203b58e` | list_unlink | high | 0 | link prev and next nodes around removed list entry |
| `0x0203b594` | mempool_free_coalesce | med | 0 | pool free with guard-magic check, refcount, adjacent-block coalescing |
| `0x0203c8b2` | atomic_refcount_inc | high | 0 | interrupt-safe atomic refcount increment under per-CPU spinlock |
| `0x0203ccb2` | atomic_refcount_dec | high | 0 | interrupt-safe atomic refcount decrement-and-test under spinlock |
| `0x0203ee9e` | audio_open_watchdog_arm | low | 0 | arm delayed open-timeout callback with remaining ticks |
| `0x02058a66` | xTaskGetCurrentTaskHandle | med | 0 | return pxCurrentTCB for this cpu inside critical |
| `0x02058ad0` | rtos_fatal_assert | med | 0 | fatal assert: cpu lock, rom reset call, hang |
| `0x02058b0c` | pcTaskGetName_current | low | 0 | current task name pointer (TCB+12), assert if none |
| `0x02058b82` | vTaskSuspendAll | med | 0 | lock scheduler, increment uxSchedulerSuspended |
| `0x02058bbe` | find_tcb_by_name | med | 0 | walk task list comparing 64-char task names |
| `0x02058c0e` | uxListRemove | high | 0 | unlink FreeRTOS list item, decrement item count |
| `0x02058c88` | vListInsertEnd | high | 0 | insert list item before pxIndex, set container |
| `0x02058c9e` | prvResetNextTaskUnblockTime | med | 0 | recompute xNextTaskUnblockTime from delayed list head |
| `0x02058cc2` | xTaskIncrementTick | high | 0 | tick++, overflow list swap, wake delayed, timeslice |
| `0x02058e6c` | vTaskSwitchContext | high | 0 | clz pick highest ready task, update current TCB |
| `0x02058f26` | os_sched | med | 0 | account task runtime, pend context-switch software IRQ |
| `0x0205900c` | __os_sched_process | med | 0 | move expired/woken tasks to ready, request dispatch |
| `0x020590fc` | os_task_get_handle | med | 0 | find task TCB by name across all task lists |
| `0x02059174` | __os_taskq_lookup | med | 0 | find task queue node by TCB handle |
| `0x02059212` | os_assert_failed | med | 0 | fatal assert: lock CPU, report, trap forever |
| `0x0205924e` | __os_q_push | med | 0 | push msg into queue ring, direct waiter handoff |
| `0x020593ac` | __os_waitlist_wake | med | 0 | wake top waiter from object wait list |
| `0x020594d6` | __os_q_put | med | 0 | enqueue one message, wake reader, flag resched |
| `0x02059580` | __os_taskq_post_type | med | 0 | post typed header and argv to named task queue |
| `0x020596ec` | os_taskq_post_type | low | 0 | public entry tail-calling taskq post_type core |
| `0x020596f8` | __os_waitlist_insert | high | 0 | sorted insert into doubly-linked wait list |
| `0x02059722` | __os_task_block | med | 0 | unready current task, queue on delay/wait list |
| `0x02059a44` | __os_time_dly | med | 0 | block current task for N ticks, then reschedule |
| `0x02059a62` | os_time_dly | low | 0 | public wrapper for tick delay |
| `0x02059a68` | os_taskq_post_msg | med | 0 | collect varargs, post Q_MSG message to task queue |
| `0x02059aa0` | __os_waitlist_init | high | 0 | init wait list head: self-linked sentinel, count zero |
| `0x02059ab2` | __os_q_create | med | 0 | init queue object: ring buffer plus two wait lists |
| `0x02059b74` | os_time_get | med | 0 | read 64-bit global tick into caller buffer |
| `0x02059b94` | __os_timeout_check | med | 0 | check delete-request flag and tick timeout expiry |
| `0x02059cfa` | __os_pend_block | med | 0 | queue current task on wait list, then block |
| `0x02059d7e` | __os_obj_wakeup_all | med | 0 | wake all waiters on object's two wait lists |
| `0x02059e76` | __os_q_post | med | 0 | queue send, blocking while ring full |
| `0x0205a09c` | os_mutex_create | med | 0 | create mutex as depth-1 queue, post unlock token |
| `0x0205a10a` | os_init | low | 0 | init task registry list, set OS-running flag |
| `0x0205a120` | __os_task_tcb_init | high | 1 | fill stack 0xA5, copy name, build initial frame |
| `0x0205a1ba` | __os_task_ready_insert | med | 0 | insert task into ready table by priority, SMP-aware |
| `0x0205a3f0` | __os_task_create_static | med | 0 | init and ready task in caller-provided TCB |
| `0x0205a440` | __os_task_register | med | 0 | link task queue node into global registry list |
| `0x0205a4ac` | os_task_create_static | low | 0 | static task create with embedded task queue |
| `0x0205a580` | __os_task_create_alloc | med | 0 | alloc TCB and stack, tcb init, make ready |
| `0x0205a5de` | os_task_create | med | 0 | public create: task plus queue, register node |
| `0x0205a6b6` | os_start | high | 0 | create idle tasks, restore first context, dispatch |
| `0x0205a7c2` | os_sem_create | med | 0 | create counting semaphore as depth-255 queue |
| `0x0205a7e0` | os_sem_post | med | 0 | post semaphore, inline path when in ISR |
| `0x0205a89a` | __os_q_get | med | 0 | advance queue read slot, copy message out |
| `0x0205a8be` | __os_q_is_empty | med | 0 | return whether queue used count is zero |
| `0x0205a922` | __os_q_pend | med | 0 | blocking queue receive with timeout, prio boost |
| `0x0205ae98` | os_mutex_pend | med | 0 | lock mutex: block unless owner, nest count++ |
| `0x0205b036` | os_mutex_post | med | 0 | unlock mutex: nest--, release token at zero |
| `0x0205b19c` | os_q_pend | med | 0 | queue pend wrapper: ISR check, timeout remap, error codes |
| `0x0205b1d0` | os_task_create | high | 0 | create task: check name, inherit prio, alloc TCB+stack+queue |
| `0x0205b47a` | taskq_msg_count | med | 0 | return task queue pending message count under lock |
| `0x0205b4e0` | taskq_msg_pop | med | 0 | pop one word from task queue ring, wake posters |
| `0x0205b520` | __os_taskq_pend | med | 0 | blocking receive loop, dispatch deferred-callback messages |
| `0x0205b690` | os_taskq_pend | low | 0 | receive task queue message, wait forever |
| `0x0205b69e` | os_taskq_del_type | med | 0 | purge messages of given type from task queue |
| `0x0205b7da` | os_taskq_flush | low | 0 | flush current task queue, wrapper over type purge |
| `0x0205b7e2` | os_time_dly_ms | med | 1 | sleep milliseconds: round to 10ms ticks, minimum one |
| `0x0205b806` | taskq_count_clear | low | 0 | reset queue pending count under scheduler lock |
| `0x0205b86e` | task_list_remove | low | 0 | unlink task from wait or ready list by task state |
| `0x0205b89a` | os_q_del | low | 0 | delete queue object: unregister from table, unlink, clear |
| `0x0205b8d8` | os_task_del | high | 0 | delete task by name: free TCB and queue, wake waiters |
| `0x0205bd9e` | task_switch_trigger | med | 0 | per-CPU context switch: swap current TCB, trigger SWI |
| `0x0205be12` | os_idle_task | med | 0 | idle loop: wfi, tickless sleep timing, low-power entry |
| `0x0205c412` | os_task_count_query | low | 0 | return scheduler task/idle counter state code |
| `0x0205c448` | sched_stat_add | low | 0 | add value to scheduler time accumulator |
| `0x0205c454` | taskq_recv_block | low | 0 | receive task queue message, wait forever |
| `0x0205c45e` | taskq_obj_del_wrap | low | 0 | call queue/object delete helper |
| `0x0205c466` | taskq_recv_try | low | 0 | receive task queue message, non-blocking |
| `0x0205c470` | os_task_del_req | low | 0 | request task deletion: set TCB flag, await resource release |
| `0x0205c584` | taskq_obj_del_wrap2 | low | 0 | queue/object delete wrapper, trailing bytes misdecoded |
| `0x0205c5b8` | os_tick_update | low | 0 | update OS tick from hardware timer, accumulate remainder |
| `0x0205c610` | os_tick_get_half | low | 0 | return tick counter divided by two |
| `0x0205c618` | task_info_get_current | low | 0 | find static task info entry for current task name |
| `0x0205decc` | ipc_handler_register | low | 0 | store callback, register handler on cross-core channel |
| `0x0205def2` | ipc_call_sync | low | 0 | post cross-core request with 80-byte payload, wait response |
| `0x0205df56` | ipc_cmd_send | low | 0 | build argv, wait peer core ready, post cross-core command |
| `0x0205e036` | os_taskq_post_type_retry | med | 0 | post msg 0x400001 with args to fixed taskq, retry while full |
| `0x0205e110` | os_taskq_post_msg_retry | med | 0 | post caller msg id to taskq, max 15 args, retry on full |
| `0x02061cf6` | flag_test_and_set | low | 0 | atomically set bit0 of node field, return previous |
| `0x02061e84` | node_list_free | low | 0 | free linked list at struct offset 332, null it |
| `0x02061f92` | msg_node_enqueue | low | 0 | alloc 16-byte node and append to queue in critical section |
| `0x0206a8be` | ui_tick_irq_reschedule | med | 0 | free irq slot, reschedule frame timer via 69.12MHz ticks |
| `0x0206b4b8` | ticks27_within_1s | med | 0 | 27-bit tick delta, test under one second (69120000) |
| `0x0206bf60` | os_objpool_active_count | med | 0 | count entries with nonnull pointer in 2-slot object pool |
| `0x0206bf8a` | svc_request_cmd_0xc1a | med | 0 | marshal 2 args, dispatch service request cmd 0xC1A |
| `0x0206bfa2` | os_obj_find_by_tag | med | 0 | resolve handle else scan 2-slot pool by tag byte |
| `0x0206bff8` | svc_request_cmd_0x42a | med | 0 | marshal 3 args, dispatch service request cmd 0x42A |
| `0x0206c016` | svc_request_cmd_0x408 | med | 0 | marshal 1 arg, dispatch service request cmd 0x408 |
| `0x0206c028` | svc_request_cmd_0x428 | med | 0 | dispatch request cmd 0x428 with fixed magic args |
| `0x0206c064` | svc_request_cmd_0x40a | med | 0 | pack three big-endian u32 args, request cmd 0x40A |
| `0x0206c0ac` | svc_request_cmd_0x40c | med | 0 | dispatch no-arg service request cmd 0x40C |
| `0x0206c0bc` | svc_request_cmd_0x40d | med | 0 | marshal 16-byte buffer as 4 words, cmd 0x40D |
| `0x0206c10a` | os_obj_field_set_locked | med | 0 | resolve object, store halfword field under spinlock critical section |
| `0x0206c18a` | os_obj_msg_post | med | 0 | post message to object, walk node list flagging matches |
| `0x0206c2fa` | svc_request_cmd_0x804 | med | 0 | dispatch no-arg service request cmd 0x804 |
| `0x0206c30a` | svc_request_cmd_0x802 | med | 0 | marshal 3 args, dispatch service request cmd 0x802 |
| `0x0206c32c` | os_obj_deactivate_locked | med | 0 | clear object active flag and unlink under critical section |
| `0x0206c404` | svc_request_cmd_0xcfe | med | 0 | marshal u16/u32 struct fields, request cmd 0xCFE |
| `0x0206c43c` | svc_request_cmd_0xcfc | med | 0 | resolve handle then dispatch request cmd 0xCFC |
| `0x0206c45c` | svc_request_cmd_0xcfa | med | 0 | resolve handle then dispatch request cmd 0xCFA |
| `0x0206c47c` | svc_request_cmd_0x401 | med | 0 | dispatch request cmd 0x401 with token 0x9E8B32 |
| `0x0206c4a4` | obj_request_cmd_0xc60 | med | 0 | request cmd 0xC60 on RAM object 0x1c0caa8 |
| `0x0206c4bc` | obj_request_cmd_0x42e | med | 0 | request cmd 0x42E on RAM object 0x1c0caa8 |
| `0x0206c500` | svc_request_cmd_0xc3e | low | 0 | marshal 10-byte struct fields, request cmd 0xC3E; trailing table data |
| `0x0206d816` | obj_flagfield_set | low | 0 | masked bitfield update of object halfword at +32 |
| `0x0206d838` | obj_index_pair_set | low | 0 | write packed flag/index fields into object halfwords +32/+34 |
| `0x020732b2` | list_first_entry_or_null | med | 0 | return first intrusive-list node container or NULL |
| `0x020732c4` | lbuf_block_split | med | 0 | split free lbuf block, magic sentinels and alignment rounding |
| `0x02073404` | list_add_locked | med | 0 | insert node into doubly-linked list under per-core spinlock |
| `0x0207346c` | node_unlink_free | low | 0 | remove node from list and release to allocator |
| `0x020734a8` | node_unlink_free_clone | low | 0 | remove node from list and release to allocator (clone) |
| `0x020856a0` | spinlock_enter_critical | high | 0 | cli, per-core nesting count, testset spinlock acquire |
| `0x020856e2` | spinlock_leave_critical | high | 0 | release spinlock, decrement nesting, sti |
| `0x02086bc0` | cpu_other_stall | low | 0 | signal other core to stall, wait handshake bit |
| `0x02086be4` | cpu_ipc_call_sync | med | 0 | post fn+arg mailbox to other core, doorbell, wait |
| `0x02086cb8` | cpu_other_resume | low | 0 | release other core from stall handshake |
| `0x02086cd0` | cpu_ipc_call_done | med | 0 | complete cross-core call, unlock; poweroff-halt tail |

## PERIPH (55)

| addr | name | conf | callers | purpose |
|---|---|---|---|---|
| `0x020004e2` | saradc_osa_irq_handlers | med | 0 | tick IRQ enable; OSA and SARADC interrupt handlers |
| `0x02001958` | percpu_buf_ptr_get | low | 0 | return per-core buffer/state pointer |
| `0x02001f5a` | timer1_init | high | 1 | init TIMER1 SFR and register its IRQ handler |
| `0x02002068` | lrct_config | med | 1 | configure and enable low-power RC timer, flag-gated |
| `0x020038b6` | gpio_pmu_set_out | low | 0 | set output bits for gpio 148/149 in SFR 0x51000 |
| `0x020038dc` | gpio16_p33_set_out | low | 0 | write gpio16 output bit via P33 register 155 |
| `0x020038ec` | gpio_port_lookup | med | 0 | map gpio number to port descriptor table entry |
| `0x02003904` | gpio_set_value | med | 0 | set/clear gpio output, dispatching special pin ranges |
| `0x020039be` | gpio_pmu_clear_pull | low | 0 | clear pull bits for gpio 148/149 in SFR 0x51000 |
| `0x020039e4` | gpio_pmu_set_dir | low | 0 | set direction for gpio 148-151 incl USB pins |
| `0x02003a42` | gpio16_p33_set_dir | low | 0 | write gpio16 direction bit via P33 register 153 |
| `0x02003a52` | p33_gpio144_set_dir | low | 0 | set direction/pull for P33 gpios 144/145 |
| `0x02003a9e` | gpio_set_direction | med | 0 | set gpio direction, dispatching special pin ranges |
| `0x02003b52` | p33_gpio144_bit_set | low | 0 | set P33 reg 0x809E bit for gpio 144/145 |
| `0x02003b7c` | gpio_set_hd | high | 0 | enable high-drive current (HD and HD1) on gpio pin |
| `0x02003c52` | gpio_pr_dir_set | med | 0 | set PR-port pin direction bit via SFR 0x809a |
| `0x02003c7c` | gpio_direction_input | high | 0 | configure gpio pin as input, set DIR bit |
| `0x02003d0e` | gpio_special_pull_up | med | 0 | pull-up config for USB/PMU special pins 148-151 |
| `0x02003d50` | gpio_pin16_pu_sfr | low | 0 | write pin16 pull-up value to SFR 156 |
| `0x02003d60` | gpio_set_pull_up | high | 0 | enable or disable gpio pull-up resistor |
| `0x02003e1c` | gpio_special_pull_down | med | 0 | pull-down config for USB/PMU special pins 148-151 |
| `0x02003e70` | gpio_pin16_pd_sfr | low | 0 | write pin16 pull-down value to SFR 157 |
| `0x02003e80` | gpio_set_pull_down | high | 0 | enable or disable gpio pull-down resistor |
| `0x02003f3c` | gpio_input_pullup | med | 0 | configure pin as digital input with pull-up |
| `0x02003f5c` | gpio_pin16_dir_sfr | low | 0 | write pin16 direction via SFRs 32 and 154 |
| `0x02003f78` | gpio_set_direction | high | 0 | set gpio direction, one=input zero=output |
| `0x02004014` | gpio_config_output | med | 0 | configure pin as push-pull output, pulls off, die on |
| `0x02004058` | gpio_config_input_hiz | med | 0 | configure pin high-impedance input, die off, no pulls |
| `0x02027dd0` | uart_rx_irq_handler | med | 0 | uart rx/timeout irq: drain dma count into ring, signal task |
| `0x02033782` | iic_enable_get | low | 0 | read enable bit of I2C instance control reg |
| `0x02033796` | iic_gate_ctrl | low | 0 | clear I2C control bits or set pin config |
| `0x020337cc` | irq_ext_pair_mask | low | 0 | mask or unmask IRQ pair 148/149 in SFR |
| `0x020337f2` | irq_enable_ctrl | med | 0 | set or clear IRQ enable bit in icfg bitmap |
| `0x0203386c` | iic_hw_init | low | 0 | init I2C instance regs, pins, IRQ pair |
| `0x0203392c` | iic_pnd_get | low | 0 | read I2C interrupt pending status bit |
| `0x02033948` | iic_pnd2_get | low | 0 | read I2C secondary pending status bit |
| `0x02033964` | iic_busy_get | low | 0 | read I2C busy flag bit16 |
| `0x0203645c` | hwreg_indexed_write_pair | low | 0 | writes packed config to indexed SFR regs 6,7 |
| `0x020365c8` | hw_str_hash_feed | low | 0 | feed string bytes to hash engine, read digest |
| `0x0203c912` | gpio_iomux_clk_toggle | low | 0 | set or clear 0x900 bits in SFR 0x51000 per enable flag |
| `0x02066854` | trng_fifo_read | med | 0 | read N bytes from hardware FIFO register 0x13B00 |
| `0x0206689a` | trng_fifo_read16 | med | 0 | read 16 random bytes from hardware FIFO |
| `0x0207dca6` | fm_radio_hf_coef_load | med | 0 | write FM receiver HF_CON1/HF_CRAM registers 0x12e14-1c |
| `0x02084774` | busy_delay_loop | high | 0 | busy-wait countdown delay loop |
| `0x0208478a` | spi0_cs_set | med | 0 | drive SPI0 flash chip-select GPIO with delay |
| `0x020847aa` | spi0_wait_ok | high | 0 | poll SPI0 PND with timeout, clear pending, return status |
| `0x020847da` | spi0_send_byte | high | 0 | set SPI0 send direction, write BUF byte, wait done |
| `0x020856c8` | p33_spi_xfer_byte | high | 0 | P33 internal-SPI byte transceive (PMU/RTC bus) |
| `0x0208570a` | p33_reg_read | med | 0 | read P33 PMU/RTC register under lock |
| `0x0208574e` | p33_reg_write | med | 0 | write P33 PMU/RTC register under lock |
| `0x0208578c` | p33_reg_rmw | med | 0 | atomic read-modify-write of P33 register field |
| `0x020857b4` | p33_reg_set_bits | med | 0 | set bits in P33 register (OR opcode) |
| `0x02086b44` | p33_spi_mode_get_set | med | 0 | get/set P33 SPI mode bits 2-3 under lock |
| `0x02086b76` | p33_reg_clear_bits | med | 0 | clear bits in P33 register (AND opcode) |
| `0x020895a0` | p33_rtc_read_ticks | med | 0 | read two 32-bit P33 counters, return elapsed delta |

## INPUT (3)

| addr | name | conf | callers | purpose |
|---|---|---|---|---|
| `0x0200053a` | adc_channel_scan | high | 0 | round-robin SARADC channel scan with timeout state machine |
| `0x0200407a` | adc_add_sample_ch | high | 0 | add adc channel to round-robin scan queue |
| `0x0202423c` | key_encoder_scan_tick | med | 0 | key/encoder/battery scan with debounce, post input events |

## UI_MENU (165)

| addr | name | conf | callers | purpose |
|---|---|---|---|---|
| `0x020081b0` | ui_watch_flag_set | low | 0 | set bit0 flag on watcher object byte +20 |
| `0x020081bc` | list_next_entry | med | 0 | next node in offset-based intrusive linked list |
| `0x020081c2` | list_del | med | 0 | unlink node from offset-based doubly-linked list |
| `0x02008216` | ui_registry_remove_free | low | 0 | remove matching nodes from ui registry list, free |
| `0x020082e4` | ui_core_remove_event_actions | low | 0 | delete matching event actions from registered elements |
| `0x02008502` | ui_elm_next_sibling | med | 0 | return element next sibling pointer at +4 |
| `0x0200850c` | ui_elm_get_scroll | low | 0 | return element aux scroll offset halfword +22 |
| `0x02008518` | ui_elm_last_sibling | med | 0 | walk sibling chain to last element |
| `0x02008528` | ui_core_find_owner_page | low | 0 | find page whose element array contains element |
| `0x0200856c` | ui_elm_get_field16 | low | 0 | return element field +16, default current window |
| `0x02008582` | ui_elm_get_focus | low | 0 | return element focus/flags field +28 |
| `0x02008598` | ui_elm_get_zorder | low | 0 | return element z-order byte field +32 |
| `0x020089ea` | ui_elm_alloc_aux | low | 0 | lazily allocate 28-byte element aux struct |
| `0x02008a2a` | ui_elm_set_scroll | low | 0 | set element scroll offset via attr msg, refresh |
| `0x02008a82` | ui_elm_redraw_children | low | 0 | recursively redraw child elements, post event 42 |
| `0x02008ac4` | ui_core_elm_state_change | low | 0 | dispatch element state/focus change by event mask |
| `0x02008bac` | ui_elm_remove_event_action | med | 0 | remove matching entries from element action array |
| `0x02008d82` | ui_win_aux_get8 | low | 0 | return window aux struct field +8 |
| `0x02008d8c` | ui_win_aux_get4 | low | 0 | return window aux struct field +4 |
| `0x02008d96` | ui_core_remove_element | med | 0 | detach element, send release events, free aux |
| `0x0200912e` | ui_res_slot_get_or_alloc | low | 0 | 16-slot id-keyed object cache lookup or allocate |
| `0x020092dc` | memzero_8 | low | 0 | zero 8-byte action entry helper |
| `0x020092e6` | ui_elm_add_event_action | low | 0 | grow element action array and insert entry |
| `0x0200938c` | ui_kv_map_insert | low | 0 | insert key/value into growable u15-key map |
| `0x02009468` | ui_dlist_push_alloc | low | 0 | allocate node and push onto pool list head |
| `0x02009494` | ui_element_init_defaults | low | 0 | zero 64-byte element struct, set default fields |
| `0x020094c2` | ui_ctx_lazy_init_stub | low | 0 | tail call to context factory at 0x0200083a |
| `0x0200965c` | ui_core_register_element | low | 0 | clone 64-byte element template, link into registry |
| `0x020096f8` | ui_elm_anim_action_start | med | 0 | build and start element attribute animation action |
| `0x02009824` | ui_action_slot_release | med | 0 | find action in 16-slot table, clear active flag |
| `0x0200993c` | ui_elm_attr_change_propagate | med | 0 | propagate style attr change to children with animations |
| `0x02009d18` | ui_elm_container_get | low | 0 | return element field+48 when type flags match |
| `0x02009d2c` | ui_scroll_content_width | med | 0 | compute horizontal content extent incl. padding/border |
| `0x02009e02` | ui_elm_offset18_get_neg | low | 0 | return negated element child offset halfword +18 |
| `0x02009e12` | ui_rect_span | high | 0 | compute rect span r1-r0+1 (width or height) |
| `0x02009e1c` | ui_rect_expand | high | 0 | expand rect by dx,dy padding on both axes |
| `0x02009e36` | ui_elm_content_rect_get | med | 0 | element rect minus border/padding attrs into out rect |
| `0x02009ed0` | ui_scroll_content_height | med | 0 | compute vertical content extent incl. padding/border |
| `0x02009f92` | ui_elm_scroll_mode_get | low | 0 | return element scroll-mode nibble when flags match |
| `0x02009fac` | ui_scroll_list_len_get | low | 0 | read list length bitfield from root, default 60 |
| `0x02009fc8` | ui_scrollbar_rects_calc | med | 0 | compute vertical/horizontal scrollbar thumb rects |
| `0x0200a55c` | ui_rect_area | high | 0 | rect area = width*height from four halfwords |
| `0x0200a578` | ui_elm_invalidate_rect | med | 0 | clip rect and queue element redraw region |
| `0x0200a5ae` | ui_scrollbar_redraw | med | 0 | invalidate both scrollbar thumb rects if nonempty |
| `0x0200a5e2` | ui_anim_step_calc | med | 0 | animation frame step from distance and duration |
| `0x0200a5fc` | ui_elm_tree_move | med | 0 | recursively offset element subtree rects by dx,dy |
| `0x0200a684` | ui_scroll_to_offset | med | 0 | scroll by dx,dy with optional 200-400ms animation |
| `0x0200a7d0` | ui_scroll_clamp_rebound | med | 0 | clamp overscroll and animate rebound into range |
| `0x0200a872` | ui_elm_offset16_get_neg | low | 0 | return negated element child offset halfword +16 |
| `0x0200a882` | ui_elm_reposition | med | 0 | move element within parent, fix layout and redraw |
| `0x0200a9ac` | ui_scroll_mode_apply | med | 0 | apply scroll mode/percent limits, reposition element |
| `0x0200aca6` | ui_scroll_y_by | med | 0 | scroll element vertically by delta via animator |
| `0x0200acd0` | ui_elm_layout_arrange | med | 0 | measure and arrange children, update rect, relayout |
| `0x0200b546` | ui_elm_relayout_tree | med | 0 | recursive relayout of dirty element subtree |
| `0x0200b59c` | ui_layout_flush | med | 0 | process pending relayout flags on root element |
| `0x0200b5d6` | ui_scroll_by_clamped | med | 0 | scroll by delta clamped to content bounds |
| `0x0200b6d4` | ui_scroll_x_by | med | 0 | scroll element horizontally by delta via animator |
| `0x0200b6fe` | ui_elm_scroll_dir_flags | low | 0 | return scroll direction nibble from element flags |
| `0x0200b70e` | ui_elm_first_child_get | low | 0 | return element child-list head pointer or null |
| `0x0200b71a` | ui_border_radius_extent | low | 0 | compute corner radius plus border extents for clipping |
| `0x0200b820` | ui_elm_typedata_get | low | 0 | return element data field when type id in range |
| `0x0200c18a` | ui_slot_pair_register | med | 0 | store pointer pair into first free of 16 slots |
| `0x0200c236` | ui_registry_remove_owner | med | 0 | scan 16-slot registry, clear entries owned by pointer |
| `0x0200c262` | ui_element_msg_handler | med | 0 | central element message dispatcher, 41 ids, draw/key/focus/style |
| `0x0200d274` | ui_element_hit_search | med | 0 | recursive deepest-element search by rect hit test |
| `0x0200d2dc` | ui_msg_handler_dispatch | med | 0 | call registered global handlers until one consumes event |
| `0x020109cc` | ui_registry_slot_clear | med | 0 | clear 8-byte registry slot by index |
| `0x02012c06` | ui_registry_point_hit | med | 0 | find registered type-2 element containing given point |
| `0x020174b2` | ui_ctx_state_check | low | 0 | check ui context flags, post msg 4201 |
| `0x020174ec` | ui_ctx_release | low | 0 | clear ui context flags, release draw resources |
| `0x020175ac` | ui_widget_refresh | low | 0 | post refresh msgs, set widget dirty flags |
| `0x0201797c` | ui_text_layout_update | med | 0 | text widget layout, ellipsis, scroll anim setup |
| `0x02017e6a` | ui_text_set_scroll_mode | med | 0 | set text scroll/align mode, restore truncated text |
| `0x02017f22` | ui_text_set_str | high | 0 | set widget text string, init and release text |
| `0x0201800a` | ui_widget_emit_event | med | 0 | walk handler list, dispatch event to widget |
| `0x02018038` | ui_text_area_size | low | 0 | compute available text area from widget attrs |
| `0x0201808c` | ui_widget_on_event | med | 0 | widget attr load and event handler jump table |
| `0x020188a0` | ui_dirty_slot_mark | low | 0 | mark context table slot dirty with size |
| `0x02018912` | menu_step_scale | low | 0 | scale edit step by signed table entry |
| `0x02018958` | ui_value_edit_handler | med | 0 | ui event handler, encoder value edit with clamps |
| `0x02018ab4` | ui_attr_get | low | 0 | find attr entry by flag in resource list |
| `0x02018ae8` | ui_attr_add | low | 0 | grow attr table, insert new attribute entry |
| `0x02018bae` | ui_attr_add_1001 | low | 0 | wrapper, add attribute id 0x1001 |
| `0x02018bba` | ui_attr_1001_set_if_new | low | 0 | find-or-add attribute id 0x1001 |
| `0x02018be2` | ui_attr_add_1459 | low | 0 | wrapper, add attribute id 0x1459 |
| `0x02018bf0` | ui_attr_add_1009 | low | 0 | wrapper, add attribute id 0x1009 |
| `0x02018bfe` | ui_attr_set_pair | low | 0 | set attribute pair 0x1006/0x1008 if changed |
| `0x02018c4e` | ui_text_set_style_attrs | low | 0 | set three text style attributes via wrappers |
| `0x02018c62` | ui_text_setup | med | 0 | configure text widget font, string, style attrs |
| `0x02018c84` | ui_label_set_text | med | 0 | set child label text string and Y offset |
| `0x02018c9c` | ui_widget_invalidate | med | 0 | mark widget dirty, refresh on visibility change |
| `0x02018cd0` | ui_widget_show_hide | med | 0 | show or hide widget selected by flag |
| `0x020197d2` | ui_window_create | med | 0 | create window object from rodata descriptor |
| `0x0201989c` | ui_handler_chain_invoke | med | 0 | walk handler list, invoke each callback |
| `0x020198b0` | ui_handler_chain_invoke2 | med | 0 | walk sibling handler chain calling callbacks |
| `0x020198ce` | ui_page_show | med | 0 | show page: run element init hooks, request redraw |
| `0x02019952` | ui_window_create_show | med | 0 | create window from descriptor 0x2043850 and show |
| `0x02019968` | ui_prop_clear_1812 | med | 0 | clear widget property 0x1812 |
| `0x02019976` | ui_prop_clear_1813 | med | 0 | clear widget property 0x1813 |
| `0x02019984` | ui_prop_set_1810 | med | 0 | set widget property 0x1810 |
| `0x02019992` | ui_prop_clear_1811 | med | 0 | clear widget property 0x1811 |
| `0x020199a0` | ui_set_color | med | 0 | set widget color property (id 32) |
| `0x020199ac` | ui_set_alpha | med | 0 | set widget alpha property (id 33) |
| `0x020199b8` | ui_widget_set_size | med | 0 | set widget width/height only when changed |
| `0x02019a06` | ui_prop_set_1032 | med | 0 | set widget property 0x1032 |
| `0x02019a14` | ui_label_create | med | 0 | create label widget with color, alpha, position |
| `0x02019a56` | ui_prop_set_96 | med | 0 | set widget text attribute property 96 |
| `0x02019a62` | ui_prop_set_840 | med | 0 | set widget font property 0x840 to 10 |
| `0x02019a70` | ui_prop_set_841 | med | 0 | set widget property 0x841 |
| `0x02019a7e` | ui_prop_set_842 | med | 0 | set widget property 0x842 |
| `0x02019a8c` | ui_prop_set_843 | med | 0 | set widget property 0x843 to -1 |
| `0x02019a9a` | ui_prop_set_845 | med | 0 | set widget property 0x845 to 204 |
| `0x02019aa8` | ui_child_window_create_show | med | 0 | create and show child window from descriptor 0x2045ee8 |
| `0x02019ac0` | ui_prop_set_145c | med | 0 | set widget text property 0x145c |
| `0x02019ace` | ui_param_item_create | med | 0 | create parameter menu item: name and value labels |
| `0x02019bb4` | ui_element_release_focus | med | 0 | clear focus pointers referencing element |
| `0x02019c62` | ui_element_remove | med | 0 | detach element from lists, run destroy hooks |
| `0x02019dd2` | ui_element_destroy | med | 0 | destroy element, free text, request redraw |
| `0x02019e6a` | ui_widget_free | med | 0 | destroy widget contents and free struct |
| `0x0201e58e` | ui_widget_set_text_fmt | low | 0 | set widget label via asprintf; transpose/octave edit handlers |
| `0x0201fe64` | perf_mode_page_exit | med | 0 | page-exit action: all-notes-off, clear arp tables/keys |
| `0x02021704` | ui_widget_param_create | low | 0 | create UI widget from float parameter table |
| `0x0202171c` | ui_elem_set_commit | low | 0 | set element fields then commit and refresh |
| `0x02021732` | ui_prop_set_2121 | low | 0 | set widget property id 2121 |
| `0x02021740` | ui_prop_set_77 | low | 0 | set widget property id 77 |
| `0x0202174c` | ui_prop_set_32 | low | 0 | set widget property id 32 |
| `0x02021758` | ui_prop_set_59 | low | 0 | set widget property id 59 |
| `0x02021764` | ui_event_list_insert | low | 0 | insert 8-byte entry into indexed circular list |
| `0x02021806` | ui_prop_set_1111 | low | 1 | set widget property id 1111 |
| `0x02021814` | ui_prop_set_48 | low | 0 | set widget property id 48 |
| `0x02021820` | ui_prop_set_49 | low | 0 | set widget property id 49 |
| `0x0202182c` | ui_synth_page_build | med | 0 | build synth menu page: widgets, six operator buttons |
| `0x02022020` | ui_page_build | med | 0 | build UI page: title string, list, sub-widgets |
| `0x02022c7a` | menu_page_select_item | med | 0 | move page selection to item index, redraw old/new |
| `0x02024878` | menu_page_event_handlers | med | 0 | menu page handlers: encoder edit, select, bank save |
| `0x0202510e` | menu_page_value_redraw | med | 0 | redraw 4-field value page with formatted text |
| `0x020253ba` | menu_param_max_lookup | med | 0 | map param id to max value via two tables |
| `0x020254b8` | menu_value_format_draw | med | 0 | format param value (note names, percent) and draw |
| `0x0202558a` | menu_param_rows_redraw | med | 0 | redraw 4 param name/value rows from tables |
| `0x0202572a` | ui_panel_create4 | med | 0 | create 4-child UI panel widget, paired destructor |
| `0x02025790` | patch_bank_page_handlers | med | 0 | patch/bank menu pages, flash bank ops, scope draw |
| `0x02068c12` | ui_arp_param_edit_handler | med | 0 | arp parameter page handler, edit rate/gate/latch fields |
| `0x02069000` | ui_pattern_clear_handler | med | 0 | pattern clear/confirm page states 34-36, posts Cleared |
| `0x020690e6` | ui_param_value_redraw | low | 0 | format and repost parameter value text element |
| `0x0206914e` | ui_menu_event_dispatch | med | 0 | central menu event dispatcher with page jump tables |
| `0x02069a78` | ui_element_buf_free | low | 0 | free window element buffer, clear slot pointer |
| `0x02069a92` | ui_window_close | med | 0 | close window: unregister timer, free elements, reset flags |
| `0x02069b3c` | ui_devid_element_post | low | 0 | post static device-id text element to display |
| `0x02069b62` | ui_flag_sync_post | low | 0 | sync flag bits into device struct, repost element |
| `0x02069b90` | ui_battery_voltage_post | med | 0 | scale battery raw x1.6, post voltage text element |
| `0x02069bb8` | ui_preset_save_handler | med | 0 | preset save page handler, 16-char name edit/copy |
| `0x02069d8a` | ui_preset_cleared_post | low | 0 | post Cleared notice element for preset slot |
| `0x02069dae` | ui_static_element_post | low | 0 | post fixed rodata element via text-post helper |
| `0x02069dca` | ui_arp_sequencer_dispatch | med | 0 | arp/sequencer page state machine, pattern bank slots |
| `0x0206abfe` | ui_sub_page_event_handler | low | 0 | small page event handler, states 1-8 and 88 |
| `0x0206ac90` | ui_elements_invoke_handler | med | 0 | walk window element list invoking registered handler |
| `0x0206acca` | ui_window_msg_queue_process | med | 0 | dequeue window message nodes under lock, free/dispatch |
| `0x0206ae08` | ui_window_element_flush | med | 0 | coalesce and insert pending elements into window list |
| `0x0206b004` | ui_windows_tick_all | med | 0 | iterate window pool: flush queues, free timers/elements |
| `0x0206b394` | ui_all_windows_idle | med | 0 | return true when no pool window active; timer helpers |
| `0x0206b4d4` | ui_windows_drain_elements | low | 0 | drain and free pending element lists of all windows |
| `0x0206b5ae` | ui_window_pool_clear | high | 0 | memset both 280-byte window pool slots |
| `0x0206b5d6` | ui_window_create_dispatch | high | 0 | allocate/init window from pool, install handlers, timeout |
| `0x0206bb38` | ui_msg_post_or_forward | low | 0 | forward message to window or defer via status timer |
| `0x0206bd64` | ui_window_msg_dispatch | med | 0 | window message handler: post status text, refresh pool |

## UI_DISPLAY (91)

| addr | name | conf | callers | purpose |
|---|---|---|---|---|
| `0x020085ae` | ui_rect_union | med | 0 | merge two rects into dst, report change flags |
| `0x0200861a` | ui_elm_rect_hit_test | low | 0 | recursively test element rect intersection and visibility |
| `0x020086c8` | ui_core_get_screen_width | low | 0 | fetch display width via draw context |
| `0x020086f4` | ui_core_get_screen_height | low | 0 | fetch display height via draw context |
| `0x02008720` | rect_circle_intersect | low | 0 | test circle vs rect via squared distance |
| `0x02008804` | rect_inside_circle | low | 0 | test all four rect corners inside circle |
| `0x02008880` | ui_invalidate_rect | low | 0 | add clipped dirty rect to window redraw array |
| `0x02008966` | ui_core_redraw | low | 0 | compute element abs rect and invalidate region |
| `0x020089c2` | ui_elm_mark_dirty | low | 0 | set dirty flags on element and last sibling |
| `0x0200b832` | ui_draw_style_init | med | 0 | zero and default-init 56-byte text draw style struct |
| `0x0200b87c` | ui_text_char_class | med | 0 | classify string first byte: control/ascii/multibyte |
| `0x0200b896` | ui_text_style_resolve | med | 0 | fill text style struct from element attrs, apply opacity |
| `0x0200bbe4` | ui_draw_ctx_init | low | 0 | clear 72-byte draw context, store owner pointer |
| `0x0200bbf4` | ui_rect_callback_if_nonempty | med | 0 | invoke draw callback when rect has positive size |
| `0x0200bc1c` | ui_rounded_rect_raster_gen | med | 0 | generate/cache rounded-rect arc scanline raster data |
| `0x0200d330` | ui_text_attr_init | med | 0 | init 24-byte text attribute struct, alpha 255 |
| `0x0200d352` | ui_draw_style_init | med | 0 | init 32-byte draw style, colors, alpha, rodata ptr |
| `0x0200d388` | utf8_2_unicode_one | high | 0 | decode one utf8 char to unicode, advance offset |
| `0x0200d46a` | font_char_width | med | 0 | walk font handler list for per-char glyph width |
| `0x0200d4ac` | font_text_wrap_width | med | 0 | measure text with word wrap, return break offset |
| `0x0200d7fc` | font_text_line_width | med | 0 | measure single-line utf8 text pixel width |
| `0x0200d8e0` | font_text_extent | med | 0 | compute multiline text bounding width and height |
| `0x0200d984` | ui_line_attr_init | low | 0 | init 10-byte line draw attribute struct |
| `0x0200d99c` | utf8_strlen | med | 0 | count unicode chars in utf8 string |
| `0x0200d9c0` | utf8_peek_char_pair | low | 0 | fetch current and next unicode char from string |
| `0x0200d9e4` | ui_draw_custom_cb_invoke | low | 0 | invoke custom draw callback when style permits |
| `0x0200d9f6` | ui_text_render | med | 0 | render wrapped aligned text into element draw context |
| `0x0200e228` | ui_font_handle_release | low | 0 | call release callback, free owned font buffer |
| `0x0200e24c` | ui_text_out | med | 0 | draw text into element dc, font resolve, align, rotate |
| `0x0200e886` | ui_rect_copy | high | 0 | copy 4-halfword rect from element to destination |
| `0x0200e898` | ui_core_draw_walk | med | 0 | recursive element draw with clip, offset, draw msgs |
| `0x0200e980` | ui_core_redraw_tree | med | 0 | walk element tree issuing redraw for each node |
| `0x0200ea02` | ui_layer_flush | med | 0 | flush layer framebuffer to lcd with flip/rotate transform |
| `0x0200ef3a` | ui_core_redraw | med | 0 | redraw entry: merge dirty rects, redraw, flush layer |
| `0x0200f632` | ui_aa_scanline_fill | med | 0 | anti-aliased scanline coverage fill into alpha mask |
| `0x02010200` | ui_res_style_load | low | 0 | close res file; load style attribute chunk from res |
| `0x020102da` | ui_image_format_bpp | med | 0 | map image format id to bits per pixel |
| `0x0201030a` | ui_image_open | med | 0 | open image from res, load palette, install decoder vtable |
| `0x020108a6` | ui_draw_line_setup | med | 0 | init line draw descriptor, fixed-point slopes, direction flags |
| `0x020109e4` | ui_draw_arc_blit | med | 0 | arc AA fill and packed image blit with rgb565 blending |
| `0x02012b8c` | ui_rect_overlap_test | med | 0 | test rect overlap plus four corner containment checks |
| `0x02012c54` | ui_element_draw_call | med | 0 | clip rect then invoke element pre-draw and draw callbacks |
| `0x02012d04` | ui_image_get_pixel | med | 0 | fetch pixel from packed image by format-specific unpacking |
| `0x02012dcc` | image_get_pixel | med | 0 | fetch pixel from 1/2/4/8-bpp bitmap/glyph data |
| `0x02012e96` | draw_image_blend | high | 0 | blit/blend image spans to RGB565 buffer with alpha |
| `0x02013be6` | image_format_probe | med | 0 | walk handler list, probe pixel-format ops match |
| `0x02013c16` | draw_shape_primitives | med | 0 | paletted image blit plus circle/line/polygon drawing |
| `0x02014d30` | coverage_box_blur | med | 0 | sliding-window box blur over u16 coverage map |
| `0x02014ec8` | gradient_color_at | med | 0 | RGB565 gradient table lookup with interpolation |
| `0x02014fde` | draw_gradient_rect | low | 0 | filled rounded rect with vertical gradient spans |
| `0x02015612` | draw_text_in_rect | med | 0 | measure and draw text aligned inside rect |
| `0x0201582a` | draw_round_rect_aa | med | 0 | anti-aliased rounded rect via blurred coverage map |
| `0x02017008` | font_glyph_lookup | med | 0 | font glyph index cache lookup, data ptr, metrics |
| `0x0201742e` | anim_easing_eval | med | 0 | animation easing interpolation, linear and cubic |
| `0x02017554` | utf8_sequence_length | high | 0 | byte count of UTF-8 sequence from lead byte |
| `0x02017582` | utf8_char_count | high | 0 | count characters in UTF-8 string |
| `0x0201760c` | ui_anim_find | med | 0 | find animation entry by id and callback |
| `0x02017656` | utf8_prev_char | high | 0 | step back one UTF-8 character in string |
| `0x020176c4` | text_wrap_measure | med | 0 | measure text width with word-wrap line breaking |
| `0x020188cc` | backlight_apply | low | 0 | apply backlight level via lookup table |
| `0x0201d9d0` | ui_show_patch_name | low | 0 | format patch index plus 10-char voice name, push display |
| `0x02021486` | lcd_spi_write_window | high | 0 | SPI1 LCD: set 240x240 window (2A/2B/2C), push pixels |
| `0x020215a0` | lcd_device_init | med | 0 | init 76B LCD device struct, callback and flags |
| `0x020215ea` | lcd_chan_enable | low | 0 | clear flag bits to enable LCD channel object |
| `0x0202160a` | lcd_pipeline_init | med | 0 | alloc framebuffer, create two channels, schedule callback |
| `0x020223ba` | ui_text_align_layout | med | 0 | compute text alignment offsets, reposition widget x/y |
| `0x0204391c` | rodata_post_libm_tables | low | 0 | misdecoded rodata: small lookup tables after libm |
| `0x02043964` | rodata_img_scale_tab | low | 0 | misdecoded rodata; byte table used by nine-slice image draw |
| `0x02043b60` | rodata_ui_gfx_tab_a | low | 0 | misdecoded rodata: UI/graphics lookup table data |
| `0x02043ba4` | rodata_ui_gfx_tab_b | low | 0 | misdecoded rodata: UI/graphics lookup table data |
| `0x02043c52` | rodata_ui_gfx_tab_c | low | 0 | misdecoded rodata: UI/graphics lookup table data |
| `0x02043c6a` | rodata_ui_gfx_tab_d | low | 0 | misdecoded rodata: UI/graphics lookup table data |
| `0x02043ee6` | rodata_ui_gfx_tab_e | low | 0 | misdecoded rodata: UI/graphics lookup table data |
| `0x020440bc` | rodata_ui_gfx_tab_f | low | 0 | misdecoded rodata: UI/graphics lookup table data |
| `0x02046594` | rodata_ui_bitmap_a | low | 0 | misdecoded rodata: icon/font bitmap graphics data |
| `0x02049126` | rodata_ui_bitmap_b | low | 0 | misdecoded rodata: icon/font bitmap graphics data |
| `0x020491be` | rodata_ui_bitmap_c | low | 0 | misdecoded rodata: icon/font bitmap graphics data |
| `0x02049e2a` | rodata_ui_bitmap_frag | low | 0 | rodata fragment between bitmap tables |
| `0x02049e2e` | rodata_ui_bitmap_d | low | 0 | misdecoded rodata: icon/font bitmap graphics data |
| `0x0204a780` | rodata_ui_bitmap_e | low | 0 | misdecoded rodata: icon/font bitmap graphics data |
| `0x0204b21a` | rodata_ui_bitmap_f | low | 0 | misdecoded rodata: icon/font bitmap graphics data |
| `0x0204b5e4` | rodata_ui_bitmap_g | low | 0 | misdecoded rodata: icon/font bitmap graphics data |
| `0x0204d35c` | rodata_font_data | med | 0 | misdecoded font bitmap, pointer stored by display init |
| `0x0204d3ae` | rodata_font_frag_a | low | 0 | tiny data fragment inside font region |
| `0x0204d3b0` | rodata_font_data_b | low | 0 | misdecoded rodata: font bitmap data |
| `0x0204d3d2` | rodata_font_data_c | low | 0 | misdecoded rodata: font bitmap data |
| `0x0204d3f8` | rodata_font_frag_b | low | 0 | small data fragment inside font region |
| `0x0204d406` | rodata_font_data_d | low | 0 | misdecoded rodata: font bitmap data |
| `0x0204d564` | rodata_font_data_e | low | 0 | misdecoded rodata: font bitmap data |
| `0x0204d72c` | rodata_font_frag_c | low | 0 | tiny data fragment inside font region |
| `0x0204d732` | rodata_font_data_f | low | 0 | misdecoded rodata: font bitmap data |

## MIDI (28)

| addr | name | conf | callers | purpose |
|---|---|---|---|---|
| `0x02000856` | midi_ctrl_packet_dispatch | med | 0 | subscribe event; route 4-byte 0xD0/0xD4 control packets |
| `0x0200088a` | midi_slot_is_active | med | 0 | test whether MIDI engine slot is active |
| `0x0200089c` | midi_slot_find | med | 0 | find MIDI engine slot index or return -1 |
| `0x020008b0` | midi_device_info_send | med | 0 | build and send device-info packet from templates |
| `0x02000992` | midi_engine_reset | med | 0 | reset MIDI engine slot list, emit notification |
| `0x020009ec` | midi_slot_match | med | 0 | match slot against value, return 0 or -1 |
| `0x02000a02` | midi_control_cmd_dispatch | med | 0 | dispatch control subcommands, update slot states, build replies |
| `0x02000c1a` | midi_msg_prefilter | med | 0 | pre-filter 4-byte messages before command dispatcher |
| `0x02000c48` | midi_stream_parser | high | 0 | MIDI byte-stream parser: running status, sysex, routing, replies |
| `0x02005d86` | usb_midi_sysex_engine | med | 0 | EP write plus USB-MIDI DX7 sysex pack/stream engine |
| `0x02006384` | usb_midi_rx_parse | med | 0 | parse USB-MIDI events, DX7 7-bit repack, taskq post |
| `0x0201f5f4` | midi_msg_dispatch | high | 0 | MIDI note/CC/pitchbend routing, voice allocation and steal |
| `0x0201fdde` | midi_rx_fifo_push | med | 0 | push bytes into MIDI ring FIFO with running status |
| `0x02020042` | seq_pattern_bank_scan | med | 0 | scan 16 seq pattern slots, count valid notes each |
| `0x020201dc` | arp_seq_mode_control | med | 0 | arp/seq mode set: panic, scheduler init, pattern load |
| `0x02020552` | midi_note_on_inject | high | 0 | build and inject 3-byte 0x90 note-on message |
| `0x0202058a` | arp_note_order_sort | med | 0 | sort held-note list by press-order priority table |
| `0x02020724` | arp_pattern_build | high | 0 | build arp note pattern: up/down/random/octave expansion |
| `0x02020b90` | arp_held_note_remove | high | 0 | clear note from held-note table, decrement count |
| `0x02020bce` | arp_held_note_add | high | 0 | set note in held-note table, increment count |
| `0x02020c0e` | seq_pattern_build | med | 0 | second pattern builder; embedded arp/seq tick engine |
| `0x02022106` | arp_seq_note_input | med | 0 | route note on/off into arp/seq engines with timestamps |
| `0x02022282` | note_on_route | high | 0 | note-on: inject synth, add arp held, seq record |
| `0x02022310` | note_off_route | high | 0 | note-off: inject synth, remove arp held, seq advance |
| `0x02023ea0` | midi_message_handler | high | 0 | parse MIDI in: DX7 sysex dumps, notes, CCs |
| `0x020273be` | midi_dispatch_thunk | low | 0 | thunk to midi_msg_type_dispatch, flash-erase idle hook |
| `0x020279a8` | midi_route_input_poll | med | 0 | pump midi_stream_parser per route, buffer message bytes |
| `0x02027af4` | serial_midi_task | med | 0 | serial task loop: midi rx parse, vendor sysex, tx dma |

## USB (74)

| addr | name | conf | callers | purpose |
|---|---|---|---|---|
| `0x0200541a` | usb_func_cb_register | low | 0 | store callback pointer into usb function driver slot |
| `0x02005438` | usb_midi_function_init | low | 0 | build 92-byte midi function config, register ep callbacks |
| `0x02005500` | usb_ep0_request_data_stage | med | 0 | handle GET/SET_INTERFACE, copy wLength EP0 payload |
| `0x02005598` | usb_ep_cfg_ptr_set | low | 0 | store endpoint config pointer into device param table |
| `0x020055ca` | usb_ep_dma_cfg_set | low | 0 | write ep dma reg 0x16820, mirror into struct |
| `0x02005632` | usb_ep_struct_reg2_write | low | 0 | write endpoint struct slot at +68 |
| `0x02005648` | usb_sfr_write | med | 0 | write indexed usb reg via 0x11804 port, busy-wait |
| `0x02005676` | usb_reg14_write | low | 0 | write usb indexed register 14 |
| `0x02005680` | usb_ep_reg16_write | low | 0 | write endpoint halfword reg 16, direct or indirect |
| `0x020056fc` | usb_ep_reg17_18_write | low | 0 | write endpoint 32-bit reg via 17/18 halfword pair |
| `0x02005782` | usb_sfr_read | med | 0 | read indexed usb reg via 0x11804 port, busy-wait |
| `0x020057b8` | usb_ep_enable | med | 0 | set endpoint enable bit in usb CON regs 7/8 |
| `0x0200584c` | usb_ep_dma_adr_set | low | 0 | write ep dma addr reg 0x16824, mirror into struct |
| `0x020058bc` | usb_ep_struct_reg3_write | low | 0 | write endpoint struct slot at +84 |
| `0x020058d2` | usb_ep_reg19_write | low | 0 | write endpoint halfword reg 19, direct or indirect |
| `0x02005952` | usb_ep_reg20_21_write | low | 0 | write endpoint 32-bit reg via 20/21 halfword pair |
| `0x020059da` | usb_ep_struct_reg6_write | low | 0 | write endpoint struct slot at +52 |
| `0x020059f0` | usb_ep_enable2 | low | 0 | set endpoint enable bit in usb CON regs 9/10 |
| `0x02005a88` | usb_ep_config | med | 0 | configure endpoint direction, type, maxpacket, dma buffer |
| `0x02005bb2` | usb_midi_ep_open | med | 0 | post audio_server msg, open EP4 bulk IN/OUT pair |
| `0x02005ce4` | usb_get_ep_buffer | med | 0 | fetch per-endpoint buffer pointer from usb dev struct |
| `0x02005cfe` | usb_txcsr_read | high | 0 | read endpoint TxCSR (SIE 0x11/0x12), dual-core locked |
| `0x020060d8` | usb_rxcsr_read | high | 0 | read endpoint RxCSR (SIE 0x14/0x15), dual-core locked |
| `0x02006160` | usb_ep_read | high | 0 | read endpoint RX FIFO into buffer with timeout |
| `0x0200675a` | usb_device_hold | med | 0 | USB PHY off and DM/DP GPIO release per device |
| `0x020067b0` | usb_add_desc_config | high | 0 | register or clear descriptor-builder hook slot |
| `0x020067cc` | uac_config_init | med | 0 | init USB-audio struct: 44100Hz rate, dma buffers |
| `0x0200681e` | usb_config_desc_build | high | 0 | run desc hooks, assemble config descriptor with length |
| `0x02006882` | usb_sie_init | med | 0 | USB PHY/SIE power-up, poll device mode, intr enables |
| `0x02006932` | usb_sie_power_write | med | 0 | write SIE POWER reg (soft-connect 0x60) |
| `0x020069a6` | usb_intr_usbe_write | med | 0 | write IntrUSBE byte (SIE 0x0B), dual-core locked |
| `0x02006a14` | usb_set_intr_txe | high | 0 | mask/clear IntrTxE bits (SIE 0x06/0x07) |
| `0x02006ac2` | usb_set_intr_rxe | high | 0 | mask/clear IntrRxE bits (SIE 0x08/0x09) |
| `0x02006b70` | usb_id2device | med | 0 | map usb id to device struct pointer |
| `0x02006b7c` | usb_device_mode | high | 0 | select USB device class mode, full init/teardown |
| `0x02006d84` | usb_read_ep0 | high | 0 | read EP0 FIFO bytes under SIE interrupt toggle |
| `0x02006e1a` | uac_sync_rate_init | low | 0 | init isoc feedback counters from sample rate |
| `0x02006e74` | uac_class_request_handler | med | 0 | UAC get/set-cur control replies and descriptors |
| `0x0200707c` | usb_std_request_dispatch | high | 0 | standard EP0 setup request dispatcher (addr/config/desc) |
| `0x02007698` | usb_get_descriptor_handler | med | 0 | GET_DESCRIPTOR/string and MIDI-class descriptor serving |
| `0x020077c4` | usb_ep0_csr_read | med | 0 | read EP0 CSR0 (SIE 0x11), dual-core locked |
| `0x0200783c` | usb_ep0_csr_write | med | 0 | write EP0 CSR0, dual-core locked |
| `0x020078b8` | usb_ep_int_enable | low | 0 | set EP dma interrupt bit; CSR0 ack/stall stubs |
| `0x020078de` | usb_write_ep0 | med | 0 | write up to 64B to EP0 FIFO, set TxPktRdy |
| `0x020601a2` | usb_ep_buf_free | low | 0 | free endpoint buffer at +20 and null pointer |
| `0x020601b8` | usb_dev_flag_clear | low | 0 | clear flag byte at device struct offset 612 |
| `0x020601c6` | usb_iso_sof_schedule | med | 0 | collect ISO eps, sort by deadline, schedule next frame |
| `0x02060382` | usb_iso_ep_advance | low | 0 | pick next ISO endpoint by frame gap, notify |
| `0x02060488` | usb_ep_close | med | 0 | teardown endpoint: free buffers, clear enable/irq bits |
| `0x02060714` | usb_ep_window_set | low | 0 | store min/max/count halfword triple into device struct |
| `0x0206073c` | usb_ep_mode_flag_set | low | 0 | set bit3 of endpoint flags when mode 1 or 3 |
| `0x02060758` | usb_ep_flag_update | low | 0 | set/clear bit8 of h[6] from byte 488 state |
| `0x02060772` | usb_sie_write_reg6 | low | 0 | write SIE register 6 with value OR 0x2100 |
| `0x02060780` | usb_ep_desc_fill | low | 0 | fill endpoint record: type bits, size 12, addr copy |
| `0x020607c4` | usb_ep_configure | med | 0 | configure endpoint from descriptor, alloc bufs and URBs |
| `0x0206087c` | usb_ep_open | low | 0 | configure ep then set state flags and notify stack |
| `0x020608e6` | usb_ep_desc_fill_alt | low | 0 | fill endpoint record variant: type 5, size 34 |
| `0x02060942` | usb_ep_configure_iso | low | 0 | configure streaming endpoint, alloc URBs, arm transfer |
| `0x02060a56` | usb_device_shutdown | med | 0 | close all 8 eps, free stack, disable controller |
| `0x02060ab6` | usb_ep_tx_submit | med | 0 | build TX buffer, queue on endpoint list, kick transfer |
| `0x02060b36` | usb_ctrl_data_stage | low | 0 | encode sequenced packet, send via low-level xfer, verify |
| `0x02060c42` | usb_urb_dispatch | low | 0 | pop queued URB, process, run completion callback |
| `0x02060c80` | usb_timer_read_fixed_ms | low | 0 | convert 24MHz timer ticks to fixed-point milliseconds |
| `0x02060c9e` | usb_ep_record_append | low | 0 | append byte data to endpoint record for marked types |
| `0x02060cc2` | usb_dev_sie_isr | high | 0 | USB device interrupt handler: per-ep dispatch, SOF timing |
| `0x0206113c` | usb_ep_fifo_setup | low | 0 | alloc endpoint buffer, program fifo, clear stall bits |
| `0x020611a0` | usb_ep_param_check | low | 0 | read 2-byte value, store modulo flag at offset 458 |
| `0x020611cc` | usb_iso_ep_service | med | 0 | ISO/audio streaming data handler plus EP8/9 ISR tail |
| `0x02061728` | usb_frame_reg3_read | low | 0 | read frame-timing register 3 minus two |
| `0x0206173c` | usb_frame_reg5_read | low | 0 | read frame-timing register 5 low halfword |
| `0x02061748` | usb_frame_reg9_read | low | 0 | read register 9, extract 9-bit field at bit 7 |
| `0x02061756` | usb_sof_count_check | low | 0 | gate register-9 read behind flags at 342/343 |
| `0x02061782` | usb_iso_timer_program | med | 0 | frame counters plus SOF/ISO timer register programming |
| `0x02086f2a` | usb_ep0_request_handler | med | 0 | EP0 std/class request dispatch, descriptors, serial string |

## SYNTH_FM (20)

| addr | name | conf | callers | purpose |
|---|---|---|---|---|
| `0x0201d99c` | dx7_global_params_apply | med | 0 | apply four table-indexed patch params into synth state |
| `0x0201da10` | dx7_lfo_params_compute | med | 0 | compute DX7 LFO rate/delay params from patch bytes |
| `0x0201f368` | dx7voice_state_copy | high | 0 | copy 320B voice state: 6 op param blocks + extras |
| `0x0201f3fc` | env_release | high | 0 | msfa Env release-stage advance: level/rate/inc compute |
| `0x0201f46c` | dx7voice_keyoff | high | 0 | per-voice key-off over 6 op envs plus pitch env |
| `0x0201f4ea` | dx7_mod_update | med | 0 | recompute controller modulation amounts via smax matrix |
| `0x02051372` | rodata_sin_freqlut | high | 0 | sine table tail plus msfa freqlut log2 table |
| `0x020514d4` | rodata_freqlut_exp2 | high | 0 | msfa freqlut body plus exp2 float table |
| `0x02051c2a` | fp_lut_data_51c2a | low | 0 | float/fixpoint parameter-curve LUT fragment misdecoded as code |
| `0x02051c60` | fp_lut_data_51c60 | low | 0 | float32 LUT data fragment misdecoded as code |
| `0x02051e30` | fp_lut_data_51e30 | low | 0 | float32 LUT data fragment misdecoded as code |
| `0x02052010` | dx7_ramp_lut_52010 | med | 0 | float32 rising ramp LUT (0.735 up), synth curve data |
| `0x0205222c` | dx7_curve_lut_524e0 | med | 0 | float32 exp-decay curve table referenced by param mapper |
| `0x02052e00` | fp_lut_data_52e00 | low | 0 | float32 slowly-falling LUT fragment misdecoded as code |
| `0x02053030` | fp_lut_data_53030 | low | 0 | negative float32 near-linear LUT fragment, misdecoded data |
| `0x02053160` | dx7_coef_luts_53484 | med | 0 | float/int coefficient LUTs incl table loaded to hw engine |
| `0x02054da8` | dx7_param_tables_54da8 | med | 0 | float LUT tail plus DX7 parameter-name strings/pointer tables |
| `0x02085824` | fm_op_chain3_kernel | med | 0 | 3-operator cascade FM kernel over 64-sample block |
| `0x02085a28` | fm_core_render | high | 0 | 6-op algorithm network compute using sin/exp2 tables |
| `0x020862fa` | dx7note_compute_block | high | 0 | per-voice env/LFO/freqlut, calls fm_core_render, mixes |

## FX (9)

| addr | name | conf | callers | purpose |
|---|---|---|---|---|
| `0x02019e9e` | fx_process_dispatch | low | 0 | run active effect by mode: per-sample float DSP loop |
| `0x0201a2a0` | fx_delayline_init | med | 0 | init effect stage: alloc count*4 delay buffer, store coefficient |
| `0x0201a2b4` | fx_effect_create | med | 0 | construct effect object: allocate delay stages, load coefficients |
| `0x0201a7e2` | fx_reverb_process | low | 0 | multi-stage comb/allpass effect render loop over sample block |
| `0x0201bf96` | fx_biquad_setup | med | 0 | compute biquad filter node coefficients via exp2, sample-rate scaled |
| `0x0201cdcc` | fx_chorus_init | med | 0 | init chorus/phaser effect: LFO constants, modulated delay taps |
| `0x0204474a` | rodata_fx_preset_coeffs | low | 0 | misdecoded rodata: effect preset float lists, sin-deg, font cmap |
| `0x02046426` | rodata_fx_tables_cont | low | 0 | misdecoded rodata: effect/synth parameter table continuation |
| `0x02087a26` | fx_chain_process | med | 0 | buffer swap, 6 effect-slot dispatch, reverb network, DMA IRQ |

## AUDIO_OUT (137)

| addr | name | conf | callers | purpose |
|---|---|---|---|---|
| `0x0200323c` | audio_module_init | low | 1 | one-time module init, register entry with sample-rate table |
| `0x02033978` | audio_slot_enable_locked | low | 0 | set per-slot enable bit in audio SFR under lock |
| `0x020339ea` | audio_channel_open | low | 0 | init audio channel slot: IRQ, SFR, state struct |
| `0x02033a62` | audio_slot_status_read | low | 0 | read per-slot busy status bit from audio SFR |
| `0x02033a7e` | audio_sfr_flag_read | low | 0 | read audio block status flag bit 18 |
| `0x02033b30` | audio_chan_fsm_run | low | 0 | dual-channel audio driver state machine with IRQ handlers |
| `0x02034a28` | audio_ana_field_write_a | low | 0 | write 8-bit field of analog control SFR |
| `0x02034a3c` | audio_ana_field_write_b | low | 0 | write 7-bit field of analog control SFR |
| `0x02034a52` | audio_ana_strobe_seq | low | 0 | toggle analog control bits with timed delay loops |
| `0x02034aee` | audio_ana_status_read | low | 0 | read analog calibration status bits via RAM stub |
| `0x02034b04` | trim_code_lookup | low | 0 | find first trim table entry above given value |
| `0x02034b2c` | audio_dac_trim_calibrate | med | 0 | 47-step analog trim sweep building midpoint table |
| `0x02034c38` | audio_reg_commit_strobe | low | 0 | pulse commit bit five times on audio SFR |
| `0x02034c68` | audio_coeff_table_upload | low | 0 | upload 256-entry 64-bit coefficient table to hardware |
| `0x02034e02` | audio_ana_regs_preset | low | 0 | bulk bit set/clear preset of analog block SFRs |
| `0x020351c6` | audio_ana_seq_init | low | 0 | short analog register write sequence then commit |
| `0x020351f4` | audio_sfr_block_preset | low | 0 | write six audio block SFR config values |
| `0x02035258` | audio_analog_init_mode | med | 0 | write two-mode analog register init table |
| `0x0203554c` | audio_coeff_ram_upload | low | 0 | upload 128 32-bit words via indexed register window |
| `0x0203560c` | audio_ana_write_pair | low | 0 | write indexed register pair with commit flag |
| `0x02035630` | audio_codec_init | med | 0 | full audio codec register and coefficient init sequence |
| `0x02036192` | audio_ana_write_verify | low | 0 | write analog register block and verify echo |
| `0x020361aa` | audio_ana_field_set | low | 0 | set 2-bit field in analog register 81 |
| `0x020361ce` | audio_gain_table_init | low | 0 | upload 128-entry gain table and output stage config |
| `0x02036368` | audio_trim_data_load | low | 0 | load 20-byte trim data with rodata default fallback |
| `0x02036448` | audio_reg_cmd_write | low | 0 | compose and write command word to audio SFR |
| `0x020386a8` | jlstream_obj_unlink_free | med | 0 | locked unlink of stream object node then free |
| `0x02038702` | jlstream_object_create | med | 0 | name-keyed stream node/pipeline create and destroy |
| `0x020389ce` | jlstream_pipeline_task | med | 0 | post node event message; pipeline data-pump worker loop |
| `0x02038cce` | jlstream_node_get_info | med | 0 | query node info string via callback under mutex |
| `0x02038d74` | jlstream_node_type_lookup | med | 0 | resolve node type name via aliases to registry entry |
| `0x02038df2` | jlstream_node_type_probe | med | 0 | scan node type registry calling probe until accepted |
| `0x02038e34` | jlstream_state_slot_alloc | med | 0 | allocate per-instance stream state slot under lock |
| `0x02038ee2` | jlstream_node_open | med | 0 | instantiate stream node: bind ops, alloc buffers, subscribe |
| `0x020395c6` | jlstream_node_start | med | 0 | wait for buffer ready then issue node start ioctls |
| `0x0203967c` | jlstream_node_flush | med | 0 | transition node state, issue control ioctls to downstream node |
| `0x020396e0` | jlstream_node_release_buffers | low | 0 | release node input/resample/downstream sub-buffers during teardown |
| `0x02039712` | jlstream_node_op_call | low | 0 | trampoline invoking node op-table callback with packed args |
| `0x0203972c` | jlstream_node_command_dispatch | med | 0 | jlstream node command dispatcher: start/stop/link/param via jump table |
| `0x02039de8` | jlstream_node_open | med | 0 | create stream node by name, alloc buffers, init params |
| `0x0203a1e2` | jlstream_node_start | med | 0 | set node running: start ioctl, state 5, post semaphore |
| `0x0203a21e` | jlstream_node_stop | med | 0 | stop node: flush entries, issue stop ioctl, post semaphore |
| `0x0203a288` | jlstream_task_loop | med | 0 | jlstream framework message loop and node close/destroy |
| `0x0203a5ee` | jlstream_node_data_fill | low | 0 | fill node output from cbuf, memset silence on underrun |
| `0x0203a7d8` | audio_src_feed_dac | med | 0 | feed PCM through hardware SRC regs 0x14300 into DAC ring |
| `0x0203aab2` | audio_callback_thunk | low | 0 | four-arg shuffle trampoline calling function pointer in r0 |
| `0x0203aac0` | jlstream_node_process | med | 0 | pull cbuf data, run node handler, push to DAC output |
| `0x0203ae92` | sbc_node_read_clamp | low | 0 | call node read op, clamp returned length to configured max |
| `0x0203aece` | sbc_frame_sync | high | 0 | locate SBC frame via 0x9C sync, compute next-frame offset |
| `0x0203af12` | sbc_framer_node_ops | med | 0 | SBC frame length from header bitfields; node open/read/free ops |
| `0x0203b6f4` | stream_bufmgr_ioctl_dispatch | med | 0 | stream buffer-manager ioctl dispatcher for 0x80044100-family commands |
| `0x0203c0ae` | jlstream_pipeline_destroy | med | 0 | walk node children, run close/free ops, unlink and free |
| `0x0203c19a` | jlstream_cbuf_block_xfer | low | 0 | 32-byte block copies via cbuf, then subscriber event dispatch |
| `0x0203c3f8` | plnk_device_block | med | 0 | PLNK/PDM-link audio device init, pump loop, IRQ handlers |
| `0x0203c92a` | audio_dac_channel_init | med | 0 | map audio pins via IOMC, alloc DMA buffer, program DAC descriptor |
| `0x0203cd70` | audio_dac_deinit | med | 0 | restore DAC regs 0x12B00 to defaults, free DMA buffer |
| `0x0203ce06` | audio_dac_device_ops | med | 0 | DAC device block: subscriber notify, channel config, DMA IRQ, PCM convert |
| `0x0203d97a` | audio_dac_dma_refill | med | 0 | compute buffer offsets, invoke per-channel DMA refill callback |
| `0x0203dbb4` | audio_dac_channel_config | med | 0 | multi-channel DAC routing bits, gains, DMA descriptors, pin config |
| `0x0203e03c` | audio_sample_rate_set | high | 0 | program clock dividers for 8k-192k sample rates |
| `0x0203e2a8` | audio_channel_start | med | 0 | start channels per bitmask: rate, clear buffers, mark descriptors active |
| `0x0203e376` | audio_channel_stop | med | 0 | stop/pause channels per bitmask, clear descriptor enable bits |
| `0x0203e438` | audio_channel_reset | med | 0 | clear descriptors, free buffer, remap pins, notify pipeline |
| `0x0203e720` | pcm_deinterleave_format_convert | med | 0 | de-interleave 2-4ch PCM, expand 16/24-bit samples for DAC output |
| `0x0203e962` | audio_channel_irq_dispatch | med | 0 | per-channel callback dispatch from DAC IRQ handlers |
| `0x0203eb14` | audio_channel_open | med | 0 | alloc channel node, link into device channel list |
| `0x0203edba` | audio_channel_close | med | 0 | unlink and free channel, select current device |
| `0x0203eec8` | audio_dac_trim_write | med | 0 | write per-channel trim code via 4-way jump table |
| `0x0203eeee` | audio_dac_trim_sense | med | 0 | poll trim comparator with clock-scaled settle delays |
| `0x0203ef56` | audio_dac_trim_calibrate | med | 0 | scan trim codes until comparator matches reference |
| `0x0203f018` | audio_dac_set_digital_volume | high | 0 | volume 0-100 to gain table, write DAC gain regs |
| `0x0203f0b0` | audio_dac_gain_mode_set | med | 0 | dispatch DAC analog gain by mode, post async message |
| `0x0203f6e0` | audio_dac_dma_stop | high | 0 | stop DAC DMA, wait pending clear, zero buffer |
| `0x0203f730` | audio_dac_set_sample_rate | med | 0 | map rate via 12-entry table, write DAC rate field |
| `0x0203f79a` | audio_dac_fifo_config | med | 0 | configure DAC FIFO thresholds and channel enables |
| `0x0203f838` | audio_dev_event_dispatch | med | 0 | channel event/ioctl/write path with sample format convert |
| `0x02040074` | audio_dac_channel_route | med | 0 | per-channel analog routing and mux register config |
| `0x020404ae` | audio_dac_set_analog_gain | med | 0 | volume 0-100 to 4/5-bit analog gain per channel |
| `0x0204055a` | audio_dac_output_enable | med | 0 | enable and route DAC output channels in control reg |
| `0x020405c0` | audio_adc_channel_enable | med | 0 | set ADC/DAC channel enable bits from args |
| `0x02040602` | audio_dac_open | med | 0 | open DAC device: configure regs, alloc DMA, set rate |
| `0x02040cfc` | audio_dac_fifo_reset | med | 0 | clear DAC FIFO and DMA config when running |
| `0x02040d2e` | audio_dac_gain_broadcast | med | 0 | write gain nibbles to all enabled channels of device |
| `0x02040df0` | audio_dac_output_open | med | 0 | FIFO config, sample-rate switch, output open/close/ioctl |
| `0x020413fa` | audio_dac_irq_handler | med | 0 | DAC DMA IRQ: refill halves via render callback, demux |
| `0x0205caac` | audio_dac_cfg_pack | low | 0 | pack parameters into DAC config halfword |
| `0x0205cac2` | audio_state_set_guarded | low | 0 | set audio state byte, call hardware func on change |
| `0x0205cb3e` | dac_vol_clamp_l | low | 0 | clamp volume index to 11, set channel flag |
| `0x0205cb48` | dac_vol_clamp_r | low | 0 | clamp volume index to 11, set channel flag (copy) |
| `0x0205cb52` | dac_state_flag_get | low | 0 | read DAC state flag byte |
| `0x0205cb5e` | dac_trim_save | med | 0 | compute DAC trim value, write 6 bytes to VM 110 |
| `0x0205cb9c` | dac_trim_get | low | 0 | read DAC trim halfword |
| `0x0205cba8` | dac_trim_adjust | low | 0 | add delta to DAC trim halfword when idle |
| `0x0205cbbc` | audio_dac_sr_calc | low | 0 | compute DAC clock/sample-rate trim via double math |
| `0x0205de4a` | audio_dac_power_down | med | 0 | disable DAC analog block, gate audio clock off |
| `0x0205de94` | dac_state_flag_clear | low | 0 | clear DAC busy/mute flag byte |
| `0x0208392c` | audio_dac_analog_mode_set | med | 0 | configure DAC analog register fields for mode 1-4 |
| `0x02083aa4` | audio_dac_trim_pulse_read | med | 0 | strobe trim counter, short delay, read result |
| `0x02083aca` | audio_adda_link_write | med | 0 | raw write to codec serial link, DMA or direct |
| `0x02083b00` | audio_adda_reg_write | med | 0 | write codec analog register via serial port |
| `0x02083b1e` | audio_adda_init_seq | med | 0 | codec analog init register write sequence |
| `0x02083b42` | adda_win208_write | med | 0 | indexed analog reg write via window 208-210 |
| `0x02083b5a` | adda_win200_write | med | 0 | indexed analog reg write via window 200-202 |
| `0x02083b72` | audio_dac_analog_init | med | 0 | init DAC analog regs, poll trim, program DAA |
| `0x02083cf4` | audio_adda_reg_read | med | 0 | read codec analog register via serial port |
| `0x02083d24` | adda_win200_read | med | 0 | indexed analog reg read via window 200 |
| `0x02083d3c` | audio_dac_analog_mute | low | 0 | clear enable bits in analog regs 64/65/4 |
| `0x02083d7a` | audio_adda_power_seq | low | 0 | run codec init seq, set analog reg 25 |
| `0x02083d94` | adda_win208_read | med | 0 | indexed analog reg read via window 208 |
| `0x02083dac` | audio_trim_dac4_set | med | 0 | write 10-bit trim value to analog regs 4/97 |
| `0x02083dd0` | audio_trim_dac6_set | med | 0 | write 10-bit trim value to analog regs 6/97 |
| `0x02083df6` | audio_trim_dac5_set | med | 0 | write 10-bit trim value to analog regs 5/97 |
| `0x02083e1c` | audio_trim_dac7_set | med | 0 | write 10-bit trim value to analog regs 7/97 |
| `0x02083e40` | audio_trim_dac8_set | med | 0 | write 10-bit trim value to analog regs 8/98 |
| `0x02083e64` | audio_trim_dac9_set | med | 0 | write 10-bit trim value to analog regs 9/98 |
| `0x02083e8a` | audio_dac_trim_write_1191c | low | 0 | write 7-bit trim field of codec reg 0x1191C |
| `0x02083ea0` | audio_adc_con_rmw | low | 0 | read-modify-write bitfield of codec reg 0x11920 |
| `0x02083eb2` | audio_dac_trim_config_load | med | 0 | load per-index trim config from RAM into DAC regs |
| `0x02083f48` | adda_win212_read | med | 0 | indexed analog reg read via window 212 |
| `0x02083f62` | audio_adda_osc_count_read | low | 0 | trigger analog measure, calibrated delay, read result |
| `0x02083fb0` | audio_dac_trim_config_autoselect | med | 0 | try 4 trim configs, keep first under threshold |
| `0x02083fe0` | audio_dac_trim_calibrate | med | 0 | codec init then sweep trims minimizing measured power |
| `0x0208434e` | audio_dac_dcc_set | med | 0 | write signed 9-bit DC-offset trim to DAC reg |
| `0x0208437c` | audio_dac_dcc_trim_calibrate | med | 0 | binary-search DAC DC-offset trim, store per-config results |
| `0x02084564` | adda_win212_write_9 | med | 0 | write analog ext reg 9 via window 212 |
| `0x02084570` | adda_win212_write_11 | med | 0 | write analog ext reg 11 via window 212 |
| `0x0208457c` | adda_win212_write_10 | med | 0 | write analog ext reg 10 via window 212 |
| `0x02084588` | audio_dac_trim_calibrate_aux | low | 0 | sweep ext regs 9-12 trims minimizing measurement |
| `0x020857fe` | audio_buf_state_init | med | 0 | reset block counters, zero 512B ping-pong buffer |
| `0x02086da2` | asrc_ring_read_interp | med | 0 | read sample ring, linear-interpolate to 24-bit stereo |
| `0x02088eee` | audio_dac_dma_irq | med | 0 | DAC DMA buffer-refill IRQ, event post, timer IRQ |
| `0x02088fc2` | pcm_mix_to_dac | med | 0 | mix 16-bit PCM into 32-bit DAC buffer with gain |
| `0x02089020` | asrc_ring_push | med | 0 | push stereo frames into ASRC ring with channel gains |
| `0x020890cc` | asrc_ring_pop_mix | med | 0 | pop ring frames, scale by gains, accumulate into out |
| `0x0208916c` | audio_dvol_level_process | low | 0 | block digital volume, gain-table map, peak metering |
| `0x0208b604` | audio_fade_step | med | 0 | step float gain toward target per block, callback |
| `0x0208b736` | audio_stream_frame_fsm | med | 0 | stream open/run/fade-out pump with soft gain curve |

## STORAGE_FS (215)

| addr | name | conf | callers | purpose |
|---|---|---|---|---|
| `0x0200372c` | norflash_read_core | med | 0 | mutex-guarded flash read in 256-byte ROM-call chunks |
| `0x020037b4` | norflash_read | med | 0 | public flash read wrapper, zero on short read |
| `0x020037c8` | sfc_enc_cipher | high | 0 | JieLi ENC LFSR stream cipher over buffer (jl_crypt) |
| `0x0200380a` | norflash_write_core | med | 0 | ROM-call flash write, rescramble ENC-region data |
| `0x020038a2` | norflash_write | med | 0 | public flash write wrapper, zero on failure |
| `0x0201001a` | res_get_file_ext | med | 0 | return pointer past last dot in path string |
| `0x0201004a` | ui_res_open | med | 0 | match path prefix on res device list, probe and open |
| `0x020100ce` | ui_res_read | med | 0 | buffered res file read with read-ahead cache |
| `0x0201d33a` | norflash_ioctl | med | 0 | flash device ioctl dispatcher: erase/write/cache cmds, mutex-guarded |
| `0x0201d4f8` | flash_partition_ioctl | med | 0 | select flash partition by index, issue masked device ioctl |
| `0x0202657e` | stream_read | low | 0 | blocking buffered read on magic-0xA6 stream object |
| `0x020267bc` | stream_close | low | 0 | close stream: wake waiters, free node list |
| `0x020268b6` | image_block_read | low | 0 | buffered sequential read from opened image/update file |
| `0x02026f8e` | cfg_header_crc_check | med | 0 | verify 30-byte config header crc16, return status |
| `0x02026fae` | vm_state_flag_get | low | 0 | return vm module state byte bit0 |
| `0x02026fc2` | flash_erase_region | med | 0 | erase N flash sectors, 4K or 256B mode |
| `0x0202703c` | vm_space_check | low | 0 | check vm used-plus-percent against stored threshold |
| `0x0202707c` | vm_sector_format | med | 0 | write magic, erase sector pair, reset vm state |
| `0x020270da` | flash_copy_block | med | 0 | copy flash range via 256-byte read/write chunks |
| `0x02027112` | vm_garbage_collect | med | 0 | relocate valid vm records, swap ping-pong sector |
| `0x02027292` | vm_maintenance_locked | med | 0 | mutex-locked vm gc/erase maintenance entry point |
| `0x02027346` | flash_erase_align_up | med | 0 | round address up to flash erase block, 256B or 4K by type |
| `0x02027382` | flash_geometry_entry_get | low | 0 | fetch 12-byte geometry table entry and remaining space |
| `0x020273c6` | flash_erase_range | med | 0 | erase address range with 256B/4K/64K granular erase cmds |
| `0x020274de` | flash_erase_range_typed | med | 0 | erase range using geometry-derived block granularity |
| `0x02027508` | vm_area_format | low | 0 | relocate vm data and write crc'd volume label record |
| `0x020277d8` | flash_capacity_get | low | 0 | query flash capacity via norflash ioctl cmd 103 |
| `0x020277ee` | vm_volume_record_verify | med | 0 | verify vm record magic, crc16, 8.3 volume label |
| `0x02027858` | vm_mount_scan | low | 0 | scan vm records from partition end, recover and compact |
| `0x02028220` | norfs_file_obj_init | low | 0 | zalloc 40B file object, copy name, set type tags |
| `0x020282d8` | path_next_component | med | 0 | extract '/'-delimited path component, uppercase, 15-char cap |
| `0x0202832e` | name16_wildcard_match | med | 0 | case-folded 16-byte name compare with '*' '?' wildcards |
| `0x020283b4` | norfs_addr_remap | low | 0 | remap entry offset via registry base and offset pair |
| `0x020283d0` | norfs_dir_find_entry | med | 0 | scan crc'd 32B dir entries for wildcard name match |
| `0x0202847a` | norfs_entry_scan | med | 0 | walk up to 32 dir entries, crc16 and name match |
| `0x020284e2` | norfs_dir_descend | low | 0 | descend one dir level, remap or advance entry base |
| `0x02028512` | norfs_entry_type_check | low | 0 | match entry then return directory-flag bit minus one |
| `0x0202852c` | norfs_path_find | low | 0 | resolve multi-component path through dir scans |
| `0x020285d4` | norfs_find_entry_in | low | 0 | scan device dir table for named crc'd entry |
| `0x0202863c` | norfs_open_subpath | low | 0 | open two-component path, require entry type three |
| `0x020286a0` | norfs_fopen | med | 0 | resolve path into file obj; trailing read/write/seek/close ops |
| `0x0202896e` | flash_read_locked | low | 0 | mutex-protected flash read via indirect rom call |
| `0x02028998` | update_file_open | low | 0 | open path on usb_update_mode device, verify entry crcs |
| `0x02028b44` | norfs_find_global_entry | low | 0 | find named entry scanning registry-backed dir records |
| `0x02028ba2` | norflash_dev_init | med | 0 | norflash init: rom id read, capacity 2^n, register device |
| `0x02028c42` | wildcard_str_match | med | 0 | bounded string compare with '*' '?' wildcards, zero on match |
| `0x02028ff2` | check_mbr_part_entry | med | 0 | validate one 16-byte MBR partition entry fields |
| `0x02029042` | scan_mbr_partitions | high | 0 | walk MBR/EBR partition tables collecting volume LBAs |
| `0x020291f0` | fatfs_obj_release | med | 0 | release FATFS object, unlink and free last ref |
| `0x02029210` | mount_alloc_fs | med | 0 | allocate and link FATFS object, query sector count |
| `0x020292ba` | sync_window | high | 0 | write back dirty cached sector window |
| `0x020292fc` | move_window | high | 0 | sync then load requested sector into window |
| `0x02029352` | mount_volume | high | 0 | parse BPB, detect FAT12/16/32, register volume |
| `0x02029762` | f_mkfs | high | 0 | format volume: pick geometry, write BPB/FAT/root |
| `0x02029f28` | dir_sdi | high | 0 | set directory cursor to index, resolve sector |
| `0x02029f6c` | get_fat | high | 0 | read FAT entry, exFAT contiguous-chain fast path |
| `0x02029fde` | change_bitmap | high | 0 | set/clear bits in exFAT allocation bitmap |
| `0x0202a09a` | put_fat | high | 0 | write FAT12/16/32 entry for a cluster |
| `0x0202a1d8` | link_fat_chain | med | 0 | loop put_fat linking contiguous cluster chain |
| `0x0202a20a` | create_chain | high | 0 | find free cluster, extend or create chain |
| `0x0202a468` | zero_cluster | med | 0 | zero-fill all sectors of a fresh cluster |
| `0x0202a4ee` | dir_next | high | 0 | advance directory cursor, allocate cluster if create |
| `0x0202a5f6` | get_fileinfo | high | 0 | fill file-info struct from raw directory entry |
| `0x0202a6a8` | dir_read | med | 0 | scan directory entries, assemble LFN, fill file info |
| `0x0202ab50` | dir_alloc | med | 0 | find n contiguous free directory entry slots |
| `0x0202abfa` | sync_fs | high | 0 | write FAT32 FSInfo sector when counts dirty |
| `0x0202ac84` | f_setlabel | high | 0 | create or update volume label directory entry |
| `0x0202adbc` | f_getfree | high | 0 | count free clusters by scanning FAT, cache result |
| `0x0202aef8` | fatfs_obj_alloc | low | 0 | malloc 812-byte filesystem work object |
| `0x0202af06` | fatfs_obj_free | low | 0 | free filesystem work object wrapper |
| `0x0202af10` | create_name | high | 0 | parse path into SFN pattern plus LFN |
| `0x0202b136` | count_wildcards | med | 0 | count '*' wildcard chars in pattern string |
| `0x0202b158` | match_wildcard_ci | med | 0 | case-insensitive wildcard compare via uppercased copies |
| `0x0202b232` | scan_max_file_suffix | med | 0 | scan dir for pattern, track max numeric suffix |
| `0x0202b36e` | file_obj_reset | low | 0 | reinit file object, preserve name and flags |
| `0x0202b3d6` | dir_block_compact | low | 0 | scan/compact 32-byte dir entries in sector buffer |
| `0x0202b498` | utf16_name_terminate_len | med | 0 | terminate UTF-16 name at 0/0xFFFF, return length |
| `0x0202b4d0` | fat83_wildcard_match | high | 0 | match 8.3 name allowing '*' and '?' wildcards |
| `0x0202b53a` | fat_dir_lookup | med | 0 | lookup name in directory with wildcard fallback compare |
| `0x0202b5cc` | fat_name_len_trim_space | high | 0 | length of name before first space character |
| `0x0202b5e6` | fat_name_to_83 | high | 0 | convert filename to padded uppercase 8.3 format |
| `0x0202b63e` | fs_dirpos_copy_or_clear | low | 0 | copy 12-byte dir position or zero 44-byte struct |
| `0x0202b652` | fatfs_walk_path | med | 0 | walk directory tree by path components, return entry |
| `0x0202b6f4` | fat_dirent_set_cluster | high | 0 | store cluster number into FAT dir entry |
| `0x0202b70c` | fat_pack_current_datetime | med | 0 | build packed FAT date/time from system time |
| `0x0202b77c` | exfat_release_cluster_chain | low | 0 | free cluster chain when stream-extension flags allow |
| `0x0202b7b0` | fs_dirpos_copy_lock | low | 0 | copy 20-byte dir position then invoke lock helper |
| `0x0202b7c8` | exfat_entry_set_checksum | high | 0 | exFAT entry-set rotate-add checksum, skipping bytes 2-3 |
| `0x0202b7f2` | exfat_read_verify_entry_set | med | 0 | read exFAT entry set and verify its checksum |
| `0x0202b8ea` | exfat_write_entry_set | med | 0 | write exFAT entry set with checksum to disk |
| `0x0202b96c` | exfat_build_entry_set | high | 0 | build 0x85/0xC0/0xC1 entries and compute name hash |
| `0x0202ba86` | exfat_create_dirent | med | 0 | create new exFAT file/dir entry set with timestamps |
| `0x0202bcbe` | fat_shortname_checksum | high | 0 | FAT LFN 8.3 shortname checksum over 11 bytes |
| `0x0202bcde` | fat_create_lfn_entries | high | 0 | write FAT LFN plus short entries for new file |
| `0x0202be28` | fat_extend_cluster_chain | med | 0 | walk or extend cluster chain, update allocation count |
| `0x0202bec6` | fatfs_mkdir | med | 0 | create directory with dot entries, LFN and exFAT |
| `0x0202c172` | fat_dirent_get_cluster | high | 0 | read first-cluster number from FAT dir entry |
| `0x0202c19a` | fatfs_open | med | 0 | open/create file by path, handling truncate and exFAT |
| `0x0202c540` | fatfs_open_path_sfn | med | 0 | resolve path, generate 8.3 numeric-tail aliases, open |
| `0x0202ca26` | fatfs_fopen | med | 0 | open file handle from r/w/rb mode string |
| `0x0202caa0` | fat_next_cluster_cached | med | 0 | FAT next-cluster lookup with per-type sector caching |
| `0x0202cb46` | fatfs_read | med | 0 | read file data via cluster runs and sector cache |
| `0x0202cd42` | fatfs_sync_entry | med | 0 | flush file: update dir entry size, cluster, timestamps |
| `0x0202cf16` | fatfs_write | med | 0 | write file data, extending cluster chain as needed |
| `0x0202d1c2` | fatfs_lseek | med | 0 | seek file position across cluster chain |
| `0x0202d41e` | fatfs_readdir | med | 0 | read next directory entry, extracting LFN/exFAT name |
| `0x0202d550` | fatfs_get_entry_name | low | 0 | format current entry name from 8.3 or LFN |
| `0x0202d6fe` | fatfs_build_dir_path | med | 0 | build absolute path string from dir-handle component stack |
| `0x0202d990` | fatfs_rename | med | 0 | rename: delete old entries, recreate with new name |
| `0x0202dc50` | fatfs_fclose | med | 0 | close file: sync entry, free cache and handle |
| `0x0202dd30` | fatfs_close_release | low | 0 | close file then free handle and volume reference |
| `0x0202dd52` | fatfs_cache_put | low | 0 | release cached sector node, renumber linked cache list |
| `0x0202de3a` | fatfs_mark_dirent_deleted | med | 0 | mark dir entry chain with 0xE5 deleted marker |
| `0x0202de9e` | fatfs_unlink | med | 0 | delete file entry set and release its clusters |
| `0x0202e0fa` | fatfs_alloc_volume_struct | low | 0 | allocate 760-byte filesystem struct via malloc |
| `0x0202e108` | fscan_ctx_alloc_tsort | low | 0 | alloc 2808B scan ctx incl. 2048B node pool |
| `0x0202e116` | vfs_fopen | med | 0 | resolve path, alloc 804B file ctx, fill FILE |
| `0x0202e190` | fat_path_component_match | med | 0 | match '/'-separated path components against dir names |
| `0x0202e1e2` | fat_dir_walk | med | 0 | recursive dir walk: attr filter, wildcard, callback, path stack |
| `0x0202e4e6` | fat_fscan_init | med | 0 | init scan ctx + node pool, open path, start walk |
| `0x0202e5ce` | fat_fscan_create | med | 0 | fscan/fscan_interrupt constructors, parse sort/attr args |
| `0x0202e774` | fat_lfn_collect | low | 0 | collect UCS-2 name pieces from LFN dir entries |
| `0x0202e80e` | fat_fill_name_bufs | low | 0 | fill entry long-name buffers under device lock |
| `0x0202e8c2` | fat_file_rebind | low | 0 | rebind file cursor fields, flag dir/vol attr |
| `0x0202e904` | fat_fcopy | med | 0 | clone file handle regions (fcopy op), rebind cursor |
| `0x0202e94e` | fat_dir_match_count | low | 0 | count dir entries matching filter flags and pattern |
| `0x0202e9be` | fat_get_file_num | low | 0 | snapshot ctx, count matching entries without cursor move |
| `0x0202ea36` | fat_fsel_resolve | low | 0 | open selected dir entry as FILE, fetch names |
| `0x0202eaee` | fat_scan_restart | low | 0 | reset scan lists and restart directory walk |
| `0x0202eb74` | fat_scan_node_fetch_fwd | low | 0 | fetch cached scan node, restart walk if stale |
| `0x0202eb9e` | fat_scan_node_fetch_back | low | 0 | fetch backward scan node, restart walk if stale |
| `0x0202ebc2` | fat_scan_node_fetch_cur | low | 0 | fetch current scan node or restart walk |
| `0x0202ebe4` | fat_scan_node_fetch_next | low | 0 | fetch next scan node or restart walk |
| `0x0202ec06` | fat_scan_node_at | low | 0 | locate scan node by index/cluster walking cache list |
| `0x0202ec6a` | fat_fsel | high | 0 | file-select dispatcher: first/next/prev/num/path + cycle modes |
| `0x0202f180` | fat_fget_attrs | high | 0 | fill vfs_attr incl. FAT datetime decode (+1980 epoch) |
| `0x0202f1f0` | fat_dirent_rewrite | low | 0 | copy out dir entries, mark 0xE5/attr, flush sectors |
| `0x0202f384` | fat_frename | low | 0 | split dst path, open parent, rewrite child entries (rename) |
| `0x0202f4e0` | fat_fget_folder_info | low | 0 | tally file/dir counts for folder info query |
| `0x0202f596` | fat_fget_folder_prev | low | 0 | tally counts for previous folder after index decrement |
| `0x0202f62c` | fat_dirent_fetch_name | low | 0 | read entry sector chain, copy long name into record |
| `0x0202f6a8` | fat_fget_dir_info | med | 0 | enumerate dir into 0x20C-byte records with skip/count |
| `0x0202f7f2` | fat_fget_file_byname_indir | low | 0 | find same-name different-extension file in directory |
| `0x0202f9b2` | fat_get_last_file_num | med | 0 | scan numbered filenames, return count and max index |
| `0x0202fa52` | fat_fsave_fat_table | med | 0 | build file cluster map for fast seek |
| `0x0202faf2` | fat_dirent_write | low | 0 | write dir entry: archive bit, timestamps, flush via device |
| `0x0202fbae` | fat_file_set_size | low | 0 | grow/shrink file cluster chain, update size and entry |
| `0x0202fc8a` | fat_fwrite | low | 0 | buffered write split at cluster boundaries |
| `0x0202fd5e` | fat_cluster_cache_lookup | low | 0 | map file offset to cluster via 5-entry range cache |
| `0x0202fe2e` | fat_ioctl | high | 0 | 22-case FS_IOCTL dispatcher: lfn bufs, dir info, seek |
| `0x02032140` | vm_area_init | med | 0 | scan VM flash areas, build record offset cache |
| `0x02032490` | vm_id_valid | med | 0 | check vm item id below 256 |
| `0x0203249c` | vm_read | med | 0 | read VM record by id with crc8 verify |
| `0x020328f4` | cfg_entry_lookup | low | 0 | find config entry matching tag "1A1" |
| `0x02032902` | cfg_blob_mount | low | 0 | locate config blob, verify count and crc |
| `0x020329e6` | cfg_id_table_lookup | low | 0 | match id in const descending id table |
| `0x02032a08` | cfg_tlv_find | med | 0 | walk TLV blob for matching id, verify crc8 |
| `0x02032a68` | cfg_tlv_find_dual | med | 0 | find TLV record in secondary or primary blob |
| `0x02032a90` | cfg_read_by_index | low | 0 | read config record payload via index entry |
| `0x02032b06` | cfg_read_by_id | med | 0 | read config record data and length by id |
| `0x02032ba4` | cfg_blob_mount_alt | low | 0 | mount second config blob region |
| `0x02032be2` | cfg_index_offset_scan | low | 0 | sum record lengths to compute item offset |
| `0x02032c10` | cfg_item_read_verify | med | 0 | read and crc-verify config item by id |
| `0x02055c00` | ftl_lba_to_flash_addr | med | 0 | map logical sector index to flash byte offset |
| `0x02055c36` | ftl_translate_sector | low | 0 | translate sector via cached map entries, type dispatch |
| `0x02055d48` | ftl_translate_wrapper | med | 0 | thin tail-call wrapper over ftl_translate_sector |
| `0x02055d50` | ftl_build_io_descriptors | low | 0 | split byte range into 12-byte io descriptor records |
| `0x02055e50` | norfs_read_sectors | med | 0 | buffered 512-byte sector read via zeroed bounce buffer |
| `0x020560dc` | norfs_write_sectors | med | 0 | sector write path with read-modify-erase handling |
| `0x020562f0` | norfs_write_fill | low | 0 | write/copy helper with memset padding and flush |
| `0x02061bb0` | dev_service_init | low | 0 | alloc device object and 512-byte buffer, register task |
| `0x02061cca` | dev_node_find_by_id | low | 0 | walk service list, return node matching halfword id |
| `0x02061d0c` | dev_msg_post | low | 0 | build message with string payload and post to service |
| `0x02061d6a` | dev_msg_post_ex | low | 0 | variant message post with optional payload copy |
| `0x02061dcc` | dev_msg_post_fn | low | 0 | post fixed five-byte message carrying code pointer |
| `0x02061e9a` | dev_event_post | low | 0 | alloc event message id 62 with payload, enqueue, signal |
| `0x02061f40` | dev_event_report | low | 0 | select format by switch, forward event to dev_event_post |
| `0x0207635c` | flash_record_read | med | 0 | bounded 32-byte record read via registered flash ops |
| `0x020763e2` | flash_record_read_latest | med | 0 | scan records, crc16-verify, return newest valid 32-byte record |
| `0x02076472` | kv_header_load_or_format | med | 0 | load 14-byte store header id113, format if invalid |
| `0x020764d0` | kv_entry_read_check | low | 0 | read 52-byte entry id114+slot, validate tag nibble |
| `0x0207650a` | kv_store_wipe | low | 0 | erase all valid 52-byte entries, re-init header |
| `0x02076560` | kv_store_gc | low | 0 | validate/rewrite entries, renumber slots, persist header |
| `0x02076b60` | vm_store_cursor_adjust | med | 0 | set/add/sub flash record-store write cursor |
| `0x02076b7a` | vm_chunk_write | med | 0 | write 32-byte chunk through flash device vtable |
| `0x020824ae` | update_ctx_alloc | med | 0 | allocate and init 104-byte update reader context |
| `0x020824de` | update_state_notify | low | 0 | set update state byte, invoke registered callback |
| `0x020824fa` | jl_sfc_cipher | high | 0 | flash XOR stream cipher, key^(offset>>2) per 32-byte block |
| `0x020829f2` | jlfs_entry_find_load | med | 0 | find 32-byte entry by name, decrypt and CRC-verify payload |
| `0x02082ad4` | flash_buf_is_erased | high | 0 | check buffer is entirely 0xFF (erased flash) |
| `0x02082af4` | flash_read_decipher | med | 0 | unaligned flash read plus sfc decipher into destination |
| `0x02082cfe` | update_reader_close | low | 0 | call update device close/release callback if registered |
| `0x02082d14` | jieli_update_set_offset | low | 0 | store 64-bit offset+size into update context |
| `0x02082d24` | jieli_ufw_update_run | med | 0 | verify UFW header/chip-id, flash verified blocks with progress |
| `0x0208332a` | jieli_update_file_check | low | 0 | check update file; delete or format-and-hang on mismatch |
| `0x02083394` | jieli_update_dispatch | med | 0 | dispatch update file types 0x5A02-0x5A08, run flasher |
| `0x02083458` | jieli_update_entry | low | 0 | busy-guard wrapper dispatching update command |
| `0x02084700` | norflash_spi0_guard | low | 0 | wait SFC idle, disable SPI0, restore saved CON |
| `0x020847f2` | norflash_enter_4byte_addr | high | 0 | send flash EN4B 0xB7 once when addr >=16MB on >16MB flash |
| `0x02084824` | norflash_write_enable | med | 0 | issue WREN, branch on flash JEDEC type bits |
| `0x02084862` | norflash_wren_verify | med | 0 | write-enable then re-check status register bit |
| `0x02084872` | spiflash_send_addr | high | 0 | shift out 3/4-byte flash address, 4-byte mode flag |
| `0x02084896` | spiflash_addr_translate | med | 0 | convert CPU address to flash device offset |
| `0x020848b0` | spiflash_rx_byte | high | 0 | receive one byte via SFC data register |
| `0x020848d0` | spiflash_wait_ready | high | 0 | poll flash status register until not busy |
| `0x0208490e` | spiflash_read_byte | med | 0 | read one byte from SFC data register |
| `0x02084924` | spiflash_read_burst | med | 0 | burst read N bytes, dual/quad per chip type |
| `0x020849a4` | spiflash_tx_byte | high | 0 | transmit one byte via SFC data register |
| `0x020849b4` | spiflash_write_burst | med | 0 | burst write N bytes, dual/quad per chip type |
| `0x02084a30` | spiflash_io_dispatch | med | 0 | dispatch read/program/erase opcodes per flash type |
| `0x02084b74` | spiflash_read_reg | med | 0 | single-byte flash register read wrapper |
| `0x02084b88` | spiflash_cache_sync | med | 0 | invalidate icache once when flash range modified |
| `0x02084bbe` | norflash_cs_and_erase | med | 0 | cmd-mode enter/exit; erase, read, write, JEDEC bodies |
| `0x02084de8` | spiflash_read_status | high | 0 | read status registers 1 and 2 (05h/35h) |
| `0x02084e22` | spiflash_write_status_cfg | med | 0 | write SR1/SR2, block-protect; power-down, security-reg bodies |

## STORAGE_PATCH (3)

| addr | name | conf | callers | purpose |
|---|---|---|---|---|
| `0x0201d532` | dx7voice_pack_store | high | 1 | pack 155B VCED voice to 128B DX7 VMEM, write flash |
| `0x0201d69c` | dx7patch_load_or_store | med | 0 | load/unpack DX7 voice bank from flash; persist edited slots |
| `0x0201dab8` | dx7patch_select_apply | med | 0 | select patch: load, unpack, apply params, show name |

## BT (719)

| addr | name | conf | callers | purpose |
|---|---|---|---|---|
| `0x0200310e` | bt_config_init | med | 0 | load BT/BLE MAC and RF-power syscfg items, apply |
| `0x020032f4` | bt_mac_addr_init | med | 0 | load BT MAC or generate random one and persist |
| `0x0201f0d0` | bt_ble_msg_post | med | 0 | post BLE state messages 12-15 from flag bits |
| `0x0201f144` | bt_ble_supervision_tick | med | 0 | BLE countdown timer posting connect/advertising messages |
| `0x0201f200` | bt_ble_toggle | med | 0 | BLE enable/disable toggle; rebuilds name with _BLE suffix |
| `0x020304bc` | bt_data_channel_open | low | 0 | register/create BT channel worker, buffers, flow thresholds |
| `0x02030654` | bt_data_channel_close | low | 0 | tear down BT channel worker and buffer pool |
| `0x020306c6` | bt_sys_event_handler | med | 0 | dispatch SYS_BT_EVENT: conn params, BD_ADDR, timeouts |
| `0x020375f2` | att_build_value_response | med | 0 | build ATT response: 3-byte header plus MTU-clamped value |
| `0x02037622` | att_error_response | high | 0 | write ATT error response (opcode 0x01, req-op, handle, err) |
| `0x02037636` | att_error_invalid_handle | med | 0 | ATT error response thunk with code 0x01 invalid handle |
| `0x0203763e` | att_db_iterator_advance | med | 0 | decode attribute record fields, advance GATT database iterator |
| `0x020376a0` | att_error_attribute_not_found | med | 0 | ATT error response thunk with code 0x0A |
| `0x020376a8` | uuid128_is_bluetooth_base | high | 0 | test 128-bit UUID against standard Bluetooth base UUID |
| `0x020376d0` | att_uuid16_match | med | 0 | compare attribute record UUID with 16-bit UUID value |
| `0x02037702` | att_uuid_match | med | 0 | match attribute UUID of 2- or 16-byte length |
| `0x02037766` | att_server_check_permission | high | 0 | map attribute permission flags to ATT error code |
| `0x020377aa` | att_service_for_handle | high | 0 | find GATT service whose handle range contains handle |
| `0x020377e4` | att_service_read_callback | med | 0 | return service read-callback pointer or global default |
| `0x020377f8` | att_read_dynamic_value | med | 0 | invoke dynamic read callback and cache value length |
| `0x0203781e` | att_read_attribute_value | med | 0 | copy attribute value to buffer or via dynamic callback |
| `0x0203786e` | att_error_read_not_permitted | med | 0 | ATT error response thunk with code 0x02 |
| `0x02037878` | att_find_attribute_by_handle | med | 0 | iterate GATT database to locate attribute by handle |
| `0x020378a6` | att_service_write_callback | med | 0 | return service write-callback pointer or global default |
| `0x020378ba` | att_error_write_not_permitted | med | 0 | ATT error response thunk with code 0x03 |
| `0x020378c4` | att_invoke_registered_callbacks | med | 0 | call each registered ATT client callback then default |
| `0x0203791e` | att_notify_clients_event3 | low | 0 | thunk notifying registered ATT clients with event 3 |
| `0x02037926` | att_server_handle_request | high | 0 | ATT server PDU dispatcher for opcodes 0x02-0x18,0x52 |
| `0x0205e018` | bt_taskq_post_by_dev | low | 0 | lookup device-table object then post msg 0x400002 to bt taskq |
| `0x0205e0fc` | bt_hook_call_op2 | low | 0 | invoke registered hook function pointer with op 2 |
| `0x0205e1ca` | bt_dev_ops_method24_call | low | 0 | dispatch op via method at +24 of global bt device object |
| `0x0205e1e4` | bt_hci_cmd_msg_send | low | 0 | pack args into [cmd,len,...] msg, send via device op 4 |
| `0x0205e228` | bt_msg_post_type1 | low | 0 | build fixed 12-byte msg id 1, post via stub |
| `0x0205e304` | bt_hci_send_op2 | low | 0 | call device method@+24 with op 2 and two args |
| `0x0205e312` | bt_state_pair_set12 | low | 0 | write two config bytes (12) in bt state struct |
| `0x0205e320` | bt_stack_dev_init | med | 0 | init msg list, register ops vtable 0x205e5e0, run stack inits |
| `0x0205e37a` | btctrler_task_main | med | 0 | task loop: pend msgs, dispatch 0x400002+ switch, run work list |
| `0x0205e594` | bt_dev_msg_post | low | 0 | find device table entry by 6-byte addr, post msg 0x400002 |
| `0x0205e604` | bt_ll_dma_init | med | 0 | alloc link-layer state, register two IRQs, program 0x28000/0x2fc80 SFRs |
| `0x0205e71e` | bt_node_pool_alloc | low | 0 | alloc and zero 8-byte node from pool at struct+24 |
| `0x0205e736` | bt_chan_field_set | low | 0 | insert 5-bit field into channel flags, set shadow halfwords |
| `0x0205e758` | bt_ll_tx_submit | low | 0 | spinlocked: build DMA descriptor, submit TX packet to channel |
| `0x0205e88c` | bt_dma_ptr_to_off | med | 0 | convert DMA buffer pointer to u16 offset, panic if out |
| `0x0205e8b2` | bt_ll_desc_fill | med | 0 | fill halfword DMA channel descriptor fields from format bits |
| `0x0205e962` | bt_ll_channel_set | med | 0 | free/alloc channel node, submit packet, fill descriptor, run callback |
| `0x0205ea6a` | bt_ll_channel_update | low | 0 | spinlocked channel state machine, updates both directions via 0x5e962 |
| `0x0205ebbc` | bt_field_max_update | low | 0 | store halfword at struct+346 if new value larger |
| `0x0205ebc8` | bt_dma_desc_index | med | 0 | convert pointer to 28-byte DMA descriptor index |
| `0x0205ebde` | bt_ll_dma_cmd_send | med | 0 | spinlocked: issue channel/len command to SFR 0x2801c, poll ack |
| `0x0205ec50` | bt_ll_dma_cmd_send_addr | med | 0 | spinlocked: write DMA addr 0x28020 then command to 0x2801c |
| `0x0205ecc4` | bt_ll_config_push | low | 0 | mark dirty flag, push masked config value via DMA command |
| `0x0205ecec` | bt_ll_config_push_if_dirty | low | 0 | spinlocked: push config via 0x5ecc4 when dirty flag set |
| `0x0205ed7e` | bt_ll_tx_enqueue | low | 0 | alloc 27-byte node, fill fields, memcpy payload, link and kick channel |
| `0x0205ee04` | bt_dev_addr_set_a | low | 0 | store 6-byte device address slot A plus three packed u16s |
| `0x0205ee48` | bt_dev_addr_set_b | low | 0 | store 6-byte device address slot B plus three packed u16s |
| `0x0205ee86` | bt_ll_reg_push_seq | low | 0 | send value via DMA cmd 5, record sequence in channel struct |
| `0x0205eea6` | ble_ll_link_param_store | med | 0 | store 32-bit value and param into link struct fields |
| `0x0205eeba` | ble_ll_set_host_chan_class | med | 0 | build used-channel remap tables from 5-byte channel map |
| `0x0205ef76` | ble_ll_prog_anchor_instant | med | 0 | program 32-bit anchor instant into HW link fields |
| `0x0205efb8` | ble_ll_read_native_clock | med | 0 | read controller native clock, return value minus 3750us |
| `0x0205efce` | ble_ll_align_anchor | med | 0 | align target time to native clock, program instant |
| `0x0205f032` | ble_ll_read_anchor_instant | med | 0 | read back 32-bit anchor instant from HW fields |
| `0x0205f052` | ble_ll_next_event_calc | med | 0 | compute link next event time against native clock |
| `0x0205f114` | ble_ll_set_state_field | med | 0 | set link state byte and packed HW field 2 |
| `0x0205f138` | ble_ll_hw_field4_set | low | 0 | write 0x8004 to HW link field 4 when idle |
| `0x0205f14e` | ble_ll_store_slot_time | med | 0 | store time as 625us slots plus remainder in struct |
| `0x0205f16c` | ble_ll_hw_field8_clear | low | 0 | clear HW link field 8 |
| `0x0205f178` | ble_ll_set_link_interval | med | 0 | store interval and program HW slot fields 1,15 |
| `0x0205f1aa` | ble_ll_ioctl_dispatch | med | 0 | 24-command BLE link-layer ioctl with varargs |
| `0x0205f74e` | ble_ll_hw_clear_fields | med | 0 | zero HW link register fields 0 through 16 |
| `0x0205f768` | ble_ll_link_entry_alloc | med | 0 | allocate link map entry, clear 28B and HW fields |
| `0x0205f7ac` | ble_ll_conn_struct_alloc | med | 0 | allocate and zero 616B connection struct, mark used |
| `0x0205f804` | ble_ll_link_map_set | med | 0 | store element offset with valid flag into link map |
| `0x0205f81e` | ble_ll_hw_field14_clear | low | 0 | clear HW link field 14 |
| `0x0205f82a` | ble_ll_hw_link_enable | med | 0 | set or clear per-link bits in baseband registers |
| `0x0205f8f8` | ble_ll_hw_link_stop | med | 0 | clear instant, wait HW idle, disable link slot |
| `0x0205f916` | ble_ll_link_reset | med | 0 | clear link state byte then stop HW link |
| `0x0205f928` | ble_ll_conn_create | high | 0 | create BLE link with adv defaults AA 0x8E89BED6 CRC 0x555555 |
| `0x0205fa96` | ble_ll_set_event_handler | med | 0 | store event callback interface pointers into context |
| `0x0205faa0` | ble_ll_set_phy | low | 0 | set PHY mode bits 3-4 of link flags by index |
| `0x0205fae0` | ble_ll_set_adv_chan_map | med | 0 | encode advertising channel enable map to HW field |
| `0x0205fb3c` | ble_ll_buf_alloc | med | 0 | allocate link buffer, assert 4-byte alignment |
| `0x0205fb60` | ble_ll_buf_bind | low | 0 | validate buffer offset and store into descriptor |
| `0x0205fb78` | ble_ll_tx_pdu_build | med | 0 | fill TX descriptor header bits and copy payload |
| `0x0205fc14` | ble_ll_link_flag_clear | low | 0 | clear bit 4 of link flags halfword |
| `0x0205fc1c` | ble_ll_register_event_cb | med | 0 | register link event callback into OS callback list |
| `0x0205fc40` | ble_ll_hw_link_start | med | 0 | enable link slot bits in baseband registers |
| `0x0205fc4e` | ble_ll_link_start_at_instant | med | 0 | start HW link then program anchor instant |
| `0x0205fc60` | ble_ll_hw_slot_scan | low | 0 | scan 8 baseband slots for active or free link |
| `0x0205fc92` | ble_ll_link_deactivate | low | 0 | mark link state and stop HW when transitioning |
| `0x0205fcac` | ble_ll_link_activate | low | 0 | mark link state and start HW when transitioning |
| `0x0205fcc4` | ble_ll_program_event_timing | low | 0 | program slot interval and offset timings for link |
| `0x0205fce8` | ble_ll_pdu_field_clamp | low | 0 | read halfword at offset 22, clamp result to 0..8 |
| `0x0205fd08` | ble_ll_conn_update_apply | med | 0 | apply connection update window, fire event callback |
| `0x0205fd84` | ble_ll_scheduler_run | med | 0 | locked scan of 8 link slots scheduling anchor points |
| `0x0206000a` | ble_ll_adv_start | med | 0 | allocate adv buffers, build PDUs, schedule advertising |
| `0x0206201a` | bt_work_item_enqueue | med | 0 | alloc 16B work node, link callback+arg into link list under lock |
| `0x020620a2` | ble_link_proc_report | med | 0 | post procedure result report, code selected by step type |
| `0x020620e0` | ble_link_event_report | med | 0 | post link event report, param chosen by type, guarded by enable |
| `0x02062146` | ble_link_event_report2 | med | 0 | post link event report variant with type-chosen param |
| `0x02062190` | ble_link_state_set_disconnect | med | 0 | mark link state 8, signal manager, log transition |
| `0x020621d0` | ble_link_proc_step_dispatch | med | 0 | execute current procedure step handler from link script table |
| `0x02062356` | ble_link_proc_event_match | med | 0 | match event code against expected step, advance procedure |
| `0x020623f4` | ble_link_proc_engine | med | 0 | decode procedure opcode, compute backoff/timing, build response PDUs |
| `0x020627b4` | ble_link_proc_queue | med | 0 | queue procedure script into link slot, trigger engine |
| `0x020627de` | ble_link_timeout_restart | med | 0 | (re)arm 40s per-link timeout timer, freeing old one |
| `0x0206281e` | ble_link_cmd_dispatch | med | 0 | dispatch BLE command by opcode: copy params, enqueue procedures |
| `0x02062a98` | ble_adv_mgr_get | med | 0 | lazily allocate 40-byte advertising manager singleton |
| `0x02062ac0` | ble_adv_config_store | med | 0 | store 15-byte advertising config block if uninitialized |
| `0x02062ae4` | ble_adv_data_set1 | med | 0 | set length-prefixed advertising data string 1, notify 21 |
| `0x02062b26` | ble_adv_data_set2 | med | 0 | set length-prefixed advertising data string 2, notify 22 |
| `0x02062b68` | ble_adv_record_post | med | 0 | assemble advertising record from stored config, post to link |
| `0x02062bce` | ble_addr_record_fill | low | 0 | fill record with 6-byte address template selected by type |
| `0x02062bf6` | ble_adv_record_build_post | med | 0 | build type-templated address record, post via property 2 |
| `0x02062c10` | ble_adv_start | med | 0 | configure advertising params, arm 1280ms timer, start advertising |
| `0x02062d58` | ble_adv_init | med | 0 | create advertising link instance, register callback, start advertising |
| `0x02062daa` | ble_adv_deinit | med | 0 | stop advertising: teardown link, free timer and manager |
| `0x02062dee` | ble_initiator_mgr_get | med | 0 | lazily allocate 32-byte connection-initiator manager singleton |
| `0x02062e16` | ble_connect_start | med | 0 | create link, copy peer address/params, initiate connection |
| `0x02062ec4` | ble_connect_stop | med | 0 | teardown initiator link, free node list and context |
| `0x02062f0c` | ble_bond_find_by_addr | high | 0 | find bond-list node by 6-byte address plus type |
| `0x02062f40` | ble_addr_bit_diversity | med | 0 | count bits differing from first bit over N bits |
| `0x02062f80` | ble_random_addr_generate | high | 0 | generate spec-compliant random static address via RAND64 |
| `0x020631c4` | ble_directed_init | med | 0 | init directed-connection manager, copy 25-byte params, start |
| `0x0206321e` | ble_directed_deinit | med | 0 | teardown directed-connection link and free manager |
| `0x02063252` | ble_link_timer_free | med | 0 | delete per-link timer at offset 336, clear pointer |
| `0x02063268` | ble_link_free | high | 0 | full link teardown under lock: free lists, clear slot |
| `0x0206342e` | ble_link_release | med | 0 | clear session if current, run callback, full teardown |
| `0x02063482` | ble_module_deinit | high | 0 | stop all roles, release every link, free controller state |
| `0x02063508` | ble_link_data_send | med | 0 | fragment payload into PDUs, enqueue on link tx queue |
| `0x02063620` | ble_link_init | med | 0 | allocate controller slot, set default conn params, register link |
| `0x02063706` | ble_link_timer_create | med | 0 | create per-link timer (callback 0x2064014) at offset 336 |
| `0x02063738` | ble_link_addr_report | med | 0 | hex-format link address, enqueue report event 1 |
| `0x020637d8` | ble_link_event_handler | med | 0 | on connect init link and timer, on disconnect clean up |
| `0x02063866` | ble_conn_timing_compute | med | 0 | compute link timing from interval/latency table into +22 |
| `0x020638a0` | ble_link_create | med | 0 | construct 416-byte link object, init lists, register callback |
| `0x02063950` | ble_rx_pkt_complete | med | 0 | unlink completed RX packet and signal stack semaphore |
| `0x020639b0` | ble_work_node_register | med | 0 | register deferred work/callback node under per-CPU lock |
| `0x02063a8a` | ble_link_state_machine | med | 0 | main BLE connection state machine: timers, callbacks, app notify |
| `0x0206432e` | ble_subscribe_register | med | 0 | handle subscribe command: refcount subscriber node, ack |
| `0x020644d6` | ble_conn_handle_get | med | 0 | return stored 16-bit connection handle global |
| `0x020644e0` | l2cap_tx_header_submit | med | 0 | marshal TX header fields, submit to ACL data channel |
| `0x02064522` | ble_seq16_cmp | low | 0 | compare 16-bit sequence values with wraparound |
| `0x02064540` | ble_ring_slot_pending | med | 0 | test ring slot occupancy by read cursor |
| `0x02064554` | ble_status_report | med | 0 | timestamp and emit formatted status event 65 |
| `0x020645a0` | ble_devinfo_response | med | 0 | unpack 32-bit id, emit device-info response event |
| `0x020645fc` | ble_gatt_cmd_dispatch | med | 0 | GATT/ATT command-byte jump-table dispatcher with acks |
| `0x02064ab6` | ble_cmd_access_check | med | 0 | command permission check by link state, sets gate flag |
| `0x02064bc6` | ble_gatt_cmd_dispatch_ex | med | 0 | secondary GATT cmd dispatcher plus AES key reinit |
| `0x02064df8` | ble_peer_record_store | med | 0 | cache 7-byte peer record, init registry if absent |
| `0x02064e1a` | ble_aes128_crypt_record | med | 0 | AES-128 transform of 3-byte record via 16B block |
| `0x02064e50` | ble_static_addr_from_uid | med | 0 | build static address from chip UID regs, marshal |
| `0x02064eb0` | ble_set_local_addr | high | 0 | store 6-byte local BT address into global |
| `0x02064ebe` | ble_stack_event_dispatch | high | 0 | top-level BLE event router via type jump table |
| `0x020650fc` | l2cap_acl_data_send | med | 0 | parse handle and 12-bit length, enqueue ACL TX |
| `0x02065126` | ble_features_init | med | 0 | init LE feature/event mask constants in control block |
| `0x0206513e` | ble_dcb_hword_get | low | 0 | return 16-bit field at BLE control block +66 |
| `0x0206514a` | ble_dcb_byte_get | low | 0 | return byte field at BLE control block +64 |
| `0x02065156` | ble_get_own_addr | med | 0 | copy own address selected by mode bit, return mode |
| `0x02065188` | ble_get_local_addr | high | 0 | copy 6-byte local BT address to caller buffer |
| `0x02065196` | hci_le_conn_update | med | 0 | send HCI LE Connection Update 0x2013, seven params |
| `0x020651c8` | ble_buffer_free | low | 0 | free container given member pointer at +16 |
| `0x020651d4` | hci_le_set_adv_enable | high | 0 | send HCI LE Set Advertise Enable 0x200A |
| `0x020651ec` | hci_le_set_adv_params | med | 0 | send HCI LE Set Advertising Parameters 0x2006 |
| `0x0206524a` | hci_le_set_adv_data | med | 0 | send HCI LE Set Advertising Data 0x2008, 32B |
| `0x0206529a` | hci_le_set_scan_rsp_data | med | 0 | send HCI LE Set Scan Response Data 0x2009, 32B |
| `0x0206531c` | hci_le_set_scan_enable | high | 0 | send HCI LE Set Scan Enable 0x200C |
| `0x0206533e` | ble_peer_addr_cache | low | 0 | pack 7-byte peer record with mode byte, cache |
| `0x0206537e` | hci_disconnect | high | 0 | send HCI Disconnect 0x0406: handle, reason |
| `0x020653a0` | hci_le_create_connection | med | 0 | build 25B param block, send LE Create Connection |
| `0x02065460` | hci_le_create_connection_raw | med | 0 | send LE Create Connection from 25-byte descriptor |
| `0x0206549a` | hci_vendor_cmd_f883 | low | 0 | send JieLi vendor HCI command 0xF883 |
| `0x020654bc` | hci_vendor_cmd_f884 | low | 0 | send JieLi vendor HCI command 0xF884 |
| `0x020654de` | hci_le_add_resolving_list | med | 0 | send LE Add Device To Resolving List with IRKs |
| `0x02065568` | bt_bd_addr_save | med | 0 | copy 6-byte bd_addr to global slot 0x1c09c66 |
| `0x02065576` | bt_evt_post_201a | med | 0 | post 2-arg event msg 0x201a via taskq poster |
| `0x0206558e` | bt_evt_rec_post_2018 | med | 0 | fill 16-byte event record, post msg 0x2018 |
| `0x020655c6` | bt_evt_data_post_201a | med | 0 | copy 16-byte payload, post 6-arg msg 0x201a |
| `0x02065612` | bt_bd_addr_save_2 | med | 0 | duplicate 6-byte bd_addr copy to 0x1c09c66 |
| `0x02065634` | bt_state_flag_clr_bit2 | med | 0 | clear bit2 of bt state halfword at 0x1c09b9c+146 |
| `0x02065646` | bredr_handle_by_addr | med | 0 | lookup link/connection handle by 6-byte bd_addr |
| `0x02065686` | bredr_link_find_by_handle | high | 0 | scan 2-link table at 0x1c0c480 for handle/id match |
| `0x020656ac` | bredr_any_link_buf_pending | med | 0 | return 1 if any link has buffer at +228 |
| `0x020656ce` | bredr_link_tx_ready_len | low | 0 | if link idle in state 2, return queued pkt len<<1 |
| `0x020656f6` | bredr_link_op_cancel_by_id | low | 0 | cancel pending link op, post event, mark link states |
| `0x02065790` | bt_addr_evt_post_405 | med | 0 | pack 6 addr bytes into msg 0x405, post taskq |
| `0x020657d4` | bt_clk_diff_wrap27 | med | 0 | wrapped 27-bit bt-clock difference with window check |
| `0x020657f4` | bredr_link_deactivate | med | 0 | stop link scheduler, free pending frag, fix link globals |
| `0x020658dc` | bt_cmd14_link_report | low | 0 | send dev cmd 0x14 with link id, state, arg |
| `0x020658fe` | bredr_link_tx_complete | low | 0 | tx completion: release frag, queue flow-ctrl pkt, report |
| `0x02065956` | bredr_link_tx_abort | low | 0 | mark current frag done, deactivate sched, report state |
| `0x02065986` | bredr_link_tx_kick | low | 0 | flag stalled frag 0x80 and queue ctrl pkt |
| `0x020659c0` | bredr_frag_set_tx_clk | med | 0 | stamp frag +32 with next bt-clock tx time |
| `0x020659ea` | bredr_txq_unlink_free | med | 0 | unlink tx queue node, free container via lm/pool |
| `0x02065a72` | bredr_link_tx_window_bytes | low | 0 | sum matching queued payload bytes across link tx lists |
| `0x02065b66` | bredr_txq_ack_upto_seq | low | 0 | free acked tx frags on list, return last seq seen |
| `0x02065bf6` | bredr_link_tx_flush_seq | low | 0 | flush link tx queues up to seq, update slot counter |
| `0x02065d1a` | bredr_link_tx_dequeue | med | 0 | detach next tx frag, mark in-flight, return payload ptr/len |
| `0x02065e8a` | bredr_link_destroy_seq | low | 0 | link destroy, op-complete(254), follow-up sequence |
| `0x02065ea2` | bredr_link_sched_op8 | low | 0 | pass link sched byte +8 to hw layer fn |
| `0x02065f12` | bredr_link_tx_inflight_count | med | 0 | count in-flight (flag 0x8, unacked) tx frags on link |
| `0x02065fac` | bredr_tx_frag_arm | med | 0 | mark frag pending, program 27-bit deadline, feed hw |
| `0x020660a2` | bredr_sched_advance_slot | med | 0 | advance link schedule by interval, correct drift, re-arm |
| `0x02066162` | bredr_link_sched_tick | med | 0 | scheduler tick: service tx, sync dual links, arm next wake |
| `0x020662d6` | bredr_tx_slot_prepare | low | 0 | feed next tx payload to baseband, arm slot timer |
| `0x020663ce` | bt_sched_flag_set | med | 0 | set/clear bit0 of sched struct byte at +22 |
| `0x020663e4` | bredr_link_flow_ctrl_send | low | 0 | clear sched flag, queue flow-ctrl pkt on link |
| `0x02066424` | bredr_active_link_count | high | 0 | count table links with handle and sched attached |
| `0x020664b0` | bt_link_mode_bit2 | med | 0 | extract bit2 of link mode byte |
| `0x020664b6` | bredr_link_txbuf_init | med | 0 | alloc+init 40B tx sched buffer, register link active |
| `0x0206650e` | bredr_clk_slots_to_event | med | 0 | wrap-safe slots until next scheduled event on link |
| `0x0206655a` | bredr_sched_phase_align | med | 0 | compute wrap-safe phase delta between two links' schedules |
| `0x020665be` | bredr_link_sched_setup | med | 0 | configure periodic link schedule: interval<=800, phase, sync |
| `0x020666f4` | link_dma_obj_close | med | 0 | release DMA channel and free session DMA object |
| `0x020667aa` | link_trace_u16 | low | 0 | tagged debug log with u16 argument |
| `0x020667c0` | link_seq_counter_next | med | 0 | rolling packet sequence index 0..10 |
| `0x020667d8` | link_dma_obj_alloc | med | 0 | alloc zeroed 32B DMA descriptor, channel unassigned |
| `0x02066816` | link_pktbuf_hdr_set | low | 0 | store 3-byte header into packet buffer object |
| `0x020668c6` | link_clock_dma_sync | low | 0 | release DMA channel, compute stream position from clock |
| `0x020669b2` | link_session_open_pkt | low | 0 | init session state, schedule timestamped start packet |
| `0x02066a56` | link_state_notify | low | 0 | set session state bytes, notify peer, delay |
| `0x02066aa8` | link_trace_state | low | 0 | tagged debug log of session state byte |
| `0x02066aca` | link_any_session_active | med | 0 | scan two sessions for live handle and DMA object |
| `0x02066af6` | link_warn_yield | low | 0 | warning log then short OS delay |
| `0x02066b26` | link_key_material_send | low | 0 | derive and dispatch session key material, trace |
| `0x02066b76` | link_dma_pair_alloc | med | 0 | alloc zeroed 20B object with two DMA channels |
| `0x02066baa` | link_dma_pair_free | med | 0 | release both DMA channels and free object |
| `0x02066c40` | link_key_frag_assemble | low | 0 | accumulate key fragments, crypto-process when complete |
| `0x02066cfa` | link_proto_msg_dispatch | med | 0 | session protocol opcode/subcommand dispatcher, framed replies |
| `0x02068410` | link_trace_handle | low | 0 | tagged debug log of session handle field |
| `0x02068432` | link_stream_start | low | 0 | arm DMA channel and clock deadline for stream |
| `0x020684b4` | link_stream_rearm | low | 0 | rearm stream deadline from hardware clock |
| `0x0206855c` | link_module_ready_check | low | 0 | warn-log when link module global pointer null |
| `0x02068618` | link_trace_key | low | 0 | tagged debug log with session key field |
| `0x0206863a` | link_buf_obj_free | med | 0 | free session buffer object if allocated |
| `0x02068650` | link_trace_open | low | 0 | tagged debug log of session name |
| `0x02068666` | link_auth_state_handler | med | 0 | auth message state machine, timer and key steps |
| `0x020688d4` | link_trace_id | low | 0 | tagged debug log with handle argument |
| `0x020688f2` | link_conn_state_handler | med | 0 | pairing/connection state machine with callback install |
| `0x02068956` | link_peer_count_sync | low | 0 | propagate count byte to other active session object |
| `0x02068998` | link_trace_peer | low | 0 | tagged debug log with peer argument |
| `0x020689b2` | link_handshake_handler | med | 0 | link setup handshake: alloc DMA obj, clock, sequence init |
| `0x02068bec` | link_disconnect | med | 0 | stop clock object and run session teardown sequence |
| `0x0206be96` | bt_addr_copy_checksum | low | 0 | copy 6-byte BT address to global, accumulate checksum |
| `0x0206d862` | bt_sched_op_wrapper | low | 0 | thin wrapper tail-calling scheduler routine at 0x6d838 |
| `0x0206d868` | bredr_link_flags40_clear | low | 0 | clears bit6 flag bytes at link struct +12/+13 |
| `0x0206d876` | bt_hw_irq_clear | med | 0 | masks/clears BT controller hw interrupt channel |
| `0x0206d8a6` | bredr_link_index_from_ptr | med | 0 | maps link struct pointer to link index via 180B stride |
| `0x0206d8e0` | lmp_set_afh_channel_map | high | 0 | expands 10-byte AFH map to 79ch table, programs baseband regs |
| `0x0206da96` | bredr_afh_reapply_link | med | 0 | locked section re-applying link AFH map to hardware |
| `0x0206db14` | bt_clk_read_native | high | 0 | latches and reads BT native clock CLKN register |
| `0x0206db26` | bt_clk_add_offset | med | 0 | adds slot offset to native clock with 27-bit wrap |
| `0x0206db6e` | bt_hw_channel_alloc | med | 0 | finds and sets first free bit in hw channel bitmap |
| `0x0206dbaa` | bt_hw_irq_install | med | 0 | installs handler/arg for BT hw irq channel, unmasks it |
| `0x0206dbda` | bt_hw_timer_install | med | 0 | arms BT hw timer irq with clock-derived deadline |
| `0x0206dbf0` | lmp_afh_instant_cb | med | 0 | timer callback applying pending AFH map at AFH instant |
| `0x0206dca4` | bredr_sched_task_insert | med | 0 | inserts anchor/interval entry into baseband scheduler table |
| `0x0206dcea` | bredr_link_pending_clear | low | 0 | clears pending flag bytes at link struct +90/+91 |
| `0x0206dcfe` | bredr_acl_tx_scheduler | med | 0 | dequeues TX packets, programs per-link scheduler slots |
| `0x0206e09a` | bredr_link_detach_cleanup | med | 0 | frees queued buffers, removes link from scheduler |
| `0x0206e1f6` | bredr_sched_task_flag14 | low | 0 | sets/clears 0x4000 flag in per-task scheduler halfword |
| `0x0206e20e` | bredr_link_set_packet_types | low | 0 | writes 0x1414/0x1E1E packet-type table to link struct |
| `0x0206e21e` | bt_clk_store | med | 0 | stores 27-bit clock value as halfword pair at +48/+50 |
| `0x0206e238` | bredr_sched_link_enable | med | 0 | sets/clears link bit across 16 scheduler halfwords |
| `0x0206e278` | bredr_link_mode_apply | low | 0 | applies per-link mode bits (0x1000) across scheduler table |
| `0x0206e382` | bredr_link_mode_set | low | 0 | stores per-link mode byte then re-applies scheduler flags |
| `0x0206e3a6` | bredr_sniff_anchor_update | low | 0 | computes next anchor with 625/1250 slot adjustments |
| `0x0206e4ba` | bredr_link_flags_clear | low | 0 | clears flag bytes at +92/+93 and scheduler flag |
| `0x0206e4d8` | bt_hw_timer_arm_at | med | 0 | arms BT hw timer channel at clock plus offset |
| `0x0206e500` | bredr_link_mode_check | low | 0 | compares link hwid against baseband reg, applies on match |
| `0x0206e524` | bt_clk_read_stored | med | 0 | reads back stored clock halfword pair from link struct |
| `0x0206e532` | bredr_link_event_dispatch | med | 0 | switch dispatch on link event: packet types, anchors, scheduling |
| `0x0206e6c4` | bredr_tx_power_set | med | 0 | clamps power index, programs RF tx power registers |
| `0x0206e72e` | bredr_link_manager_tick | med | 0 | per-link LM tick: AFH assessment, RSSI stats, TX scheduling |
| `0x0206ee84` | bredr_lm_scan_all_links | med | 0 | frees arg, iterates link list running LM tick per link |
| `0x0206ef16` | bredr_links_idle_check | low | 0 | scans active links, requests buffer/event when none active |
| `0x0206efc6` | bredr_link_afh_state_free | low | 0 | clears per-link AFH/mode state on link removal |
| `0x0206f008` | bredr_pending_link_destroy | med | 0 | guarded one-shot deferred link teardown and free |
| `0x0206f058` | bredr_link_destroy_entry | med | 0 | trampoline into deferred link destroy worker |
| `0x0206f05e` | bt_hw_channel_release | low | 0 | clears bit r0 in hw channel bitmap byte |
| `0x0206f072` | bredr_pending_op_complete | low | 0 | deferred op teardown with completion callback invocation |
| `0x0206f0e2` | bredr_op_complete_entry | low | 0 | wrapper calling pending-op complete with arg1=1 |
| `0x0206f0ec` | bredr_pending_op_free3 | low | 0 | third deferred teardown variant freeing sub-struct +108 |
| `0x0206f142` | bt_scan_session_free | low | 0 | thunk: free global BT scan/session object and piconet block |
| `0x0206f148` | bt_rxbuf_pool_size_get | med | 0 | thunk: RX buffer pool size scaled by stored percent |
| `0x0206f154` | bt_clkn_read | med | 0 | thunk: capture and read BT native clock (CLKN) |
| `0x0206f15c` | btctrler_idle_query | med | 0 | critical: suspend BT if unconfigured, test link queues empty |
| `0x0206f206` | bredr_timing_config_commit | low | 0 | toggle baseband enable bit31, program slot timing factor |
| `0x0206f23a` | bt_link_flag_set | med | 0 | set bit3 flag in link struct byte+12 |
| `0x0206f242` | bt_link_load_8bytes | low | 0 | pack 8 bytes into 4 halfwords at link struct+60 |
| `0x0206f260` | bt_link_paircfg_write | low | 0 | write link halfword pair +32/34: bit15 flag, 8-bit value |
| `0x0206f268` | bt_multi_link_active | med | 0 | count connected links, return 1 if more than one |
| `0x0206f29c` | bt_clkn_slot_delay | med | 0 | compute us offset to slot boundary from CLKN (625/1250) |
| `0x0206f2f8` | bt_link_flag_get | med | 0 | read bit3 flag of link struct byte+12 |
| `0x0206f300` | bt_link_busy_set | med | 0 | set link busy byte flag at +18 |
| `0x0206f308` | bt_link_busy_clear_sched | med | 0 | clear link busy flag, run BT scheduler when idle |
| `0x0206f37a` | bt_link_flags_read | med | 0 | read link byte+12 with low-3 address bits masked |
| `0x0206f382` | bredr_channel_disable | low | 0 | disable baseband channel r0 via SFR bit16 clear |
| `0x0206f3a6` | bredr_bufbase_program | med | 0 | program shared-RAM buffer offset into 16 slot entries |
| `0x0206f46a` | bredr_slottab_mode_set | med | 0 | set 2-bit mode field (bits13-14) in 16 slot-table entries |
| `0x0206f4a0` | bredr_ram_window_setup | low | 0 | program baseband shared-RAM window/length registers 0x2012C |
| `0x0206f4f8` | bt_link_channel_destroy | med | 0 | free link channel buffers, endpoints, object; signal semaphore |
| `0x0206f65a` | bt_am_addr_pick | low | 0 | choose free 3-bit active-member address from link list |
| `0x0206f6ba` | bt_link_bufoffset_store | med | 0 | store shared-RAM buffer offset into link slot halfword |
| `0x0206f6d4` | bt_link_flags_write | med | 0 | write link byte+12 flags, preserve low-3 address bits |
| `0x0206f6e4` | bt_link_cfg13_write | med | 0 | write link byte+13: bit7 flag plus 5-bit value |
| `0x0206f6f8` | bt_bytes_to_hwords6 | med | 0 | unpack 6 bytes into 3 halfwords (BD_ADDR load) |
| `0x0206f718` | bt_bytes_to_hwords5 | med | 0 | unpack 5 bytes into 2 halfwords plus trailing byte |
| `0x0206f732` | bt_clkn_compare_arm | med | 0 | arm BT clock compare: capture CLKN, add delta, program 0x200E4 |
| `0x0206f752` | bt_piconet_link_init | med | 0 | init piconet block: BD_ADDR, sync word, slot cfg, arm timer |
| `0x0206f8b8` | bt_link_channel_create | med | 0 | alloc channel buffers and descriptor, init link piconet |
| `0x0206f908` | bt_conn_id_alloc | med | 0 | allocate free connection index bit (1-7) in dev struct |
| `0x0206f938` | bt_fhs_payload_build | high | 0 | build 18-byte FHS payload: LAP, CoD, clock, AM_ADDR |
| `0x0206f9d8` | bt_piconet_bufptr_set | med | 0 | store shared-RAM buffer offset into piconet slot +24/26 |
| `0x0206fa06` | bt_conn_create | med | 0 | create BT connection: alloc ctx, build FHS, program radio |
| `0x0206fc04` | bt_bufslot_offset_map | low | 0 | map slot index nibble to buffer offset (n/2, +40 odd) |
| `0x0206fc14` | bredr_scan_config_apply | med | 0 | apply scan window/interval tables to baseband state machine |
| `0x0206fd10` | bt_rxbuf_percent_set | med | 0 | set RX buffer pool percent byte for link index |
| `0x0206fd1c` | bt_link_teardown | med | 0 | teardown BT link: cancel timers, free channel, buffers, scan |
| `0x0206ff28` | bt_link_param_adjust | low | 0 | adjust link index by halfword thresholds (800/1100), clamp 0-15 |
| `0x0206ff5c` | bt_tx_power_set | med | 0 | set link TX power via radio table lookup, clamped to 11 |
| `0x0206ff90` | bt_piconet_block_alloc | med | 0 | allocate and init 180-byte piconet block from pool of 4 |
| `0x020700de` | bredr_scan_enable | high | 0 | enable inquiry/page scan: build EIR data and local FHS |
| `0x020702e6` | bt_bb_scan_obj_create | med | 0 | create 120B scan/session object, bind BD_ADDR, radio descriptors |
| `0x020703f0` | bt_bb_scan_timed_create | med | 0 | create 168B scan object with slot-timeout and DMA descriptors |
| `0x02070592` | bt_bb_slot_phase_adjust | low | 0 | normalize 10-bit slot phase counter with guard bands |
| `0x020705be` | bt_fhs_payload_unpack | med | 0 | unpack 18-byte FHS payload into address and clock fields |
| `0x02070664` | bt_bb_frame_tx_arm | med | 0 | arm radio TX: latch slot timer, program descriptors, phase |
| `0x02070706` | bt_bb_irq_mask_clear | med | 0 | clear and mask radio interrupt pending bit 0x200 |
| `0x02070716` | bt_bb_buf_desc_bind | med | 0 | bind per-channel packet buffer into radio DMA descriptor |
| `0x02070762` | bt_bb_conn_obj_create | med | 0 | allocate 736B connection object, pick free channel, init buffers |
| `0x0207093a` | bt_bb_rx_stream_scan | med | 0 | scan and compact 512B circular RX stream, sync-pattern match |
| `0x02070b78` | bt_link_touch | med | 0 | stamp link object with current hardware tick |
| `0x02070b86` | bt_bb_param_cycle | low | 0 | cycle 5-entry parameter table into radio register setter |
| `0x02070bac` | bt_bb_radio_isr | high | 0 | BR/EDR baseband radio IRQ handler, 4 channels RX/TX packets |
| `0x0207211a` | bt_link_rx_credit_post | low | 0 | compute available RX buffer count, post flow-control update |
| `0x02072168` | bt_link_state_tick | med | 0 | per-link state machine tick: supervision timeout, events, rearm |
| `0x0207232a` | bt_link_slot_service | med | 0 | slot-timer link service: clock drift compensation, DMA TX pump |
| `0x0207271c` | bt_slot_cb_dispatch_isr | med | 0 | slot-timer IRQ: dispatch eight registered slot callbacks |
| `0x020729aa` | bt_bb_init | high | 0 | init baseband controller: radio SFRs, 79-hop table, IRQs 40/41 |
| `0x02072af6` | bt_ctrler_state_reset | high | 0 | clear controller globals and reset connection list head |
| `0x02072b46` | bt_bb_is_inited | high | 0 | return baseband controller initialized flag |
| `0x02072b56` | bt_pkt_type_map | low | 0 | map packet type codes 38/44/55/61 to internal indices |
| `0x02072b88` | bt_bb_channel_setup | med | 0 | create 96B channel context, program DMA descriptors, packet format |
| `0x02072d62` | bt_bb_slot_phase_us | low | 0 | latch radio slot timer, compute microsecond slot phase |
| `0x02072d8e` | btctrler_kick_run_locked | low | 0 | spinlock: run deferred controller work when kick pending |
| `0x02072e02` | bt_bb_deinit | med | 0 | stop radio, free IRQs 40/41, clear init flag |
| `0x02072e60` | bt_slot_deadline_arm | low | 0 | arm 27-bit slot deadline, register named timer callback |
| `0x02072ea0` | bt_conn_find_by_addr | med | 0 | locked connection-table scan matching 6-byte device address |
| `0x02072f86` | bt_conn_find_by_id | med | 0 | scan 2x280B connection entries by handle field |
| `0x02072faa` | bt_pkt_tlv_scan | low | 0 | walk variable-length packet record, locate marker byte 0x9C |
| `0x02072fe4` | bt_chan_interval_sum | low | 0 | sum per-channel interval costs over a channel list |
| `0x0207307a` | bt_conn_bw_check_locked | low | 0 | spinlock: verify connection active, sum both channel lists |
| `0x02073132` | bt_buf_alloc | med | 0 | allocate buffer from lbuf pool, retry/wait unless in IRQ |
| `0x020731c8` | bt_buf_free | med | 0 | unlink buffer block, return to pool, decrement usage watermark |
| `0x02073206` | bt_buf_release | med | 0 | spinlock-unlink buffer node; free or repost to event queue |
| `0x02073394` | bt_buf_pool_alloc | med | 0 | allocate from buffer pool 0/1 unless usage over threshold |
| `0x02073486` | bt_buf_pool_threshold | med | 0 | compute pool usage threshold bytes from percent entry |
| `0x020734c2` | bt_dispatch_wrap_5e228 | low | 0 | tail-call wrapper into 0x0205xxxx helper on BT path |
| `0x020734cc` | bt_buf_free_a | med | 0 | free buffer back to BT pool A |
| `0x020734e0` | bt_buf_zalloc_a | high | 0 | allocate zeroed buffer from BT pool A |
| `0x02073510` | bt_buf_zalloc_b | high | 0 | allocate zeroed buffer from BT pool B |
| `0x02073546` | bt_list_pop_locked | med | 0 | SMP-locked pop of first node from list |
| `0x020735b8` | bt_pool_param_set | med | 0 | set per-pool percentage byte, assert index<2 |
| `0x020735da` | bt_pool_usage_calc | med | 0 | sum buffer usage against percentage watermark |
| `0x020736e0` | bt_buf_pools_init | high | 0 | init BT buffer pools, mutex and accounting |
| `0x02073754` | bt_sched_recalc_timing | low | 0 | recompute per-type scheduling timing table |
| `0x0207391c` | bt_sched_switch_current | high | 0 | switch current runnable object, invoke out/in callbacks |
| `0x02073962` | bt_sched_pick_next | med | 0 | pick next runnable object, age dynamic priorities |
| `0x02073a6c` | bt_sched_remove | med | 0 | remove object from run list, reschedule if current |
| `0x02073b5e` | bt_sched_idle_obj_cleanup | low | 0 | deferred removal of idle object when flagged |
| `0x02073bde` | bt_sched_set_pending_ptr | low | 0 | store pending-object pointer under SMP lock |
| `0x02073c44` | bt_obj_flag_bit1_set | med | 0 | set or clear object flag bit1 under lock |
| `0x02073cae` | bt_sched_run_with_override | low | 0 | schedule object with temporary timing override |
| `0x02073d18` | bt_sched_block | med | 0 | locked wrapper: remove object from run list |
| `0x02073d78` | bt_sched_sleepable_check | med | 0 | check only light-weight object types remain pending |
| `0x02073d9e` | bt_sched_ready | med | 0 | make object runnable: reset quantum, enqueue, preempt |
| `0x02073e82` | bt_sched_idle_create | med | 0 | create and ready idle object when none flagged |
| `0x02073f54` | bt_sched_reset_prios | med | 0 | reset all dynamic priorities, deselect current object |
| `0x02073fce` | bt_sched_schedule | med | 0 | locked wrapper invoking scheduler pick-next |
| `0x0207402e` | bt_sched_resched_if_current | low | 0 | reschedule only if given object is current |
| `0x02074060` | bt_sched_wakeup | med | 0 | locked wrapper: wake/ready an object |
| `0x020740c0` | bt_sched_kick_type32 | low | 0 | kick scheduler for every type-32 object, trace |
| `0x02074152` | bt_sched_shutdown | med | 0 | drain run list, release trace ids, reset scheduler |
| `0x0207437e` | bt_sched_timing_update | low | 0 | set object byte and recompute timing under lock |
| `0x02074756` | bt_list_find_by_u16 | med | 0 | find list node by u16 id field |
| `0x02074784` | bt_chan_table_lookup | med | 0 | map (type,id16) to index via 24-entry table |
| `0x020747ba` | bt_conn_slot_by_handle | med | 0 | find connection slot by 10-bit handle, else 0xFF |
| `0x020747e6` | bt_pkt_tx_space | med | 0 | compute fragment payload capacity of TX ring |
| `0x020748a0` | bt_pkt_fragment_write | med | 0 | write buffer as MTU-fragmented records into ring |
| `0x02074a04` | bt_conn_first_active | low | 0 | return first connection slot with nonzero handle |
| `0x02074a28` | bt_pkt_layer_init | med | 0 | init packet-layer context: tables, ring, handle register |
| `0x02074b2e` | bt_pkt_evt_notify | med | 0 | post 0xFF event to packet module message queue |
| `0x02074b54` | bt_node_list_remove | med | 0 | unlink node from module list at 0x01c09de8 |
| `0x02074b62` | btstack_cmd_dispatch | med | 0 | validate, copy varargs, switch cmds, else queue to cmd cbuf |
| `0x02074ece` | bt_put_be32_field12 | med | 0 | store u32 big-endian into struct offset 12 |
| `0x02074ede` | bt_chanmap_clear_type | med | 0 | clear channel-map entries matching type nibble |
| `0x02074f08` | bt_chanmap_entry_update | med | 0 | find, allocate or free 24-slot channel-map entry |
| `0x02074f6a` | bt_state_set_bit11 | low | 0 | set bit 0x800 in big-endian state word |
| `0x02074fa0` | bt_state_clr_bit13 | low | 0 | clear flag byte and bit 0x2000 in state word |
| `0x02074fe0` | bt_cfg_set_word4 | low | 0 | store constant 8000 into config halfword +4 |
| `0x02074fee` | bt_cfg_set_word6 | low | 0 | store constant 8000 into config halfword +6 |
| `0x02074ffc` | bt_state_set_bit12 | low | 0 | set bit 0x1000 in big-endian state word |
| `0x02075032` | bt_state_mark_magic | low | 0 | force 0x23 marker bytes in state word |
| `0x020750aa` | bt_addr_hash_build | med | 0 | build 6-byte address hash frame from BT MAC and CRC |
| `0x020750e2` | bt_ota_hook_set_a | low | 0 | store update-module entry point into hook slot |
| `0x020750f2` | bt_ota_hook_set_b | low | 0 | store update-module entry point into hook slot |
| `0x02075102` | bt_host_ipc_init | low | 0 | register IPC handler, await sync, install ops block |
| `0x0207513c` | bt_link_role_match | low | 0 | compare state-word field against BT context role bits |
| `0x02075172` | bt_conn_find_by_addr | high | 0 | find connection context entry by 6-byte BD_ADDR |
| `0x020751b0` | bt_conn_select_active | med | 0 | pick usable connection entry by flags and handle |
| `0x0207523e` | bt_dev_info_by_addr | med | 0 | wrapper: lookup device handle/info by address |
| `0x02075248` | bt_disconnect_by_addr | med | 0 | disconnect link when address known (type 0 or 2) |
| `0x0207526e` | bt_pkt_buf_alloc | med | 0 | allocate BT packet buffer, return payload pointer |
| `0x02075284` | pkt_put_le16 | high | 0 | write u16 little-endian into packet buffer |
| `0x02075294` | bt_pkt_build_fmt | med | 0 | build packet from format descriptor plus varargs |
| `0x02075342` | bt_pkt_queue_tx | med | 0 | queue packet to connection tx window or free |
| `0x020753b8` | bt_pkt_fmt_send | med | 0 | size, allocate, build and queue formatted packet |
| `0x02075446` | bt_tx_credit_avail | med | 0 | sum per-node counters against quota, return credits |
| `0x02075492` | bt_tx_can_send | med | 0 | test whether connection id has tx credits |
| `0x020754aa` | bt_tx_idle_recheck | low | 0 | re-check credits when tx busy flag clear |
| `0x020754c6` | bt_tx_busy_lock | med | 0 | set tx busy flag, return previous state |
| `0x020754e0` | bt_tx_window_commit | low | 0 | write tx window header into ring, bump counters |
| `0x0207558c` | bt_tx_resume_locked | low | 0 | resume locked tx: rebuild header and commit window |
| `0x020755f0` | bt_tx_send_fmt5 | low | 0 | lock tx, build fmt-5 packet on ring, send |
| `0x0207563e` | bt_node_enqueue | low | 0 | enqueue node into global pending list 0x1c0c920 |
| `0x02075650` | bt_flags16_set | med | 0 | set flag bits in struct halfword +16 |
| `0x02075658` | bt_bond_addr_update | med | 0 | register or clear 6-byte address in two-slot table |
| `0x02075724` | bt_addr_counter_next | med | 0 | increment wrapping address/nonce counter byte |
| `0x02075742` | bt_flags16_clr | med | 0 | clear flag bits in struct halfword +16 |
| `0x0207574c` | bt_flag_field_gate | low | 0 | return bits5+ field gated by flag bit1 |
| `0x02075758` | bt_event_deliver | med | 0 | dispatch event to connection handler or global handler |
| `0x02075780` | l2cap_emit_channel_opened | med | 0 | emit 0x70 channel-opened event: status, addr, cid/mtu fields |
| `0x020757f6` | l2cap_emit_event_74 | low | 0 | emit 5-byte l2cap event 0x74 with cid and param |
| `0x02075822` | l2cap_emit_channel_closed | med | 0 | emit 0x71 channel-closed event carrying channel id |
| `0x0207584a` | l2cap_channel_free | med | 0 | emit close event, unlink channel, free to pool |
| `0x02075870` | bt_list_iter_link | low | 0 | link iterator node to list head fields |
| `0x0207587c` | l2cap_channel_iter_init | low | 0 | init channel-list iterator over 0x1c0c6dc list |
| `0x02075888` | l2cap_run | high | 0 | process signaling queue, channel state machines, pending tx |
| `0x02075d1a` | bt_stack_flag_224_read | low | 0 | return whether bt struct flag at +224 set |
| `0x02075d2c` | btstack_config_command | med | 0 | BT cmd dispatcher: set name/addr/keys, disconnect-all, event log |
| `0x02075f94` | bt_addr_cache_scan | low | 0 | scan 8-slot 6-byte addr cache from rotating index |
| `0x02075ff4` | bt_addr_cache_index_update | low | 0 | advance or clear rotating addr-cache slot index |
| `0x02076028` | bt_active_connection_count | low | 0 | count used 24-byte connection entries with handles |
| `0x02076076` | btctrler_op_wrap_65a72 | low | 0 | null-guarded forwarder to hci-layer routine 0x65a72 |
| `0x0207608e` | btctrler_op_wrap_65d1a | low | 0 | state-checked forwarder to 0x65d1a, -EINVAL when idle |
| `0x020760b0` | btctrler_op_wrap_7307a | low | 0 | null-guarded forwarder to transport routine 0x7307a |
| `0x020760c8` | btctrler_op_wrap_65ea2 | low | 0 | null-guarded forwarder to hci-layer routine 0x65ea2 |
| `0x020760e0` | btctrler_op_wrap_65f12 | low | 0 | state-checked forwarder to 0x65f12, -EINVAL when idle |
| `0x02076100` | bt_config_flag_write | low | 0 | set/clear flag bit18 in packed bt config dword |
| `0x02076156` | bt_config_flag18_read | low | 0 | extract flag bit18 from packed bt config dword |
| `0x02076176` | bt_config_flag15_read | low | 0 | extract flag bit15 from packed bt config dword |
| `0x020761a8` | bt_stack_config_init | med | 0 | apply cfg to controller, zero l2cap global, default params |
| `0x0207626c` | bt_memory_pool_setup | med | 0 | link count stride-sized blocks into free list |
| `0x02076284` | bt_list_find_or_append | med | 0 | find node in list else append at tail |
| `0x02076298` | bt_list_register_6e0 | low | 0 | register node in global list 0x1c0c6e0 if absent |
| `0x020762a6` | bt_feature_toggle_apply | low | 0 | toggle cfg bit1 and push update to controller |
| `0x020762d0` | bt_service_node_register | low | 0 | init node with data, append to registry list |
| `0x020762e4` | bt_handler_find_by_id | med | 0 | find registered node by 16-bit id in list |
| `0x02076300` | bt_list_pop_head | med | 0 | detach and return list head node |
| `0x02076310` | bt_list_add_unique | med | 0 | push node at head if not already linked |
| `0x02076324` | bt_id_callback_register | low | 0 | alloc pool node, register callback under 16-bit id |
| `0x0207667a` | bt_mode_to_slot | low | 0 | map mode 4/6/2 to slot 0/1/2 else -1 |
| `0x02076694` | bt_mode_handler_set | low | 0 | store 64-bit value into per-mode slot table |
| `0x020766ae` | bt_stack_init | med | 0 | bt host stack init: pools, l2cap, config, mac restore, task |
| `0x02076a12` | hci_task_msg_post | med | 0 | post small event message to hci/btstack task |
| `0x02076a42` | hci_connection_create | med | 0 | create connection entry for bdaddr, notify task |
| `0x02076b2a` | hci_local_lmp_feature_test | med | 0 | test bit20 of local LMP feature flags |
| `0x02076c00` | bt_linkkey_delete | med | 0 | scan pairing store, erase records matching bdaddr |
| `0x02076c6e` | bt_stack_status_flag | low | 0 | read masked bt stack busy/status flag |
| `0x02076c90` | hci_event_broadcast | med | 0 | call all registered hci event handlers with packet |
| `0x02076cca` | bt_pairing_record_verify | med | 0 | read 32B pairing record, verify addr and crc16 |
| `0x02076d22` | bt_linkkey_get | med | 0 | return 16-byte link key for device address |
| `0x02076d8a` | bt_linkkey_store | med | 0 | find or reuse slot, write 32B pairing record |
| `0x02076f6a` | bt_linkkey_put | med | 0 | insert link key record for device into store |
| `0x02076fcc` | bt_pairing_record_byte4_access | low | 0 | read/update type byte of device pairing record |
| `0x0207704e` | bt_device_table_update | low | 0 | register/remove device addr, sync pairing record |
| `0x02077070` | hci_conn_lookup_thunk | med | 0 | thunk to connection-by-handle lookup |
| `0x0207707a` | hci_send_cmd_thunk | med | 0 | thunk to hci command issuer |
| `0x02077084` | l2cap_next_sig_id | med | 0 | increment and return l2cap signalling identifier |
| `0x02077098` | hci_pending_event_push | low | 0 | queue 8-byte event record, kick processing |
| `0x020770e8` | hci_max_acl_len_query | med | 0 | return max acl data length 672 or 1006 |
| `0x02077104` | l2cap_channel_signal_handler | med | 0 | per-channel signalling: disconnect/config option parsing |
| `0x0207735e` | l2cap_channel_find_by_sig_id | med | 0 | irq-safe channel list lookup by signalling id |
| `0x020773fa` | l2cap_acl_rx_handler | med | 0 | acl rx: cid dispatch, signalling cmds, l2cap events |
| `0x020777ac` | l2cap_run | med | 0 | process channel states/timeouts, send signalling replies |
| `0x02077a04` | hci_vendor_events_broadcast | low | 0 | build 0xE2-tagged subevents, broadcast to handlers |
| `0x02077a74` | bt_record_find_by_id_addr | med | 0 | find list node by id and 6-byte address |
| `0x02077aba` | bt_record_alloc_add | med | 0 | allocate 1236B node, init addr/id, link list |
| `0x02077b10` | bt_connection_list_poll | low | 0 | iterate connection list, service pending states/timeouts |
| `0x02077b96` | hci_event_handler | med | 0 | btstack hci event dispatcher: conn/linkkey/le-meta events |
| `0x02078424` | hci_can_send_query | low | 0 | query tx availability from stack counters |
| `0x02078448` | bt_listeners_event_notify | low | 0 | emit 4-byte event 0x78 to registered callbacks |
| `0x02078528` | ble_entry_find_by_addr | med | 0 | find le connection entry by 6-byte address |
| `0x02078554` | le_service_item_bind | low | 0 | bind rodata service item into free entry slot |
| `0x02078596` | ble_entry_alloc | med | 0 | allocate le connection entry, register service items |
| `0x0207861e` | bt_pairing_record_byte5_access | low | 0 | read/update flag byte of device pairing record |
| `0x02078680` | l2cap_channel_create | med | 0 | allocate/init l2cap channel, register and configure |
| `0x0207875c` | ble_entry_find_by_handle | med | 0 | find le entry by handle in two-slot table |
| `0x0207878e` | l2cap_tx_packet_build | low | 0 | fill tx packet header fields and payload, enqueue |
| `0x020787da` | l2cap_channel_data_send | low | 0 | lookup channel, copy payload, transmit; panic on failure |
| `0x02078826` | l2cap_data_send | med | 0 | send L2CAP packet by handle, return success flag |
| `0x02078836` | avdtp_signal_msg_send | high | 0 | build AVDTP 2-byte signaling header, send via L2CAP |
| `0x0207886c` | avdtp_signal_cmd_send | high | 0 | build and send AVDTP signaling command incl delayreport |
| `0x020788bc` | avdtp_discover_cmd_send | med | 0 | send DISCOVER signal then reset both SEP states |
| `0x020788f2` | avdtp_connect_event_handle | med | 0 | on connect: start discover, notify registered listeners |
| `0x0207893e` | l2cap_channel_close_req | med | 0 | lookup channel by handle, request close when active |
| `0x0207895c` | avdtp_delayreport_send | med | 0 | send DELAYREPORT signal with queued payload byte |
| `0x02078972` | avdtp_session_event_dispatch | med | 0 | dispatch session events 13/50/51/59 to listeners |
| `0x02078a44` | avdtp_discover_rsp_build | high | 0 | DISCOVER handler: collect both SEPs' info into response |
| `0x02078ab0` | avdtp_sep_find_by_seid | high | 0 | find stream endpoint by 6-bit SEID in table |
| `0x02078aca` | avdtp_get_capabilities_handle | med | 0 | GET_(ALL_)CAPABILITIES: query SEP ops, build reply |
| `0x02078b40` | avdtp_set_configuration_handle | med | 0 | SET_CONFIGURATION: bind SEP, configure via ops vtable |
| `0x02078c0a` | avdtp_get_configuration_handle | med | 0 | GET_CONFIGURATION: return current SEP configuration |
| `0x02078c7a` | avdtp_reconfigure_handle | med | 0 | RECONFIGURE: apply codec/reporting capability changes |
| `0x02078d16` | avdtp_open_handle | med | 0 | OPEN signal: move configured SEP to open state |
| `0x02078da6` | avdtp_start_handle | med | 0 | START signal: move open SEP to streaming state |
| `0x02078e38` | avdtp_close_handle | med | 0 | CLOSE signal: stop stream, release SEP flags |
| `0x02078ed2` | avdtp_suspend_handle | med | 0 | SUSPEND signal: streaming SEP back to open state |
| `0x02078f62` | avdtp_abort_handle | med | 0 | ABORT signal: force SEP to aborted state |
| `0x02078fb6` | avdtp_accept_rsp_send | med | 0 | send 2-byte AVDTP accept response for signal |
| `0x02078fec` | avdtp_media_rtp_rx | med | 0 | media RX: validate RTP header/seq, route to SEP |
| `0x0207915a` | avdtp_open_rsp_commit | low | 0 | finalize SEP open state, emit signal response |
| `0x020791a2` | avdtp_signaling_packet_process | high | 0 | parse AVDTP signaling packet, dispatch signal handlers |
| `0x020794a0` | avdtp_disconnect_req | med | 0 | mark signaling channel disconnecting, request close |
| `0x020794b4` | a2dp_feature_mask_test | low | 0 | test argument bits against global capability mask |
| `0x020794c0` | a2dp_state_flags_update | med | 0 | update A2DP connection flags, emit btstack events |
| `0x020798a8` | a2dp_connect_ind_handle | low | 0 | connect indication: find device by address, notify listeners |
| `0x020799c2` | avdtp_sep_error_notify | low | 0 | notify all listeners of SEP abort with error |
| `0x020799f6` | avdtp_l2cap_event_dispatch | med | 0 | L2CAP event router: signaling/media RX, connect, close |
| `0x02079c22` | avdtp_service_cap_parse | med | 0 | parse AVDTP capabilities, extract SBC rate and channels |
| `0x02079f50` | a2dp_media_data_write | low | 0 | route received media packet toward decoder output |
| `0x02079f8a` | a2dp_media_sessions_poll | low | 0 | iterate three stream sessions, flush pending media |
| `0x02079fd8` | a2dp_state_flag_set | low | 0 | set connection state bits on current device record |
| `0x0207a00a` | a2dp_user_ctrl_dispatch | med | 0 | fifteen-case A2DP user command and state dispatcher |
| `0x0207a2e8` | bt_handle_entry_lookup | low | 0 | scan two-entry table for matching channel handle |
| `0x0207a30e` | u24_pack_le | med | 0 | pack three bytes into one 24-bit value |
| `0x0207a31e` | avrcp_vendor_cmd_dispatch | med | 0 | match BT-SIG company id, call registered PDU handler |
| `0x0207a374` | avctp_tx_flush | med | 0 | transmit queued AVCTP message, clear pending flag |
| `0x0207a398` | avrcp_packet_build_send | med | 0 | build AVCTP frame with PID 0x110E, queue payload |
| `0x0207a438` | bt_event_flag_set | low | 0 | set event bit in session flags, notify task |
| `0x0207a44a` | avctp_avrcp_packet_handle | high | 0 | validate AVCTP PID 0x110E, dispatch AV/C passthrough/unit/vendor opcodes |
| `0x0207a764` | avctp_channel_find_by_addr | high | 0 | scan two-slot channel table, memcmp 6-byte bdaddr |
| `0x0207a794` | avctp_channel_alloc_init | high | 0 | take free channel slot, init defaults, addr, callbacks |
| `0x0207a7f0` | bt_event_wakeup_thunk | med | 0 | u16-arg thunk into os_event_wakeup |
| `0x0207a7fc` | avctp_pending_wakeup_cancel | med | 0 | cancel pending AVCTP wakeup/timer, clear record |
| `0x0207a812` | avctp_channel_free | med | 0 | notify listeners, clear flags, release channel slot |
| `0x0207a876` | avctp_channel_link_setup | med | 0 | find-or-alloc channel, register CID, flags, notify |
| `0x0207a908` | avctp_l2cap_event_dispatch | med | 0 | route l2cap events 0x70-0x7A and AVRCP rx packets |
| `0x0207aaae` | avctp_timer_set_scaled | low | 0 | store timeout unit, scale to ms, arm sys timer |
| `0x0207aae8` | avctp_conn_state_ctrl | med | 0 | connect/disconnect/timeout control for AVCTP channel |
| `0x0207abe4` | avrcp_status_flag_sync | low | 0 | sync play/pause status bits, notify, register event ids |
| `0x0207adfa` | avctp_tx_seq_send | low | 0 | bump 4-bit tx sequence, build and send AVCTP packet |
| `0x0207ae48` | avrcp_get_element_attrs_send | high | 0 | send AVRCP GetElementAttributes PDU 0x20 request |
| `0x0207ae8c` | avrcp_rsp_event_parse | med | 0 | parse AVRCP responses: events bitmask, playback status, dispatch |
| `0x0207b22c` | sdp_channel_close_if_active | med | 0 | close SDP l2cap channel when query active |
| `0x0207b246` | sdp_channel_open | med | 0 | open SDP l2cap channel (PSM 1), store query UUID |
| `0x0207b27c` | store_be16 | high | 0 | write u16 big-endian at buffer offset |
| `0x0207b28c` | sdp_de_seq_header_store | med | 0 | write SDP sequence header byte plus BE16 length |
| `0x0207b29a` | sdp_de_header_reserve | med | 0 | emit placeholder 3-byte data element header |
| `0x0207b2a2` | sdp_uuid128_de_store | high | 0 | store UUID128 data element (0x1C, 16 bytes) |
| `0x0207b2c4` | store_be32 | high | 0 | write u32 big-endian at buffer offset |
| `0x0207b2ea` | sdp_data_element_store | high | 0 | encode SDP data element header and BE payload |
| `0x0207b332` | sdp_de_size_class | high | 0 | extract SDP element size descriptor (low 3 bits) |
| `0x0207b338` | sdp_de_header_len_calc | med | 0 | map size class to element header byte count |
| `0x0207b352` | sdp_de_type | high | 0 | extract SDP element type (bits 3..7) |
| `0x0207b358` | sdp_de_record_len | high | 0 | compute total SDP data element record length |
| `0x0207b3a8` | l2cap_channel_exists | med | 0 | bool: channel lookup by sig id non-null |
| `0x0207b3b8` | sdp_l2cap_send_guarded | med | 0 | send SDP packet when length and channel valid |
| `0x0207b3d2` | sdp_search_attr_req_send | med | 0 | build/send ServiceSearchAttributeRequest for UUID |
| `0x0207b4bc` | sdp_query_session_ctrl | med | 0 | SDP client query state machine: start/abort/retry PnP |
| `0x0207b556` | sdp_de_seq_foreach | med | 0 | walk SDP sequence elements invoking callback each |
| `0x0207b5b0` | sdp_record_uuid_match | low | 0 | scan service record for requested UUID match |
| `0x0207b5ce` | sdp_l2cap_close_thunk | med | 0 | thunk to l2cap_channel_close_req |
| `0x0207b5d6` | sdp_service_search_handler | med | 0 | PDU 2 handler: match services, build search response |
| `0x0207b752` | sdp_uint16_seq_scan | low | 0 | iterate sequence, callback per uint16 element value |
| `0x0207b7dc` | sdp_first_uint16_get | low | 0 | return first uint16 attribute value via scanner |
| `0x0207b7fa` | sdp_uint16_params_get | low | 0 | collect uint16 protocol params into out struct |
| `0x0207b82e` | sdp_service_attr_handler | med | 0 | PDU 4 handler: build ServiceAttributeResponse from record |
| `0x0207b96e` | sdp_search_attr_handler | med | 0 | PDU 6 handler plus SDP l2cap server dispatcher |
| `0x0207bcba` | sdp_record_attr_find | low | 0 | scan record elements via callback, return match |
| `0x0207bcd8` | sdp_tx_stream_write | med | 0 | append bytes to SDP response stream, update counters |
| `0x0207bda4` | sdp_get_normalized_uuid | high | 0 | parse SDP UUID element (16/32/128-bit), normalize with base UUID |
| `0x0207be0c` | sdp_record_matches_service_search_pattern | med | 0 | match SDP record attributes/UUIDs against search pattern |
| `0x0207be90` | sdp_tx_pending_flush | low | 0 | commit pending SDP tx length, notify channel, clear |
| `0x0207beb0` | sdp_master_launch_connection | med | 0 | orchestrate profile connects, send SDP query per service UUID |
| `0x0207c28a` | bt_busy_timer_tick | low | 0 | decrement busy counter in bt context, report active |
| `0x0207c2a8` | bt_cmd_timer_tick | low | 0 | decrement pending-command counter, report still pending |
| `0x0207c2c6` | user_cmd_timeout_check | med | 0 | scan command records, decrement nibbles, post retry messages |
| `0x0207c3a8` | bt_conn_send_step_scan | low | 0 | iterate two BT connections, advance per-conn send steps |
| `0x0207c440` | bt_profile_channel_add | med | 0 | allocate 24-byte channel record, mark profile connecting |
| `0x0207c520` | sdp_channel_query_launch | low | 0 | mark channel busy, start/retry SDP query unless SDP UUID |
| `0x0207c552` | bt_profile_channel_remove | med | 0 | free channel record, save peer addr, rotate index |
| `0x0207c5dc` | hci_connectable_control | med | 0 | set/clear connectable flag, issue HCI scan command |
| `0x0207c606` | hci_inquiry_scan_off | low | 0 | thunk disabling inquiry scan via irq-locked helper |
| `0x0207c610` | hci_page_scan_off | low | 0 | thunk disabling page scan via helper |
| `0x0207c61a` | user_cmd_loop_handler | med | 0 | BT user-command run loop; also HID device-name setup |
| `0x0207ce08` | bt_peer_addr_save | low | 0 | store peer bdaddr plus length into saved-addr struct |
| `0x0207ce1e` | bt_hci_event_dispatch | med | 0 | dispatch HCI ACL events: connect, disconnect, key handling |
| `0x0207d108` | bt_channel_mtu_store | low | 0 | irq-locked per-channel u16 min/mtu store by index |
| `0x0207d18a` | att_ccc_flag_set | low | 0 | set flag in 8-byte ATT record for handle index |
| `0x0207d1a8` | net_store_16 | high | 0 | store u16 big-endian at buffer offset |
| `0x0207d1b8` | reverse_bytes | high | 0 | reverse-copy N bytes into destination |
| `0x0207d1d0` | reverse_128 | high | 0 | reverse 16-byte key into destination |
| `0x0207d1d8` | little_endian_store_16 | high | 0 | store u16 little-endian at buffer offset |
| `0x0207d1e8` | reverse_bd_addr | high | 0 | reverse 6-byte bluetooth address |
| `0x0207d1f0` | ptr_is_null | low | 0 | return boolean argument-is-null |
| `0x0207d1fa` | store_le32_at_field11 | low | 0 | write u32 little-endian at struct offset 11 |
| `0x0207d20a` | bt_bond_flag_get_thunk | low | 0 | tail-call thunk into bond-db flag helper |
| `0x0207d212` | bt_bond_param_stage | low | 0 | stage four u16 fields into bond context, commit |
| `0x0207d25a` | bt_bond_param_update | low | 0 | copy data into bond context then stage params |
| `0x0207d286` | reverse_bytes_local | med | 0 | local duplicate reverse-copy helper for addr/key |
| `0x0207d29e` | bt_get_current_conn_addr | low | 0 | return current connection peer addr/type, fallback local |
| `0x0207d2e4` | big_endian_read_32 | high | 0 | read u32 big-endian from byte buffer |
| `0x0207d2fc` | reverse_56 | med | 0 | reverse 7-byte field into destination |
| `0x0207d306` | bt_bond_record_match | med | 0 | match bond record by addr, plus key if authenticated |
| `0x0207d354` | bt_bond_db_lookup | med | 0 | iterate VM bond slots, match address and 16-byte key |
| `0x0207d3fc` | reverse_64 | med | 0 | reverse 8-byte field into destination |
| `0x0207d406` | bt_link_key_type_get | med | 0 | return current connection link key type 0..3 |
| `0x0207d430` | bt_get_local_addr_reversed | low | 0 | return local bdaddr reversed, zeros when no connection |
| `0x0207d460` | bt_bond_db_delete_record | med | 0 | erase VM bond slot, compact index table, persist |
| `0x0207d4c6` | bt_bond_db_remove_records | med | 0 | iterate bonded device table, remove records matching address |
| `0x0207d54a` | bt_bond_db_add_record | med | 0 | build 52-byte device record, dedupe, persist via VM write |
| `0x0207d6c6` | bt_bond_db_find_record | med | 0 | find bonded record by address, type and callback |
| `0x0207d742` | bt_bond_db_find_wrapper | low | 0 | argument-swap wrapper around bt_bond_db_find_record |
| `0x0207d768` | bt_hci_transport_task | med | 0 | btstack HCI message dequeue and opcode dispatch loop |
| `0x0207db7a` | bt_stack_flag_clear | low | 0 | clear byte flag at bt state struct +533 |
| `0x0207db8c` | bt_bond_db_remove_type10 | low | 0 | remove type-10 bonded records matching address |
| `0x0207dc02` | bt_config_set_field3 | low | 0 | set bt config field 3 via helper |
| `0x0207dc18` | bt_bond_db_has_addr | low | 0 | check bonded device existence by address |
| `0x0207dc48` | bt_bond_db_validate | low | 0 | validate device db header flags, conditionally check entry |
| `0x0207dd38` | le_device_db_remove | med | 0 | mark LE bonding entry free (0xFF) |
| `0x0207dd4c` | le_device_db_init | med | 0 | malloc 56-byte LE bonding entry table |
| `0x0207dd84` | le_device_db_free_slot_count | med | 0 | count free slots in LE bonding table |
| `0x0207dda8` | le_device_db_identity_get | med | 0 | read entry index, address and IRK |
| `0x0207ddf6` | le_device_db_encryption_get | med | 0 | read LTK, EDIV, RAND and auth flags |
| `0x0207de40` | le_device_db_add | med | 0 | store address and IRK into free bonding slot |
| `0x0207de7c` | le_device_db_encryption_set | med | 0 | write LTK, EDIV, RAND, key size, auth flags |
| `0x0207deb6` | le_device_db_deinit | med | 0 | free LE bonding table buffer |
| `0x0207df44` | bt_conn_sm_ctx_get | low | 0 | lookup connection by handle, return +60 context |
| `0x0207df66` | ble_sm_passkey_clear | low | 0 | clear pairing passkey buffer, set SM state, core-locked |
| `0x0207dfea` | ble_sm_tk_buf_clear | med | 0 | zero 16-byte TK buffer at context +32 |
| `0x0207e006` | ble_sm_passkey_set_default | low | 0 | write default 123456 passkey into SM context |
| `0x0207e098` | ble_sm_config_byte_set | low | 0 | store config byte at SM context +320 |
| `0x0207e0aa` | ble_sm_auth_req_default | low | 0 | set default auth-requirements byte 51 at +314 |
| `0x0207e0be` | ble_sm_init | med | 0 | alloc SM context, load or generate IRK/CSRK via VM/TRNG |
| `0x0207e1ee` | ble_sm_param_pair_set | low | 0 | set two SM parameter bytes to 5 at +312 |
| `0x0207e208` | ble_sm_key_size_range_set | med | 0 | set encryption key size range 7..16 at +310 |
| `0x0207e224` | ble_sm_auth_flags_or | low | 0 | OR bit 8 into auth flags halfword at +314 |
| `0x0207e23c` | ble_sm_queue_init | low | 0 | init list/queue node at SM context +396 |
| `0x0207e254` | ble_sm_handler_register | low | 0 | store handler fn 0x0200097e, init node at +388 |
| `0x0207e270` | bt_cfg_buf_fields_init | low | 0 | zero 16-byte buffer, set config fields 12/14 |
| `0x0207e296` | bt_stack_stat_inc_324 | low | 0 | increment event counter at context +324 |
| `0x0207e2a8` | ble_hci_cmd_send | low | 0 | build two param buffers, send HCI command via 0x654de |
| `0x0207e2e4` | bt_stack_stat_inc_328 | low | 0 | increment event counter at context +328 |
| `0x0207e2f6` | ble_hci_handler_set | low | 0 | store handler pointer at +376, notify via 0x65552 |
| `0x0207e30c` | sm_address_resolution_idle | med | 0 | return 1 when no address resolution in progress |
| `0x0207e320` | sm_event_packet_build | med | 0 | build sm_just_event_t header (type,size,handle,addr) |
| `0x0207e346` | sm_event_dispatch | med | 0 | invoke registered SM packet handlers with event |
| `0x0207e386` | sm_event_send_simple | med | 0 | build 16-byte SM event, dispatch to handlers |
| `0x0207e3a8` | sm_address_resolution_start | med | 0 | stage peer addr, notify identity-resolving started (0xD8) |
| `0x0207e3ee` | sm_key_is_zero | med | 0 | check 16-byte SMP key all zero |
| `0x0207e3f6` | sm_event_send_with_device | low | 0 | build SM event including device-db lookup and peer address |
| `0x0207e446` | sm_address_resolution_done | med | 0 | finish identity resolving, notify success (0xDA) or failure |
| `0x0207e510` | sm_event_send_for_conn | med | 0 | emit connection SM event (pairing started 0xDF) to handlers |
| `0x0207e540` | sm_pairing_ctx_reset | low | 0 | reset pairing context bytes before LTK/encryption work |
| `0x0207e55c` | sm_get_pairing_auth_req | med | 0 | compute auth_req byte for SMP pairing PDU |
| `0x0207e57c` | sm_prepare_pairing_pdus | med | 0 | assemble SMP pairing request/response PDU fields (iocap,oob,authreq,keydist) |
| `0x0207e63a` | sm_io_cap_encode | low | 0 | encode IO capability bits into method-matrix index |
| `0x0207e65a` | sm_set_io_capabilities | med | 0 | store local IO capability encoding for pairing |
| `0x0207e672` | sm_select_stk_method | med | 0 | pick pairing method via 5x5 IO-capability matrix table |
| `0x0207e73e` | sm_pairing_timer_stop | med | 0 | remove active pairing timeout timer |
| `0x0207e75a` | sm_pairing_timer_start | med | 0 | arm 30s pairing timeout with callback and connection |
| `0x0207e788` | sm_pairing_timer_clear_handle | med | 0 | stop pairing timer if handle matches active pairing |
| `0x0207e7aa` | sm_conn_timeout_restart | low | 0 | restart per-connection 300ms response timer |
| `0x0207e7e4` | sm_pairing_timer_restart | low | 0 | wrapper re-arming the pairing timeout timer |
| `0x0207e7ea` | sm_event_send_ext | low | 0 | build 16-byte SM event with extra stack arg, dispatch |
| `0x0207e818` | sm_pairing_execute_method | low | 0 | dispatch pairing user-interaction events per selected method |
| `0x0207e8bc` | sm_state_advance | med | 0 | increment connection pairing state field |
| `0x0207e8c2` | sm_c1_xor_p1 | low | 0 | SMP c1: XOR block with pairing req/rsp p1 value |
| `0x0207e90c` | sm_peer_io_cap_matches | low | 0 | compare peer IO capability encoding against local |
| `0x0207e938` | sm_bonding_store_peer_keys | med | 0 | store peer LTK/keys in bonding db, notify identity created |
| `0x0207ea7e` | sm_run | high | 0 | btstack SM main pairing/encryption/resolution state machine |
| `0x0207f482` | sm_load_peer_ltk_from_db | med | 0 | fetch bonded LTK/EDIV/RAND into pairing context |
| `0x0207f4fe` | sm_encryption_start_continue | low | 0 | advance deferred encryption-start state then run SM |
| `0x0207f588` | sm_deinit | low | 0 | free SM global state block |
| `0x0207f5a6` | sm_encryption_key_size | med | 0 | return negotiated encryption key size for handle |
| `0x0207f5c0` | sm_authenticated | low | 0 | return authenticated flag for connection handle |
| `0x0207f5d8` | sm_security_level | low | 0 | return security level for connection handle |
| `0x0207f5f6` | sm_disconnect | low | 0 | disconnect BLE link with reason 0x13, stop pairing timer |
| `0x0207f668` | sm_zero_pad | med | 0 | zero key buffer tail from offset to byte 15 |
| `0x0207f67c` | sm_hci_event_handler | high | 0 | SM HCI events (connect/disconnect/encrypt/LE-rand) plus rand/encrypt results |
| `0x0207fcfa` | sm_pairing_state_reset | low | 0 | reset connection pairing state to initial phase |
| `0x0207fd0e` | sm_pdu_handler | high | 0 | receive/validate SMP PDUs via code-length table, drive pairing |
| `0x02080104` | ble_att_server_setup_init | med | 0 | register ATT CID handler, profile db, callbacks, timers |
| `0x0208015a` | att_server_register_packet_handler | med | 0 | store app packet handler into ATT state |
| `0x0208016a` | att_server_request_can_send_now_event | med | 0 | set can-send flag, request L2CAP can-send on CID 4 |
| `0x02080182` | att_can_send_now_stub | low | 0 | tail-call wrapper to can-send request |
| `0x02080188` | att_get_connection | med | 0 | lookup connection by handle, return ATT state offset |
| `0x0208019a` | att_can_send_check | low | 0 | wrapper querying ATT channel busy state |
| `0x020801a4` | att_server_notify | high | 0 | send ATT Handle Value Notification (0x1B) |
| `0x020801f8` | att_server_indicate | high | 0 | send ATT Indication (0x1D), arm 30s confirm timer |
| `0x02080278` | att_packet_dispatch | low | 0 | route incoming ATT events to registered handlers |
| `0x0208033a` | att_hci_event_handler | med | 0 | HCI events: connect/disconnect/encrypt, per-conn ATT state |
| `0x0208049e` | att_emit_mtu_event | med | 0 | emit 0xB5 MTU-exchange-complete event to app handler |
| `0x020804e0` | att_server_packet_handler | med | 0 | main ATT channel handler: PDUs, can-send, indication confirm |
| `0x0208080a` | att_conn_bitfield_query | low | 0 | read 3-bit field from connection state byte |
| `0x02080838` | att_mtu_entry_find | low | 0 | find per-connection MTU entry by con handle |
| `0x02080850` | att_mtu_entry_create | med | 0 | get-or-create MTU entry, default ATT_DEFAULT_MTU 23 |
| `0x02080896` | att_mtu_entry_create_stub | low | 0 | tail-call wrapper to MTU entry create |
| `0x0208089c` | att_set_mtu_notify | low | 0 | update connection MTU, emit change event |
| `0x02081f48` | ssp_f1_p192 | med | 0 | HMAC-SHA256 over U||V||Z (49 bytes), 16-byte commitment |
| `0x02081f80` | ssp_f1_p192_swap | med | 0 | f1 wrapper reversing big-endian coordinates and digest |
| `0x02081fe6` | ssp_g_input_sha256 | med | 0 | pack 80-byte g-function input, one-shot SHA-256 |
| `0x0208202c` | ssp_g_p192_passkey | high | 0 | numeric comparison value from digest mod 10^6 |
| `0x020820cc` | ssp_f3_p192 | med | 0 | HMAC-SHA256 with 24-byte key over 63-byte message |
| `0x02082136` | ssp_f3_p192_build | med | 0 | pack nonces, IO capabilities and addresses, call f3 |
| `0x0208223e` | ssp_f2_p192 | med | 0 | HMAC-SHA256 with 24-byte key over 48-byte message |
| `0x0208229c` | ssp_f2_p192_linkkey | high | 0 | link key derivation, packs btlk keyID for f2 |

## POWER (21)

| addr | name | conf | callers | purpose |
|---|---|---|---|---|
| `0x0201e724` | sys_power_flag_set | med | 0 | set/clear indexed flag bit from power descriptor table |
| `0x0201e764` | sys_power_set_state | high | 0 | power state machine: per-state flags, enter/exit callbacks |
| `0x020309fa` | pmu_counter_read_us | med | 0 | read PMU counter via p33, scale to microseconds |
| `0x02030a7c` | lp_device_suspend_notify | med | 0 | run suspend ops for named devices, gate PMU power |
| `0x02030bd8` | sleep_enter_save_state | med | 0 | save SFR/IRQ state to RAM, arm wake sources |
| `0x020314cc` | low_power_sleep_cycle | med | 0 | enter and exit sleep, report slept microseconds |
| `0x02031780` | lp_device_resume_notify | med | 0 | restore PMU shadow, run device resume ops |
| `0x020318b0` | lp_wakeup_drift_fix | low | 0 | repair tick drift after wake, retrigger resume notify |
| `0x020333a6` | lrc_calibration_isr | med | 0 | average 20 counter samples, update lp clock Hz |
| `0x0203353c` | lp_suspend_ready_check | low | 0 | verify device list idle, set suspend-ready flag |
| `0x02034852` | lowpower_idle_try | low | 0 | low-power idle condition check and hook under lock |
| `0x020348cc` | lowpower_veto_list_check | low | 0 | walk registered sleep callbacks checking for veto |
| `0x020348f0` | lowpower_sleep_enter | low | 0 | take sleep-inhibit vote then run sleep entry checks |
| `0x02034ed2` | lowpower_inhibit_release | low | 0 | release sleep-inhibit count; tail is periodic trim monitor |
| `0x02036f6c` | pmu_charge_manage | med | 0 | periodic P33 PMU register config, charge state machine |
| `0x0206bf48` | battery_param_set | low | 0 | store halfword battery parameter into status struct |
| `0x0206bf54` | battery_voltage_raw_set | low | 0 | store raw battery voltage halfword for UI display |
| `0x02089586` | pmu_wakeup_status_check | med | 0 | read P33 reg 0x35, test wakeup-source bits |
| `0x02089656` | rtc_alarm_set_us | med | 0 | convert microseconds to ticks, program RTC compare |
| `0x020898d8` | pmu_reg_seq | low | 0 | short P33 register 0x59 bit sequence (PMU config) |
| `0x02089944` | power_sleep_manager | med | 0 | poweroff, deep-sleep enter/restore, clock and flash reinit |

## SECURITY (70)

| addr | name | conf | callers | purpose |
|---|---|---|---|---|
| `0x02036a70` | hw_cipher_16b_block | med | 0 | feed 2x16B blocks to crypto engine, read 16B result |
| `0x02038296` | aes_hw_block_transform | high | 0 | single 128-bit AES block via crypto SFR 0x41200 |
| `0x02038388` | aes_ccm_encrypt_auth | med | 0 | AES-CCM CBC-MAC plus CTR mode over hardware AES |
| `0x0203855c` | aes_ccm_hw_entry | med | 0 | load AES key under hardware mutex then run CCM |
| `0x02061dfa` | hw_crypto_block_op | low | 0 | run 16-byte block through HW crypto engine, post result |
| `0x02068582` | aes_xor16 | med | 0 | XOR two 16-byte blocks into output |
| `0x0206859e` | link_auth_nonce_mix | med | 0 | mix TRNG nonce into 16-byte session keys |
| `0x02068742` | link_auth_challenge_gen | med | 0 | TRNG challenge into packet buffer, AES encrypt, endian swap |
| `0x020687a2` | link_auth_ecdh_compute | low | 0 | gather session params into multi-arg crypto primitive call |
| `0x02068808` | link_auth_ecdh_run | low | 0 | run key exchange computation and trace result |
| `0x0206883c` | link_auth_confirm_verify | med | 0 | compute auth value and memcmp 16-byte confirmation |
| `0x0206aa06` | chip_uid_scramble_transform | low | 0 | obfuscate 6-byte chip ID to 5-byte XOR-fold code |
| `0x0206c728` | cipher_sbox_table_data | low | 0 | misdisassembled cipher S-box and ECC constant tables |
| `0x0206ca32` | cipher_key_schedule | med | 0 | expand 16-byte key into 272-byte round context |
| `0x0206caec` | cipher_diffuse_bytes | med | 0 | 8-step pairwise byte diffusion over 16-byte block |
| `0x0206cb0c` | cipher_permute16 | high | 0 | fixed 16-byte permutation via stack buffer |
| `0x0206cb86` | cipher_rounds_core | med | 0 | 8-round SP-network, dual 256B S-boxes, XOR/ADD key mixing |
| `0x0206cd50` | cipher_cbc_crypt | med | 0 | CBC-like chained block crypt with derived subkeys |
| `0x0206cf76` | cipher_crypt_len12 | low | 0 | wrapper: chained crypt of 12-byte block |
| `0x0206cf9a` | cipher_crypt_len6 | low | 0 | wrapper: chained crypt of 6-byte block |
| `0x0206cfac` | cipher_mac_final | low | 0 | pad final block with tweak, key-schedule and encrypt |
| `0x0206d066` | cipher_mac_combine | low | 0 | interleave two inputs bytewise then encrypt block |
| `0x0206d574` | ecc_param_table_data | low | 0 | misdisassembled bignum/curve constant table data |
| `0x020808e8` | bi_more_comps | med | 0 | zero-extend bigint comps array to n words |
| `0x0208090a` | bi_alloc | high | 0 | allocate bigint from free list or memory pool |
| `0x02080960` | bi_initialize | high | 0 | init BI_CTX, create permanent bi_radix |
| `0x02080986` | trim | high | 0 | shrink bigint size past zero high words |
| `0x020809a0` | bi_import | med | 0 | import 16 big-endian bytes into new bigint |
| `0x020809e0` | find_max_exp_index | med | 0 | bit index of most significant set bit |
| `0x02080a06` | comp_left_shift | med | 0 | shift bigint left by n bits, growing |
| `0x02080ab0` | bi_rshift | med | 0 | shift bigint right by n bits in place |
| `0x02080b42` | bi_xor | high | 0 | XOR-combine two bigints, return larger |
| `0x02080b88` | bi_free | high | 0 | decrement refs, return bigint to free list |
| `0x02080bb2` | bi_poly_mod2 | med | 0 | GF(2) polynomial remainder via shift and XOR |
| `0x02080c24` | bi_poly_mul | med | 0 | carryless GF(2) polynomial multiply |
| `0x02080ca8` | bi_comps_export_be | low | 0 | export bigint comps as big-endian bytes |
| `0x02080cd2` | bi_terminate | med | 0 | depermanent and free bi_radix |
| `0x02080ce0` | sha256ProcessBlock | high | 0 | SHA-256 64-round block compression function |
| `0x02080dfe` | sha256Update | high | 0 | hash data in 64-byte blocks, track totals |
| `0x02080e60` | sha256Final | high | 0 | pad message, append bit length, emit digest |
| `0x02080ec4` | hmacCompute | high | 0 | one-shot HMAC-SHA256 via hash descriptor |
| `0x02081050` | sha256Compute | high | 0 | one-shot SHA-256; block holds sha256Init, K table |
| `0x02081282` | uECC_vli_clear | med | 0 | zero n words of a vli |
| `0x02081292` | uECC_vli_bytesToNative | med | 0 | pack byte string into vli words |
| `0x020812ce` | uECC_vli_add | med | 0 | multiword add, return carry |
| `0x02081300` | uECC_vli_testBit | med | 0 | test bit n of vli word array |
| `0x02081310` | ecc_p192_reduce | med | 0 | fast reduction mod P-192 prime, bit-mask plus conditional subtract |
| `0x02081358` | mpi_is_zero | high | 0 | OR all limbs, return 1 when bignum is zero |
| `0x02081372` | mpi_sub | high | 0 | limb-wise subtract with borrow, returns final borrow |
| `0x020813a4` | mpi_cmp | high | 0 | compare two bignums, returns -1/0/1 |
| `0x020813ce` | mpi_copy | high | 0 | copy bignum limb array of n words |
| `0x020813e4` | mpi_mac64 | high | 0 | 64-bit multiply-accumulate limb with carry-out chain |
| `0x0208140e` | ecc_field_mul | high | 0 | comba limb multiply then callback reduction mod p |
| `0x020814da` | ecc_field_sqr | med | 0 | field square shim: out = a^2 mod p |
| `0x020814e4` | ecc_point_scale_jacobian | med | 0 | scale point coords by z^2 and z^3 (Jacobian) |
| `0x0208151e` | ecc_field_sub | med | 0 | modular subtraction with conditional add-back of prime |
| `0x02081538` | mpi_cmp_words | high | 0 | compare limb arrays from most significant, returns 1/0/-1 |
| `0x02081562` | ecc_field_add | med | 0 | modular addition with conditional subtract of prime |
| `0x0208158a` | ecc_point_double_p192 | low | 0 | long field-op sequence, Jacobian point doubling |
| `0x02081698` | ecc_point_add_p192 | low | 0 | field-op sequence, point addition ladder step |
| `0x02081760` | mpi_rshift1 | high | 0 | shift bignum right one bit across limbs |
| `0x0208177c` | ecc_field_halve | med | 0 | divide by 2 mod p, adds prime first when odd |
| `0x020817ae` | ecc_field_invert | med | 0 | binary GCD modular inversion using halve and subtract |
| `0x020818a8` | ecc_point_mul_p192 | med | 0 | scalar multiply ladder with bit scan and affine conversion |
| `0x02081a46` | mpi_words_to_bytes | med | 0 | pack limbs into byte string via bit-offset extraction |
| `0x02081a72` | ecdh_p192_gen_keypair | med | 0 | RAND64 random scalar with retry, pub = k*G |
| `0x02081baa` | ecdh_p192_scalar_mul_valid | med | 0 | scalar times point with non-infinity result validation |
| `0x02081bfe` | ecdh_p192_compute_dhkey | med | 0 | import peer public key, compute and export shared secret |
| `0x02082536` | update_pkg_parse_verify | med | 0 | parse and verify update package header and .bin records |
| `0x02082b80` | update_verify_blocks | med | 0 | walk entry data blocks, CRC-verify and decipher each |

## MEMLIB (103)

| addr | name | conf | callers | purpose |
|---|---|---|---|---|
| `0x020026a8` | printf_parse_number | med | 0 | parse decimal field width/precision from format string |
| `0x020026ce` | printf_emit_string | med | 0 | emit %s string with width padding and precision |
| `0x0200273a` | printf_format_integer | med | 0 | convert 64-bit integer to digits with flags and base |
| `0x02002ba8` | vsnprintf | high | 0 | bounded printf engine: flags, width, precision, conversions |
| `0x020030f8` | _diprintf_r | high | 0 | formatted print to descriptor, newlib wrapper |
| `0x02008016` | memset_opt | high | 0 | word-optimized memset, 32-byte blocks |
| `0x020080ac` | zalloc_or_static | med | 0 | malloc, else zeroed static fallback buffer |
| `0x020080d4` | free_if_heap | med | 0 | free unless pointer is static fallback buffer |
| `0x0200843c` | bzero | high | 0 | zero buffer via aligned memset chunks |
| `0x020084bc` | realloc | med | 0 | realloc wrapper handling null ptr and zero size |
| `0x020094ca` | memcpy | high | 0 | optimized byte/word memcpy with 32-byte blocks |
| `0x02012c84` | fill_ff | med | 0 | fast fill buffer with 0xff, aligned block loops |
| `0x02018ce2` | dec_atoi | high | 0 | parse decimal integer, advancing string pointer |
| `0x02018d08` | sprintf_putc | high | 0 | append one char to sprintf output buffer |
| `0x02018d14` | sprintf_write_padded | high | 0 | write string with width, justification, pad char |
| `0x02018d7a` | sprintf_itoa | high | 0 | format 32-bit int to padded ASCII with sign |
| `0x02018e18` | sprintf_lltoa | high | 0 | format 64-bit int to padded ASCII with sign |
| `0x02018ec6` | _dtoa_r | high | 0 | double to decimal digit string with rounding |
| `0x0201909e` | dtoa | med | 0 | dtoa wrapper forcing fixed conversion mode |
| `0x020190b6` | _cvt | high | 0 | format double as e/f/g style text with exponent |
| `0x0201926c` | printf_efg_conv | med | 0 | printf %e/%f/%g handling: flags, precision, padding |
| `0x02019408` | vsprintf | high | 0 | vsprintf core: parse format, all conversions |
| `0x0201a258` | arena_alloc_zero | high | 0 | bump allocator: 4-align, bounds-check, zero-fill, return block |
| `0x0201d51e` | _getwchar_r | high | 0 | newlib reentrancy wrapper for getwchar |
| `0x0201db5e` | _getwchar_r | high | 0 | newlib reentrancy wrapper for getwchar |
| `0x0201db72` | _getwchar_r | high | 0 | newlib reentrancy wrapper for getwchar |
| `0x0201db86` | printf_fmt_int | high | 0 | printf integer formatter: width, zero/space pad, sign, base prefix |
| `0x0201dd0a` | _vsnprintf_r | high | 0 | printf format engine: conversions, width/precision, length modifiers |
| `0x0201e572` | snprintf | high | 0 | bounded-buffer sprintf wrapping the format core |
| `0x0201eb28` | list_link | med | 0 | doubly-linked list node link helper |
| `0x0201eb2e` | heap_malloc | high | 0 | SMP-locked best-fit free-list alloc, block split, guard magic |
| `0x0201ee96` | heap_block_check | high | 0 | validate heap block guard magics, panic on corruption |
| `0x0201eeda` | list_link | med | 0 | doubly-linked list node link helper |
| `0x0201eee0` | list_insert_after | med | 0 | doubly-linked list insert-after helper |
| `0x0201eeec` | heap_free | high | 0 | guard-checked free, coalesce neighbors, SMP-locked list |
| `0x0201f064` | list_insert_after | med | 0 | doubly-linked list insert-after helper |
| `0x0201f070` | list_del_init | med | 0 | unlink node and re-init as empty list head |
| `0x020282be` | strn_toupper | high | 0 | uppercase n bytes of ascii string in place |
| `0x02028fd2` | ld_word | high | 0 | load 16-bit little-endian value from byte pair |
| `0x02028fdc` | get_number | high | 0 | KNOWN_LIB helper, load 32-bit from bytes |
| `0x0202970a` | st_dword | high | 0 | store 32-bit value as four little-endian bytes |
| `0x0202971a` | st_qword | high | 0 | store 64-bit value as eight little-endian bytes |
| `0x0202975a` | st_word | high | 0 | store 16-bit value as two little-endian bytes |
| `0x0202a65c` | name_buf_tolower | med | 0 | lowercase A-Z letters over n-byte buffer |
| `0x0202a682` | name_buf_toupper | med | 0 | uppercase a-z letters over n-byte buffer |
| `0x0202b10c` | fmt_dec3 | med | 0 | format value as three ASCII decimal digits |
| `0x020350d0` | reverse_byte_copy | low | 0 | copy bytes forward into descending destination buffer |
| `0x02036678` | fmt_arg_walk_calc | low | 0 | walk printf-like format, consume varargs, sum size |
| `0x02036be4` | memcpy_rev16 | med | 0 | copy 16 bytes via backward-copy helper |
| `0x0203741c` | hex_nibble_ascii | high | 0 | convert 0-15 nibble to hex ASCII char |
| `0x0203862a` | list_add_tail | high | 0 | insert node before head of doubly-linked list |
| `0x0203869a` | list_del_init | high | 0 | unlink doubly-linked list node and reinitialize it |
| `0x02038d22` | strncasecmp_pos | high | 0 | case-insensitive bounded string compare returning match position |
| `0x0204260a` | memcmp | high | 0 | byte/word memory compare |
| `0x02042642` | memmove | high | 0 | overlap-safe memory copy, both directions |
| `0x02042704` | strcat | high | 0 | append string at end of destination |
| `0x0204271c` | strchr | high | 0 | find byte in string |
| `0x02042730` | strcmp | high | 0 | string compare with word-at-a-time fast path |
| `0x020427d0` | strcpy | high | 0 | string copy with word-at-a-time fast path |
| `0x0204283e` | strlen | high | 0 | string length |
| `0x0204284a` | strncmp | high | 0 | bounded string compare |
| `0x02042864` | strnlen | high | 0 | bounded string length |
| `0x02042878` | strtol | high | 0 | string to long, base detect, ERANGE via errno |
| `0x02042f08` | memset | high | 0 | fill memory with byte value |
| `0x020565a6` | mspace_ensure_init | high | 0 | lazy-init dlmalloc mparams/magic under spinlock |
| `0x02056670` | heap_find_segment | med | 0 | find heap segment descriptor owning given address |
| `0x0205668e` | sbrk | med | 0 | bump heap break pointer, bound-check against limit |
| `0x020566f0` | mspace_init_top | med | 0 | install aligned top-chunk header into mspace state |
| `0x0205672e` | mspace_malloc | high | 0 | dlmalloc core: smallbin/treebin paths, corruption traps |
| `0x02057892` | malloc | high | 0 | malloc wrapper tail-calling mspace_malloc |
| `0x0205789a` | mspace_free | high | 0 | dlmalloc free: chunk coalescing, bin insert, checks |
| `0x02057f96` | free | high | 0 | free wrapper tail-calling mspace_free |
| `0x02057f9e` | zalloc | med | 0 | malloc then memset zero on success |
| `0x02057fb8` | dispose_chunk | med | 0 | dlmalloc chunk dispose/coalesce helper |
| `0x02058446` | mspace_realloc | high | 0 | realloc: in-place shrink/extend, else malloc-copy |
| `0x02058812` | calloc | high | 0 | calloc with nmemb*size overflow guard |
| `0x0205884a` | mspace_memalign | med | 0 | power-of-2 aligned alloc via overallocate and split |
| `0x02065484` | setlinebuf | high | 0 | libc stub: set line buffering on stream |
| `0x02065552` | setlinebuf | high | 0 | libc stub: set line buffering on stream |
| `0x020666e4` | setlinebuf | high | 0 | KNOWN_LIB setlinebuf |
| `0x020668a2` | byte_buf_reverse | med | 0 | in-place reverse of byte buffer halves |
| `0x0206699e` | setlinebuf | high | 0 | libc setlinebuf (KNOWN_LIB match) |
| `0x02069b24` | setlinebuf | high | 0 | KNOWN_LIB verbatim |
| `0x0206be80` | setlinebuf | high | 0 | KNOWN_LIB verbatim |
| `0x0206bfe6` | setlinebuf | high | 0 | libc stub (KNOWN_LIB match) |
| `0x0206c052` | setlinebuf | high | 0 | libc stub (KNOWN_LIB match) |
| `0x0206c0f8` | setlinebuf | high | 0 | libc stub (KNOWN_LIB match) |
| `0x0206c3ee` | setlinebuf | high | 0 | libc stub (KNOWN_LIB match) |
| `0x0206c4d4` | setlinebuf | high | 0 | libc stub (KNOWN_LIB match) |
| `0x0206c4ea` | setlinebuf | high | 0 | libc stub (KNOWN_LIB match) |
| `0x0206db5e` | hsearch | high | 0 | KNOWN_LIB hash table search |
| `0x0207470c` | ld16_unaligned | high | 0 | load u16 from byte pair (unaligned read) |
| `0x0207471a` | slist_iter_has_next | med | 0 | list iterator: test whether next node exists |
| `0x02074736` | slist_iter_next | med | 0 | list iterator: advance cursor, return node |
| `0x02074b42` | slist_unlink_node | high | 0 | remove node from singly-linked list |
| `0x0207562a` | slist_insert_unique | med | 0 | insert node at list head if not already linked |
| `0x0207605e` | cfree | high | 0 | libc cfree: release block back to heap pool |
| `0x020770d6` | asctime | high | 0 | libc asctime: format broken-down time to string |
| `0x020779ee` | cfree | high | 0 | libc cfree: free allocated memory |
| `0x0207d756` | asctime | high | 0 | format broken-down time to static string |
| `0x0207dc0c` | read_le16 | med | 0 | read little-endian u16 from byte stream |
| `0x0207df56` | setlinebuf | high | 0 | set line buffering on stream |
| `0x0207e3d8` | is_buffer_all_zero | high | 0 | return 1 if all buffer bytes zero |

## MATHLIB (46)

| addr | name | conf | callers | purpose |
|---|---|---|---|---|
| `0x02001f7a` | bit_index_log2 | med | 0 | find highest set-bit index of value |
| `0x020020a0` | time_count_convert64 | med | 0 | 64-bit mul/div scale count by calibrated rate |
| `0x020023e8` | __udivdi3 | high | 0 | unsigned 64-bit division |
| `0x020025da` | chip_crc16 | med | 0 | hardware CRC16 over buffer via SFR 0x13500 |
| `0x02005592` | bit2_extract | low | 0 | return bit 2 of argument |
| `0x02007ea2` | s16_delta | low | 0 | compute 1+r1-r0 as signed 16-bit delta |
| `0x0200e1d4` | sin_lut_deg | med | 0 | fixed-point sine by degrees, quadrant-folded table lookup |
| `0x02017000` | cmp_u16 | med | 0 | compare two u16 values, bsearch comparator |
| `0x020188be` | clamp_add_range | med | 0 | add delta then clamp result to range |
| `0x0201bd44` | exp2f_lut | med | 0 | float exp2 via table interpolation, pi/sqrt2 constants |
| `0x0201d328` | pow2_u32 | med | 0 | compute 2^n via shift loop, bit-mask helper |
| `0x02028fc6` | u32_bit_length | med | 0 | count right-shifts to zero: 255 plus bit length |
| `0x02029f62` | pow2_mask | high | 0 | return (1<<n)-1 bitmask helper |
| `0x0202b21e` | pow10_u32 | high | 0 | return 10 raised to n |
| `0x0202ca16` | remquol | high | 0 | libm remainder and quotient, long double variant |
| `0x02037566` | crc16_hw_thunk | med | 0 | tail-call thunk to hardware CRC16 engine routine |
| `0x02038ed0` | ilog2_ceil | high | 0 | compute bit index of highest set bit of value |
| `0x02042564` | modf | high | 0 | split double into integer part and fraction |
| `0x020429c4` | rep_clz | high | 0 | 64-bit count-leading-zeros soft-float helper |
| `0x020429e2` | normalize | high | 0 | normalize double mantissa in place |
| `0x02042a04` | __adddf3 | high | 0 | software double add/sub; trailing df compare cores |
| `0x02042e70` | __eqdf2 | med | 0 | trampoline into shared df compare core |
| `0x02042e72` | __ltdf2 | med | 0 | trampoline into shared df compare core |
| `0x02042e74` | __ledf2 | med | 0 | trampoline into shared df compare core |
| `0x02042e76` | __gtdf2 | med | 0 | trampoline into gtdf2 compare core |
| `0x02042e78` | __subdf3 | high | 0 | negate second double, tail-jump into __adddf3 |
| `0x02042e7e` | __ieee754_sqrtf | high | 0 | FDLIBM float square root, digit-by-digit |
| `0x02042f34` | normalize | high | 0 | softfp helper: normalize 64-bit fraction, return shift |
| `0x02042f6a` | __divdf3 | high | 0 | software IEEE754 double division |
| `0x0204327a` | __fixdfsi | high | 0 | convert double to signed int32 |
| `0x020432ce` | __floatsidf | high | 0 | convert signed int32 to double |
| `0x0204331a` | __floatunsidf | high | 0 | convert unsigned int32 to double |
| `0x0204334e` | normalize | high | 0 | softfp helper: normalize 64-bit fraction, return shift |
| `0x02043384` | __muldf3 | high | 0 | software IEEE754 double multiply |
| `0x0205e248` | remquol | high | 0 | libm long-double remquo wrapper |
| `0x0205e25a` | ldbl_thunk_6cf9a | low | 0 | thunk to long-double helper at 0x206cf9a |
| `0x0205e264` | ldbl_ram_op_store | low | 0 | call RAM-resident long-double op, store byte result |
| `0x0205e280` | remquol | high | 0 | libm long-double remquo wrapper |
| `0x0205e292` | ldbl_thunk_6d066 | low | 0 | thunk to long-double helper at 0x206d066 |
| `0x0205e29c` | ldbl_ram_op | low | 0 | call RAM-resident long-double op with state block |
| `0x0205e2b4` | remquol | high | 0 | libm long-double remquo wrapper |
| `0x0205e2c6` | ldbl_thunk_8202c | low | 0 | thunk to RAM long-double helper at 0x208202c |
| `0x0205e2d0` | ldbl_thunk_args4 | low | 0 | forward 4 stack args to RAM long-double helper |
| `0x0205e2ee` | fmal | high | 0 | libm long-double fused multiply-add wrapper |
| `0x02075072` | crc16_nibble | med | 0 | nibble-wise 16-bit CRC over buffer via table |
| `0x0208252c` | crc16_hw_buf | high | 0 | hardware CRC16 over buffer, tail call |

## APP (26)

| addr | name | conf | callers | purpose |
|---|---|---|---|---|
| `0x020079c2` | prop_entry_find | low | 0 | find value by u16 id in tiered key table |
| `0x02007a20` | prop_value_resolve | low | 0 | resolve u16 property via section tree and builtin defaults |
| `0x02007d04` | prop_list_count | low | 0 | return entry count from list header |
| `0x02007d0e` | event_dispatch | med | 0 | dispatch event to wildcard/id listener lists |
| `0x02007e50` | event_post | med | 0 | post event object, save and restore context |
| `0x02007e88` | event_post_notify | low | 0 | post event 44 with 0xE0010000 marker value |
| `0x02007eac` | param_smooth_compute | low | 0 | compute clamped smoothed value, notify on change |
| `0x02007f8c` | param_commit_update | low | 0 | commit param with hysteresis, set dirty flags |
| `0x020080ea` | prop_entry_remove | low | 0 | remove u16 id entry, realloc table smaller |
| `0x020081a4` | flags_clear_bit0 | low | 0 | clear bit0 of flags byte at struct +20 |
| `0x0201d650` | app_mode_switch_notify | low | 0 | cycle app mode flag (0-2 to 2-4), post notify callback |
| `0x02022cea` | task_flag_hook_stub | low | 0 | call hook 0x02020938 when task flag bit 0x20 set |
| `0x02022cfe` | usr_app_task | high | 0 | app main task: hw/LCD/audio init then UI event loop |
| `0x02026824` | named_node_register | low | 0 | alloc node, vsnprintf name, append registry list |
| `0x02026bb8` | cleanup_thunk_65e8a | low | 0 | tail call to three-step cleanup routine |
| `0x02026bc4` | update_cmd_dispatch | low | 0 | checksummed cmd protocol 17-48 with flash write |
| `0x02027ee2` | update_state_callback | med | 0 | update state cb: build FM-1_009 ota record, handshake, reset |
| `0x0204d750` | rodata_app_main | med | 0 | mixed app rodata: msfa tables, USB descriptors, UI strings, FAT templates |
| `0x0206b41a` | dev_status_notify | low | 0 | post status-change notification element, wake window |
| `0x0206b47a` | dev_status_timer_restart | low | 0 | restart 50ms status timer when windows idle; tick-add head |
| `0x0206ba72` | dev_status_timer_stop | low | 0 | delete status timer, update flag, re-notify |
| `0x0206baa2` | dev_status_update_deferred | med | 0 | copy 6-byte id into ctx under lock, arm 20ms timer |
| `0x0206bb58` | app_msg_dispatch | med | 0 | top-level app message dispatch: battery/config/UI events |
| `0x0206bec2` | dev_status_word_set | low | 0 | store word into device status struct field 84 |
| `0x0206bece` | dev_info_name_set | med | 0 | strcpy device name into 32-byte field, truncate/pad |
| `0x0206bf18` | app_mode_flag_set | low | 0 | set/clear mode flag bits in global config struct |

## UNKNOWN (11)

| addr | name | conf | callers | purpose |
|---|---|---|---|---|
| `0x0203500e` | sub_0203500e | low | 0 | null-default thunk tail-calling helper 0x73fce |
| `0x02035022` | sub_02035022 | low | 0 | arg-shuffling thunk with fixed rodata object |
| `0x020350c2` | sub_020350c2 | low | 0 | read 16-bit little-endian field at byte offset |
| `0x0207d74e` | sub_0207d74e | low | 0 | tail-call wrapper to 0x020754c6 |
| `0x020800f6` | sub_020800f6 | low | 0 | zero 16-word RAM block at 0x01c0d6f4 |
| `0x0208c17e` | sub_208c17e | low | 0 | misdisassembled data table fragment |
| `0x0208c198` | sub_208c198 | low | 0 | misdisassembled data table fragment |
| `0x0208c1e6` | sub_208c1e6 | low | 0 | misdisassembled data table fragment |
| `0x0208c200` | sub_208c200 | low | 0 | misdisassembled data table fragment |
| `0x0208c3b4` | sub_208c3b4 | low | 0 | shard-end data, no valid code body |
| `0x020fcd26` | sub_020fcd26 | low | 0 | end-of-image boundary artifact; zero instructions past code_end 0x208e59c |
