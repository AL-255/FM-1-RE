# Verified rollback from a modified V15-derived build to stock V15 - 2026-09-04

I recovered my FM-1 from a locally modified firmware package back to stock V15 over USB. There is no official FM-1 V16 release involved here: the device reported version 16 only because my test package was derived from stock V15 and had its version identity intentionally bumped to 16 so the normal updater would accept the modified image.

That distinction matters. This recovery demonstrates that the FM-1 can be moved backward from a higher reported version identity to an older stock package when the application is still running and the update transport remains reachable. In this case, the modified package had also broken the normal USB configuration descriptor, but an already-active Windows descriptor filter still exposed the MIDI port.

The recovery failure turned out to be in the host response framing, not an anti-rollback fuse or permanent device-side downgrade block. The device's final 481-byte loader request got a reply declaring 488 body bytes while actually containing 489. The device checks that decoded length before dispatching the response, so it rejected the packet. Encoding the complete decoded message first and then packing it into MIDI-safe 7-bit bytes fixed the transfer. The same correction also applies to other partial-block requests.

The live run used a local Windows.Devices.Midi adapter. This PR brings the shared protocol corrections into the Linux client; it does not claim a hardware test of the ALSA transport. The adapter also needed to accept Windows' numbered port labels (`2 - USB-Midi`) and stock identity checksums. No Windows driver or replacement firmware is included here.

## What this proves

The successful rollback is evidence that, for this tested path, the version restriction enforced by the normal updater is at least partly host-side policy rather than a one-way device fuse. The device was running a V15-derived test build that identified itself as version 16, and the corrected client successfully supplied the stock V15 package, completed the normal OTA write, rebooted, and returned as stock V15.

This does not yet prove arbitrary rollback between every historical FM-1 release. Older packages may differ in metadata, loader behavior, or package layout and should still be checked before use. It also does not replace the lower-level JieLi USB_KEY/UBOOT recovery path for a hard brick where the application no longer runs or no usable update transport is reachable.

## Code path

```text
device requests logical offset + length
  -> slice that exact number of bytes from the stock package
  -> build [00 59 30][length+8][type][address][length][payload][checksum]
  -> pack the complete message into 7-bit MIDI bytes
  -> send the response
  -> acknowledge E0000000 / F0000000 with success\0
  -> verify the identity after the device returns
```

The complete header construction is visible in the existing
[vendor packet builder](../../analysis/host-updater/ota_worker_decomp.c#L1455),
`FUN_140017b20`. The device's length check is at V13 `0x02026BDA`/`0x02026BDC`
in the [vendor disassembly](../../analysis/disassembly/app_pi32v2_objdump.txt#L56222).

Stock V15 and its loader return a zero-padded plain identity, such as
`ota-FM-1_015`. The client now reads that format while retaining the older
encoded identity format. Stock replies use the one's-complement checksum.
My modified V15-derived test build reported `FM-1_016` but retained V15's checksum after the version digit was changed; the exception is limited to that exact captured response.

## Instrumentation and observed result

```text
read-only command: modified V15-derived test build reporting FM-1 V16 on 4C4A:C755
  -> hash-check the unchanged stock V15 package
  -> 48 staging data requests, then E0000000
  -> capture new USB identity 4D4A:4155
  -> command reply: ota-FM-1 V15
  -> 1167 flash data requests, then F0000000
  -> capture normal USB identity 4C4A:C755
  -> separate read-only command: FM-1 V15
  -> read raw USB descriptor: 293 bytes, valid walk
  -> Windows enumeration: FM-1 Audio OK, FM-1 Midi OK
```

The image was `FM-1_015`, 699956 bytes (699936 after removing FWSC markers),
SHA-256 `DB1642B2B6FA5C2CCCB11FFD13878068BB28601678D3644049F99DC40E7EDB8A`.
The post-boot configuration descriptor SHA-256 was
`8E5F630AEF8941ECDCC59628B616216D9C15AC25A1BB6A03A97C430A08614DBF`.

The [redacted record](../../tools/tests/fixtures/fm1-v15-reflash-2026-09-04.json)
preserves every requested address, length and flash type. Each run is
`[first_address, length, flash_type, count, address_stride]`; expanding the runs
reproduces all 49 first-stage and 1168 second-stage records, including their
terminal requests. The data-request counts exclude those terminal records.
It also contains the actual OTA identity reply and the separate post-boot
observations. Original logs were retained locally and checked against their
saved hash manifest before this allowlisted record was extracted. Host paths,
device-instance IDs, serials and firmware payloads are excluded.

## Check the evidence without touching hardware

From the repository root:

```sh
python tools/verify_reflash_record.py
python -m unittest discover -s tools/tests -v
```

The checker expands the captured requests, checks their bounds and counts,
requires both terminal signals and the separate post-boot V15 observation,
and decodes generated replies against the device's length/checksum contract.
With no firmware supplied, it uses synthetic zero payloads for the wire checks.
To replay the requested payload bytes from your own copy of the exact stock
package, still without opening MIDI ports:

```sh
python tools/verify_reflash_record.py --firmware path/to/FM-1_V15.fwsc
```

Expected first line:

```text
Recorded capture chain verified: FM-1 V16 -> OTA V15 -> flash complete -> FM-1 V15.
```

In that checker output, `FM-1 V16` is the captured identity of the locally modified V15-derived test package, not an official V16 firmware release.

That command checks the supplied record's consistency. It does not independently
authenticate a historical capture or perform another flash. The hardware result
comes from the recorded device observations. A terminal signal alone would not
establish the installed version; changing the recorded post-boot version back to
16 makes the check fail.

This was the stock OTA erase/write process, without a separate whole-chip wipe,
ROM recovery, flash readback or an audio playback test. The PC was not rebooted
and no elevation prompt was needed during the reflash; the device reset itself
through the normal update protocol. It is evidence for this unit and this path,
not interrupted-update safety or recovery from an application that cannot run.
