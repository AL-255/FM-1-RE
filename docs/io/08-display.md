# 08 — Display: 240×240 SPI LCD, ui_core framework, FM-1 menu

Target: M-Vave FM-1, JieLi AC791N/WL82. The UI is JieLi's element-tree UI framework
("ui_core"): 64-byte elements with attribute lists, a layout/scroll engine, an
RGB565 layer compositor, and a strip-buffered flush path to the LCD over SPI1.
Confidence tags: **high** = proven from disassembly, **med** = strong inference,
**low** = guess.

Primary evidence: `analysis/shards/shard_0201f0d0_020223ba.txt` (LCD driver, page
builders), `shard_02022c7a_02027292.txt` (`usr_app_task` LCD init),
`shard_0200c236_02012d04.txt` (redraw/flush, msg dispatcher),
`shard_020096f8_0200c18a.txt` (layout/scroll), `shard_02012dcc_02018c62.txt`
(font/text/menu handlers), `shard_02018c84_02019e6a.txt` (sprintf).

---

## 1. Display hardware

**Panel: 240×240 RGB565 TFT on SPI1 (SFR base `0x11D00`)** — high.

> Note: an earlier project memo said "SPI2 (0x11E00)". The disassembly shows the whole
> LCD path (init script, window set, pixel push) on **0x11D00 = SPI1**. `board_init`
> also pokes SPI2 (`[0x11E00] = 0x6020; [0x11E00+4] = 0x1D`, then a 2-byte transfer),
> which is a *different* device/aux path (purpose unconfirmed, **low**).

SPI register usage (jielie `spi.md`: CON+0, TX byte +8, DMA addr +12, DMA len +16;
CON bit15 PND, bit14 PCLR, bit13 IE):

| Step | Evidence | conf |
|---|---|---|
| `usr_app_task` `0x02022CFE` writes `[0x11D00] = 0x4020; [0x11D00+4] = 4` | `0x02022F2E..0x02022F3E` | high |
| LCD init script: 21 records × 18 bytes at `0x0204EA00+0x165C` = **`0x0205005C`**: `b+0` = cmd, `b+1` = len, payload `+2`; bitmask `0xFFFDE` marks cmds with data; 100/120 ms delays | `0x02022F46..0x02022FC0` | high |
| Command/data select + CS via SFR **`0x50080`** bits 7 (0x80) and 8 (0x100), toggled around every byte/DMA burst | `lcd_spi_write_window` `0x02021486`, init loop | med |
| GPIO 39 in, GPIO 40/41/42 out-low during LCD init (reset/backlight candidates) | `0x02022F02..0x02022F2A` | med |
| **`lcd_spi_write_window` `0x02021486`**: sends `2Ah` (col), `2Bh` (page), `2Ch` (write), pushes 240×240×2 = 115200 B in 40-byte DMA bursts (2880 bursts), then `29h` (display on) | shard_0201f0d0 | high |
| Standard ST7789/ILI9341-style command set → panel class confirmed by 2A/2B/2C/29 | — | med |

IRQ wiring: `board_init` `0x0200417E` registers **irq 37** (prio 5, RAM handler
`0x01C045F6`) and **irq 122** (prio 4, RAM handler `0x01C0470C`) via `request_irq`
`0x020016D2` — both next to the SPI display setup (LCD DMA-done / TE candidates,
**med**). `usr_app_task` additionally registers **irq 16** (RAM handler `0x01C034E4`)
right after LCD init and **irq 20** → `0x02027F4E` (`0x02022FD6`, `0x02022D26`).

### Framebuffer geometry (high)

Set up in `usr_app_task` `0x02022FDC..0x0202301E`:

- two RGB565 **strip buffers** `0x1C16F4C` and `0x1C19C4C`, `0x2D00` = 11520 bytes each
  = 240×24 pixels — the screen is flushed in 24-row strips (10 strips/frame);
- fb/layer control struct at `0x1C16F30` (`[+12] = 0x1680` stride-ish, buffer ptrs at +0/+4);
- **LCD device struct at `0x1C1C94C`** (76 bytes, `lcd_device_init` `0x020215A0`):
  `h[+0] = 240` (width), `h[+2] = 240` (height), `[+12] = 0x1C16F30` (fb struct),
  `[+20] = 0x0201899C` (pixel-push callback), `[+60]/[+64] = 0x0201096E` (draw
  callback, inside `ui_draw_line_setup` `0x020108A6` region);
