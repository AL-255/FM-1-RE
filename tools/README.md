# FM-1 update-protocol tools

These tools reproduce and inspect the stock FM-1 USB-MIDI update protocol.
They do not build replacement firmware.

## USB-MIDI client

`fm1_ota.py` implements the two-stage pull protocol observed in the Windows
M-UPGRADE application. It supports discovery, handshake inspection, request
serving, and transmission of an existing `.fwsc` package:

```bash
python3 tools/fm1_ota.py scan
python3 tools/fm1_ota.py flash path/to/official-package.fwsc
```

The client validates the device identity, bounds-checks loader requests, waits
for the observed terminal signals, and checks the post-reboot identity. Its
packet codec and state machine have offline unit coverage, but current timing
and recovery behavior have not been verified on available hardware.

The [V16 to stock V15 record](../docs/io/12-v15-reflash-proof.md) documents a
successful reflash through a local Windows MIDI adapter using the corrected
framing. Check the redacted request sequence and generated packets offline:

```sh
python tools/verify_reflash_record.py
```

This checks saved evidence, not current hardware. The ALSA transport was not
used in that live run. No firmware payload or Windows driver is included.

## UBOOT reference

The pinned `3rd-party/jl-uboot-tool` submodule documents JieLi UBOOT discovery,
RAM execution, and flash commands. It lists WL82/AC791N support as unknown, and
an externally entered UBOOT/MaskROM mode has not been demonstrated on the
retail FM-1. This branch contains no wrapper that invokes its write or erase
operations.

Do not treat normal-mode OTA as recovery from a corrupt application. The
single-bank write behavior, interrupted-update behavior, and ROM-level restore
procedure remain open questions in `TODO_aug2.md`.
