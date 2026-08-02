# Device OTA loader images

These are the outer `ota.bin` images served to the normal-mode application's
step-1 verifier. The inner LZ4 stream expands to a 23324-byte pi32v2 executable
loaded at `0x01C0A800`.

- `ota_stock.bin`: byte-exact loader from the V13 and V14 stock packages.
- `ota_patched2.bin`: same-size experimental image with an inert decompressed
  data byte changed and all nested CRC fields repaired.

Neither image demonstrates a successful custom flash. Current hardware tests
with a shrunken loader ended at `0xE0000000` and never reached the loader's
`0xF0000000` commit handshake. See `docs/ota-loader-shrinking.md` and the root
`TODO_Aug1.md` before attempting device updates.
