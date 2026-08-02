# 09 — Storage: NOR flash driver, norfs/FAT filesystems, VM key-value store, DX7 patches, firmware update

Target: M-Vave FM-1, JieLi BR22/AC693N. One external SPI NOR flash holds everything:
the firmware XIP image, a small NOR-resident file area ("sdfile"/norfs), a FAT/exFAT
volume, the VM (virtual-memory EEPROM-emulation) key-value area used by syscfg, and the
raw DX7 bank/patch region. Confidence: **high** = proven, **med** = strong inference,
**low** = guess.

Primary evidence: `analysis/shards/shard_020847aa_020847f2.txt`,
`shard_02084824_0208c3b4.txt` (SPI0/flash low level),
`shard_02002154_02003b52.txt` (ROM-call read/write cores),
`shard_02027346_02028fc6.txt` (flash ioctl, device framework, update file open),
`shard_02028fd2_0202b3d6.txt` + `shard_0202b498_0202e0fa.txt` + `shard_0202e108_0203091c.txt`
(FAT/VFS), `shard_02030942_02033964.txt` (VM KV), `shard_02019e9e_0201f07e.txt`
(DX7 pack/store), `shard_02082d14_0208478a.txt` (ufw/jlfs).

---

## 1. NOR flash driver (SPI0)

**SPI0 base `0x11C00`** (jielie `spi.md`: CON+0, BUF+8; CON bit15 PND, bit14 PCLR).
Low-level (all high conf):

| addr | name | notes |
|---|---|---|
| `0x020847AA` | `spi0_wait_ok` | poll `[0x11C00]` sign bit (PND) with 50 000 000-iteration timeout, clear via `\|= 0x4000`; returns 0 ok / −1 timeout |
| `0x020847DA` | `spi0_send_byte` | set TX direction (`\|= 8`, clear bit 12), `[0x11C00+8] = byte`, wait, restore |
| `0x0208478A` | `norflash_cs` | CS low/high helper (r0 = 0/1) |
| `0x02084700` | `norflash_spi0_guard` | wait SFC idle, save/restore SPI0 CON around bit-banged phases |
| `0x020847F2` | `norflash_enter_4byte_addr` | if flash size `[0x1C20190+24] > 16 MB` and addr ≥ 16 MB: one-shot **EN4B `0xB7`** |

**Command-mode engine `norflash_cs_and_erase` `0x02084BBE`** (med): enters SFC command
mode via SFR **`0x40200`** — saves `[0x1C20190+56]`, programs SPI0 CON from
`[0x1C20190+60]`, sets `[0x5101C] |= 0x20`, waits `0x40200` sign bit clear, issues the
command. The merged cluster around it contains:

- **page program**: WREN (`0x02084824` + verify `0x02084862`), opcode `0x02`,
  3/4-byte address via `spiflash_send_addr` `0x02084872`, byte loop, wait-ready
  `0x020848D0`, icache sync `0x02084B88` — at `0x02084C24`;
- **read**: dispatch `spiflash_io_dispatch` `0x02084A30` (single/dual/quad by chip type);
- **erase** at `0x02084D4E`: selector − 200 → `tbb` table —
  4 kB sector (`0x20`), 64 kB block (`0xD8`), whole chip (`0xC7`), 256-byte page
  (`0x81`, **med**); bounds-checked against `[0x1C20190+24]` flash size;
- **JEDEC ID** `0x9F` → 3 bytes into `[0x1C20190+28]`; **unique ID** `0x4B`
  (4 dummy + 16 UID bytes) — at `0x02084CC6`.

**Normal (memory-mapped) data path** — the CPU reads flash XIP, writes/erases go
through mask-ROM services (high):

| addr | name | notes |
|---|---|---|
| `0x0200372C` | `norflash_read_core` | mutex `0x1C0E670+2196` (`os_mutex_pend` `0x0205AE98`), bounds vs `[0x1C20190+24]`, reads in ≤256 B chunks via ROM **`0xFFC00404`** |
| `0x020037B4` | `norflash_read` | public wrapper, returns 0 on short read |
| `0x0200380A` | `norflash_write_core` | ROM **`0xFFC00476`**; then re-scrambles any data in the encrypted region (`< [0x1C20190+36]`) with the boot key `h[0x1C7FD50+28]` via the LFSR cipher `0x020037C8` |
| `0x020038A2` | `norflash_write` | public wrapper, 0 on failure |
| `0x02001D33A` | `norflash_ioctl` | device ioctl: erase/write/cache-control commands, mutex-guarded (cmd 206 = query VM area, used by `vm_area_init`) |
| `0x02028BA2` | `norflash_dev_init` | JEDEC read, capacity = 2^n, registers the device into the framework |

---

## 2. Filesystems

Two stacks share the flash through the device framework (devices `'norflash'`
`0x02055780`, `'nor_sdfile'` `0x0205572D`, `'sdfile_fat'` `0x02055738`, `'ramfs'`
`0x0204EAEC`, `'virtual'` `0x0204EC40`).

