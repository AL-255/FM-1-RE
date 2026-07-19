/* LCD overlay driver for the FM-1 demo (device only).
 *
 * Drives the 240x240 RGB565 panel on SPI1 (base 0x11D00) directly,
 * replicating the stock lcd_spi_write_window (0x02021486) command protocol
 * (ST7789/ILI9341-class: 0x2A col, 0x2B row, 0x2C write; D/C on SFR 0x50080
 * bit7, CS on bit8). A small RGB565 overlay buffer holds the demo UI text
 * rendered with font8x16.
 */
#ifndef DEMO_LCD_H
#define DEMO_LCD_H

#include <stdint.h>

#ifdef __cplusplus
extern "C" {
#endif

/* overlay geometry: bottom strip of the 240x240 panel */
#define LCD_W        240
#define OVL_X        0
#define OVL_Y        (240 - 56)   /* 56 px tall bottom bar */
#define OVL_W        240
#define OVL_H        56

/* colors (RGB565) */
#define COL_BG       0x1082     /* dark slate */
#define COL_FG       0xFFFF     /* white */
#define COL_ACCENT   0x07FF     /* cyan */
#define COL_NOTE     0xFFE0     /* yellow */

void lcd_ovl_init(void);
void lcd_ovl_clear(void);

/* text into the overlay buffer (no SPI yet) */
void lcd_ovl_text(int x, int y, const char* s, uint16_t color);

/* push the overlay buffer to the panel (SPI) */
void lcd_ovl_flush(void);

#ifdef __cplusplus
}
#endif

#endif
