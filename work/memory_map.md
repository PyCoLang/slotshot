# SlotShot Memory Map

Ez a dokumentum összefoglalja az összes mappelt memóriacímet a slotshot.pyco fájlban.

## Összefoglaló

| Régió                | Kezdet     | Vége   | Méret    | Cél                              |
| -------------------- | ---------- | ------ | -------- | -------------------------------- |
| CPU Port             | $01        | $01    | 1 byte   | RAM/ROM banking                  |
| Zero Page - User     | $2A        | $4B    | 34 byte  | Játék ZP változók                |
| Zero Page - Random   | $FB        | $FE    | 4 byte   | LFSR + Weyl                      |
| Jiffy Clock          | $A1        | $A2    | 2 byte   | Időzítés                         |
| Kernal               | $C6, $028A | -      | 2 byte   | Keyboard                         |
| **Relocate $0200**   | $0200      | $0262  | 99 byte  | Menu screen függvények           |
| Work Buffer          | $0400      | $06A7  | 680 byte | Column buffer + pool             |
| **Relocate $C140**   | $C140      | ~$C3A0 | ~610 byte| SFX + IRQ + title_screen         |
| Sprite Data          | $C000      | $C13F  | 320 byte | 5 sprite (64 byte/sprite)        |
| Screen RAM           | $C400      | $C7FF  | 1 KB     | Screen + sprite pointers         |
| Charset              | $C800      | $CFFF  | 2 KB     | ROM copy + custom chars          |
| I/O                  | $D000      | $DFFF  | 4 KB     | VIC, SID, CIA                    |
| Title Bitmap         | $E000      | $FFFF  | 8 KB     | Multicolor bitmap                |

---

## Zero Page ($00-$FF)

### PyCo Rendszer (NE HASZNÁLD!)
| Cím     | Változó    | Méret  | Leírás                  |
| ------- | ---------- | ------ | ----------------------- |
| $02-$07 | tmp0-tmp5  | 6 byte | Temp regiszterek        |
| $08-$09 | FP         | 2 byte | Frame Pointer           |
| $0A-$0B | SSP        | 2 byte | Software Stack Pointer  |
| $0F-$10 | ZP_SELF    | 2 byte | Self pointer            |
| $13-$16 | retval     | 4 byte | Return value            |
| $1A-$1F | irq_tmp0-5 | 6 byte | IRQ temp regiszterek    |
| $22-$29 | LEAF_ZP    | 8 byte | O4 leaf function locals |

### Felhasználói Zero Page ($2A-$56)

| Cím     | Konstans név         | Méret          | Leírás                          |
| ------- | -------------------- | -------------- | ------------------------------- |
| $2A     | ZP_BULLET_ACTIVE     | 1 byte         | 0=inactive, 1=active            |
| $2B-$2C | ZP_BULLET_X          | 2 byte (word)  | Bullet X pozíció (16-bit)       |
| $2D     | ZP_BULLET_Y          | 1 byte         | Bullet Y pozíció (pixels)       |
| $2E     | ZP_BULLET_HIT        | 1 byte         | 0=flying, 1=hit                 |
| $2F     | ZP_BULLET_ROW        | 1 byte         | Grid row at firing (0-9)        |
| $30     | ZP_CANNON_TARGET_Y   | 1 byte         | Target Y pozíció                |
| $31     | ZP_CANNON_CURRENT_Y  | 1 byte         | Current Y pozíció               |
| $32     | ZP_CANNON_ROW        | 1 byte         | Cannon grid row (0-9)           |
| $33     | ZP_SPRITE_ENABLE     | 1 byte         | Sprite enable shadow            |
| $34     | ZP_JOY_TMP           | 1 byte         | Direction bits                  |
| $35     | ZP_PAUSED            | 1 byte         | 0=running, 1=paused             |
| $36     | ZP_BULLET_HIT_COL    | 1 byte         | Grid column of collision        |
| $37     | ZP_JOY_DELAY         | 1 byte         | Frames until repeat             |
| $38     | ZP_SPARKLE_PHASE     | 1 byte         | 0=off, 1-3=animating            |
| $39     | ZP_STAR_MASK         | 1 byte         | Star sprite enable mask         |
| $3A     | ZP_BULLET_TYPE       | 1 byte         | 0=white, 1=yellow               |
| $3B     | ZP_NEXT_BULLET_TYPE  | 1 byte         | Next bullet type                |
| $3C     | ZP_YELLOW_STATE      | 1 byte         | Yellow bullet state machine     |
| $3D     | ZP_YELLOW_LAST_EMPTY | 1 byte         | Last empty column found         |
| $3E     | ZP_FRAME_COUNTER     | 1 byte         | Frames since last second (0-59) |
| $3F-$40 | ZP_GAME_SECONDS      | 2 byte (word)  | Total elapsed seconds           |
| $41     | ZP_SFX_ACTIVE        | 1 byte         | 0=off, 1=playing, 3=arpeggio    |
| $42     | ZP_SFX_TIMER         | 1 byte         | Remaining notes/frames          |
| $43-$44 | ZP_SFX_FREQ          | 2 byte (word)  | Current frequency               |
| $45     | ZP_SFX_DELTA         | 1 byte (sbyte) | Frequency delta                 |
| $46     | ZP_SFX_PHASE         | 1 byte         | Frame counter within note       |
| $47     | ZP_SFX_PENDING       | 1 byte         | Frames to wait                  |
| $48     | ZP_SFX_NOTE_LEN      | 1 byte         | Note length in frames           |
| $49     | ZP_MENU_SELECTED     | 1 byte         | Selected menu item (0-3)        |
| $4A-$4B | ZP_SPARKLE_POS       | 2 byte (word)  | Sparkle screen pos (IRQ valid.) |

