# SlotShot Memory Map

This document summarizes the memory layout of the SlotShot game.

## Visual Memory Map

```
$0000 ┌─────────────────────────────────────────┐
      │ Zero Page                               │
      │   $02-$29: PyCo system                  │
      │   $2A-$4D: SlotShot variables (36 B)    │
      │   $4E-$56: FREE (9 bytes)               │
      │   $FB-$FE: Random state                 │
$0100 ├─────────────────────────────────────────┤
      │ CPU Stack                               │
$0200 ├─────────────────────────────────────────┤
      │ ★ RELOCATE $0200: Menu screens (99 B)   │
      │   story_screen / about / donate         │
$0263 ├ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─┤
      │ Kernal work area ($0277 kbd buffer)     │
$0400 ├─────────────────────────────────────────┤
      │ Work Buffers (free due to VIC Bank 3)   │
      │   $0400: Column blit buffer (40 B)      │
      │   $0428: Column pool (957 B)            │
      │   $07E7: FREE (~24 bytes)               │
$0801 ├─────────────────────────────────────────┤
      │ Program (code + data + BSS)             │
      │   ↓ SSP stack grows upward ↓            │
$C000 ╔═════════════════════════════════════════╗
      ║ VIC BANK 3                              ║
      ║                                         ║
      ║ $C000-$C13F: Sprite data (5×64 bytes)   ║
      ║   Block 0: Cannon ready                 ║
      ║   Block 1: Cannon fired                 ║
      ║   Block 2: Bullet                       ║
      ║   Block 3: Sparkle                      ║
      ║   Block 4: Star                         ║
      ║                                         ║
      ║ ★ RELOCATE $C140: SFX + IRQ (~600 B)    ║
      ║   sfx_play_* functions                  ║
      ║   Random.range_mask()                   ║
      ║   title_screen()                        ║
      ║   irq_screen_handler()                  ║
      ║                                         ║
      ║ $C400-$C7FF: Screen RAM (1 KB)          ║
      ║   $C7F8: Sprite pointers                ║
      ║                                         ║
      ║ $C800-$CFFF: Charset (2 KB)             ║
      ║   ROM copy + custom chars               ║
$D000 ╠═════════════════════════════════════════╣
      ║ I/O REGISTERS                           ║
      ║   VIC-II, SID, Color RAM, CIA1/2        ║
$E000 ╠═════════════════════════════════════════╣
      ║ Title bitmap (8 KB, RLE compressed)     ║
$FFFF ╚═════════════════════════════════════════╝
```

---

## Zero Page ($00-$FF)

### PyCo System (reserved)

| Addr      | Variable     | Size   | Description             |
| --------- | ------------ | ------ | ----------------------- |
| $02-$07   | tmp0-tmp5    | 6 B    | Temp registers          |
| $08-$09   | FP           | 2 B    | Frame Pointer           |
| $0A-$0B   | SSP          | 2 B    | Software Stack Pointer  |
| $0F-$10   | ZP_SELF      | 2 B    | Self pointer            |
| $13-$16   | retval       | 4 B    | Return value            |
| $1A-$1F   | irq_tmp0-5   | 6 B    | IRQ temp registers      |
| $22-$29   | LEAF_ZP      | 8 B    | O4 leaf function locals |

### User Variables ($2A-$4D, $FB-$FE)

**Bullet state:**
| Addr    | Constant             | Type   | Description                      |
| ------- | -------------------- | ------ | -------------------------------- |
| $2A     | ZP_BULLET_ACTIVE     | byte   | 0=inactive, 1=active             |
| $2B-$2C | ZP_BULLET_X          | word   | X position (16-bit)              |
| $2D     | ZP_BULLET_Y          | byte   | Y position (pixels)              |
| $2E     | ZP_BULLET_ROW        | byte   | Grid row at firing (0-9)         |
| $36     | ZP_BULLET_HIT_COL    | byte   | 255=no hit, 0-19=column          |
| $3A     | ZP_BULLET_TYPE       | byte   | 0=white, 1=yellow                |
| $3B     | ZP_NEXT_BULLET_TYPE  | byte   | Next bullet type                 |
| $3C     | ZP_YELLOW_STATE      | byte   | Yellow state machine             |
| $3D     | ZP_YELLOW_LAST_EMPTY | byte   | Last empty column found          |
| $4C-$4D | ZP_BULLET_ROW_BASE   | word   | Row offset cache (IRQ opt.)      |

