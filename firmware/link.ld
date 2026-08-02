/* Link layout for the FM-1 demo blob.
 *
 * The blob is appended to app.bin in flash and runs XIP at DEMO_XIP_BASE;
 * its read-write data lives in a free RAM gap (stock .bss ends 0x01C211FC,
 * boot hwinfo struct is at 0x01C7FD50 — we sit clear between them).
 *
 * Flat image layout (what objcopy emits, what we append to app.bin):
 *   [ .text | .rodata | .data image ]
 * .data runs from RAM: demo_install() copies it from __data_lma and zeroes
 * .bss before doing anything else.
 */
OUTPUT_FORMAT("elf32-pi32v2")
OUTPUT_ARCH(pi32v2)
ENTRY(demo_install)

DEMO_XIP_BASE = 0x02046600;   /* inside app.bin's font/bitmap region (raw, XIP-mapped) */
DEMO_RAM_BASE = 0x01C30000;

MEMORY {
  XIP (rx)  : ORIGIN = DEMO_XIP_BASE, LENGTH = 64K
  RAM (rwx) : ORIGIN = DEMO_RAM_BASE, LENGTH = 192K
}

SECTIONS {
  .text DEMO_XIP_BASE : {
    KEEP(*(.text.demo_tramp))
    KEEP(*(.text.demo_entry))
    *(.text)
    *(.text.*)
  } > XIP
  .rodata : {
    *(.rodata)
    *(.rodata.*)
    . = ALIGN(4);
  } > XIP

  . = ALIGN(4);
  __data_lma = .;                       /* flash offset of the .data image */
  .data DEMO_RAM_BASE : AT(__data_lma) {
    __data_start = .;
    *(.data)
    *(.data.*)
    . = ALIGN(4);
    __data_end = .;
  } > RAM
  .bss (NOLOAD) : {
    __bss_start = .;
    *(.bss)
    *(.bss.*)
    *(COMMON)
    . = ALIGN(8);
    __bss_end = .;
  } > RAM
  . = ALIGN(8);
  __heap_start = .;
  __heap_end = DEMO_RAM_BASE + 192K - 4;
  /DISCARD/ : { *(.comment) *(.note*) *(.eh_frame*) }
}
