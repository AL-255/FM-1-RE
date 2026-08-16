# FM-1 USB device stack

Reverse-engineered from `app.bin` (pi32v2, flash VMA `0x02000000`). Every claim
carries the function address it was read from; `[high|med|low]`
marks confidence. Code citations name the enriched shard the disassembly was taken
from. Cross-references: MIDI side in `05-midi.md`; SIE register semantics in
`reference/jielie/periph/usb-fs.md`; SDK structure reference in
`reference/ac695n_soundbox_sdk/include_lib/driver/device/usb/` (BR23 sibling
SDK — `struct usb_device_t`, `usb_setup_t` and the `desc_config` ABI match the
firmware 1:1).

Naming: `ENG` = the app-global state block `0x01C0E670` (shared with MIDI).

---

## 1. Composite device identity

The FM-1 enumerates as a **USB 2.0 full-speed composite device: UAC1 audio + USB-MIDI**.

Device descriptor template at `0x0204F07D` (18 bytes) [high]:

| Field | Value |
|---|---|
| bLength / bDescriptorType | 18 / 1 |
| bcdUSB | 2.00 |
| bDeviceClass/SubClass/Protocol | 0 / 0 / 0 (per-interface) |
| bMaxPacketSize0 | 64 |
| idVendor / idProduct | `0x4C4A` "JL" / `0x4155` "UA" |
| bcdDevice | 1.00 |
| iManufacturer / iProduct / iSerialNumber | 1 / 2 / 3 |
| bNumConfigurations | 1 |

String descriptors (UTF-16LE) [high]:

| Index | Address | Content |
|---|---|---|
| "FM-1 Midi" | `0x0204F0CB` | MIDI interface name |
| "FM-1 Audio" | `0x0204F182` | Audio interface name |
| "Jieli Technology" | `0x0204F46F` | manufacturer |
| "USB Composite Device" | `0x0204F573` | product |

Serial number: generated at runtime — see §4.4.

A second 18-byte device-descriptor template is copied from `0x0204ED30+1133`
(`0x0204F19D`) with byte 11 patched to `0xC7` by the EP0 handler (`0x02087664`);
it belongs to the alternate/loader-mode identity [low]. Configuration/interface
descriptor templates live in the `0x0204EC3C..0x0204F6xx` rodata bank; the builders
below assemble them per mode.

### Configuration layouts (builder bodies inside `usb_std_request_dispatch`'s FUNC)

| Mode bits | Builder | Content |
|---|---|---|
| `& 2` (MIDI) | `0x020070E4` | audio-control IF + MIDI-streaming interface (92 B fn cfg registered by `usb_midi_function_init`, §5.1) |
| `& 4` (audio) | `0x020074CA` | UAC1: AC interface + AS interfaces, 108 B total (`0x020073AA`) |
| `& 6 == 6` (composite) | `0x02007676` | 192 B: UAC + MIDI combined (`0x02007556`) |
| `& 0x80` | `0x02005576` | additional class hook (registered but not enumerated in stock modes) [low] |

AS streaming descriptors observed in rodata (`0x0204F691` region): CS AS general
`07 24 01 01 01 01 00`, format type `0b 24 02 01 02 03 18 01 44 ac 00` (**2 channels,
3-byte subframes, 24-bit, 44100 Hz**), ISO EP `09 05 02 09 20 01 01 00 00` (EP2 OUT,
isochronous **adaptive**, wMaxPacketSize **288**, bInterval 1), CS EP
`07 25 01 01 01 01 00` (sampling-freq control) [high].

---

## 2. The USB device controller

MUSB-derived SIE (Mentor register layout, JieLi shuffled) behind a DMA front-end;
register reference: `reference/jielie/periph/usb-fs.md`. Two interrupt
outputs: **SIE interrupt** and **SOF interrupt** on separate CPU IRQ inputs.

### 2.1 Register map as used by this firmware

Direct (byte/halfword) registers — device-1 fast path:

| Addr | Use | Firmware accessor |
|---|---|---|
| `0x16000` | SIE FADDR (direct write) | `0x02007756` |
| `0x16001` | SIE POWER direct write (0x60 = soft-connect) | `usb_sie_power_write` `0x02006932` |
| `0x16002..` | EP0 setup packet bytes (read at +8/+0/+2) | RAM ISR `0x020870C0` |
| `0x16020` | EP0 FIFO (64 B, byte writes) | `usb_write_ep0` `0x020078DE` |
| `0x16102` | EP0 CSR0 (h) | `usb_ep0_csr_read/write` `0x020077C4/0x0200783C` |

