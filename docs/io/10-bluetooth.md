# 10 — Bluetooth: BLE link layer, HCI/L2CAP/ATT/SM, BLE-MIDI, classic BT

Target: M-Vave FM-1, JieLi AC791N/WL82. The firmware carries JieLi's full dual-mode
stack: a vendor BLE link layer ("btctrler"/"link_layer" task strings `0x020557C9` /
`0x020557D2`), a btstack-derived host ("btstack" `0x02055814`, HCI H4 transport string
`'H4_Controller'` `0x02055860`), and the FM-1 BLE-MIDI service on top. Build stamps:
`'INCLUDE_BTSTACK-$ac3ebaf'` `0x0205C6DA`, `'BTSTACK-$04de815'` `0x0205C828`,
`'SYSTEM-*modified ... @20220920-$fdc21c0'` `0x0205C796`,
`'DRIVER-*modified*-liangyongxin-@20231109-$9aaf4e5'` `0x0205C7E4`,
`'UPDATE-*modified*-tanchiquan-@20230817-$2374938'` `0x0205C839`.
Confidence: **high** = proven, **med** = strong inference, **low** = guess.

Primary evidence: `analysis/shards/shard_0205e018..shard_02082cfe` (BT band),
`shard_020000a0_020020de.txt` (MIDI parser), `shard_02037498_020395c6.txt` (AES).

---

## 1. BLE link layer (btctrler)

| addr | name | notes | conf |
|---|---|---|---|
| `0x0205FD84` | `ble_ll_scheduler_run` | SMP-locked scan of the link pool at `0x01C0C3C0` (busy flag `+4`), scheduling anchor points | med |
| `0x0205F928` | `ble_ll_conn_create` | link init: **AA `0x8E89BED6`**, CRC init `0x555555`, base interval 40 | high |
| `0x02063620` | `ble_link_init` | allocate slot from a 16-bit slot bitmap at `0x01C0C368`, handle base `0x50\|slot`; default conn params at link+364 (below) | med |
| `0x0205F768` | (slot alloc) | pool bookkeeping called by conn_create | low |
| `0x0205F178` | `ble_ll_set_link_interval` | store interval, program HW slot fields 1/15 | med |
| `0x0205FCC4` | `ble_ll_program_event_timing` | program slot interval/offset timings | low |
| `0x0205FD08` | `ble_ll_conn_update_apply` | apply conn-update window, fire event cb | med |
| `0x0205EA6A` | `bt_ll_channel_update` | channel-map state machine, spinlocked | low |

The task brief's "8-slot link pool `0x01C0C3C0`" matches the scheduler's pool walk; the
allocator scans 16 bitmap bits, so ≤16 slots compiled in, ~8 provisioned (med).

Default connection parameters (from `ble_link_init` `0x02063620`, link+364, units of
1.25 ms / 10 ms, **med**): interval floor 27 (33.75 ms), ceiling 328 (410 ms),
config-overridable through bytes at `0x1C09C50`/`0x1C09C54` (default 251), supervision
timeout 2120 (21.2 s).

---

## 2. HCI

- **`hci_event_handler` `0x02077B96`**: btstack event dispatcher — two `tbh` jump
  tables covering event codes 1..24 and 49..62 (connection complete, disconnection,
  link-key, LE meta). Connection state at `0x1C0C908`, event broadcast via
  `hci_event_broadcast` `0x02076C90` to registered handlers.
- Command builders (host → controller):

| addr | name | opcode |
|---|---|---|
| `0x0206537E` | `hci_disconnect` | `0x0406` (handle, reason) |
| `0x020653A0` / `0x02065460` | `hci_le_create_connection` | `0x200D`, 25-byte param block |
| `0x02065196` | `hci_le_conn_update` | `0x2013`, seven params |
| `0x020651D4` | `hci_le_set_adv_enable` | `0x200A` |
| `0x020651EC` | `hci_le_set_adv_params` | `0x2006` |
| `0x0206524A` / `0x0206529A` | `hci_le_set_adv_data` / `set_scan_rsp_data` | `0x2008` / `0x2009`, 32 B |
| `0x0206531C` | `hci_le_set_scan_enable` | `0x200C` |
| `0x020654DE` | `hci_le_add_resolving_list` | with IRKs |
| `0x0206549A` / `0x020654BC` | JieLi vendor commands | **`0xF883` / `0xF884`** |

- ACL plumbing: `hci_max_acl_len_query` `0x020770E8` (buffer 672 or 1006),
  `hci_task_msg_post` `0x02076A12`, `hci_pending_event_push` `0x02077098`.

---

## 3. L2CAP

Packet marshal/format cluster `0x020644E0..0x020753B8`:

