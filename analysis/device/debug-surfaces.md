# Debug, factory-test, and console surface audit

Date: 2026-08-02

Targets:

- V13 application `firmware-images/v13/raw_fw/FM-1.fwsc_unpack/files/app.bin`
- V14 application `firmware-images/v14/raw_fw/FM-1.fwsc_unpack/files/app.bin`
- Stock V13/V14 `isd_config.ini` and `uboot.boot`
- AC791N/WL82 SDK at `/home/yukidama/JL/fw-AC79_AIoT_SDK`

## Result

No reachable interactive debug console, text shell, factory-test menu, or
recovery key sequence has been established in the stock FM-1 firmware.

This is a negative static-analysis result, not proof that no undocumented
hardware strap or ROM mode exists. In particular, none of the findings below
changes the updater safety verdict: a console cannot be used as a recovery plan
until it is entered and exercised on hardware with a deliberately broken main
application.

| candidate | stock evidence | conclusion |
|---|---|---|
| USB serial/CDC shell | normal descriptors are UAC1 audio + USB-MIDI only | no CDC console |
| application UART shell | live UART is the DIN-MIDI RX path at SFR `0x12100` | binary MIDI, not text console |
| UBOOT debug TX | stock packed config has `UTBD=1000000` but no `UTTX` key | baud configured; no routed TX pin |
| UBOOT UART updater | stock packed config has no `UTRX` key | generic feature not selected |
| Finsh/msh | no shell prompt/command strings found in V14 | no stock entry found |
| AT server | no `AT+` command strings found in V14 | no stock entry found |
| BQB/FCC mode | SDK supports it; apparent stock `bqb:` strings are instructions | no application activation found |
| online configuration tool | SDK CDC handler can read/erase/write flash and request MaskROM | protocol signature and CDC interface absent from stock executables |
| `autotest` | real embedded controller-library string | library provenance, not an entry path |
| two-key chord | traced in V13 and V14 | resets octave/semitone offsets |
| panic/assert sink | P33 register bit-field write, then infinite loop | fatal/power path, not a console |
| 3-byte USB `'s'` callback | switches USB class mode | transport and registration unresolved; not a text shell |

## USB exposure

Normal mode enumerates as VID:PID `4C4A:4155` with UAC1 audio and USB-MIDI
interfaces. The descriptor builder's stock mode is class mask 6 (audio + MIDI),
and no CDC ACM interface is present. USB-MIDI does expose the vendor SysEx and
normal-mode update protocols already documented in `docs/io/05-midi.md` and
`docs/io/11-ota-protocol.md`; these are binary control surfaces, not terminals.

The routine previously described as a `"usb:N"` console command is not an
argv/text parser:

- V13 `0x02006D38`, V14 `0x02006F90`.
- Input is a structure: byte `+2` must equal 3, byte `+4` is a selector, and
  word `+8` points to a 3-byte payload.
- Payload byte 0 must be `'s'`; byte 2 is converted from ASCII by subtracting
  `'0'`, without an observed bounds check.
- Selector 0 calls `usb_device_mode(digit, 0x86)`.
- Selector 1 masks the chosen USB interrupt route and calls
  `usb_device_mode(digit, 0)`.

The `usb_device_mode` ABI is `(usb_id r0, class_mode r1)`, matching the SDK,
not the reversed signature previously recorded in `docs/io/06-usb.md`. No
direct call, flat code-pointer reference, registration record, or source
transport for the callback has been recovered. It may be unused generic
configuration glue. Sending guessed 3-byte packets over USB-MIDI is not
justified by this routine.

The normal-mode syscmd parser at V13 `0x02026BC4` is a more important exposed
binary surface. It accepts command IDs 17 through 48 and has indirect callback
operations. V14 contains the same dispatcher at `0x0202730E` with the same
branch table. Commands 19, 20, 22–32, and 37–47 are no-ops, not default writes.
Commands 33–36 invoke four methods on one of eight callback objects. Command 48
only completes a transfer whose token, length, and destination were previously
armed in `ENG+416/+420/+424`; it is not a free-standing callback.