Indexed SIE access (all endpoints): port `0x11800` (busy bit 2) / `0x11804`
(`(idx<<8)|val`, sign-bit completion) via `usb_sfr_write` `0x02005648` /
`usb_sfr_read` `0x02005782`. SIE index map (jielie doc): 0 FAddr, 1 Power, 2/3
IntrTx1/2, 4/5 IntrRx1/2, 6 IntrUSB, 7/8 IntrTxE1/2, 9/10 IntrRxE1/2, 11 IntrUSBE,
12/13 Frame, 14 Index, 15 DevCtl, 16 TxMaxP, 17 CSR0/TxCSRL, 18 TxCSRH, 19 RxMaxP,
20 RxCSRL, 21 RxCSRH, 22 Count0/RxCount.

Controller / DMA block:

| Addr | Use | Firmware accessor |
|---|---|---|
| `0x16800` | USB_CON0 (PHY_ON bit0, USB_NRST bit2, SIEIE bit11, SOFIE bit10, SOF/SIE pend bits 13/14) | `usb_sie_init` `0x02006882`, `usb_device_hold` `0x0200675A` |
| `0x16A0C` | PHY power/IO config (`|= 0x1C, 1`) | `usb_sie_init` |
| `0x16820+ep*8` | EP DMA config (RX) | `usb_ep_dma_cfg_set` `0x020055CA` |
| `0x16824+ep*8` | EP DMA address (RX) | `usb_ep_dma_adr_set` `0x0200584C` |
| `0x16804+ep*4` | EP3/4 TX DMA count+kick (bit31) | `usb_ep_write` `0x02005D86` |
| `0x11808+ep*4` | EP TX FIFO count (EP0..2 style) | same |
| `0x11834` | EP4 dedicated TX count | same |
| `0x16850` | EP TX/RX enable bits (bit0 TX, bit1 RX) | `usb_ep_config` `0x02005A88` |
| `0x11800` bit 11 | USB device IRQ enable (INTC) | `usb_device_mode` `0x02006C88` |
| `0x11800` bit (19+ep) | per-EP IRQ enable | `usb_ep_int_enable` `0x020078B8` |

`0x28000`-block (device endpoint controller; used by the SIE ISR and EP logic):

| Addr | Use |
|---|---|
| `0x28000` | EP enable/status word; `0x28034` EP-enable set (`0x0205F56C`) |
| `0x28028` | TX pending (bit per EP; +8 bit offset for EP8+) |
| `0x2802C` | TX pending ack (write-1) |
| `0x28030` | TX interrupt mask |
| `0x28038` | misc/bus status: bit1 busy (spin in `0x0205F8F8`), bit7 bus-event → ack with bit6 (`0x02061124`) |
| `0x2804C` | RX pending (bit per EP, `1<<(ep+8)` ack) |
| `0x28050` | RX interrupt mask |

### 2.2 Software structures

- **Device table** `0x01C0E908[id*4]` → usb device struct; **function/setup table**
  `0x01C0E910[id*4]` → `usb_setup_t`-compatible struct (§7); `usb_id2device`
  `0x02006B70`, `usb_device2id` `0x02005592` (bit 2 of byte +23).
- **Endpoint record table** `[0x01C0C3C0]` → struct; `[+16]` = array of EP record
  pointers, **8 EPs, stride 28** — walked by `usb_dev_sie_isr` `0x02060CC2`.
- **EP DMA address table** `0x01C21174 + id*68` (5 EPs), programmed by
  `usb_device_mode` via `usb_ep_dma_adr_set`.
- Per-device EP completion-callback tables: **RX/OUT** `ENG+1512 + id*20 + ep*4`,
  **TX/IN** `ENG+1552 + id*20 + ep*4`, registered with `usb_ep_cfg_ptr_set`
  `0x02005598`, invoked from the RAM-resident ISR fan-out (`0x02087272..0x02087360`).
- Per-device work areas: `ENG+664 + id*4` → `ENG+11684 + id*968`,
  `ENG+672 + id*4` → `ENG+11811 + id*968` (allocated/cleared in `usb_device_mode`).
- Audio control block `0x01C0E03C` (`uac_config_init` `0x020067CC`): 44100 Hz,
  ISO DMA buffers `[+40] = 0x01C20F2C`, `[+36] = 0x01C21050`, alt settings,
  feature-unit fields.
