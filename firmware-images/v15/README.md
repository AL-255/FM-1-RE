# FM-1 V15 firmware

This directory contains the `FM-1.fwsc` package M-VAVE publishes for V15,
fetched from the vendor CDN on 2026-09-06:

`https://yms-file-store.oss-cn-hongkong.aliyuncs.com/software/firmware/FM-1.fwsc`
(`Last-Modified: Thu, 30 Jul 2026 06:17:06 GMT`, ETag
`3B14C994402E2FE88D0BA7B3600A5DEF`, 699956 bytes). The URL carries no version,
so `raw_fw/fetch.sh` downloads it and refuses anything but this SHA-256.

The macOS updater `M-UPGRADE-FM1.dmg` offered by the vendor on 2026-09-06
(app binary dated 2026-07-08) still embeds the V14 package byte for byte, so
V15 appears to be CDN-only.

Reproduce the unpacking:

```bash
cd raw_fw
./fetch.sh      # optional: re-download and verify
./extract.sh
```

The outer markers decode to `FM-1_015`, and the decrypted JLFS application is
581564 bytes (3392 bytes smaller than V14). Compared with V14:

- `top/uboot.boot`, `top/isd_config.ini`, `files/cfg`, `files/cfg_tool.bin`
  and the 19969-byte outer `ota.bin` are byte-identical. `ota.bin` sits at
  package offset `0xA5F14` (V14: `0xA6F14`) and passes
  `scripts/extract_ota_loader.py`; the decompressed `usb_hid_ota.bin` is the
  same 23324-byte image.
- The application area shrinks by `0x1000`: `cfg_tool.bin` moves from
  `0x92E1C` to `0x920DC`, and the VM region from `0x94000` (`0x55000` bytes)
  to `0x93000` (`0x56000` bytes). `BTIF` and `USR` are unchanged. The
  decrypted flash images are identical for the first `0x4000` bytes.
- The SDK build stamps (`INCLUDE_*`, `DRIVER-…`, `SYSTEM-…`, `UPDATE-…`) are
  identical, so only M-VAVE's application code changed.
- New strings: `Glide`, `Glide Val`, `Fingered`, `Full Time`; three sequencer
  pages (`1/3 … 3/3  Sequencer`); two `Globe` pages; reordered operator pages
  (`1/6 OP1 Tune&Lvl`, `3/6 OP1 Envelope`, `4/6 OP1 Sens&Osc`); a patch
  `Rename` UI (`OP1 A-Z  OP2 a-z`, `OP3 Punct  OP4 0-9`, `OP5 Delete  K3 Pick`);
  `K1-K4 Select Patch`, `VOICE %d`, `Mix: %d%%`. Removed: `Reset All Patches
  Turn the K4`, `Cancel Reset Turn the K1`.
- The msfa algorithm table is at `app.bin` offset `0x8BE8C` (V14: `0x8CBCC`),
  with the same variant of algorithms 4 and 6.

`analysis/strings_raw.txt` was produced with `scripts/extract_binary_strings.py`
exactly as for V14. No linear disassembly or function map is included; those
need the vendor toolchain pipeline (`scripts/analyze_v14.sh`).

Identity reply of a stock V15 unit (2026-09-06, macOS, python-rtmidi), useful
as a parser fixture: the answer to `F0 00 32 45 00 00 00 40 7F F7` was

```text
F0 00 32 45 58 01 00 00 23 4D 5A 44 79 05 26 4C 1A 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 20 06 F7
```

which unpacks to `00 59 11 | 1B 00 00 | "FM-1_015" + zero padding | 19`.

SHA-256 (also in `../SHA256SUMS`):

```text
db1642b2b6fa5c2cccb11ffd13878068bb28601678d3644049f99dc40e7edb8a  FM-1.fwsc
306e47065f35d7a7a05ada7f5dd092f6e770952054f33f0a86b75fd10ffe3203  app.bin
730e54f0a439f58d147be4364ad21e19566945ada9d3a7bbc8371dce5068d3ef  uboot.boot
```