- `lcd_pipeline_init` `0x0202160A` allocates the framebuffers (via `[dev+68]` alloc
  hook), links the device into the UI context list at `[0x01C0E670+176]`, and
  registers the deferred flush via `deferred_call_schedule` `0x02021444`.

---

## 2. The ui_core framework stack

Bottom-up, with the addresses that matter:

| layer | function | purpose | conf |
|---|---|---|---|
| element | `ui_element_init_defaults` `0x02009494` | zero 64-byte element, defaults (`[+40]=500` anim ms, `[+36]=100` alpha?, `[+24]=0x02017568` default handler, `h[+60]=1`) | med |
| element | `ui_core_register_element` `0x0200965C` | clone 64-byte element template, link into registry | low |
| element | `ui_element_msg_handler` `0x0200C262` | central dispatcher: id = `[msg+8] & 0x7F`, **41 message ids** via `tbh` jump table (draw/key/focus/style/scroll) | med |
| attr | `prop_value_resolve` `0x02007A20` | read u16 attr id (e.g. `0x1000`,`0x1032`,`0x1810..0x1813`,`0x27D0`) from element attr list | low |
| hit | `ui_element_hit_search` `0x0200D274` | deepest element under point, used by redraw/key routing | med |
| layout | `ui_elm_layout_arrange` `0x0200ACD0` | measure + arrange children, updates rect, recursion `ui_elm_relayout_tree` `0x0200B546`, dirty pass `ui_layout_flush` `0x0200B59C` | med |
| scroll | `ui_scroll_to_offset` `0x0200A684` | scroll dx,dy with 200–400 ms animation; clamp/rebound `0x0200A7D0`, content extents `0x02009D2C`/`0x02009ED0`, scrollbars `0x02009FC8`/`0x0200A5AE` | med |
| redraw | `ui_core_redraw` `0x0200EF3A` | entry: merge dirty rects → `ui_core_redraw_tree` `0x0200E980` / draw walk `0x0200E898` → layer flush | med |
| flush | `ui_layer_flush` `0x0200EA02` | dirty-rect + flip/rotate transform (mode bits in ctx: horizontal mirror loop at `0x0200EAD0` swaps RGB565 halfwords) → LCD push callback | med |
| blit | `ui_draw_arc_blit` `0x020109E4` (8616 B) | AA arc fill + packed-image blit with RGB565 blending; line setup `ui_draw_line_setup` `0x020108A6` | med |
| blit | `draw_image_blend` `0x02012E96` | blit/blend image spans to RGB565 with alpha; `ui_image_get_pixel` `0x02012D04`, `image_get_pixel` `0x02012DCC` (1/2/4/8-bpp unpack) | high |
| font | `font_glyph_lookup` `0x02017008` | glyph cache `[font+20]`, walks 20-byte range records, 4 encodings via `tbb`; rodata font bitmaps at `0x0204D35C..0x0204D732+` | med |
| font | `font_char_width` `0x0200D46A`, `font_text_wrap_width` `0x0200D4AC`, `font_text_line_width` `0x0200D7FC`, `font_text_extent` `0x0200D8E0` | measuring/wrap | med |
| utf8 | `utf8_2_unicode_one` `0x0200D388`, `utf8_sequence_length` `0x02017554`, `utf8_char_count` `0x02017582`, `utf8_prev_char` `0x02017656`, `utf8_strlen` `0x0200D99C` | UTF-8 decode | high |
| text | `ui_text_set_str` `0x02017F22` | widget text ptr at `elm+36`, flag bit3 at `elm+72` = static; frees old (`0x020080D4`), `strlen`+`malloc`+`strcpy` new, then `ui_core_redraw` `0x02008966` | high |
| text | `ui_text_layout_update` `0x0201797C`, `ui_text_set_scroll_mode` `0x02017E6A`, `ui_text_align_layout` `0x020223BA` | ellipsis, scroll anim, alignment | med |
| printf | `sprintf_putc` `0x02018D08` … `vsprintf` `0x02019408` (`sprintf_itoa` `0x02018D7A`, `sprintf_lltoa` `0x02018E18`) | in-house sprintf used for all value formatting | high |

### Element struct (64 bytes) — key offsets (med)