- **Dual-core locking**: shared-memory peripherals are accessed under an SMP
  ticket lock — `cli`, counter `0x01C0953C[cnum]++`, `lockset`/`lockclr` on
  `0x01C09534[cnum]`, `csync`, `sti` — visible in `usb_txcsr_read` `0x02005CFE`,
  `usb_rxcsr_read` `0x020060D8`, `usb_intr_usbe_write` `0x020069A6`, etc. Keep this
  discipline in custom code touching USB SFRs.

### 2.3 Interrupts

- **SIE ISR** `usb_dev_sie_isr` `0x02060CC2` (body `0x02060CE0`, registered via
  `0x020016D2` with `0x02007A9E` from `usb_device_mode`): reads TX pending `0x28028`,
  acks `0x2802C`, RX pending `0x2804C`/mask `0x28050`, bus event `0x28038`; walks the
  EP table `0x01C0C3C0` per pending EP: NAK retry countdown (`b[ctx+336+166]`),
  per-type `tbb` (ISO IN, bulk, control), URB completion callbacks
  `[[ctx+472]+4]+12` / `+4`, double-buffer swap for ISO OUT, taskq msgs 26/28/30 via
  `0x0205E736`, and the adaptive-feedback computation for audio (§6.3).
- **SOF/ISO timer** `usb_iso_timer_program` `0x02061782` (1070 B): frame counters and
  SOF-timer register programming; frame accessors `usb_frame_reg3/5/9_read`
  `0x02061728/0x0206173C/0x02061748`, `usb_sof_count_check` `0x02061756`;
  ISO scheduling `usb_iso_sof_schedule` `0x020601C6` / `usb_iso_ep_advance`
  `0x02060382`.
- EP frame/SIE register helpers `0x0205EBDE` (read idx) / `0x0205EC50` (write idx)
  are used for SOF frame number (idx 7) and interval registers.

---

## 3. Enumeration flow

### 3.1 Mode selection — `usb_device_mode` `0x02006B7C`

(`shard_02005ce4_020081a4.txt`) [high]

```
usb_device_mode(usb_id r0, class_mode r1)
class_mode: 0 = teardown; bit1 (2) = MIDI; bit2 (4) = audio; 6 = composite;
            bit7 (0x80) = extra class hook
```

Teardown (mode 0): clears all 8 descriptor hooks (`usb_add_desc_config(id, 8, 0)`),
drops route hook `[ENG+400]`, `usb_device_hold` (PHY off, DM/DP released to GPIO
via `0x02003904` calls 148/149), frees per-dev structs, posts taskq msg 15.

Setup (mode ≠ 0), in order:
1. `usb_add_desc_config(id, 0, builder)` — registers the config descriptor builder
   for the mode (§1).
2. `uac_config_init` `0x020067CC` (44.1 kHz, ISO buffers).
3. If bit7: registers extra class hook `0x02005576`.
4. Clears per-dev callback tables (`ENG+1512/1552`, 5 words each) and allocates the
   per-dev work areas (`ENG+664/672`).
5. `usb_config_desc_build` `0x0200681E(id, buf = [dev_struct+4])` — see 3.2.
6. `usb_sie_init` `0x02006882` — PHY/SIE power-up: `0x16A0C |= 0x1C|1`, delay,
   `0x16800 |= 3`, poll `0x16800` bit4 (PHY ready), IO config, `|= 0x1800`.
7. `usb_sie_power_write` `0x02006932` — SIE POWER = `0x60` (soft-connect + ).
8. Interrupt masks: `usb_intr_usbe_write` `0x020069A6`, `usb_set_intr_txe`
   `0x02006A14`, `usb_set_intr_rxe` `0x02006AC2` (SIE idx 11 / 7+8 / 9+10);
   `[0x11800] |= 0x800` (device IRQ in INTC).
9. EP DMA address table (5 EPs at `0x01C21174 + id*68`) via `usb_ep_dma_adr_set`.
10. `usb_ep_enable` `0x020057B8` / `usb_ep_enable2` `0x020059F0` for EP0.
11. IRQ registration `0x020016D2` with `0x02007A9E` (SIE) / `0x02007A8A` (SOF).
12. If `[ENG+672+id*4] != 0`: installs `[func_struct+12] = 0x020077EA` (descriptor
    hook override) [med].

An unresolved binary callback at `0x02006D38` can switch modes, but it is not a
proven console command. It accepts a structure with a length/type byte at `+2`,
a selector byte at `+4`, and a data pointer at `+8`. It handles only a 3-byte
payload whose first byte is `'s'`; payload byte 2 is converted from an ASCII
digit without range validation. Selector 0 calls `usb_device_mode(digit, 0x86)`.
Selector 1 masks the selected USB interrupt route and calls
`usb_device_mode(digit, 0)` [high for parsing, low for transport/reachability].

