# Firmware investigation - 2026-08-02

## Safety verdict

**NO-GO for non-stock flashing remains in force.** Offline work now identifies the
actual AC791N/WL82 boot chain and gives the stock OTA loader a close
symbol-bearing SDK relative. It still does not prove a ROM-level recovery path,
automatic rollback, or survival of interrupted single-bank writes. Do not use
an experimental package on hardware that cannot be recovered independently.

## Findings closed offline

### The target is AC791N/WL82, not BR22/AC693N

The strongest identity evidence is internally consistent:

| evidence | observed value |
|---|---|
| Decrypted V13/V14 package product ID | `AC791N_STORY` |
| Configuration signature | `AC791N-v0.01-cfg_tool-v0.10` |
| Stock SPL SDK location | `cpu/wl82/tools/uboot.boot` |
| Exact SDK release | `AC79NN_SDK_V1.1.9_2023-08-01` |
| V13/V14/SDK SPL SHA-256 | `730e54f0a439f58d147be4364ad21e19566945ada9d3a7bbc8371dce5068d3ef` |

The exact SPL first appears locally at SDK commit
`3df0315c330de6e9b78bebf0ca395df9c093fb34` (2023-05-31), whose change note
mentions an INI-reading fix for USB download on four-line flash and synchronizing
UBOOT voltage configuration with the SDK. The application string `JL-BR22` is
therefore not sufficient SoC identification; it is likely inherited library or
filesystem nomenclature.

**Consequence:** documentation and scripts that select BR22/AC693N registers or
download tools are unsafe. Legacy upload and raw-flash scripts preserved on the
`with-custom-firmware` branch are not validated for this target and must not be
used until the WL82/AC791N MaskROM/flash procedure is independently established.

### V14 retains the same application update subsystem

The new V14 analysis contains 2062 call-target-derived functions, 42 RAM
entries, and 5531 extracted printable strings. The update-library stamps are
identical in V13 and V14:

- `INCLUDE_UPDATE-$0c1663e`
- `UPDATE-*modified*-tanchiquan-@20230817-$2374938`

The core update block keeps the same function sizes and call-graph shape and is
uniformly relocated by `+0x74C`:

| role | V13 | V14 | size | raw-byte equality |
|---|---:|---:|---:|---:|
| context allocation | `0x020824AE` | `0x02082BFA` | 48 | 85.42% |
| state notification | `0x020824DE` | `0x02082C2A` | 28 | 82.14% |
| SFC cipher | `0x020824FA` | `0x02082C46` | 50 | 96.00% |
| package parse/verify | `0x02082536` | `0x02082C82` | 1212 | 93.32% |
| JLFS find/load | `0x020829F2` | `0x0208313E` | 226 | 95.58% |
| block verification | `0x02082B80` | `0x020832CC` | 382 | 94.50% |
| UFW update run | `0x02082D24` | `0x02083470` | 1542 | 94.49% |
| update dispatch | `0x02083394` | `0x02083AE0` | 196 | 90.82% |
| update entry | `0x02083458` | `0x02083BA4` | 1236 | 71.28% |

The lower equality of `update_entry` is not evidence of a protocol rewrite;
its size and graph remain stable and it contains more relocated references.
V13 identifies itself as `FM-1_009`, despite the archive name, while V14 uses
`FM-1_014`. New tooling must read the embedded identity rather than infer a
version from filenames.

### The stock SPL is stable and SDK-identifiable

V13 and V14 ship byte-identical 14384-byte `uboot.boot` and 699-byte
`isd_config.ini` files. `scripts/analyze_uboot.sh` now reproduces vendor
disassembly/indexes for both the stripped stock SPL and the matching SDK
`uboot.boot_debug`. Useful debug-build strings include:

- `use the first dir_head` / `use the second dir_head`
- `use the first_app_dir_head` / `use the second_app_dir_head`
- `lz4 decompress fail`, `crc %x != %x`, and `decompress failed`
- `update from inside flash`, `usb_update_mode`
- `jump to flash run >>> %x %x`

These show that the generic SPL supports multiple directory heads and update
entry modes. They do not show that the FM-1 package provisions two application
banks.

### The FM-1 configuration is single-backup

The matching SDK rule emits `NEW_FLASH_FS=YES` when
`CONFIG_DOUBLE_BANK_ENABLE` is false and emits the double-bank keys only in the
opposite branch. The FM-1 configuration has no double-bank keys, and its package
manifest contains one `app.bin` plus `cfg_tool.bin`. The SPL contains generic
`app_dir_head2` support, but there is no evidence that this product provisions
or activates a second application image.

Treat the update as single-bank: there is no demonstrated automatic A/B
rollback after a corrupt or interrupted primary-app write.

### PB01 is a reset input, not a proven recovery input