**Szabad ZP terület:** $4C-$56 (11 byte)

### Random State
| Cím     | Konstans név      | Méret         | Leírás               |
| ------- | ----------------- | ------------- | -------------------- |
| $FB-$FC | RANDOM_STATE_ADDR | 2 byte (word) | 16-bit LFSR state    |
| $FD-$FE | RANDOM_WEYL_ADDR  | 2 byte (word) | 16-bit Weyl sequence |

---

## Low Memory ($0000-$07FF)

### CPU/System
| Cím   | Konstans név  | Méret   | Leírás                  |
| ----- | ------------- | ------- | ----------------------- |
| $01   | CPU_PORT      | 1 byte  | RAM/ROM banking         |
| $A1   | JIFFY_HI_ADDR | 1 byte  | Jiffy clock middle byte |
| $A2   | JIFFY_LO_ADDR | 1 byte  | Jiffy clock low byte    |
| $C6   | KBD_COUNT     | 1 byte  | Keyboard buffer count   |
| $0277 | KBD_BUFFER    | 10 byte | Keyboard buffer         |
| $028A | KERNAL_RPTFLG | 1 byte  | Key repeat flag         |

### Relocate Region $0200-$0262 (CPU Stack Area)

**Régió mérete:** 99 byte ($0063) - forrás: `slotshot.dbg`

| Cím   | Méret | Függvény         | Leírás                          |
|-------|-------|------------------|---------------------------------|
| $0200 | 33 B  | `story_screen()` | Story menüpont kezelése         |
| $0221 | 33 B  | `about_screen()` | About menüpont kezelése         |
| $0242 | 33 B  | `donate_screen()`| Donate menüpont kezelése        |

**Régió vége:** $0263

⚠️ **Figyelem:** Ez a CPU stack területe ($0100-$01FF) FELETT van, de a Kernal work area-ban ($0200-$02FF). Biztonságos, ha a Kernal nem használja ezt a részt.

### Work Buffers ($0400-$07FF)
Ez a terület a VIC Bank 3 miatt szabad (screen RAM = $C400).

| Cím         | Konstans név       | Méret    | Leírás                        |
| ----------- | ------------------ | -------- | ----------------------------- |
| $0400-$0427 | COLUMN_BUFFER_ADDR | 40 byte  | Column blit buffer            |
| $0428-$06A7 | COLUMN_POOL_ADDR   | 640 byte | Pre-generated column patterns |
| $06A8-$07FF | -                  | 344 byte | **SZABAD**                    |

---

## VIC Bank 3 ($C000-$FFFF)

### Sprite Data ($C000-$C13F)