No direct call, flat pointer reference, text command table, or input transport
for this callback has been located in V13. V14 contains the same routine at
`0x02006F90`. Treat it as library packet/configuration glue until its registration
path is recovered; it does not establish a UART or USB shell.

### 3.2 Descriptor assembly — `usb_config_desc_build` `0x0200681E`

[high]

- Copies a 9-byte config header template from `0x02043846` into the buffer (in the
  V13 image this region holds a ramp table — the meaningful fields are patched
  afterwards, see caveat §9).
- Iterates the 8 hook slots `0x01C0E520 + id*32 + i*4` (registered by
  `usb_add_desc_config` `0x020067B0`; `index > 7` clears all). Each hook is called
  with the **desc_config ABI** `(usb_id r0, ptr r1, &cur_itf_num r2) → length r0`;
  returned bytes appended; running interface count delivered to `b[buf+4]`
  (bNumInterfaces); `wTotalLength` patched into `b[buf+2..3]`; total capped at
  **768** bytes.
- This is exactly the BR23 SDK `usb_add_desc_config()` / `desc_config` ABI.

### 3.3 EP0 standard requests — `usb_std_request_dispatch` `0x0200707C`

(`shard_02005ce4_020081a4.txt`) [high]. Two parts:

- **Head `0x0200707C`**: `(usb_device_t r0, handler r1)` — stores the class request
  handler into `usb_device_t.setup_recv (+16)` and sets `b[+1] = 2`. This is how
  interface handlers are bound (SDK `usb_set_interface_hander` equivalent; see §7).
- **Body `0x0200709C..`**: setup-packet dispatcher:
  - Class requests (`bmRequestType & 0x60 == 0x20`, bRequest 0x81..0x87): `tbb`
    switch — UAC GET/SET_CUR family against the feature-unit fields of
    `0x01C0E03C` (volume/mute per channel, `0x020072BC` for the OUT data stage).
  - Standard requests 0..11 (`tbb` at `0x020070F0`): SET_ADDRESS
    (`0x02007286` region: applies FADDR via `0x02007756`, rearms RX), GET_STATUS,
    CLEAR/SET_FEATURE, SET_CONFIGURATION (`0x02007108`: wValue==0 → unconfigure,
    device states 2/3/4), GET_DESCRIPTOR (§4.2), GET/SET_INTERFACE
    (`0x02007140..0x02007196`: per-interface alternate settings stored in
    `0x01C0E03C+16/18/20/22`, wLength==0 status stage via `usb_ep0_request_data_stage`
    with len 0), SET_DESCRIPTOR rejected (b[+1] = 3 = stall).

### 3.4 EP0 data stage — `usb_ep0_request_data_stage` `0x02005500` + twin `0x02005C76`

(`shard_02003b7c_02005bb2.txt`) [med]

`usb_ep0_request_data_stage(dev, req, src, avail)`: sets `b[dev+1] = 1` (data stage),
`h[dev+2] = wLength` (clamped to `avail`, `b[dev+21]` = more flag), `[dev+8]` =
`[dev+4]` (TX cursor = setup buffer), `memmove` payload. The twin state machine
(`0x02005C76`, sibling `0x02005544`) drives `b[dev+1]` phases 0/10/11 and device
states `b[dev+20]` 2/3/4 (status IN/OUT, last-data zero-length packet).

`usb_device_t` layout (matches BR23 SDK `usb_stack.h` exactly):

| Off | Field | | Off | Field |
|---|---|---|---|---|
| +0 | baddr | | +12 | setup_hook |
| +1 | bsetup_phase | | +16 | setup_recv |
| +2 | wDataLength (h) | | +20 | bDeviceStates (2/3/4) |
| +4 | setup_buffer | | +21 | bDataOverFlag |
| +8 | setup_ptr | | +23 | usb_id (bit 2) |

`usb_write_ep0` `0x020078DE` (≤64 B chunks into `0x16020`, then CSR0 via
`0x020078DE`→`0x0200783C` r1=10 = TxPktRdy|DataEnd); `usb_read_ep0` `0x02006D84`;
EP0 enable via `usb_ep_enable` `0x020057B8`.

### 3.5 RAM-resident EP0/ISR engine — `usb_ep0_request_handler` `0x02086F2A`