### 2.1 norfs — the "sdfile" NOR area (med)

A tiny JieLi filesystem of **CRC'd 32-byte directory entries** directly on NOR flash:

- `norfs_fopen` `0x020286A0` — resolve path → 40 B file object (`norfs_file_obj_init`
  `0x02028220`), trailing read/write/seek/close ops;
- `norfs_path_find` `0x0202852C`, `norfs_dir_find_entry` `0x020283D0`,
  `norfs_entry_scan` `0x0202847A` (≤32 entries, crc16 + name match),
  `norfs_addr_remap` `0x020283B4`;
- FM-1 content: `mnt/sdfile/app/usr` `0x0204F0A1`, `mnt/sdfile/app/btif` `0x0204F12E`,
  `mnt/sdfile/app/cfg_tool.bin` `0x0204F33C`, `res.bin` `0x0204EC48` (UI resources,
  read through `ui_res_read` `0x020100CE` with read-ahead cache).

### 2.2 FAT12/16/32 + exFAT (FatFS-derived, extended)

| addr | name | notes | conf |
|---|---|---|---|
| `0x02029352` | `mount_volume` | parse BPB; exFAT detected via OEM field at +67 (`u32` + `'T'` byte check, `0x02029374..0x0202939C`); FAT12/16/32 by cluster count | high |
| `0x02029210` | `mount_alloc_fs` | allocate + link FATFS object, query sector count | med |
| `0x0202AEF8` | `fatfs_obj_alloc` | 812-byte filesystem work object | low |
| `0x020292FC` | `move_window` | sync then load sector into the FAT window | high |
| `0x0202C19A` | `fatfs_open` | open/create by path, truncate + exFAT handling | med |
| `0x0202CA26` | `fatfs_fopen` | mode-string (`r`/`w`/`rb`) front-end | med |
| `0x02029762` | `f_mkfs` | format: pick geometry, write BPB/FAT/root | high |
| `0x0202E1E2` | `fat_dir_walk` | recursive walk: attr filter, wildcard, callback, path stack | med |
| `0x0202FE2E` | `fat_ioctl` | **22-case** FS_IOCTL dispatcher (lfn buffers, dir info, seek) | high |
| `0x0202EC6A` | `fat_fsel` | file-select dispatcher: first/next/prev/num/path + cycle modes — the patch/bank browser primitive | high |
| `0x0202B96C` | `exfat_build_entry_set` | build 0x85/0xC0/0xC1 entries + name hash | high |
| `0x0202B7C8` / `0x0202B7F2` / `0x0202B8EA` | exfat entry-set checksum / verify / write | rotate-add checksum skipping bytes 2-3 | high/med |
| `0x0202B53A` … `0x0202BCF2` | FAT name/LFN helpers | 8.3 convert `0x0202B5E6`, LFN create `0x0202BCDE`, shortname checksum `0x0202BCBE` | high |

---

## 3. VM flash key-value store (syscfg backend)

JieLi's EEPROM-emulation "VM" layer: a ping-pong pair of flash sectors holding
append-only records, ids 0..255.

- **`vm_area_init` `0x02032140`**: gets the area from `norflash_ioctl(206)`; region
  size ≤ 8 kB or 16 kB by type; splits it in half — two sector bases at
  `[0x1C0E670+9252]` and `+9264`, half-size at `+9256`; **512-byte record offset cache**
  at `0x1C0E670+9276` (256 halfwords, one per id, `0x02032226..0x0203223C`);
  then `vm_mount_scan` `0x02027858`.
- **Sector magics**: first word of a sector is **`0x55AAAA54`** when freshly
  formatted/active and **`0xDDEEAA54`** for the retiring side
  (`0x02032294..0x020322AC`; written by `vm_sector_format` `0x0202707C`, swapped by
  `vm_garbage_collect` `0x02027112`, maintenance entry `vm_maintenance_locked`
  `0x02027292`) — conf med.
- **`vm_read` `0x0203249C`** (`id`, `buf`, `buflen`): id < 256 (`vm_id_valid`
  `0x02032490`); cached record offset `h[0x1C0E670+9276+id*2]`; active sector selected
  by state byte bit 1 (`b[0x1C0E670+9874]`); record = **4-byte header** {check byte,
  flags, 12-bit length at bits 4..15} + payload; integrity via the hardware CRC unit
  (`chip_crc16` `0x020025DA`, SFR `0x13500`), masked compare at `0x02032550`;
  errors −508/−510/−512; mutex `0x1C0E670+9788`.
- Writes: `vm_chunk_write` `0x02076B7A` (32-byte chunks through the flash device
  vtable), `vm_store_cursor_adjust` `0x02076B60`; GC relocates live records and swaps
  the ping-pong sector (`0x02027112`).
- **syscfg sits on top**: `syscfg_read` `0x02002612` / `syscfg_write` `0x020032B8`
  dispatch config items through a registered ops table (SYS, high).

---

## 4. DX7 patch storage

