# Firmware update review - 2026-08-01

## Release decision

**NO-GO for flashing custom firmware.** The repository can build a structurally
valid package and emulate the Windows host protocol, but it has not completed a
custom update on hardware. The last device test stopped at the loader's
`0xE0000000` verification signal, rebooted, and left the stock image installed.
Later offline tracing shows that `0xF0000000` is a terminal acknowledgement
after erase/write/finalization gates, not authorization to begin those writes.

Do not describe `build/FM-1-demo.fwsc` as flash-ready until every P0
item below is complete.

## Current status

| area | status | evidence |
|---|---|---|
| V13 application | Broad linear disassembly and 2062 call-target-derived entries | `analysis/disassembly/`, `analysis/` |
| V14 application | Extracted and vendor-objdump listing generated | `firmware-images/v14/` |
| Windows updater | Critical worker and terminal protocol decompiled | `analysis/host-updater/` |
| Linux USB-MIDI client | Wire packets, finish state, and identity checks covered by 14 offline tests | `tools/fm1_ota.py`, `tools/tests/` |
| Device OTA loader | Executable extracted and indexed; finish gate traced at assembly level | `analysis/device/ota-loader/` |
| Custom package | UFW/JLFS structure and CRCs parse successfully | `tools/build_fwsc.py` |
| End-to-end custom flash | Failed before terminal completion; no `0xF0000000` request | `docs/ota-loader-shrinking.md` |
| Recovery from a broken custom app | Unproven; no accessible hardware UBOOT mode | `tools/README.md` |

## P0 - required before any device flash

- [x] **Map the device-side OTA loader.** Extract the 23324-byte inner image,
  generate a vendor listing and function database at load address `0x01C0A800`,
  and check the artifacts into `analysis/device/ota-loader/`.
- [x] **Explain the finish gate.** The routine starts at inner-image offset
  `0x1362`; the actual `0xF0000000` request is at `0x1398`, after package,
  partition, and flash gates. Every suppressing branch is documented in
  `analysis/device/ota-loader/finish-gates.md`. This is offline evidence only.
- [ ] **Retest the corrected host timing.** The current client now matches the
  updater's 2000 ms start delay and 3000 ms post-verification delay, but those
  changes have not been exercised against hardware.
- [ ] **Create a fail-open boot path.** `demo_install()` currently runs
  synchronously from the stock app-task trampoline. Add a physical boot bypass,
  watchdog-backed failure counter, or delayed activation after the stock USB
  update service is known to be alive.
- [ ] **Prove stock recovery.** Verify that an installed custom version can
  accept the stock V14 package. The custom builder advertises `FM-1_015`, while
  the available recovery image advertises `FM-1_014`. Bundled updater logs
  prove that the stock path accepts an FM-1 downgrade from 10 to 8, but do not
  prove that a broken custom application's update service remains reachable.
- [ ] **Use recoverable hardware for first commit tests.** Obtain a full flash
  dump and working JTAG/UART or other ROM-level recovery before testing erase or
  commit behavior. Include interrupted-transfer and invalid-image tests.

## P1 - complete the disassembly needed for OTA work

- [ ] Build a V14 function database, call graph, string-reference map, and
  classified index. The checked-in V14 artifact is currently only a linear
  listing.
- [ ] Semantically match the V13 and V14 update subsystems. V13 hook addresses
  are not valid V14 addresses: exact-byte matching places the old MIDI entry
  near `0x0201F760` and the old app-task entry near `0x02022F32`, and the V13
  verifier bodies near `0x02082536..0x02083394` changed materially.
- [ ] Disassemble and map `uboot.boot`. It is executable recovery/boot code, not
  an opaque configuration blob.
- [ ] Separate code and data before claiming full function coverage. Current
  entries come from direct `call` targets and boundaries are inferred from the
  next target; callback-only functions can be missed and data fragments can be
  classified as code.
- [ ] Remove the known bogus `0x020FCD26` function entry and audit the data-table
  fragments at the end of the current function index.
- [ ] Reconcile classification confidence. The current `db.json` pipeline
  contains 668 low-confidence and 11 unknown entries; the independent
  `master_index.json` pipeline leaves 824 entries unclassified.

## P1 - harden the host updater

- [ ] Add a strict `.fwsc` preflight before sending the upgrade command:
  header CRC, encrypted entry-list CRC, entry ranges, entry CRCs after required
  transforms, chip/product allowlist, exact image length, and OTA inner/outer
  header validation.
- [ ] Reject unknown or structurally modified loaders by default. Require an
  explicit development override for experimental loader images.
- [ ] Hardware-test normal-mode and OTA-mode identity comparisons. The client
  now decodes both handshakes and rejects a model mismatch before either
  transfer; the comparison has only offline coverage.
- [ ] Hardware-test post-reboot identity verification. The client now mirrors
  M-UPGRADE's model/version parser and fails when the reported identity differs
  from the package header; this has only offline coverage.
- [ ] Add replay tests using complete captured request sequences. The existing
  state-machine tests mock `serve_requests()` and do not exercise re-enumeration,
  ALSA behavior, or the real loader's error paths.
- [ ] Make `serve` require a positively identified OTA loader unless an explicit
  override is supplied.

## P2 - build and documentation cleanup

- [ ] Port the custom image to a V14 base only after V14 hook sites and free
  regions are proven with instruction fingerprints and surrounding-byte guards.
- [ ] Keep the official V14 `ota.bin`, configuration, SPL, and partition layout
  byte-identical until the loader checks are understood.
- [ ] Replace fixed firmware offsets with parsed JLFS/UFW entry locations where
  possible. Fail closed when fingerprints or expected sizes differ.
- [x] Correct claims such as "fully reverse-engineered", "all functions", and
  "OTA loader is robust" so they distinguish verified behavior from hypotheses.
- [ ] Generate a machine-readable firmware inventory containing hashes, product
  markers, app sizes, loader hashes, and analysis coverage for each stock image.

## Offline checks completed on 2026-08-01

- `python3 -m unittest discover -s tools/tests -v`: 14 tests passed.
- `make -C firmware image`: rebuilt the pi32v2 blob and verified the
  hook fingerprints in the patched application image.
- `fwunpack_newfw.py` successfully parsed both a stock-app/stock-loader control
  package and the default experimental package, including their JLFS entries.
- `scripts/analyze_ota_loader.sh` reproduced the 23324-byte executable, vendor
  listing, 204-entry function database, and 219 extracted printable strings.
- `scripts/run_ghidra_loader.sh` produced a 6992-instruction corroborative
  sweep and 219 call-target-derived entries; incomplete pi32v2 decoding remains
  a known Ghidra limitation.

These checks prove serialization and build consistency only. They do not prove
flash erase/write behavior, bootability, rollback, or recovery.
