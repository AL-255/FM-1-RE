# Legacy ROM/UBOOT tools

These scripts require the FM-1 to enumerate in JieLi ROM/UBOOT download mode.
No working way to enter that mode is known on the retail device, so these are
reference and recovery-development tools, not the supported update path.

`build_official.py` also predates the current blob link layout and is not a
release builder. Validate its link address, partition placement, and output on
recoverable hardware before using either flasher.

The active buttonless protocol implementation lives one directory up in
`fm1_ota.py`.
