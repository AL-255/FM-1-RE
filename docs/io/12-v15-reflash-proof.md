# Verified V16 to stock V15 reflash - 2026-09-04

I got my FM-1 back from a modified V16 to stock V15 over USB. The application
still answered MIDI commands, but its USB configuration descriptor was broken.
An already-active Windows descriptor filter made the MIDI port available.

The failure was in the host response framing. The device's final 481-byte loader
request got a reply declaring 488 body bytes while containing 489. The device
checks that length before dispatching the response. Encoding the entire message
fixed it. The same fix also matters for the 10-byte request near the end of the
second stage.

The live run used a local Windows.Devices.Midi adapter. This PR brings the shared
protocol corrections into the Linux client; it does not claim a hardware test of
the ALSA transport. The adapter also needed to accept Windows' numbered port
labels (`2 - USB-Midi`) and stock identity checksums. No Windows driver or
replacement firmware is included here.

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
My modified V16 had kept V15's checksum after changing its version digit;
the exception is limited to that exact captured V16 response.

## Instrumentation and observed result

```text
read-only command: FM-1 V16 on 4C4A:C755
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
