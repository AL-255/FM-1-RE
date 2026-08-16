# FM-1 V14 firmware

This directory contains the firmware extracted from the Windows
`M-UPGRADE-FM1.exe` updater dated 2026-07-06. The original local source was
`../fwupdate-V14_260706/M-UPGRADE-FM1/M-UPGRADE-FM1.exe`, relative to this
repository's parent directory.

The executable registers Qt resource data at PE virtual address `0x140026030`.
The `:/Resources/FM-1.fwsc` resource begins at resource-data offset `0x4004`;
its four-byte big-endian size prefix is `0x000abe34` (704052 bytes).

Reproduce the extraction and unpacking:

```bash
cd raw_fw
python3 extract_from_updater.py \
  ../../../../fwupdate-V14_260706/M-UPGRADE-FM1/M-UPGRADE-FM1.exe
./extract.sh
```

The outer markers decode to `FM-1_014`, and the decrypted JLFS application is
584956 bytes. `uboot.boot`, `cfg_tool.bin`, and the 19969-byte outer `ota.bin`
are byte-identical to the V13 baseline; `app.bin` and the flash image changed.

`decomp/app_pi32v2_objdump.txt` is the authoritative listing generated with
JieLi's vendor toolchain from `raw_fw/FM-1.fwsc_unpack/files/app.bin`.
`analysis/function_db.json` and `analysis/func_index.csv` contain the
call-target-derived V14 function map.

SHA-256:

```text
4359d9183eb2679d65fcf3284764728f71df747c40058de5700b639917dc12cd  M-UPGRADE-FM1.exe
a1adca99b1f9823ff2873292be74877a7a14ca0846fca3d25a23aba2750162d3  FM-1.fwsc
54a32371e8fc19e7492210e958023762f7335e354a4cab41cb26c35d6f0f0443  app.bin
```
