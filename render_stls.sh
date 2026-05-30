#!/usr/bin/env bash
#
# Render the full table set to STL from the .scad sources.
# STL files are gitignored, so this is how you regenerate them.
#
# Usage:
#   ./render_stls.sh                      # render everything into ./stl/
#   OUT=/tmp/out ./render_stls.sh         # render into a different directory
#   OPENSCAD=/path/to/openscad ./render_stls.sh
#
# Filenames encode dimensions as small×large. Barricades and L-ruins take
# W = the larger (long) axis and D = the smaller (short) axis. The lone
# exception is big_l_ruin_6x3, whose L is deliberately reversed (short base,
# long height): W = the short axis, D = the long axis.

set -euo pipefail

# --- locate the openscad binary -------------------------------------------
OPENSCAD="${OPENSCAD:-}"
if [[ -z "$OPENSCAD" ]]; then
    if command -v openscad >/dev/null 2>&1; then
        OPENSCAD="$(command -v openscad)"
    elif [[ -x /Applications/OpenSCAD.app/Contents/MacOS/OpenSCAD ]]; then
        OPENSCAD="/Applications/OpenSCAD.app/Contents/MacOS/OpenSCAD"
    else
        echo "error: openscad not found. Install it, or set OPENSCAD=/path/to/openscad" >&2
        exit 1
    fi
fi

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
OUT="${OUT:-$ROOT/stl}"
mkdir -p "$OUT"

count=0
render() {  # render <out_name> <scad_path> [extra -D args...]
    local name="$1" scad="$2"; shift 2
    printf '  %-36s' "$name.stl"
    local log
    if log="$("$OPENSCAD" -o "$OUT/$name.stl" "$@" "$ROOT/$scad" 2>&1)"; then
        echo "ok"
        count=$((count + 1))
    else
        echo "FAILED"
        echo "$log" >&2
        return 1
    fi
}

echo "openscad: $OPENSCAD"
echo "output:   $OUT"
echo

echo "Footprints (single piece):"
render footprint_2x6    footprints/short_line.scad
render footprint_2.5x10 footprints/long_line.scad
render footprint_4x6    footprints/medium_rect.scad

echo "Footprints (split into male + female halves):"
render footprint_7x11.5_piece_male     footprints/large_rect.scad     -D 'RENDER="piece_male"'
render footprint_7x11.5_piece_female   footprints/large_rect.scad     -D 'RENDER="piece_female"'
render footprint_2x11.5x8_piece_male   footprints/wedge_2x11.5x8.scad -D 'RENDER="piece_male"'
render footprint_2x11.5x8_piece_female footprints/wedge_2x11.5x8.scad -D 'RENDER="piece_female"'

echo "Barricades:"
render tall_barricade_3x5      terrain/barricade.scad -D 'STYLE="tall"'  -D 'W=inches(5)'   -D 'D=inches(3)'
render tall_barricade_2x6      terrain/barricade.scad -D 'STYLE="tall"'  -D 'W=inches(6)'   -D 'D=inches(2)'
render tall_barricade_2.5x2.5  terrain/barricade.scad -D 'STYLE="tall"'  -D 'W=inches(2.5)' -D 'D=inches(2.5)'
render short_barricade_1.5x5   terrain/barricade.scad -D 'STYLE="short"' -D 'W=inches(5)'   -D 'D=inches(1.5)'
render short_barricade_0.5x3.5 terrain/barricade.scad -D 'STYLE="short"' -D 'W=inches(3.5)' -D 'D=inches(0.5)'

echo "L-ruins:"
render big_l_ruin_4x5       terrain/l_ruin.scad -D 'STYLE="big"'   -D 'W=inches(5)'   -D 'D=inches(4)'
render big_l_ruin_2.5x6     terrain/l_ruin.scad -D 'STYLE="big"'   -D 'W=inches(6)'   -D 'D=inches(2.5)'
render big_l_ruin_5x6       terrain/l_ruin.scad -D 'STYLE="big"'   -D 'W=inches(6)'   -D 'D=inches(5)'
render big_l_ruin_6x3       terrain/l_ruin.scad -D 'STYLE="big"'   -D 'W=inches(3)'   -D 'D=inches(6)'
render small_l_ruin_1.5x1.5 terrain/l_ruin.scad -D 'STYLE="small"' -D 'W=inches(1.5)' -D 'D=inches(1.5)'
render small_l_ruin_2x3     terrain/l_ruin.scad -D 'STYLE="small"' -D 'W=inches(3)'   -D 'D=inches(2)'
render small_l_ruin_1.5x3   terrain/l_ruin.scad -D 'STYLE="small"' -D 'W=inches(3)'   -D 'D=inches(1.5)'

echo
echo "Done — rendered $count files into $OUT"