| Cím         | Block | Méret   | Leírás              |
| ----------- | ----- | ------- | ------------------- |
| $C000-$C03F | 0     | 64 byte | Cannon Ready sprite |
| $C040-$C07F | 1     | 64 byte | Cannon Fired sprite |
| $C080-$C0BF | 2     | 64 byte | Bullet sprite       |
| $C0C0-$C0FF | 3     | 64 byte | Sparkle sprite      |
| $C100-$C13F | 4     | 64 byte | Star sprite         |

**Konstansok:**
- `SPRITE_DATA_ADDR = 0xC000`
- `CANNON_BLOCK_READY = 0`
- `CANNON_BLOCK_FIRED = 1`
- `BULLET_BLOCK = 2`
- `SPARKLE_BLOCK = 3`
- `STAR_BLOCK = 4`

### Relocate Functions ($C140-$C3FF)

**Régió mérete:** ~610 byte (újrafordítás után frissül) - forrás: `slotshot.dbg`

| Cím   | Méret  | Függvény               | Típus       | Leírás                     |
|-------|--------|------------------------|-------------|----------------------------|
| $C140 | 68 B   | `sfx_play_fire()`      | function    | Lövés hangeffekt           |
| $C184 | 70 B   | `_sfx_start_clear()`   | @irq_helper | Clear hang indítása        |
| $C1CA | 62 B   | `sfx_play_hit()`       | @irq_helper | Találat hangeffekt         |
| $C208 | 70 B   | `sfx_play_bibip()`     | function    | Countdown bi-bip hang      |
| $C24E | 62 B   | `sfx_play_slide()`     | function    | Cannon slide hang          |
| $C28C | 63 B   | `Random.range_mask()`  | method      | Random szám maszkolás      |
| $C2CB | 140 B  | `title_screen()`       | function    | Title screen inicializáció |
| $C3?? | ~74 B  | `irq_screen_handler()` | @irq        | Title screen raster IRQ    |

**Megjegyzés:** Pontos címek újrafordítás után a `slotshot.dbg`-ből olvashatók.

**Szabad terület:** Újrafordítás után ellenőrizd, hogy elfér-e!

### Screen RAM ($C400-$C7FF)
| Cím         | Konstans név        | Méret     | Leírás            |
| ----------- | ------------------- | --------- | ----------------- |
| $C400-$C7E7 | SCREEN              | 1000 byte | Screen characters |
| $C7F8-$C7FF | SPRITE_POINTER_BASE | 8 byte    | Sprite pointers   |

### Charset ($C800-$CFFF)
| Cím         | Konstans név | Méret     | Leírás                     |
| ----------- | ------------ | --------- | -------------------------- |
| $C800-$CFFF | CHARSET_RAM  | 2048 byte | ROM charset + custom chars |

**Custom Character Overlays:**

| Cím   | Char | Leírás       |
| ----- | ---- | ------------ |
| $C8D8 | 27   | S top        |
| $C8E0 | 28   | S bottom     |
| $C8E8 | 29   | L top        |
| $C8F0 | 30   | L bottom     |
| $C8F8 | 31   | O top        |
| $C910 | 34   | O bottom     |
| $C918 | 35   | T top        |
| $C920 | 36   | T bottom     |
| $C928 | 37   | H top        |
| $C930 | 38   | H bottom     |
| $C938 | 39   | "next" TL    |
| $C940 | 40   | "next" TR    |
| $C948 | 41   | "next" BL    |
| $C950 | 42   | "next" BR    |
| $C9D8 | 59   | Progress bar |
| $C9E0 | 60   | Block TL     |
| $C9E8 | 61   | Block TR     |
| $C9F0 | 62   | Block BL     |
| $C9F8 | 63   | Block BR     |

### I/O Area ($D000-$DFFF)
Nem használható RAM-ként (VIC, SID, CIA regiszterek).

A játék $D000-ra hivatkozik `CHAR_ROM` konstansként is, de ez csak akkor érhető el, ha az I/O ki van kapcsolva.

### Title Bitmap ($E000-$FFFF)
| Cím         | Konstans név | Méret     | Leírás              |
| ----------- | ------------ | --------- | ------------------- |
| $E000-$FFFF | BITMAP_ADDR  | 8192 byte | Title screen bitmap |

---

## I/O Regiszterek ($D000-$DFFF)

### VIC-II ($D000-$D02E)

