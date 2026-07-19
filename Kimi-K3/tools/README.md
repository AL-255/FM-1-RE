# Uploading the FM-1 demo firmware

## Method 1 (recommended, buttonless): M-UPGRADE official OTA

The FM-1's real update mechanism is a **MIDI-triggered OTA over USB HID** —
no UBOOT button on this device. M-Vave's **M-UPGRADE** tool drives it.

**What you need:** `build/FM-1-demo.fwsc` (already built and verified).

```bash
# rebuild if needed:
cd Kimi-K3/firmware && make
cd .. && python3 tools/build_fwsc.py     # -> build/FM-1-demo.fwsc
```

**Flash steps (Windows or macOS):**
1. Connect the FM-1 over USB (it shows as "FM-1 Midi" composite device).
2. Run **M-UPGRADE** ([M-Vave download page](https://www.m-vave.com/download)).
3. Select the FM-1 device, choose `build/FM-1-demo.fwsc`.
4. The tool sends the OTA-entry command over MIDI, the device re-enumerates
   as `ota-FM-1` (USB HID), receives the image, and flashes it. It reboots
   to normal on its own.

The `.fwsc` is structurally identical to the stock one M-UPGRADE ships (same
JLFS/UFW layout, chip key `0x980F`, correct header CRCs); only the `app.bin`
code and the demo blob inside it differ.

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

## If you want a Linux-native flash

The OTA protocol is partially reverse-engineered (see `docs/io/05-midi.md`
and the `update_cmd_dispatch 0x02026BC4` analysis: a checksummed command
protocol, cmd ids 17–48, packet = `[.., cmd, len24, payload, ~sum&0xFF]`).
A Linux client needs the OTA-entry command and the ota.bin HID transfer
protocol traced from a live M-UPGRADE session (USB capture on Windows, or
usbmon). That is a documented follow-up, not done in this session because
guessing it wrong risks a bad flash.