The stock configuration decodes to `RESET=PB01_08_0` and `UPDATE_JUMP=0`. The
exact SDK rule defines that reset tuple as PB01, eight-second hold, active low.
It defines `UPDATE_JUMP=0` as the reset path rather than an in-process jump to
MaskROM.

No current evidence shows that holding PB01 enters USB recovery. Calling it a
recovery button would be unsafe; it is only a confirmed long-press reset input.

### The stock loader maps to the SDK `updata_mode` framework

The SDK remote branch `origin/AC791N_OTA_loader` contains loader source,
symbol-bearing proprietary libraries, its linker script, and a tracked pi32v2
ELF. The post-build script packages `usb_hid_ota.bin` at `0x01C0A800`, exactly
the stock loader origin.

The branch ELF `.text` is 23812 bytes and names `updata_mode` at
`0x01C0C5BC`, size `0x66E`. An exact byte run maps the tail of the function
immediately before it to stock offsets `0x1326..0x1360`, but the code diverges
at the next boundary. Positional alignment alone would incorrectly rename the
stock function at `0x01C0BB62`; the August 1 conservative `ota_finish_gate`
label remains correct.

The outer control flow provides a stronger symbol map:

| SDK symbol | SDK address | stock address | matching evidence |
|---|---:|---:|---|
| `updata_mode` | `0x01C0C5BC` | `0x01C0BC10` | same call position and result pointer in `uboot_main` |
| `chip_restart` | `0x01C0CC66` | `0x01C0BD7A` | same jump/reset tests and call ordering |
| `updata_check_updata_result` | `0x01C0CCA8` | `0x01C0BDBA` | same size and 94.12% raw-byte equality |
| `uboot_main` | `0x01C0CCCA` | `0x01C0BDDC` | stock vector target and same terminal-result branches |

The stock `updata_mode` is smaller because its USB-HID peripheral transport is
different from the tracked ELF's USB-host-oriented build. The map is based on
call semantics and distinctive control flow, not a constant address delta.

Other SDK symbols provide a vocabulary for the stock update pipeline:

| SDK symbol | SDK address | stock role already traced |
|---|---:|---|
| `ufw_head_check` | `0x01C0E07E` | inspect UFW/flash headers |
| `update_type_check` | `0x01C0E812` | verify and construct update plan |
| `flash_update_process` | `0x01C0EEF0` | write planned regions |
| `flash_all_data_verify` | `0x01C0F1A8` | verify written flash |
| `clr_update_loader_record` | `0x01C0F4B6` | clear update-loader record |
| `flash_update_reserve_area` | `0x01C0F514` | finalize reserved metadata |
| `get_update_jump_flag` | `0x01C0F54A` | choose reset versus MaskROM jump |

The source pipeline checks the UFW header, flash header or selected partitions,
update type, erase/write result, whole-flash verification, loader-record state,
and reserved area before returning a terminal result.

The stock `ota_finish_gate` sends `0xF0000000`, expects eight bytes equal to
`"success\0"`, tries at most four times, and returns zero even after all four
comparisons fail. Its stock callers can now be followed through the session
loop and `updata_mode` into `uboot_main`, which records the terminal result and
calls stock `chip_restart()` on the active-update path. That routine reaches
the CPU-reset function on its normal path. With the FM-1's `UPDATE_JUMP=0`,
this matches the SDK source's reset path rather than its optional MaskROM jump.

This makes the host response a terminal acknowledgement rather than
authorization to perform earlier writes. It is not permission to weaken host
handling: disconnect/re-enumeration timing and the behavior after a damaged
single-bank write still require hardware confirmation.

### No hidden console or recovery chord has been found

The V13/V14 application and stock boot configuration were audited for UART
shells, USB CDC, Finsh/msh, AT commands, Bluetooth DUT/BQB activation, factory
keys, and panic output. The result is negative for a reachable interactive
console:

- Normal USB is UAC1 audio plus USB-MIDI. It has no CDC ACM interface.
- The live application UART at SFR `0x12100` is the DIN-MIDI receive path.
- Stock `isd_config.ini` contains `UTBD=1000000` but omits both the SDK's
  `UTTX` boot-debug pin and `UTRX` UART-update pin. The baud field alone does
  not expose a pad.
- The SDK can optionally build Finsh, AT-server, BQB/FCC, and DUT modes, but
  no stock command table or application-level activation path was located.
- Exact scans for the SDK RF/FCC tool's 10-byte Wi-Fi, BT, DUT, BQB, heart,
  and ready activation frames found no match in either stock application,
  UBOOT, or the extracted OTA loaders.
