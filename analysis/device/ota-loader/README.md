# Device OTA loader images

These are the outer `ota.bin` images served to the normal-mode application's
step-1 verifier. The inner LZ4 stream expands to a 23324-byte pi32v2 executable
loaded at `0x01C0A800`.

- `ota_stock.bin`: byte-exact loader from the V13 and V14 stock packages.
- `ota_patched2.bin`: same-size experimental image with an inert decompressed
  data byte changed and all nested CRC fields repaired.

Reproduce the checked-in analysis with:

```sh
scripts/analyze_ota_loader.sh
scripts/run_ghidra_loader.sh
```

The first command verifies and decompresses `ota_stock.bin`, extracts strings,
and creates the authoritative vendor-toolchain listing and call-target-derived
function database. The second creates a corroborative Ghidra linear sweep and
targeted decompilation. The community Ghidra pi32v2 language has unresolved
instructions, so `usb_hid_ota_objdump.txt` is authoritative and
`finish_decomp.c` must not be read as complete control flow.

Key artifacts:

- `usb_hid_ota.bin`: decompressed executable, SHA-256
  `42798ffc24f385302f07865216726fbdd0bfeff1339bdd909edcc93f3b1bb53c`.
- `function_db.json`, `func_index.csv`, `strings.json`: vendor-listing index.
- `usb_hid_ota_linear.asm`, `usb_hid_ota_annotated.asm`: Ghidra sweep and
  call-target annotations.
- `finish-gates.md`: assembly-level trace of the final validation and host
  handshake routine.

The AC79 SDK repository at `/home/yukidama/JL/fw-AC79_AIoT_SDK` also contains
an `origin/AC791N_OTA_loader` branch. Its linker script uses the same
`0x01C0A800` origin. Control-flow matching against its tracked symbol-bearing
`uboot.exe` identifies stock `updata_mode`, `chip_restart`, and `uboot_main`.
It does not rename the subordinate stock finish gate at `0x01C0BB62`: the
transport-specific bodies diverge at that boundary. This is close lineage, not
an exact source match; the branch `.text` is 23812 bytes while the stock inner
executable is 23324 bytes.

Neither image demonstrates a successful custom flash. Current hardware tests
with a shrunken loader ended at `0xE0000000` and never reached the loader's
`0xF0000000` terminal handshake. See `docs/ota-loader-shrinking.md` and the root
`TODO_Aug1.md` before attempting device updates.