| offset | field |
|---|---|
| `+4` | first child (child list; `[elm+4]` walked by layout) |
| `+20,+22` | rect x, y (halfwords, signed) |
| `+24,+26` | rect w, h (halfwords) |
| `+28` | attr/aux list head (`r4 = elm + 28` throughout the msg handler) |
| `+36` | text string pointer (text widgets) / alpha default 100 |
| `+40` | animation duration default 500 |
| `+60..+62` | state/flags halfwords |

Rect at `+20..+26` is proven by `ui_elm_content_rect_get` `0x02009E36` and the layout
engine `0x0200ACD0` (`h[r9+20]`, `h[r9+24]`).

---

## 3. The FM-1 menu on top of ui_core

- Page instances are **488-byte** structs (`ui_page_build` `0x02022020`, malloc
  `0x020057F9E`); current page id at `b[0x01C0E670+23]`, page event-handler table at
  **`0x0204F50C`** (= `0x0204EA00+2828`) — see 07-input.md §5.2.
- `ui_synth_page_build` `0x0202182C` — main synth page (six operator buttons), built
  once at startup (`usr_app_task` `0x02023022`).
- `menu_param_rows_redraw` `0x0202558A` — redraws 4 param name/value rows:
  - param id ≤ 125 → name from the **per-operator table `0x0204FA68`** (= `0x0204EA00+4200`),
    21 entries, indexed `id % 21` (6 ops × 21 params = 126);
  - param id 126..144 → **global table `0x0204F824`** (= `0x0204EA00+3620`), 19 entries;
  - row title strings via `0x0204EA00+728` = `0x0204ECD8`.
- DX7 param name strings live at **`0x02055401..0x020554BF`**: `Algorithm`, `Feedback`,
  `Osc Sync`, `Speed`, `Lfo Sync`, `Wave`, `Pitch Sens`, `Transpose`, `BreakPoint`,
  `L Depth`, `R Depth`, `L Curve`, `R Curve`, `RateScale`, `A ModSens`, `KeyVelocity`,
  `Out Level`, `OscMode`, `FreqCoarse`, `FreqFine`, `Detune` (verified by ASCII dump
  of `app.bin`).
- **Effects string-pointer table `0x0204F90C`** (16 u32 entries, near-duplicate copy at
  `0x0204F948` — two FX slots, **med**): points into the block `Preset` `0x02055501`,
  `Saved` `0x02055508`, `Filter` `0x0205550E`, `Reverb` `0x02055515`, `Delay`
  `0x0205551C`, `Distortion` `0x02055522`, `Chorus` `0x0205552D`, `Phaser` `0x02055534`,
  `Room` `0x0205553B`, `Hall` `0x02055540`, `Plate` `0x02055545`, `Low Pass`
  `0x0205554B`, `Band Pass` `0x02055554`, `High Pass` `0x0205555E`. Several entries
  point at intra-string offsets (e.g. `0x02055509`→"aved"); consistent with
  suffix-merged strings or scroll offsets — treat exact per-slot mapping as **low**.
- `menu_page_value_redraw` `0x0202510E` — 4-field value page with formatted text.
- **`ui_value_edit_handler` `0x02018958`** — the settings/param editor: consumes
  class-`0x07` encoder events (`r1 == 0x07000000` at `0x0201897E`), encoder id 0 =
  button (toggles `b[elm+21]` from event bit 15), ids ≤ 5 edit `b[param+10]` via
  `clamp_add_range` `0x020188BE` against limit `b[param+6]`, then refreshes widgets
  2/3/4 through `ui_dirty_slot_mark` `0x020188A0`.
- Value strings formatted with the in-house sprintf (`%d%%`, `%03d`, `%s%d` formats in
  the `0x0204EAxx` string block).

---

## 4. Recovered display interfaces

`ui_core_register_element 0x0200965C` registers 64-byte element records whose
rectangle halfwords occupy offsets `+20..+26`. `ui_text_set_str 0x02017F22`
updates a text element, and `ui_widget_invalidate 0x02018C9C` schedules it for
the next `ui_core_redraw 0x0200EF3A` pass.

The renderer uses alternating RGB565 strip buffers at `0x01C16F4C` and
`0x01C19C4C`, each 240×24 pixels. The layer at `0x01C16F30` selects the active
strip, and `ui_layer_flush 0x0200EA02` transfers its dirty rectangle. There is
no full-screen framebuffer in RAM. `lcd_spi_write_window 0x02021486` is the
direct full-panel SPI1 path and emits commands `2A`, `2B`, `2C`, and `29`
around a 115200-byte RGB565 transfer **[med]**.
