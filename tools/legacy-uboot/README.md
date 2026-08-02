# Legacy ROM/UBOOT tools

These scripts require the FM-1 to enumerate in JieLi ROM/UBOOT download mode.
No working way to enter that mode is known on the retail device, so these are
reference and recovery-development tools, not the supported update path.

The package identifies the target as AC791N/WL82. Earlier versions of these
scripts defaulted to BR22, but that family selection is unsupported evidence
and can be destructive. Device operations now fail closed unless the caller
sets `FM1_ALLOW_UNVERIFIED_ROM_FLASH=AC791N` and supplies explicit verified
chip, boot-offset, and flash-size parameters as applicable. Running
`upload.sh` without an argument now builds only; it cannot flash an attached
device implicitly.

`build_official.py` also predates the current blob link layout and is not a
release builder. Validate its link address, partition placement, and output on
recoverable hardware before using either flasher.

The active buttonless protocol implementation lives one directory up in
`fm1_ota.py`.