The callback-object table is read at V13 `ENG+1336` and V14 `ENG+1400`. No
direct writes to either set of slots were found in the recovered application
code. The objects may be installed through startup copies or an indirect
registrar, or the generic interface may be unused. Because commands 34 and 48
can copy data if runtime state is present, do not fuzz this interface on the
only recoverable unit. The exact command map and two transport-specific reply
records are documented in `docs/io/11-ota-protocol.md`.

The SDK type search does not identify these objects. `struct config_target`
is only an ID and callback pair. `struct uart_operations` does have the same
four leading slot offsets (`init`, `read`, `write`, `ioctl`), but the syscmd
argument order is incompatible with a UART device API: command 34 passes the
payload pointer as `r0`, an integer as `r1`, and the length as `r2`, with no
object/device pointer. The layout resemblance is therefore insufficient to
name the table, especially without a recovered registrar.

## UART and boot configuration

The application has a configured UART receive/timeout IRQ at V13 `0x02027DD0`
using SFR `0x12100`. Its bytes feed the serial MIDI parser. The printable word
`uart` at V14 file offset `0x4F125` belongs to the clock-source lookup data used
by `clk_get_rate`; it does not identify a command console.

The AC791N/WL82 SDK's `cpu/wl82/tools/isd_config_rule.c` distinguishes three
boot keys:

- `UTTX`: UBOOT debug-output pin.
- `UTBD`: UBOOT debug baud rate.
- `UTRX`: UART firmware-update input, restricted by the rule to PB00, PB05,
  or PA05.

The stock V13 and V14 packed configs are byte-identical. They contain `UTBD`
with value 1000000 but contain neither `UTTX` nor `UTRX`. A baud value alone
does not route a debug signal to a pad. `UTRX`, if enabled in a different
build, is described by the SDK as a serial updater rather than an interactive
shell.

`tools/legacy-uboot/isd_config.ini` is not the stock config: it explicitly sets
`UTTX=PB04`. It must not be cited as proof that production FM-1 firmware emits
on PB04. Repacking that file would also change boot configuration and is not a
safe diagnostic experiment without a ROM recovery procedure.

## Key chord trace

V13 scanner entry `0x020244A2` tests the state bytes for scanner slots 0 and 1
at `ENG+2837` and `ENG+2839`. When both equal 1 it writes `0x64006400` over the
two state records and queues:

```text
0x00000064
0x00010064
0x06000001
```

The class jump table at `0x02023874` is decoded using the pi32v2 `tbb`
semantics in `reference/ghidra-jieli/data/languages/pi32v2_ins_progflow.sinc`.
Class 6 branches to `0x02023114`. Since `(0x06000001 >> 16) & 0xff` is zero,
the handler clears `ENG+4779` and `ENG+4780` and refreshes the UI. Those bytes
are the octave and semitone shifts in the keyboard-note calculation.

V14 independently confirms the behavior:

- scanner `0x02024B7C`, state bytes `ENG+2901/+2903` (base `0x01C0E690`);
- the same three event words;
- class-6 handler `0x0202334A`;
- shifted octave/semitone bytes `ENG+5099/+5100`.

The physical front-panel labels corresponding to scanner slots 0 and 1 are not
yet mapped. The software effect is nevertheless high-confidence and stable
across releases: this chord resets keyboard transposition, not firmware state,
test mode, or boot selection.

## SDK-only test facilities

The SDK can build several facilities that should not be projected onto stock
firmware merely because their libraries are available:

- Finsh commands are retained in `.FSymTab` only under
  `CONFIG_FINSH_ENABLE`.
- AT commands register in `.RtAtCmdTab`.
- `btcontroller_mode.h` defines `BT_NORMAL`, `BT_BQB`, `BT_FCC`, `BT_FRE`, and
  `BT_PER`, with the default set to `BT_NORMAL`.
- The same header says BLE test serial defaults to USB, test mode disables
  UART0/keys, and a normal-mode product may explicitly call
  `bredr_set_dut_enble()` to enter classic-Bluetooth DUT operation.

No Finsh prompt, msh command, AT command, login/password, or conventional panic
text was found in the V14 printable-string audit. The app's formatting engines
and generic SDK logging code do not by themselves establish an output route.

