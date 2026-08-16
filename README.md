# FM-1 firmware reverse engineering

Reverse engineering and update-protocol research for the M-Vave FM-1
synthesizer. Package, SPL, and SDK provenance identify the target as JieLi
AC791N/WL82 with a pi32v2 CPU, XIP flash at `0x02000000`, and a
Dexed/msfa-derived six-operator FM engine. The embedded `JL-BR22` string is
inherited library nomenclature, not reliable SoC identification.

This `main` branch intentionally contains no replacement firmware or custom
image builders. The former experimental implementation is preserved on the
[`with-custom-firmware`](https://github.com/AL-255/FM-1-RE/tree/with-custom-firmware)
branch.

## Repository layout

- `analysis/`: V13 disassembly, reassembly, function databases, classifications,
  raw and enriched shards, OTA loader images, and host updater decompilation.
- `docs/`: firmware characterization, architecture, subsystem teardowns,
  function indexes, and OTA protocol findings.
- `scripts/`: the unified disassembly and classification pipelines.
- `tools/`: USB-MIDI updater protocol client and offline tests.
- `ghidra/`: checked-in pi32v2 headless analysis scripts.
- `firmware-images/`: immutable V13 and V14 packages and unpacked inputs.
- `reference/`: ignored SDKs, Ghidra installation, and upstream source mirrors.
- `3rd-party/`: pinned firmware parsing and JieLi boot-tool submodules.
- `TODO_aug2.md`: AC791N boot-chain corrections and the latest open questions.

See `analysis/README.md` for the relationship between the two function-analysis
pipelines. `analysis/db.json` and `docs/function-index.md` are the current
classification outputs; the independent `function_db.json`/`master_index.json`
pipeline remains checked in for cross-validation and provenance.

## Reproduce

Run commands from the repository root:

```bash
# Low-level disassembly and independent function map
scripts/run_ghidra.sh
python3 scripts/build_funcdb.py
python3 scripts/resolve_strings.py
python3 scripts/match_libs.py
python3 scripts/build_master_index.py
python3 scripts/build_slices.py

# OTA loader extraction, vendor map, and corroborative Ghidra sweep
scripts/analyze_ota_loader.sh
scripts/run_ghidra_loader.sh

# Current enriched classification database and documentation
python3 scripts/build_db.py
scripts/disasm_toolchain_libs.sh
python3 scripts/match_libs.py
python3 scripts/mech_tag.py
python3 scripts/export_shards.py
python3 scripts/aggregate.py

# Offline OTA protocol checks
python3 -m unittest discover -s tools/tests -v
```

## Safety status

The update protocol is not a demonstrated recovery mechanism. Offline work has
not established ROM recovery, rollback, or safe interrupted-write behavior for
the single-bank layout. The console/factory-mode audit in
`analysis/device/debug-surfaces.md` found no substitute recovery entry. Read
`TODO_aug2.md` before using any update or flash utility.

## External references

- [USB_KEY | jielie](https://kagaimiq.github.io/jielie/isp/usb/usb-key.html):
  reverse-engineered notes on invoking JieLi USB boot using a signal on D+/D-,
  including the key waveform, acknowledgement, timing, and USB bus caveats.
- [JL SoC forum thread](https://esp8266.ru/forum/threads/jl-soc.5500/):
  long-running Russian community discussion of JieLi SoCs, SDKs, toolchains,
  programmers, boot activators, and USB/ISP/UART key experiments. Reports are
  community observations and may apply only to the chip family being discussed.
- [SMK-37 Pro community notes](https://gist.github.com/probonopd/18b3ed65a69d0229eb630c47d7e316dc):
  observations about a related M-Vave/JieLi keyboard that may help identify
  shared packaging, update, and hardware conventions.
- [kagaimiq/jl-misctools](https://github.com/kagaimiq/jl-misctools)
  (`3rd-party/jl-misctools`, also checked out at `../jl-misctools`): utilities
  for JieLi firmware containers, key files, UI resources, and older formats.
- [kagaimiq/jl-uboot-tool](https://github.com/kagaimiq/jl-uboot-tool)
  (`3rd-party/jl-uboot-tool`): Python tooling for discovering UBOOT devices,
  loading code into RAM, and reading, writing, or erasing flash. Its support
  table lists WL82/AC791N as unknown, so it is not an established FM-1 flasher.
- [Jieli-Tech/fw-AC79_AIoT_SDK](https://gitee.com/Jieli-Tech/fw-AC79_AIoT_SDK)
  (`../fw-AC79_AIoT_SDK`): official AC791N/WL82 SDK containing peripheral and
  MaskROM API headers, boot/update configuration, libraries, build tools, and
  application examples used to identify stock firmware behavior.