(`shard_02084824_0208c3b4.txt`; this file is the `.data` flash image — the code is
copied to RAM `0x01C00000+` at boot and executes there) [med]

- First body (`0x02086F2A`): the ISO **adaptive feedback averager** — consumes
  6-byte records (two 24-bit signed deltas), scales by `h[0x01C1EEFE]`, accumulates
  into `[0x01C1EF08 + idx*4]`; ring pointers `h[0x01C1EEF4]` (wr) /
  `h[0x01C1EEF6]` (rd), flag `b[0x01C1EEF8]`.
- `0x02087092`: ISO IN arm — opens EP2 IN with `[0x01C0E03C+40]` buffer, maxpacket 288.
- `0x020870C0` (main EP0 engine): reads setup bytes from `0x16002` (+8/+0/+2) under
  SMP lock, then:
  - EP0 SETUP (IntrTx bit2): marks `b[dev_struct+20] = 2`, clears flags, then calls
    the registered class handler `[usb_device_t+16]` (setup_recv) and finally any
    pending setup hook — with a 16..24-word scan of the per-dev struct for a
    non-null slot called as `fn(r6, -1)`.
  - EP0 OUT data / status phases; calls `[usb_device_t+12]` (setup_hook).
  - **EP1..4 complete fan-out**: per pending bit, calls RX cbs
    `ENG+1512 + id*20 + ep*4` (OUT) and TX cbs `ENG+1552 + id*20 + ep*4` (IN) with
    `(ep0_state, ep_number)`.
  - Standard-request switch on bRequest ≤ 9 (`tbh` at `0x020874B2`):
    GET_DESCRIPTOR (§4.2), SET_ADDRESS (state gate `b[r15+0] == 3`),
    SET_CONFIGURATION (`0x0208761C`: non-zero value → configured, `b[r10] = 4`;
    value 0 → closes EPs 1..4 via four `0x02048C0D8` calls), GET/SET_INTERFACE
    (`0x02087694`: audio alt setting 0/1 → `0x02087A1A`), GET_STATUS device/endpoint
    (remote-wakeup / halt bits via `h[ENG+496+id*2]`), SET/CLEAR_FEATURE
    (`0x020875C0/0x020875F0`, incl. `0x51000 &= ~0x100` test-mode hooks).

---

## 4. Descriptors in detail

### 4.1 Descriptor bank

`0x0204EC3C..0x0204F6xx` holds the template pool: AC interface (`09 04 00 00 00 01
01 00 09` at `0x0204EC5B`), AC header (`09 24 01 …`), terminals, AS/CS/EP templates
(§1), MIDI templates (§5.1), plus string fragments. Builders patch interface numbers
sequentially from a cursor (`[r4+0]`).

### 4.2 GET_DESCRIPTOR handling

`usb_get_descriptor_handler` `0x02007698`: vendor hook for class-type device
requests (`bmRequestType == 0x20`, bRequest 1, wValue 0x0100 → binds `0x02006FF0`).
Device-recipient path (`0x020076CA`): type 3 (string) with index 8/9 served 23/21
bytes from `0x0204F29F` / `0x0204F1E8` (the latter a 16-entry nibble-remap table used
by the serial generator) [med].

In the RAM EP0 engine (`0x0208764C` region): wValue>>8 — 1 = device (18 B from
`0x0204ED30+1133`, byte 11 patched, §1), 2 = config (via `0x02048B03E` → the
registered config buffer), 3 = string (`tbb`: 0 → LANGID `{04 03 09 04}` (en-US
0x0409); 1/2 → bank strings; 0xEE (Microsoft OS string) → vendor reply;
else stall).

### 4.3 SET_CONFIGURATION side effects

On configure (non-zero): `usb_ep_int_enable` for the class EPs, per-dev struct state
= 4. On unconfigure (value 0): EPs 1..4 closed (`0x02048C0D8` × 4), state cleared
(`0x020876BE` region).

### 4.4 Serial number from chip ID — `0x020877F0`

[high] Builds a 34-byte string descriptor in place: `b[0] = 34`, `b[1] = 3`, then
reads the **8-byte chip ID at `0x01C20190`** and expands each nibble to an ASCII hex
char (`'0'+n` / `'A'+n-10`), stored as UTF-16LE — a 16-character hex serial unique
per chip. (For iSerialNumber = 3; the device-descriptor iSerial field indexes this
generated string.)

---

## 5. USB-MIDI class driver

### 5.1 Endpoint pair — `usb_midi_ep_open` `0x02005BB2`