| addr | name | notes |
|---|---|---|
| `0x020644E0` | `l2cap_tx_header_submit` | marshal TX header, submit to ACL data channel |
| `0x020650FC` | `l2cap_acl_data_send` | parse handle + 12-bit length, enqueue ACL TX |
| `0x020753B8` | `bt_pkt_fmt_send` | size, allocate, build and queue a formatted packet |
| `0x02075888` / `0x020777AC` | `l2cap_run` | signaling queue, channel state machines, pending TX |
| `0x020773FA` | `l2cap_acl_rx_handler` | ACL RX: CID dispatch, signalling cmds |
| `0x02078680` | `l2cap_channel_create` | allocate/init channel |
| `0x02077084` | `l2cap_next_sig_id` | signalling identifier |
| `0x02075780` | `l2cap_emit_channel_opened` | event `0x70` with cid/mtu fields |
| `0x0207587C` | `l2cap_channel_iter_init` | channel list at `0x01C0C6DC` |

ATT rides fixed **CID 4** (seen in `att_server_notify`, below).

---

## 4. ATT / GATT server

| addr | name | notes | conf |
|---|---|---|---|
| `0x02080104` | `ble_att_server_setup_init` | ATT context at `0x01C0D6F4`: profile db ptr `[+16]`, read cb `[+20] = 0x02001388`, write cb `[+24] = 0x020013DA`, handlers via `0x02076298` / `0x0207E23C` | med |
| `0x02037926` | `att_server_handle_request` | PDU dispatcher for opcodes `0x02..0x18, 0x52` (2416 B) | high |
| `0x020801A4` | `att_server_notify` | opcode **`0x1B`**: `(conn, handle, value, len)` → `att_build_value_response` → send on CID 4; b`[0x1C0C6DC+16] = 27` | high |
| `0x020801F8` | `att_server_indicate` | opcode `0x1D`, arms 30 s confirm timer | high |
| `0x020377AA` | `att_service_for_handle` | find GATT service whose handle range contains a handle | high |
| `0x0203763E` | `att_db_iterator_advance` | GATT db record walker | med |
| `0x020375F2` | `att_build_value_response` | 3-byte header + MTU-clamped value | med |
| `0x020804E0` | `att_server_packet_handler` | PDUs, can-send, indication confirm | med |
| `0x0208049E` | `att_emit_mtu_event` | emit `0xB5` MTU-exchange-complete to app | med |

**MTU**: per-connection ATT state initialized with MTU fields 517 (`0x020803AC..0x020803B4`);
incoming Exchange-MTU clamped to ≤ 517 (`if (r5 > 517)` at `0x0208075E`). Protocol
default 23 until exchanged (med).

### GATT database (rodata, `0x02043680..0x0204373F`)

Decoded from `app.bin` (btstack ATT-db record format, **med**):

| handles | content |
|---|---|
| `0x60..0x65` | service with two characteristics + CCCDs (vendor/JieLi service A) |
| `0x66..0x6F` | second vendor service |
| **`0x70`** | **primary service: BLE-MIDI** (`03B80E5A-EDE8-4B33-A751-6CE34EC4C700` at `0x020436C5`) |
| **`0x71/0x72`** | characteristic decl + **value: BLE-MIDI I/O** (`7772E5DB-3868-4112-A1A9-F2669D106BF3` at `0x020436E0`), properties `0x16` (write-without-response + notify) |
| **`0x73`** | CCCD `0x2902` |

Service boundary table at `0x02043710`; the db is followed by a config struct at
`0x02043740` (includes pointer `0x0200C3B4`, halfwords `0x3C`) and a callback table at
`0x02043760`.

---

## 5. Security Manager + crypto

| addr | name | notes |
|---|---|---|
| `0x0207E0BE` | `ble_sm_init` | alloc SM context, load-or-generate **IRK/CSRK** via VM store / TRNG |
| `0x0207F67C` | `sm_hci_event_handler` | connect/disconnect/encrypt/LE-rand events (1662 B) |
| `0x0207F5F6` | `sm_disconnect` | disconnect with reason `0x13`, stop pairing timer |
| `0x02076CCA` | `bt_pairing_record_verify` | 32-byte pairing record, addr + crc16 |
| `0x02038296` | `aes_hw_block_transform` | single 128-bit AES block through **crypto SFR `0x41200`** (4 big-endian words at `[0x41204]`) — the AES-CCM primitive for LL encryption |
| `0x02080CE0` | `sha256ProcessBlock` | SHA-256 64-round compression |
| `0x02080EC4` | `hmacCompute` | one-shot HMAC-SHA-256 (update/package auth, `'SHA-256'` string `0x0205583C`) |
| `0x020818A8` | `ecc_point_mul_p192` | **P-192** scalar multiply ladder (legacy SSP) |
| `0x0208229C` | `ssp_f2_p192_linkkey` | link-key derivation `f2`, packs `btlk` keyID |

