#!/bin/bash
# Convert Slotshot game assets from work folder
# Run from: examples/games/Slotshot/work/

set -e  # Exit on error

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
INCLUDES_DIR="$SCRIPT_DIR/../includes"

# Ensure output directory exists
mkdir -p "$INCLUDES_DIR"

echo "=== Converting Slotshot Assets ==="
echo ""

# Convert Koala image to PyCo include (RLE compressed, embedded in program)
echo "Converting title image (Koala -> RLE include)..."
pycoc image "$SCRIPT_DIR/title_image/slotshot.koa" \
    -C rle \
    -B 6 \
    -o "$INCLUDES_DIR/slotshot_image_rle.pyco"

# Convert Furnace music to PyCo include (embedded in program)
echo "Converting music (Furnace -> PyCo include)..."
pycoc music "$SCRIPT_DIR/music/slotshot.fur" \
    -o "$INCLUDES_DIR/slotshot_music.pyco"
pycoc music "$SCRIPT_DIR/music/slotshot_gameover.fur" \
    -o "$INCLUDES_DIR/slotshot_gameover_music.pyco"
pycoc music "$SCRIPT_DIR/music/slotshot_highscore.fur" \
    -o "$INCLUDES_DIR/slotshot_highscore_music.pyco"

echo ""
echo "=== Done ==="
echo "Generated include files:"
echo "  $INCLUDES_DIR/slotshot_image_rle.pyco"
echo "  $INCLUDES_DIR/slotshot_music.pyco"
echo "  $INCLUDES_DIR/slotshot_gameover_music.pyco"
