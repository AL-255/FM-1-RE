/* LCD overlay driver — device implementation (pi32v2 + stock hardware).
 * Host builds get a no-op stub at the bottom. */
#include "lcd.h"

#ifdef __pi32v2__

#include "font8x16.h"
#include "rt.h"

#define SPI1_CON  (*(volatile unsigned*)0x11D00)
#define SPI1_TXB  (*(volatile unsigned*)0x11D08)
#define SPI1_DADR (*(volatile unsigned*)0x11D0C)
#define SPI1_DLEN (*(volatile unsigned*)0x11D10)
#define LCD_DCCS  (*(volatile unsigned*)0x50080)

static uint16_t ovl_buf[OVL_W * OVL_H];

static void spi_wait(void) {
  while ((SPI1_CON & 0x8000) == 0) {}
  SPI1_CON |= 0x4000;                       /* PCLR */
}

static void dc_cmd_byte(uint8_t c) {
  LCD_DCCS &= ~0x100u;                      /* CS low  */
  LCD_DCCS &= ~0x80u;                       /* D/C cmd */
  SPI1_TXB = c;
  spi_wait();
}

static void dc_data_hdr(void) {
  LCD_DCCS |= 0x80u;                        /* D/C data */
  LCD_DCCS |= 0x100u;
  LCD_DCCS &= ~0x80u;
}

static void dc_data_dma(const void* p, int len) {
  SPI1_DADR = (unsigned)p;
  SPI1_DLEN = (unsigned short)len;
  spi_wait();
}

/* window write: (x0,y0)-(x1,y1), pixels = RGB565 big-endian-on-wire.
 * The panel wants big-endian; our buffer is little-endian, so we swap on
 * the fly into 40-byte chunks (mirrors the stock DMA pacing). */
static void lcd_window(int x0, int y0, int x1, int y1, const uint16_t* pix, int npix) {
  uint8_t col[4] = { (uint8_t)(x0 >> 8), (uint8_t)x0, (uint8_t)(x1 >> 8), (uint8_t)x1 };
  uint8_t row[4] = { (uint8_t)(y0 >> 8), (uint8_t)y0, (uint8_t)(y1 >> 8), (uint8_t)y1 };
  static uint8_t chunk[40];
  int done = 0;

  dc_cmd_byte(0x2A); dc_data_hdr(); dc_data_dma(col, 4); LCD_DCCS |= 0x80u;
  dc_cmd_byte(0x2B); dc_data_hdr(); dc_data_dma(row, 4); LCD_DCCS |= 0x80u;
  dc_cmd_byte(0x2C);

  LCD_DCCS |= 0x80u;
  unsigned r4 = LCD_DCCS | 0x100u;
  LCD_DCCS = r4;
  LCD_DCCS &= ~0x80u;
  while (done < npix) {
    int n = npix - done;
    if (n > 20) n = 20;                     /* 20 px = 40 bytes per burst */
    for (int i = 0; i < n; i++) {
      uint16_t v = pix[done + i];
      chunk[2 * i] = (uint8_t)(v >> 8);
      chunk[2 * i + 1] = (uint8_t)v;
    }
    SPI1_DADR = (unsigned)chunk;
    SPI1_DLEN = 2 * n;
    spi_wait();
    LCD_DCCS |= 0x80u;
    done += n;
  }
  LCD_DCCS &= ~0x100u;
}

void lcd_ovl_init(void) { lcd_ovl_clear(); }

void lcd_ovl_clear(void) {
  for (int i = 0; i < OVL_W * OVL_H; i++) ovl_buf[i] = COL_BG;
}

void lcd_ovl_text(int x, int y, const char* s, uint16_t color) {
  for (; *s; s++, x += 8) {
    if (x < 0 || x >= OVL_W || y < 0 || y > OVL_H - 16) continue;
    unsigned char c = (unsigned char)*s;
    if (c < 32 || c > 126) c = '?';
    const unsigned char* g = font8x16[c - 32];
    for (int r = 0; r < 16; r++) {
      uint16_t* line = &ovl_buf[(y + r) * OVL_W + x];
      unsigned char bits = g[r];
      for (int b = 0; b < 8; b++)
        if (bits & (0x80 >> b)) line[b] = color;
    }
  }
}

void lcd_ovl_flush(void) {
  lcd_window(OVL_X, OVL_Y, OVL_X + OVL_W - 1, OVL_Y + OVL_H - 1, ovl_buf, OVL_W * OVL_H);
}

#else  /* host build: keep the linker happy */
void lcd_ovl_init(void) {}
void lcd_ovl_clear(void) {}
void lcd_ovl_text(int x, int y, const char* s, uint16_t color) {
  (void)x; (void)y; (void)s; (void)color;
}
void lcd_ovl_flush(void) {}
#endif