| Cím   | Konstans név      | Leírás                            |
| ----- | ----------------- | --------------------------------- |
| $D000 | SPRITE_X          | Sprite 0-7 X pos (even addresses) |
| $D001 | SPRITE_Y          | Sprite 0-7 Y pos (odd addresses)  |
| $D010 | SPRITE_X_MSB      | X pos MSB for all sprites         |
| $D011 | VIC_CTRL1         | Control reg 1 (ECM, raster MSB)   |
| $D012 | VIC_RASTER        | Raster line register              |
| $D015 | SPRITE_ENABLE     | Sprite enable                     |
| $D016 | VIC_CTRL2         | Control reg 2 (scroll, 40/38 col) |
| $D017 | SPRITE_EXPAND_Y   | Sprite Y expansion                |
| $D018 | VIC_MEMPTR        | Memory control (screen/charset)   |
| $D019 | VIC_IRQ_STATUS    | IRQ status/acknowledge            |
| $D01A | VIC_IRQ_ENABLE    | IRQ enable                        |
| $D01B | SPRITE_PRIORITY   | Sprite priority                   |
| $D01C | SPRITE_MULTICOLOR | Sprite multicolor mode            |
| $D01D | SPRITE_EXPAND_X   | Sprite X expansion                |
| $D020 | BORDER            | Border color                      |
| $D021 | BACKGROUND        | Background color 0                |
| $D022 | VIC_BG1           | Background color 1 (ECM)          |
| $D023 | VIC_BG2           | Background color 2 (ECM)          |
| $D024 | VIC_BG3           | Background color 3 (ECM)          |
| $D025 | SPRITE_MC1        | Sprite multicolor 1               |
| $D026 | SPRITE_MC2        | Sprite multicolor 2               |
| $D027 | SPRITE_COLOR_0    | Sprite 0 color (+1 for each)      |

### SID ($D400-$D41C)

| Cím   | Konstans név | Leírás                    |
| ----- | ------------ | ------------------------- |
| $D40E | SID_CH3_FREQ | Channel 3 freq (lo)       |
| $D40F | -            | Channel 3 freq (hi)       |
| $D412 | SID_CH3_CTRL | Channel 3 control         |
| $D413 | SID_CH3_AD   | Channel 3 attack/decay    |
| $D414 | SID_CH3_SR   | Channel 3 sustain/release |

**Megjegyzés:** A musicplayer használja a többi SID regisztert is, de azok az include-ban vannak definiálva.

### Color RAM ($D800-$DBE7)
| Cím         | Konstans név | Méret     | Leírás                  |
| ----------- | ------------ | --------- | ----------------------- |
| $D800-$DBE7 | COLOR        | 1000 byte | Color RAM (4-bit only!) |

### CIA1 ($DC00-$DCFF)
| Cím   | Konstans név | Leírás              |
| ----- | ------------ | ------------------- |
| $DC00 | JOY_PORT     | Port A (joystick 2) |
| $DC04 | CIA1_TA_LO   | Timer A low byte    |
| $DC05 | CIA1_TA_HI   | Timer A high byte   |
| $DC0D | CIA1_ICR     | Interrupt control   |

### CIA2 ($DD00-$DDFF)
| Cím   | Konstans név | Leírás                      |
| ----- | ------------ | --------------------------- |
| $DD00 | CIA2_PRA     | Port A (VIC bank selection) |

---

## Vizuális Memória Térkép

