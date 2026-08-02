# Uploading the FM-1 demo firmware

## Method 1 (buttonless): Linux USB-MIDI OTA client

The FM-1 update is a two-stage USB-MIDI SysEx pull protocol. No UBOOT button
or HID transport is involved.

**What you need:** `build/FM-1-demo.fwsc` (already built and verified).

```bash
# rebuild if needed:
cd Kimi-K3/firmware && make
cd .. && python3 tools/build_fwsc.py     # -> build/FM-1-demo.fwsc
```

```bash
python3 tools/fm1_ota.py scan
python3 tools/fm1_ota.py flash build/FM-1-demo.fwsc
```

The client validates the handshake, serves both pull stages, accepts either
the stock OTA PID or the custom loader's reused normal PID, and reports success
only after the loader sends `0xF0000000`. It is byte-checked against the
2026-07-06 M-UPGRADE executable and offline tests, but the latest timing and
re-enumeration fixes have not been retested on hardware.

The official Windows M-UPGRADE application remains the recovery reference. Its
V14 executable embeds the stock `FM-1_014` image extracted under
`disasm_FM-1_2026_07_06_V14/`.

The `.fwsc` preserves the stock JLFS/UFW layout and chip key `0x980F`, with all
container CRCs recomputed. The builder patches `app.bin`, changes inert cfg
padding to bypass the no-op gate, and can inject the shrunken OTA loader.

## Method 2: JieLi isd_download (needs UBOOT mode — NOT available here)

`tools/upload.sh` uses JieLi's `isd_download`. It requires the device in
**UBOOT/update mode**, which on most JieLi boards is entered with a button
strap. **The FM-1 has no such button** (its update path is the OTA one
above), so this method does not work on it in practice. Kept for reference.

## Method 3: raw jl-uboot-tool (needs UBOOT mass-storage — NOT available)

`tools/flash.sh` likewise requires the UBOOT mass-storage device. Not
available on the FM-1 without the button. Kept for reference / other boards.

## After flashing

Power-cycle (or it reboots itself after OTA). The unit boots the stock UI;
the bottom LCD strip shows the demo overlay (`KEY` = physical keys held,
`MIDI` = last MIDI note + preset), and USB/UART/BLE MIDI plays the basic
synth (program change 0–3 = SAW LEAD / SQ BASS / SYNC PAD / PLUCK).

## Recovery

Re-flash the stock `FM-1.fwsc` (from M-Vave's download page) with M-UPGRADE.
The OTA loader is robust — a failed/interrupted transfer just leaves the old
firmware running, and the device stays able to enter OTA mode again.

Protocol details and current hardware limitations are documented in
`docs/io/11-ota-protocol.md` and `docs/ota-loader-shrinking.md`.