- The live edit buffer is the 155-byte VCED at **`0x1C0E670+5608`**.
- **`dx7voice_pack_store` `0x0201D532`** (high): packs VCED → 128-byte DX7 VMEM on the
  stack, then writes it to flash:
  - 6 ops × 21 bytes → 6 × 17 bytes with visible bit-packing (rates/levels merged,
    `0x0201D562..0x0201D5C8`); loop until 126 input bytes;
  - +9 pitch-EG bytes → VMEM+102; packed byte at +111; 4 LFO bytes at +112; packed
    sync/feedback byte at +116; +1 at +117; 10-byte name at +118 (total 128);
  - store address = `[0x1C0E670+256]` (bank base, set from board config) +
    `b[0x1C0E670+4778] << 7` (voice slot × 128), via `norflash_read` `0x02003712`
    (read-modify) + `norflash_write` `0x020037B4`, 128 bytes;
  - marker `b[0x1C0E670+5763] = 63` set first.
- The bank save UI is the menu page with string **`'  Dx7 32 Voice Save To ...  '`**
  `0x0204F3AE` — 32 voices × 128 B = one 4 kB sector per bank, matching the 0x20
  sector-erase granularity (med).
- Loading: `dx7patch_select_apply` `0x0201DAB8` — select patch: load, unpack, apply
  params, show name.

---

## 5. Firmware update (ufw / jlfs / OTA)

- **`jieli_ufw_update_run` `0x02082D24`**: allocates a 580-byte context
  (`mspace_malloc` `0x0205672E`), 1024-byte block buffer; checks the file-type magic
  (compares against **`0x5A04` / `0x5A08`** at `0x02082D84..0x02082D98`);
  `jieli_update_dispatch` `0x02083394` covers types **`0x5A02..0x5A08`**;
  `jieli_update_file_check` `0x0208332A` deletes or format-and-hangs on mismatch;
  progress callback through `[0x1C0E670+608]`.
- Package entries located from a 3-entry × 32-byte name table at `0x0204E4A4`
  (`0x02082DAC..0x02082DEE`), each name decrypted with **`jl_sfc_cipher` `0x020824FA`**
  (XOR stream, `key ^ (offset>>2)` per 32-byte block) and CRC-checked
  (`cfg_header_crc_check` `0x02026F8E`).
- Update file names (rodata `0x02082365..`): `Zedr_ota2.bin`, `Zsd_update2.bin`,
  `Zble_app_ota.bin`, `Zspp_app_ota.bin`, `Zusb_update2.bin`, `Zble_ota.bin`,
  `Zuart_user.bin`, `Znor_ota.bin`, `Znet_ota.bin`, `Zusb_hid_ota.bin` `0x02082419`,
  `ota.bin` `0x0208243A`; `LOADER.BIN` `0x02055831`.
- **jlfs** (JieLi library FS) package verify: `jlfs_entry_find_load` `0x020829F2` —
  find 32-byte entry by name, decrypt + CRC-verify payload; reader context
  `update_ctx_alloc` `0x020824AE` (104 B), `update_state_notify` `0x020824DE`.
- **OTA/update callback**: `update_state_callback` `0x02027EE2` — builds a 15-byte
  status record (leading bytes `89,48,8` …, one's-complement checksum tail) into
  `0x1C0E810+396`, posts `sys_event`, and resets on completion; the update-mode device
  path comes from `update_file_open` `0x02028998` (opens on the `'usb_update_mode'`
  `0x02055762` device, verifies entry CRCs). Firmware id string **`'FM-1_009'`**
  `0x0204F241`; ufw magic fragment `'"3DUfw'` `0x0204EF3E`.

---

## 6. Storing data from custom code — recipe

**Small config values (preferred):** go through the VM layer, exactly like syscfg does:

```c
// read:  vm_read(id, buf, buflen) -> length or <0 on error
int n = ((int (*)(int id, void *buf, int len))0x0203249C)(MY_ID, buf, sizeof buf);
```

For writes, mirror the stock path: append the record with `vm_chunk_write`
`0x02076B7A` under the VM mutex (`0x1C0E670+9788`, `os_mutex_pend` `0x0205AE98` /
`os_mutex_post` `0x0205B036`) with the same 4-byte header {check, flags, len} the
reader expects, or — simpler and safer — reuse a free syscfg item id and call
`syscfg_write` `0x020032B8`. Keep ids < 256 (`vm_id_valid` `0x02032490`); the GC will
copy your record as long as the header CRC is right.

**Blobs / patch-like data:** find a free flash region, erase with
`norflash_ioctl(erase)` or the `0x02084D4E` erase body (4 kB granularity!), then
`norflash_write` `0x020038A2`. Never write without erasing; never write across the
encrypted-region boundary (`[0x1C20190+36]`) unless you replicate the re-scramble in
`norflash_write_core` `0x0200380A`.

**Files:** on the FAT volume use `fatfs_fopen` `0x0202CA26` ("rb"/"w"), on the NOR
sdfile area use `norfs_fopen` `0x020286A0`; browse with `fat_fsel` `0x0202EC6A`.