The SDK RF/FCC tool has distinctive 10-byte activation frames beginning
`01 A1 A2 06 01 02 03 04 05`, with final bytes `01` (Wi-Fi), `02` (BT), `06`
(BT DUT), or `07` (BT BQB), plus `A3` heart/ready variants. Exact binary scans
found none of these frames in the V13 application, V14 application, stock
UBOOT, or extracted OTA loaders. This rules out that specific SDK factory-tool
implementation in the scanned stock images; it does not rule out a different
ROM-only tester protocol.

The SDK also contains a more dangerous online configuration tool in
`apps/common/config/new_cfg_tool.c`. Its CRC16-protected packets begin
`5A AA A5`; commands `0x24`, `0x25`, and `0x27` erase, write, and read physical
flash ranges, while `0x26` disables interrupts and RAM protection, disables
the MMU, sets NVRAM boot state 2, asserts `JL_CLOCK->PWR_CON` bit 4, and waits
for reset into the MaskROM USB updater. The implementation is compiled only
when EQ and online EQ are enabled with `TCFG_COMM_TYPE == TCFG_USB_COMM`, and
its receive entry is `usb_cdc_read_data_handler`.

Exact scans found no `5A AA A5` preamble in either stock application, either
stock UBOOT, or either extracted OTA loader. The normal USB descriptors also
lack CDC. Both releases do include the same 383-byte `cfg_tool.bin` resource
(SHA-256
`276579954f076886a6a7694f65dc71c034a63a2c204b76749065c0ac7b010d1b`),
containing configuration/calibration identifiers such as `JL_AC79XX`; the SDK
opens that file as data and its packaging scripts install it independently of
the online transport. Its presence is not evidence that `new_cfg_tool.c` is
linked. On current static evidence, this raw-flash endpoint is unavailable in
the stock firmware and cannot be treated as a recovery route.

Two V14 `strings` hits for `bqb:` at file offsets `0x40F79` and `0x40FF1` are
false positives. Both start in the middle of live pi32v2 instructions around
`0x02040F70..0x02041018`; neither is a string object or has a flat pointer
reference. The same accident occurs in V13 at `0x40833` and `0x408AB`.

`autotest` at V14 offset `0x65D6C` (V13 `0x65620`) is a real null-terminated
object next to controller data. The identical token occurs in the SDK's
`btctrler.a(lmp.c.o)` LLVM bitcode together with DUT-controller symbols. This
fingerprints linked Bluetooth-controller library material, but no FM-1 UI,
MIDI, BLE-application, or boot call that enables DUT/BQB mode has been located.

## Fatal paths

The common V13 fatal sink at `0x02000292` is called from many validation sites.
It invokes MaskROM address `0xFFC00F6C` with fixed arguments `(0xA0, 4, 1, 1)`
and then loops forever. Calls elsewhere establish the ABI as
`P33_CON_SET(u16 addr, u8 start, u8 len, u8 data)`: nearby MaskROM services are
the corresponding one-byte P33 read/write/OR helpers, and the WL82 SDK declares
the same four-argument interface. Register `0xA0` is `P3_PR_PWR`, so the sink
sets bit 4 in that power-register block before halting. The electrical/reset
effect of that bit is not documented in the available header, but this is not
a UART logger, formatted assertion printer, or console entry.

## Hardware work still required

1. Capture USB descriptors in normal, update-requested, failed-update, and
   long-reset states; watch for any identity other than UAC/MIDI and OTA HID.
2. Probe plausible UART/test pads during cold boot at 1 Mbaud while leaving the
   stock packed config unchanged. Record voltage, idle level, and complete boot
   bytes before attaching an active transmitter.
3. Map scanner slots 0 and 1 to physical controls and verify only the transpose
   reset behavior.
4. With independent ROM recovery available, inspect whether the syscmd
   callback-object table is populated at runtime before sending callback cases.
5. Establish the actual AC791N MaskROM strap/pin sequence. Neither PB01 reset,
   the transpose chord, nor the optional SDK UART modes currently satisfy the
   recovery requirement.