(`shard_02003b7c_02005bb2.txt`) [med]. Called with the MIDI function struct; body:

1. Repairs MIDI route rings (`ENG+852` table, count `b[ENG+864]`), resets route lock
   `b[ENG+865] = 0xFF`.
2. Installs the route output hook `[ENG+400] = 0x02005FAC` (the USB-MIDI TX pump,
   see `05-midi.md` §2.2), posts taskq msg 18 to `"c04"`.
3. `usb_ep_cfg_ptr_set(id, 0x84, 0x020061E4)` (IN complete cb);
   `usb_ep_config(id, 0x84, bulk(2), fifo 0x01C20E1C, maxpacket 64)`;
   then `0x02005BB2(dev, 4)` head call — `[0x11800] &= ~(1<<(ep+19))` (clears the
   EP4 pending/enable bit; exact polarity unverified [low]).
4. Same for OUT: cb `0x0200685C`, `usb_ep_config(id, 0x04, bulk, 0x01C20EA4, 64)`.

`usb_midi_function_init` `0x02005438` registers the function (92-byte config,
callbacks `0x02005664`, `0x02005CE0`, `0x02005D96` into the setup_t slots) [low —
body shares its FUNC with route-config code; the rodata it copies is the
`0x0204ED78+` bank].

### 5.2 Endpoint configuration primitive — `usb_ep_config` `0x02005A88`

(`shard_02003b7c_02005bb2.txt`) [med]

```
usb_ep_config(usb_id r0, ep r1 (bit7 = IN), type r2 (1 iso / 2 bulk),
              dma_buf r3, maxpacket r4([sp+24]))
```

OUT (ep & 0x80 == 0): DMA addr `0x0200584C`, maxp mirror `0x020058BC`, reg19
(0x020058D2) = 1023, reg20/21 (0x02005952) = 144, bulk → fifo mirror
(`0x020059DA`), ISO → `0x4000` flag; high-bandwidth compute for EP3/4
(`(maxp & 0x7FE) * (1 + ((maxp>>11)&3))`); RX enable `[0x16850] |= 2`;
`usb_ep_enable` `0x020057B8`.
IN: DMA cfg `0x020055CA`, maxp mirror `0x02005632`, reg16 = 1023, reg17/18 = 72,
ISO `0x4000`; high-bandwidth for EP3/4; TX enable `[0x16850] |= 1`;
`usb_ep_enable2` `0x020059F0`.

### 5.3 RX path — `usb_midi_rx_parse` `0x02006384`

(`shard_02005ce4_020081a4.txt`) [high]. Details in `05-midi.md` §2.2. Highlights:
64 B packet → 16 events; CIN filter; running-status squashing; ring push
(`ENG+944..952`); taskq msg 128 to `"04"`; DX7 7-bit reassembly (msg 144); loader
magic → mask-ROM `0xFFC02532`. The small wrapper at `0x0200673C` reads the EP4 OUT
DMA buffer via `usb_ep_read(0, 4, buf64, 64)` `0x02006160` and calls the parser.

### 5.4 TX path — `usb_midi_sysex_engine` `0x02005D86` (+ `0x02005E8C`)

[high]. `usb_ep_write(id, ep, len)`: TxCSR polling (`usb_txcsr_read` `0x02005CFE`),
per-packet DMA (`0x16804+ep*4` = count | bit31 kick for EP3/4, else `0x11808+ep*4`;
EP4 special `0x11834`), NAK handling (bit7), stall detect (bit14), timeout derived
from packet count. The body at `0x02005E8C` frames 64 B USB-MIDI packets: CIN 4
start/continue, 5/6/7 end (1/2/3 B), zero pad; DX7 dump 8→7-bit packing; vendor
magic `F0 35 59 … F7` suppression; route merge through `midi_stream_parser` with
CIN return values written to byte 0 of each event.

---

## 6. USB audio class driver (UAC1)

### 6.1 Interfaces and requests

- Audio Control (IF0): AC header, input/output terminals, feature unit; class
  requests 0x81..0x87 (`UAC_GET/SET_CUR/MIN/MAX/RES`) handled in the
  `usb_std_request_dispatch` body against `0x01C0E03C` fields (§3.3); GET/SET_INTERFACE
  alt settings in `0x01C0E03C+16..22`.
- Audio Streaming (IF1/IF2): alt 0 (zero-bandwidth) / alt 1 (streaming); format
  24-bit 2-ch 44.1 kHz (`0x0204F691` region); EP2 OUT adaptive iso 288 B,
  EP3 IN used for synch feedback [med].

