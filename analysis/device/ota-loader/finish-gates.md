# OTA loader finish gate

## Scope and confidence

This traces the stock loader routine at image offset `0x1362`, runtime address
`0x01C0BB62`. Addresses and branches below come from the JieLi vendor objdump.
The name is a conservative role name, not a recovered source symbol. The
Ghidra decompilation is incomplete because the community pi32v2 language fails
to decode several instructions.

The SDK loader
`cpu/wl82/tools/loader_tools/usb_update2.bin` (23200 bytes, SHA-256
`ec17e524c17f5f2eda5dbca3c3205b9c41aa0dd8464b3b8881bbb26e72114600`)
is a different build, but strongly corroborates the layout. The callbacks at
device offset `0x3E0E`, finalizer at `0x4AAE`, and fatal handler at `0x4AE4`
have instruction-for-instruction counterparts at SDK offsets `0x3E58`,
`0x4A98`, and `0x4A3A`. The larger routines also retain close control-flow and
constant signatures.

The local AC79 SDK's `origin/AC791N_OTA_loader` branch is a better lineage
reference. Its tracked pi32v2 ELF has `.text` at `0x01C0A800` and symbols for
the outer update framework. An exact byte run maps the tail of the SDK's
preceding `update_part_area_info_opt` to stock offsets `0x1326..0x1360`, but the
bodies diverge at the next function boundary. It would therefore be incorrect
to transfer the adjacent SDK `updata_mode` symbol to stock offset `0x1362`.

Control-flow matching instead maps the stock vector target at `0x15DC` to SDK
`uboot_main`, stock `0x1410` to `updata_mode`, stock `0x157A` to
`chip_restart`, and stock `0x15BA` to `updata_check_updata_result`. This is
supported by the same result comparisons and call ordering, plus 94.12% raw
byte equality for the 34-byte result-check function. The transport-specific
`updata_mode` bodies differ substantially.

## Control flow

Equivalent pseudocode, with error handling expanded, is:

```c
int ota_finish_gate(void) {
    int selection;
    int error = inspect_update_headers(&selection);       // +0x37E2

    if (error == 0 && selection != -1)
        error = run_partition_callbacks(selection);       // +0x3E0E

    if (error == 0 && selection == -1) {
        error = validate_required_file_heads();            // +0x3C1C
        if (error == 0) {
            int have_plan = 0;
            error = verify_and_plan_update(&have_plan);    // +0x3F14
            if (error == 0 || error == 13) {
                if (!have_plan)
                    error = 14;
                else if ((error = prepare_flash_regions()) == 0 &&
                         (error = write_update_regions()) == 0)
                    error = finalize_update_metadata();   // +0x4AAE
            }
        }
    }

    if (error != 0) {
        if (is_fatal_update_error(error)) {                // +0x4FF8
            handle_fatal_update_error();                  // +0x4AE4
            return -1;
        }
        return -2;
    }

    return finish_host_handshake();
}
```

The exact suppressors of the `0xF0000000` request within this path are
therefore:

| gate | offset | observed failure domain |
|---|---:|---|
| Header and flash inspection | `0x37E2` | Returns a nonzero status before selecting the callback or full-update path. Constants assigned to its final status include 1, 8, 11, 14, and 25. |
| Selected partition callbacks | `0x3E0E` | A selected callback failure becomes 12 or the callback record's byte at `+20`; callback return `-3` is explicitly accepted. A direct input of `-1` returns 21. |
| Required file-head validation | `0x3C1C` | Scans 32-byte records for `flash.bin`, `app_dir_head`, and `uboot.boot`; missing records and header/CRC failures produce nonzero status. |
| Update verification/planning | `0x3F14` | Any nonzero result other than 13 suppresses the request. Result 13 is explicitly tolerated, but the output plan flag must still be nonzero. |
| Plan-present check | `0x13D0` | A zero plan flag is converted to status 14. |
| Flash preparation | `0x4536` | Any nonzero return suppresses the request. |
| Region write/update | `0x47C0` | Any nonzero return suppresses the request. Constants 11, 19, and 20 occur on error paths. |
| Metadata finalization | `0x4AAE` | Its returned status is checked at `0x1386`; nonzero suppresses the request. |

The SDK enum in `include_lib/update/update_loader_download.h` gives names to
the error values classified as fatal by `0x4FF8`:

| value | SDK name |
|---:|---|
| 11 | `UPDATE_RESULT_EX_DSP_UPDATE_ERR` |
| 12 | `UPDATE_RESULT_CFG_UPDATE_ERR` |
| 13 | `UPDATE_RESULT_FLASH_ERASE_ERR` |
| 22 | `UPDATE_RESULT_TWS_NO_CONNECT` |
| 25 | `UPDATE_RESULT_UFW_CODE_HEAD_CRC_ERR` |
| 28 | `UPDATE_RESULT_LOADER_HEAD_CRC_ERR` |
| 30 | `UPDATE_RESULT_DUALBANK_GET_UFW_APP_HEAD_ERR` |
| 31 | `UPDATE_RESULT_DUALBANK_GET_LOCAL_APP_HEAD_ERR` |
| 32 | `UPDATE_RESULT_DUALBANK_APP_HEAD_NOT_MATCH` |

The classifier implements this exact set with bitmap `0x003A4807`. Values in
the table call the fatal handler and return `-1`; other nonzero values return
`-2`. The stock loader may use an older enum or reuse small status values in
local routines, as shown by the explicit tolerance of 13. The SDK names are
therefore evidence, not proof of every callee's source-level meaning.

## Host handshake

The request is issued at offset `0x1398`, not at the routine entry `0x1362`:

1. Call transport routine `0x0FA2` with command `0xF0000000`, length 8, and an
   eight-byte stack buffer.
2. Compare the buffer with the eight bytes `"success\0"` using the exact
   memcmp-like routine at `0x29EE`.
3. Retry after a mismatch, for at most four transport calls.
4. Return 0 immediately on a match. After four mismatches, also return 0.

The transport return value is not checked at this call site. Consequently, a
zero return from this stock path does not prove that the host replied with
`"success"`.

The stock caller trace is now complete. `ota_finish_gate()` is called by a
session loop at offset `0x13EA`; a zero result clears its active-state byte and
returns through stock `updata_mode` at `0x1410`. Stock `uboot_main` at `0x15DC`
then classifies the result, records status, and calls `chip_restart()` at
`0x157A` for the active-update path. This matches the SDK's source-level call
ordering.

Stock `chip_restart()` tests the update-jump flag, then reaches the CPU-reset
routine at `0x1576` on its normal path. The FM-1 configuration sets
`UPDATE_JUMP=0`, so the source-correlated normal behavior is reset rather than
a direct MaskROM jump. Hardware traces are still needed to determine when the
host observes disconnect/re-enumeration and what happens after a damaged
single-bank write.

## Remaining safety questions

- Confirm the erase, write, metadata, reboot, and rollback side effects of
  `0x4536`, `0x47C0`, and `0x4AAE` on recoverable hardware.
- Capture the real transport behavior for timeout, short reply, wrong reply,
  and disconnect during the four-attempt finish handshake.
- Confirm which update-result enum revision the FM-1 stock loader uses.
- Determine whether a power loss after flash writes but before or during
  `0xF0000000` leaves a bootable bank or recoverable ROM path.

These findings close the offline control-flow question only. They do not make
the current custom package safe to flash.