- The SDK's online configuration tool is a separate CDC protocol beginning
  `5A AA A5`. It implements raw flash read (`0x27`), erase (`0x24`), write
  (`0x25`), and MaskROM-update entry (`0x26`). That exact preamble is absent
  from all six scanned stock executables (both applications, both UBOOTs, and
  both extracted OTA loaders), and normal USB has no CDC interface.
- The identical 383-byte `cfg_tool.bin` shipped by V13 and V14 is a packaged
  configuration/calibration resource, not the online tool implementation.
  The SDK opens it as a file, and build scripts package it independently.
- V14 `bqb:` string hits are printable bytes inside instructions, not strings.
  The real `autotest` object fingerprints linked Bluetooth-controller library
  material and is not evidence of a reachable factory mode.
- The fatal sink at V13 `0x02000292` calls MaskROM `P33_CON_SET` for
  `P3_PR_PWR` bit 4 and halts. The bit's physical power/reset effect remains
  undocumented, but the call is neither a UART logger nor a console.

The apparent two-key debug chord is now closed. V13 scanner `0x020244A2`
queues `0x00000064`, `0x00010064`, and **`0x06000001`** when scanner slots 0
and 1 are pressed. Class 6 reaches `0x02023114`, clears the keyboard octave and
semitone offsets (`ENG+4779/+4780`), and refreshes the UI. V14 repeats the same
behavior at scanner `0x02024B7C` and handler `0x0202334A`. It is a transpose
reset shortcut, not a factory, firmware-update, or recovery entry.

The routine previously labeled a `"usb:N"` console command is instead an
unresolved structured-packet callback (V13 `0x02006D38`, V14 `0x02006F90`). It
accepts a 3-byte payload beginning with `'s'` and calls
`usb_device_mode(usb_id, class_mode)`, but no input transport or registration
path has been recovered. This trace also corrected the `usb_device_mode` ABI:
the USB ID is `r0` and the class mask is `r1`, matching the SDK.

Full evidence and addresses are recorded in
`analysis/device/debug-surfaces.md`. None of these paths can substitute for a
demonstrated AC791N MaskROM recovery procedure.

### Normal-mode syscmd map and transport split

The V13 normal-mode dispatcher at `0x02026BC4` and V14 dispatcher at
`0x0202730E` have the same framing and 32-entry command table. Decoding the
pi32v2 `tbh` table corrected the earlier broad classification:

- 17 returns a fixed 27-byte record; 18 returns a fixed 13-byte record.
- 21 drains the common ring at `ENG+960/+964/+968`.
- 19, 20, 22–32, and 37–47 are no-ops that return without a response. They are
  not a default-write family.
- 33–36 select an object index 0–7 and call methods at object offsets 0, 8, 4,
  and 12 respectively. Their shapes are control, write, read, and two-argument
  status operations.
- 48 is a stateful transfer completion. It only copies after matching a stored
  token and length and finding a non-null destination in `ENG+416/+420/+424`,
  then clears the armed state and posts `ENG+1876`.

The callback table moved with the engine layout: V13 reads `ENG+1336`
(`0x01C0EBA8`); V14 reads `ENG+1400` (`0x01C0EC08`). Exhaustive direct-reference
searches found only the four method-dispatch reads in each version and no
direct table writer. This leaves three possibilities: startup-initialized data,
an indirect registrar, or dead generic support. Runtime population is still
unknown and must not be guessed by probing commands that can copy memory.

An SDK type comparison did not resolve the callback ABI. `config_target` is
only an ID/callback pair. The leading offsets resemble `uart_operations`
(`init/read/write/ioctl`), but command 34 supplies `(payload, integer, length)`
without a UART device pointer, so naming the objects as UART operations would
be unsafe speculation.

The dispatcher's third argument is now identified. USB-MIDI's three-CIN-4
binary unpacker stages `ENG+812` and calls with transport 0. The Bluetooth
packet handler's event `0x72` stages `ENG+648` and calls with transport 1.
Responses use different records and length units; the USB path counts unpacked
bits for later MIDI-safe 8-to-7 repacking, while Bluetooth stages byte lengths.
This syscmd family is exposed over MIDI transports but is separate from the
normal-mode OTA trigger and the RAM loader's UFW pull protocol.

## Corrected update model

1. The normal application accepts the USB-MIDI update command and selects an
   update mode.
2. The application verifies and loads the `usb_hid_ota.bin` executable from
   the outer `ota.bin` into RAM at `0x01C0A800`.
3. The loader pulls UFW data through host requests, validates product/package
   metadata, and creates a flash update plan.
4. The loader erases/writes the single configured application layout, verifies
   flash contents, and updates loader/reserved metadata.
5. Only after those gates does it send `0xF0000000` and consume the host's
   `"success\0"` response.
6. The stock outer loader records the result and invokes its reset path. Exact
   timeout, power-loss, next-boot, and recovery behavior is unproven.

## Remaining work

### P0 - required before non-stock flashing