**Cannon state:**
| Addr  | Constant            | Type | Description            |
| ----- | ------------------- | ---- | ---------------------- |
| $30   | ZP_CANNON_TARGET_Y  | byte | Target Y position      |
| $31   | ZP_CANNON_CURRENT_Y | byte | Current Y (animation)  |
| $32   | ZP_CANNON_ROW       | byte | Grid row (0-9)         |

**Sprite control:**
| Addr    | Constant         | Type | Description                 |
| ------- | ---------------- | ---- | --------------------------- |
| $33     | ZP_SPRITE_ENABLE | byte | Enable shadow (sprite 0-2)  |
| $38     | ZP_SPARKLE_PHASE | byte | 0=off, 1-3=animating        |
| $39     | ZP_STAR_MASK     | byte | Star sprite mask (3-7)      |
| $4A-$4B | ZP_SPARKLE_POS   | word | Screen position             |

**Input:**
| Addr  | Constant     | Type | Description              |
| ----- | ------------ | ---- | ------------------------ |
| $34   | ZP_JOY_TMP   | byte | Direction bits           |
| $37   | ZP_JOY_DELAY | byte | Frames until repeat      |

**Game state:**
| Addr    | Constant         | Type | Description           |
| ------- | ---------------- | ---- | --------------------- |
| $35     | ZP_PAUSED        | byte | 0=running, 1=paused   |
| $3E     | ZP_FRAME_COUNTER | byte | Frames since second   |
| $3F-$40 | ZP_GAME_SECONDS  | word | Elapsed seconds       |
| $49     | ZP_MENU_SELECTED | byte | Menu item (0-3)       |

**SFX (IRQ):**
| Addr    | Constant        | Type  | Description           |
| ------- | --------------- | ----- | --------------------- |
| $41     | ZP_SFX_ACTIVE   | byte  | 0=off, 1=play, 3=arp  |
| $42     | ZP_SFX_TIMER    | byte  | Remaining frames      |
| $43-$44 | ZP_SFX_FREQ     | word  | Current frequency     |
| $45     | ZP_SFX_DELTA    | sbyte | Frequency delta       |
| $46     | ZP_SFX_PHASE    | byte  | Frame counter         |
| $47     | ZP_SFX_PENDING  | byte  | Wait frames           |
| $48     | ZP_SFX_NOTE_LEN | byte  | Note length           |

**Random:**
| Addr    | Constant          | Type | Description       |
| ------- | ----------------- | ---- | ----------------- |
| $FB-$FC | RANDOM_STATE_ADDR | word | 16-bit LFSR       |
| $FD-$FE | RANDOM_WEYL_ADDR  | word | 16-bit Weyl seq   |

**Free:** $4E-$56 (9 bytes)

---

## Memory Regions

### $0200-$0262: Relocate Menu (99 bytes)

| Addr  | Size  | Function           |
| ----- | ----- | ------------------ |
| $0200 | 33 B  | `story_screen()`   |
| $0221 | 33 B  | `about_screen()`   |
| $0242 | 33 B  | `donate_screen()`  |

### $0400-$07FF: Work Buffers

This area is free because VIC Bank 3 uses $C400 for screen RAM.

| Addr        | Constant           | Size    |
| ----------- | ------------------ | ------- |
| $0400-$0427 | COLUMN_BUFFER_ADDR | 40 B    |
| $0428-$07E7 | COLUMN_POOL_ADDR   | 957 B   |
| $07E8-$07FF | -                  | 24 B    |

### $C000-$C13F: Sprite Data (320 bytes)

| Block | Addr  | Sprite         |
| ----- | ----- | -------------- |
| 0     | $C000 | Cannon Ready   |
| 1     | $C040 | Cannon Fired   |
| 2     | $C080 | Bullet         |
| 3     | $C0C0 | Sparkle        |
| 4     | $C100 | Star           |

### $C140-$C3FF: Relocate SFX/IRQ (~600 bytes)

| Function               | Type        |
| ---------------------- | ----------- |
| `sfx_play_fire()`      | function    |
| `_sfx_start_clear()`   | @irq_helper |
| `sfx_play_hit()`       | @irq_helper |
| `sfx_play_bibip()`     | function    |
| `sfx_play_slide()`     | function    |
| `Random.range_mask()`  | method      |
| `title_screen()`       | function    |
| `irq_screen_handler()` | @irq        |

### $C400-$C7FF: Screen RAM