### 6.2 ISO EP service — `usb_iso_ep_service` `0x020611CC`

(`shard_020601a2_02061f92.txt`) [med]. Per-frame handling: SOF sync fields in the EP
context (sequence/expected counters at +56/+58/+38/+40/+42/+44), frame flag word
`h[ctx+8]` (bits for first-frame, resync), per-frame 6-byte sequence/CRC check
(`0x02061338` memcmp vs `ctx+316+52`), missed-frame recovery (`h[ctx+14]`), replay
of last good frame on error, completion callback `[[ctx+472]+4]+4` invoked with the
frame, and the EP8/9 ISR tail (high-bandwidth variants of the same logic).

### 6.3 Adaptive feedback (asynchronous sink)

Computed in the SIE ISR (`0x02060F7A..0x020610C8`): when the feedback EP is due
(`b[ctx+325] == 7` state): reads SOF frame (SIE idx 7, sign-extended) and the local
sample counter, computes `drift = 625 - (frame & 1023) - (cnt & 0xFF) + acc`;
correction step ±100 or ±525 per side; emits the new 3-byte **10.14 feedback value**
at `h[ctx+32]/h[ctx+34]`; accumulator `[0x01C09D10] += 100` per adjustment window.
The long-term averager is the RAM-resident `0x02086F2A` (§3.5). The feedback EP is
armed by `0x02087092` (EP2 IN, 288 B buffer at `[0x01C0E03C+40]`) [med].

### 6.4 Audio taskq plumbing

`uac_sync_rate_init` `0x02006E1A` (feedback counters from sample rate);
`uac_class_request_handler` `0x02006E74`; audio-server msg post inside
`usb_midi_ep_open`'s preamble; ISO double-buffer swap + taskq msgs 26/28/30 in the
ISR (`0x0205E736`).

---

## 7. Recovered USB extension APIs

The stack retains JieLi SDK extension points. The following ABIs are verified
against the stock firmware:

### 7.1 Register a configuration (class) — desc_config ABI

```c
void usb_add_desc_config(usb_dev id, u32 index, desc_config fn);  // 0x020067B0
// fn: u32 (*)(usb_dev id, u8 *ptr, u32 *cur_itf_num)
//   write your interface+endpoint descriptors at ptr, return byte count;
//   *cur_itf_num is the running bInterfaceNumber (increment it per interface).
// index 0..7 → hook slots at 0x01C0E520 + id*32 + index*4; index > 7 clears all.
```

The stock builders are `0x020070E4` (MIDI), `0x020074CA` (audio),
`0x02007676` (composite). Total config ≤ 768 B (`usb_config_desc_build`
`0x0200681E`).

### 7.2 Bind class request handlers

```c
// setup_recv (class/vendor setup packets on your interface):
((void(*)(void *usb_device_t, u32 handler))0x0200707C)(dev, (u32)my_handler);
//   → stores into usb_device_t+16; handler called from the RAM EP0 engine with
//     (ep0_state, usb_ctrlrequest*); return 1 if handled, 0 to stall.

// interface handler / reset handler tables (setup_t at [0x01C0E910 + id*4]):
//   +32 + i*4: interface_hander[8]   via 0x0200541A(id, itf, fn)
//   +64 + i*4: reset_hander[9]       via 0x02005438 (head; note shared FUNC)
// setup_hook at usb_device_t+12 — called before standard processing.
```

### 7.3 Open endpoints

```c
usb_ep_config(id, ep, type, dma_buf, maxpacket);   // 0x02005A88 (§5.2)
usb_ep_cfg_ptr_set(id, ep, cb);                    // 0x02005598
//   cb(usb_device_t*, ep) on transfer complete:
//   OUT cbs live at ENG+1512 + id*20 + ep*4, IN cbs at ENG+1552 + id*20 + ep*4.
usb_ep_int_enable(id, ep);                         // 0x020078B8: [0x11800] |= 1<<(19+ep)
```

Transfers: `usb_ep_read` `0x02006160` (FIFO drain with timeout),
`usb_ep_write` `0x02005D86` (§5.4), ISO arm `usb_ep_configure_iso` `0x02060942`,
generic open `usb_ep_open` `0x0206087C`, close `usb_ep_close` `0x02060488`,
shutdown `usb_device_shutdown` `0x02060A56`.

### 7.4 Switch modes at runtime

`usb_device_mode` `0x02006B7C` (§3.1) has the ABI `(usb_id, mode_bitmask)`.
The packet source and registration path of callback `0x02006D38` are
unresolved.
Enumeration uses `usb_sie_power_write` (POWER 0x60) / `usb_device_hold`
`0x0200675A`.