- [ ] Identify a repeatable AC791N/WL82 ROM-level recovery entry and confirm
  that it works when the primary application is corrupt. Record the physical
  pins/test pads, USB identity, host command, and restoration procedure.
- [ ] Obtain a complete stock flash dump on recoverable hardware and verify a
  byte-for-byte restoration path before the first non-stock erase/write test.
- [ ] Test power loss and disconnect at header validation, erase, write,
  whole-flash verify, metadata finalization, and the four finish-handshake
  attempts. A bootable app or proven ROM recovery is required after every case.
- [ ] Retest the Linux client's 2000 ms start delay, 3000 ms post-verification
  delay, model checks, and post-reboot identity checks on recoverable hardware.
- [ ] Prove that stock V14 can restore a deliberately altered application. A
  normal-mode updater inside a non-booting application is not a recovery
  strategy.

### P1 - offline hardening

- [ ] Revalidate every register address and peripheral assumption borrowed
  from BR21/BR22 sibling documentation against WL82 headers; string similarity
  is not hardware proof. Known sibling-derived claims are now labeled as such.
- [ ] Use the branch ELF symbols and debug information to fingerprint and name
  the exact stock loader functions. Keep byte-different functions marked as
  inferred rather than source-recovered.
- [ ] Add strict `.fwsc` preflight: header and entry-list CRCs, entry ranges,
  transformed entry CRCs, exact length, `AC791N_STORY` product allowlist,
  expected SPL/config hashes, and nested OTA validation.
- [ ] Reject unknown loaders and incompatible SPL/config/layout combinations by
  default. SDK notes explicitly warn that UBOOT mismatches and crossing
  single/double-backup modes can make OTA fail.
- [ ] Separate code from embedded tables in the app/SPL indexes and recover
  callback-only functions before treating function counts as coverage.
- [ ] Add complete request-sequence replay tests, including short responses,
  wrong finish acknowledgements, disconnects, re-enumeration, and loader errors.
- [ ] Recover the registration/population path for the normal-mode syscmd
  callback-object table at V13 `ENG+1336` / V14 `ENG+1400`, and the arming path
  for command 48, before probing command IDs 33–36 or 48.
- [ ] Verify on hardware that `5A AA A5` packets receive no response in normal
  mode only after ROM recovery is available. Do not send the erase/write
  commands; descriptor and passive-traffic capture should come first.
- [ ] Map key-scanner slots 0 and 1 to front-panel labels and verify that the
  stable V13/V14 chord only resets octave/semitone state.

## Reproducible artifacts added in this pass

- `scripts/analyze_v14.sh` builds V14 function and string indexes under
  `firmware-images/v14/analysis/`.
- `scripts/analyze_uboot.sh` verifies exact SDK-tag provenance and builds stock
  and paired-debug SPL indexes under `analysis/device/uboot/`.
- `analysis/device/uboot/README.md` records the load address, hashes, SDK tag,
  and the mixed-code/data limitation.
- `analysis/device/ota-loader/finish-gates.md` now maps the stock outer caller
  chain and corrects the reset-path interpretation.
- `analysis/device/debug-surfaces.md` records the console/factory-mode audit,
  closes the false BQB and key-chord leads, and separates SDK capabilities from
  stock reachability.
- `scripts/run_ghidra_loader.sh` now treats Ghidra's `SCRIPT ERROR` output as a
  failure because the headless launcher can still return process status zero.

These artifacts improve traceability and reduce guesswork. They do not change
the hardware safety decision.

## Offline verification completed

- `scripts/analyze_v14.sh`: regenerated 2062 function entries, 42 RAM entries,
  and 5531 strings over `0x02000000..0x0208ECFC`.
- `scripts/analyze_uboot.sh`: verified the stock SPL against the pinned SDK tag
  and regenerated the 55-entry stock and 66-entry paired-debug indexes.
- `scripts/analyze_ota_loader.sh`: reproduced the 23324-byte inner executable,
  its SHA-256, 204 function entries, and 219 strings.
- `scripts/run_ghidra_loader.sh`: regenerated a 6992-instruction sweep and
  decompiled all 16 targets. Pi32v2 p-code warnings remain expected.
- `python3 -m unittest discover -s tools/tests -v`: all 14 tests passed.
- Exact binary assertions found no `5A AA A5` online-tool preamble in the six
  stock application/UBOOT/OTA-loader artifacts and verified that both
  `cfg_tool.bin` resources are identical 383-byte files with SHA-256
  `276579954f076886a6a7694f65dc71c034a63a2c204b76749065c0ac7b010d1b`.
- Historical tests on the preservation branch rejected unacknowledged legacy
  `upload` and raw `dump` commands before device access.

All checks are offline. None validates erase/write behavior on an FM-1.