```
$0000 ┌─────────────────────────────────────────┐
      │ Zero Page                               │
      │   $02-$29: PyCo rendszer                │
      │   $2A-$4B: SlotShot változók (34 byte)  │
      │   $4C-$56: SZABAD (11 byte)             │
      │   $FB-$FE: Random state                 │
$0100 ├─────────────────────────────────────────┤
      │ Stack (CPU)                             │
$0200 ├─────────────────────────────────────────┤
      │ ★ RELOCATE: Menu screens (99 byte)      │
      │   $0200: story_screen()                 │
      │   $0221: about_screen()                 │
      │   $0242: donate_screen()                │
$0263 ├─────────────────────────────────────────┤
      │ Kernal work area                        │
      │   $0277: Keyboard buffer (10 byte)      │
      │   $028A: Key repeat flag                │
      │ $033C-$03FF: Cassette buffer (SZABAD)   │
$0400 ├─────────────────────────────────────────┤
      │ Work Buffers (szabadon használható!)    │
      │   $0400-$0427: Column blit buffer       │
      │   $0428-$06A7: Column pool              │
      │   $06A8-$07FF: SZABAD (344 byte)        │
$0800 ├─────────────────────────────────────────┤
      │ BASIC ROM terület (nem használjuk)      │
$0801 ├─────────────────────────────────────────┤
      │ Program (code + data + BSS)             │
      │   ~43KB, ~$B239-ig                      │
      │                                         │
      │   ↓ SSP stack grows upward ↓            │
$B239 ├─────────────────────────────────────────┤
      │ Stack headroom (~3KB)                   │
$C000 ╔═════════════════════════════════════════╗
      ║ VIC BANK 3                              ║
      ║                                         ║
      ║ $C000-$C13F: Sprite data (5 sprites)    ║
      ║   $C000: Cannon ready (block 0)         ║
      ║   $C040: Cannon fired (block 1)         ║
      ║   $C080: Bullet (block 2)               ║
      ║   $C0C0: Sparkle (block 3)              ║
      ║   $C100: Star (block 4)                 ║
      ║                                         ║
      ║ ★ RELOCATE: SFX + IRQ (~610 byte)        ║
      ║   $C140: sfx_play_fire()                ║
      ║   $C184: _sfx_start_clear()             ║
      ║   $C1CA: sfx_play_hit()                 ║
      ║   $C208: sfx_play_bibip()               ║
      ║   $C24E: sfx_play_slide()               ║
      ║   $C28C: Random.range_mask()            ║
      ║   $C2CB: title_screen()                 ║
      ║   $C3??: irq_screen_handler()           ║
      ║ (szabad terület: fordítás után frissül) ║
      ║                                         ║
      ║ $C400-$C7FF: Screen RAM                 ║
      ║   $C7F8: Sprite pointers                ║
      ║                                         ║
      ║ $C800-$CFFF: Charset                    ║
      ║   (ROM copy + custom chars)             ║
      ║                                         ║
$D000 ╠═════════════════════════════════════════╣
      ║ I/O REGISZTEREK                         ║
      ║   $D000-$D02E: VIC-II                   ║
      ║   $D400-$D41C: SID                      ║
      ║   $D800-$DBE7: Color RAM                ║
      ║   $DC00-$DCFF: CIA1                     ║
      ║   $DD00-$DDFF: CIA2                     ║
$E000 ╠═════════════════════════════════════════╣
      ║ $E000-$FFFF: Title bitmap (8KB)         ║
      ║                                         ║
$FFFF ╚═════════════════════════════════════════╝
```

---

## Ismert Problémák / Potenciális Ütközések

### 1. Relocate $C140 régió határa

A `@relocate(0xC140)` régió a Screen RAM ($C400) előtt végződik:
- **Teljes terület:** $C140-$C3FF = 704 byte
- **Használt:** ~610 byte (87%)
- **Szabad:** ~94 byte (13%)

⚠️ Ha a régió túlnyúlik $C400-on, a kód a Screen RAM-ba írna és önmagát felülírná!

### 2. Charset overflow lehetőség

A custom karakterek $C8D8-$C9F8 között vannak (char 27-63), ami $C800 + 27*8 = $C8D8 és $C800 + 63*8 + 8 = $CA00.
Ez rendben van, mert a charset $C800-$CFFF (2KB).

---

## Konstans Értékek Összefoglaló

### VIC Memory Pointers
| Konstans            | Érték | Jelentés                    |
| ------------------- | ----- | --------------------------- |
| GAME_MEMPTR         | $12   | Screen $C400, Charset $C800 |
| TITLE_MEMPTR_TEXT   | $12   | Ugyanaz (text mode)         |
| TITLE_MEMPTR_BITMAP | $18   | Screen $C400, Bitmap $E000  |

### Sprite Block Indices
| Konstans           | Érték | Cím   |
| ------------------ | ----- | ----- |
| CANNON_BLOCK_READY | 0     | $C000 |
| CANNON_BLOCK_FIRED | 1     | $C040 |
| BULLET_BLOCK       | 2     | $C080 |
| SPARKLE_BLOCK      | 3     | $C0C0 |
| STAR_BLOCK         | 4     | $C100 |