---

## 8. Function index (this document)

| Addr | Name | Conf |
|---|---|---|
| `0x0200541A` | usb_func_cb_register (interface_hander slot) | low |
| `0x02005438` | usb_midi_function_init (+ reset_hander slot head) | low |
| `0x02005500` | usb_ep0_request_data_stage | med |
| `0x02005592` | usb_device2id (bit 2 of +23) | low |
| `0x02005598` | usb_ep_cfg_ptr_set | low |
| `0x020055CA` | usb_ep_dma_cfg_set (0x16820) | low |
| `0x02005648` | usb_sfr_write (0x11800/0x11804 port) | med |
| `0x02005782` | usb_sfr_read | med |
| `0x020057B8` | usb_ep_enable | med |
| `0x0200584C` | usb_ep_dma_adr_set (0x16824) | low |
| `0x020059F0` | usb_ep_enable2 | low |
| `0x02005A88` | usb_ep_config | med |
| `0x02005BB2` | usb_midi_ep_open (EP4 bulk pair) | med |
| `0x02005CE4` | usb_get_ep_buffer | med |
| `0x02005CFE` | usb_txcsr_read (SIE 0x11/0x12) | high |
| `0x02005D86` | usb_midi_sysex_engine / usb_ep_write | med |
| `0x020060D8` | usb_rxcsr_read (SIE 0x14/0x15) | high |
| `0x02006160` | usb_ep_read | high |
| `0x02006384` | usb_midi_rx_parse | med |
| `0x0200675A` | usb_device_hold (PHY off, GPIO release) | med |
| `0x020067B0` | usb_add_desc_config (8 hooks) | high |
| `0x020067CC` | uac_config_init (44.1 kHz) | med |
| `0x0200681E` | usb_config_desc_build | high |
| `0x02006882` | usb_sie_init (PHY/SIE power-up) | med |
| `0x02006932` | usb_sie_power_write (POWER 0x60) | med |
| `0x020069A6` | usb_intr_usbe_write (SIE 0x0B) | med |
| `0x02006A14` | usb_set_intr_txe (SIE 0x06/0x07) | high |
| `0x02006AC2` | usb_set_intr_rxe (SIE 0x08/0x09) | high |
| `0x02006B70` | usb_id2device | med |
| `0x02006B7C` | usb_device_mode | high |
| `0x02006D38` | unresolved 3-byte USB mode-control callback | med |
| `0x02006D84` | usb_read_ep0 | high |
| `0x02006E74` | uac_class_request_handler | med |
| `0x0200707C` | usb_std_request_dispatch (head: bind setup_recv) | high |
| `0x02007698` | usb_get_descriptor_handler | med |
| `0x020077C4` | usb_ep0_csr_read (0x16102) | med |
| `0x0200783C` | usb_ep0_csr_write | med |
| `0x020078B8` | usb_ep_int_enable (0x11800 bit 19+ep) | low |
| `0x020078DE` | usb_write_ep0 (0x16020, ≤64 B) | med |
| `0x02060CC2` | usb_dev_sie_isr | high |
| `0x020611CC` | usb_iso_ep_service | med |
| `0x02061782` | usb_iso_timer_program (SOF/ISO) | med |
| `0x02086F2A` | usb_ep0_request_handler (RAM) + ISO feedback avg | med |
| `0x020877F0` | serial-number string generator (chip ID `0x01C20190`) | high |

## 9. Caveats

- The 9-byte config-header template address `0x02043846` (used by
  `usb_config_desc_build`) contains ramp data in the V13 image; total length and
  interface count are patched later, but the header's remaining bytes should be
  verified on target if you rely on the stock builder [low]. Same rodata-bank
  anomaly family as the MIDI length table (`05-midi.md` §3.3).
- `usb_midi_function_init` `0x02005438` and `usb_func_cb_register` `0x0200541A`
  carry `low` confidence in the classification DB; their FUNC bodies blend with
  route-config code — treat exact slot layouts (+32/+64) as med-confidence.
- Strings 8/9 served from `0x0204F1E8`/`0x0204F29F` are not plain UTF-16 strings
  (nibble table / pointer table contents); their exact consumer is unverified [low].
- Mask-ROM stubs on this path: `0xFFC02532` (loader entry via USB-MIDI magic),
  `0xFFC028A0` (IRQ trampolines `0x0200796A/0x0200797E`).
