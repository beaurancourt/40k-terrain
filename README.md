# 40k Terrain (OpenSCAD)

Parametric area-terrain pieces for Warhammer 40,000 11th edition. Designed for a 256×256×256mm FDM bed; oversized pieces are split with finger joints and superglued.

## Concept

- **Baseplates** are thin polygons matching each piece's footprint and define the rules-legal area. The top surface stays flat (so models can stand anywhere on it) with a **Lego-inspired grid of through-holes**.
- **Terrain pieces** (walls, blocks, ruins) carry matching **studs on their underside** that drop into baseplate holes, so play doesn't shift them around.
- **Pieces over 256mm** are split with through-thickness **finger joints**. Print both halves, glue the seam.

## Footprints

| Piece | Inches | mm | Split |
|---|---|---|---|
| Large rectangle ×4 | 7 × 11.5 | 177.8 × 292.1 | Yes, across long axis |
| Large wedge ×2 | 2 × 11.5 × 8 | 50.8 × 292.1 × 203.2 | Yes, across long axis |
| Medium rectangle ×4 | 6 × 4 | 152.4 × 101.6 | No |
| Long line ×2 | 10 × 2.5 | 254 × 63.5 | No (2mm bed margin — print without a brim) |
| Short line ×4 | 6 × 2 | 152.4 × 50.8 | No |

The wedge is a trapezoid (2" tall on the left, 8" on the right, 11.5" base); two tile into a 10"×11.5" rectangle.

## Rendering a piece

STL files are not checked into the repo — render them from the `.scad` sources
as described here.

Split footprints expose a `RENDER` variable at the top of the file:

- `"preview"` — both halves shown assembled, for screen
- `"piece_male"` / `"piece_female"` — single half, for STL export

The **male** half carries the protruding finger tabs; the **female** half has the matching slots.

Open `footprints/large_rect.scad` in OpenSCAD, change `RENDER`, press F6 to render, F7 to export.

From the command line:

```
openscad -o piece_male.stl   -D 'RENDER="piece_male"'   footprints/large_rect.scad
openscad -o piece_female.stl -D 'RENDER="piece_female"' footprints/large_rect.scad
```

Or render the whole table set at once with [`render_stls.sh`](render_stls.sh):

```
./render_stls.sh                     # write every piece into stl/
OUT=/tmp/out ./render_stls.sh        # render into another directory
OPENSCAD=/path/to/openscad ./render_stls.sh
```

## Layout

```
render_stls.sh    Render the whole table set to stl/
lib/
  units.scad      Inch <-> mm, shared constants
  studs.scad      Stud/socket primitives, grid helpers
  joinery.scad    Finger-joint tabs and slots
  footprint.scad  rect_footprint() helper for single-piece plates
footprints/
  large_rect.scad
  wedge_2x11.5x8.scad
  medium_rect.scad
  long_line.scad
  short_line.scad
terrain/
  test_block.scad     Small block with hanging studs — validate the lock system
  joinery_test.scad   Tiny two-piece plate for testing finger-joint fit
  barricade.scad      Crenellated barricade. STYLE="short" (~1.75", drive-over)
                      or "tall" (~5.4", blocks line of sight)
  l_ruin.scad         L-shaped ruin. STYLE="small" (under-2" solid L) or
                      "big" (>5" two-story with platform & Gothic windows).
                      Single piece.
```

## First test prints

Validate both the finger joinery and the stud/hole fit on cheap test pieces before committing to a full baseplate.

1. **Joinery fit** — render `terrain/joinery_test.scad` as `piece_male` and `piece_female`, then print both (small, ~25 min total). The tabs should slide into the slots with light friction; superglue holds the seam. If it's too tight or sloppy, adjust `FINGER_TOL` in `lib/joinery.scad` by 0.05–0.1mm and reprint just these two pieces.
2. **Stud/hole fit** — render and print `footprints/medium_rect.scad` (smallest real baseplate) and `terrain/test_block.scad`. Lay-flat the test block in your slicer so the studs point up. Studs should drop into baseplate holes with a snug press fit. If too tight or loose, adjust `STUD_TOL` in `lib/studs.scad` by 0.1mm and reprint just the test block.

Once both fits are dialed in, commit to the full footprint set (see print quantities below).

## Print list

The full table set — 46 pieces. Render each from its `.scad` source (see *Rendering a piece*); footprints over 256mm export as `piece_male` + `piece_female` halves.

**Ruins** — `terrain/l_ruin.scad`

| Qty | Size | `STYLE` |
|---|---|---|
| 2 | 4×5 | `big` (tall) |
| 2 | 2.5×6 | `big` (tall) |
| 2 | 5×6 | `big` (tall) |
| 2 | 3×6 | `big` (tall) |
| 2 | 1.5×1.5 | `small` (short) |
| 2 | 2×3 | `small` (short) |
| 4 | 1.5×3 | `small` (short) |

**Barricades** — `terrain/barricade.scad`

| Qty | Size | `STYLE` |
|---|---|---|
| 2 | 3×5 | `tall` |
| 2 | 2×6 | `tall` |
| 2 | 2.5×2.5 | `tall` |
| 2 | 1.5×5 | `short` |
| 4 | 0.5×3.5 | `short` |

**Footprints** — `footprints/`

| Qty | Size | Source |
|---|---|---|
| 4 | 2×6 (short line) | `short_line.scad` |
| 2 | 2.5×10 (long line) | `long_line.scad` |
| 4 | 4×6 (medium rect) | `medium_rect.scad` |
| 2 male + 2 female | 7×11.5 (large rect) | `large_rect.scad` |
| 2 male + 2 female | 2×11.5×8 (wedge) | `wedge_2x11.5x8.scad` |

## Tuning

All key dimensions live in `lib/` as named constants — stud diameter and height, socket clearance, finger depth and tolerance, grid spacing, baseplate thickness. Print the test block on a medium rectangle first; if the studs are too tight or too loose in the baseplate holes, adjust `STUD_TOL` in `lib/studs.scad` by 0.1mm and reprint.

**Placement grid:** the stud grid is corner-anchored — the first hole sits 0.25" from the corner, then every 0.5" — using the identical lattice on every baseplate and terrain piece. Corner-align a piece to a baseplate corner and its studs drop into holes on any baseplate, including across split seams. Placement is quantized to the 0.5" grid rather than free-floating like real Lego; that's the intended trade-off for FDM-friendly tolerances.