- $C400-$C7E7: Screen (1000 bytes)
- $C7F8-$C7FF: Sprite pointers (8 bytes)

### $C800-$CFFF: Charset (2 KB)

ROM charset + custom characters:

| Char  | Addr  | Description        |
| ----- | ----- | ------------------ |
| 27-31 | $C8D8 | S/L/O letters (logo) |
| 34-42 | $C910 | O/T/H + "next" box |
| 59-63 | $C9D8 | Progress + blocks  |

### $E000-$FFFF: Title Bitmap (8 KB)

Multicolor bitmap, stored RLE compressed.

---

## I/O Registers

### VIC-II ($D000-$D02E)

| Addr  | Constant         | Description           |
| ----- | ---------------- | --------------------- |
| $D000 | SPRITE_X         | Sprite X (even)       |
| $D001 | SPRITE_Y         | Sprite Y (odd)        |
| $D010 | SPRITE_X_MSB     | X pos MSB             |
| $D011 | VIC_CTRL1        | Control 1 (ECM, DEN)  |
| $D012 | VIC_RASTER       | Raster line           |
| $D015 | SPRITE_ENABLE    | Sprite enable         |
| $D016 | VIC_CTRL2        | Control 2 (MCM)       |
| $D017 | SPRITE_EXPAND_Y  | Y expansion           |
| $D018 | VIC_MEMPTR       | Memory control        |
| $D019 | VIC_IRQ_STATUS   | IRQ status            |
| $D01A | VIC_IRQ_ENABLE   | IRQ enable            |
| $D01B | SPRITE_PRIORITY  | Priority              |
| $D01C | SPRITE_MULTICOLOR| Multicolor            |
| $D01D | SPRITE_EXPAND_X  | X expansion           |
| $D020 | BORDER           | Border color          |
| $D021 | BACKGROUND       | Background 0          |
| $D022 | VIC_BG1          | ECM background 1      |
| $D023 | VIC_BG2          | ECM background 2      |
| $D024 | VIC_BG3          | ECM background 3      |
| $D025 | SPRITE_MC1       | Sprite MC 1           |
| $D026 | SPRITE_MC2       | Sprite MC 2           |
| $D027 | SPRITE_COLOR_0   | Sprite 0 color        |

### SID Ch3 ($D40E-$D414)

| Addr  | Constant     | Description      |
| ----- | ------------ | ---------------- |
| $D40E | SID_CH3_FREQ | Freq low         |
| $D40F | -            | Freq high        |
| $D412 | SID_CH3_CTRL | Control          |
| $D413 | SID_CH3_AD   | Attack/Decay     |
| $D414 | SID_CH3_SR   | Sustain/Release  |

### Color RAM ($D800)

| Addr  | Constant | Size       |
| ----- | -------- | ---------- |
| $D800 | COLOR    | 1000 bytes |

### CIA

| Addr  | Constant   | Description         |
| ----- | ---------- | ------------------- |
| $DC00 | JOY_PORT   | Joystick 2          |
| $DC04 | CIA1_TA_LO | Timer A low         |
| $DC05 | CIA1_TA_HI | Timer A high        |
| $DC0D | CIA1_ICR   | Interrupt control   |
| $DD00 | CIA2_PRA   | VIC bank selection  |

### System

| Addr  | Constant      | Description     |
| ----- | ------------- | --------------- |
| $01   | CPU_PORT      | RAM/ROM banking |
| $A1   | JIFFY_HI_ADDR | Jiffy middle    |
| $A2   | JIFFY_LO_ADDR | Jiffy low       |
| $C6   | KBD_COUNT     | Kbd buffer cnt  |
| $0277 | KBD_BUFFER    | Kbd buffer      |
| $028A | KERNAL_RPTFLG | Key repeat      |

---

## VIC Memory Constants

| Constant            | Value | Description                 |
| ------------------- | ----- | --------------------------- |
| GAME_MEMPTR         | $12   | Screen $C400, Charset $C800 |
| TITLE_MEMPTR_TEXT   | $12   | Same (text mode)            |
| TITLE_MEMPTR_BITMAP | $18   | Screen $C400, Bitmap $E000  |

---

## Warnings

### Relocate $C140 Region Boundary

- **Max space:** $C140-$C3FF = 704 bytes
- **Used:** ~600 bytes (85%)
- **Limit:** Screen RAM starts at $C400!

If the region overflows past $C400, the code would overwrite Screen RAM!