---

## 6. BLE-MIDI: how MIDI rides ATT

- **Transport**: MIDI bytes flow in **ATT Handle Value Notifications on handle `0x72`**
  (TX, FM-1 → host) via `att_server_notify` `0x020801A4`, and as **write-without-response
  to handle `0x72`** (RX, host → FM-1). MTU: negotiated up to 517 (§4), so a BLE-MIDI
  packet can carry many MIDI bytes per connection event.
- **RX path**: the ATT write callback registered at `0x01C0D6F4+24` = **`0x020013DA`**,
  which lands inside the BLE-MIDI framing parser within `midi_stream_parser`
  `0x02000C48` (`shard_020000a0_020020de.txt`): it strips the Apple BLE-MIDI header
  (`byte & 0xC0 == 0x80` timestamp framing at `0x020013F2..`), reassembles sysex
  (`0xF7` end marker at `0x02001444`), tracks running status (`b[ctx+45]/b[ctx+46]`)
  and feeds the common MIDI engine. The read callback `[+20] = 0x02001388` is the
  buffered TX-side read (`0x0200137A..`).
- From there everything converges with USB-MIDI/serial into `midi_msg_dispatch`
  `0x0201F5F4` (note/CC/pitchbend routing, voice steal) and the DX7 sysex handler
  `midi_message_handler` `0x02023EA0`.
- **Connection params**: see §1 (≈33.75–410 ms interval range, 21.2 s timeout). For
  low MIDI latency the app requests the fast end via `hci_le_conn_update` `0x02065196`.
- Advertising: `hci_le_set_adv_data` `0x0206524A` / scan-rsp `0x0206529A`;
  device name is the same `"FM-1 Midi"` (`0x0204F0CB`) family used by USB (med).

---

## 7. Classic BR/EDR

Present in the build, largely vestigial for the FM-1 product (it ships as a BLE-MIDI
device; classic paths are SDK carryover, **med**):

- Baseband scheduler: `bredr_sched_advance_slot` `0x020660A2`,
  `bredr_link_sched_setup` `0x020665BE` (interval ≤ 800, phase, sync),
  `bredr_sched_task_insert` `0x0206DCA4`, `bredr_scan_config_apply` `0x0206FC14`,
  `bredr_sniff_anchor_update` `0x0206E3A6` (625/1250-slot anchors).
- A2DP/AVDTP: `a2dp_state_flags_update` `0x020794C0`, `a2dp_user_ctrl_dispatch`
  `0x0207A00A` (15-case), `avdtp_discover_cmd_send` `0x020788BC`,
  `a2dp_media_data_write` `0x02079F50`; stamp string `'JL_A2DP'` `0x0207467E`.
- AVRCP/AVCTP: `avctp_avrcp_packet_handle` `0x0207A44A` (PID `0x110E`, AV/C
  passthrough/unit/vendor), `avrcp_get_element_attrs_send` `0x0207AE48` (PDU `0x20`),
  `avrcp_rsp_event_parse` `0x0207AE8C`.
- SBC: `sbc_frame_sync` `0x0203AECE` (sync word `0x9C`, next-frame offset),
  `'sbc_encoder'` string `0x02055711`.
- HFP/SPP: no HFP-named functions classified; OTA file names include
  `Zspp_app_ota.bin` `0x020823AD` — treat HFP as absent/thin, SPP possible (low).

---

## 8. Recovered Bluetooth interfaces and limits

- `att_server_notify 0x020801A4(conn, handle, value, length)` sends ATT
  notifications. BLE-MIDI uses handle `0x72`, an MTU-limited payload, and the
  Apple timestamp framing described above.
- The ATT write callback slot is at `0x01C0D6F4+24` and defaults to
  `0x020013DA`. `att_server_register_packet_handler 0x0208015A` feeds the HCI
  event broadcast list at `0x02076C90`.
- Connection-parameter defaults reside at `0x01C09C50` and `0x01C09C54`;
  `hci_le_conn_update 0x02065196` consumes updated values.

Limits of the recovered surface:

- The link layer itself (`btctrler` 0x0205Exxx) is tied to JieLi baseband
  hardware, including slot programming and AA/CRC setup in
  `ble_ll_conn_create`; it is not a portable component.
- Vendor HCI opcodes `0xF883`/`0xF884` (`0x0206549A`/`0x020654BC`) are JieLi-private.
- Classic A2DP/AVRCP stacks are compiled in but not shown to be wired into the
  FM-1 UI/audio path. The SBC encoder string is present, while the FM-1 output
  path remains separate (see the AUDIO_OUT documentation).
