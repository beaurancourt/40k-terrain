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
| Large triangle ×2 | 8 × 11.5 | 203.2 × 292.1 | Yes, across long leg |
| Medium rectangle ×4 | 6 × 4 | 152.4 × 101.6 | No |
| Long line ×2 | 10 × 2.5 | 254 × 63.5 | No (2mm bed margin — print without a brim) |
| Short line ×4 | 6 × 2 | 152.4 × 50.8 | No |

## Rendering a piece

STL files are not checked into the repo — render them from the `.scad` sources
as described here.

Split footprints expose a `RENDER` variable at the top of the file:

- `"preview"` — both halves shown assembled, for screen
- `"piece_a"` / `"piece_b"` — single half, for STL export

Open `footprints/large_rect.scad` in OpenSCAD, change `RENDER`, press F6 to render, F7 to export.

From the command line:

```
openscad -o piece_a.stl -D 'RENDER="piece_a"' footprints/large_rect.scad
openscad -o piece_b.stl -D 'RENDER="piece_b"' footprints/large_rect.scad
```

## Layout

```
lib/
  units.scad      Inch <-> mm, shared constants
  studs.scad      Stud/socket primitives, grid helpers
  joinery.scad    Finger-joint tabs and slots
  footprint.scad  rect_footprint() helper for single-piece plates
footprints/
  large_rect.scad
  large_triangle.scad
  medium_rect.scad
  long_line.scad
  short_line.scad
terrain/
  test_block.scad     Small block with hanging studs — validate the lock system
  joinery_test.scad   Tiny two-piece plate for testing finger-joint fit
  barricade.scad      Crenellated <2" barricade (SIZE="long" or "short")
  l_ruin.scad         L-shaped ruin. SIZE="medium" (under-2" solid L) or
                      "large"/"triangle" (>5" two-story with platform & windows;
                      splits into piece_a/piece_b like the baseplates)
```

## First test prints

Validate both the finger joinery and the stud/hole fit on cheap test pieces before committing to a full baseplate.

1. **Joinery fit** — render `terrain/joinery_test.scad` as `piece_a` and `piece_b`, then print both (small, ~25 min total). The tabs should slide into the slots with light friction; superglue holds the seam. If it's too tight or sloppy, adjust `FINGER_TOL` in `lib/joinery.scad` by 0.05–0.1mm and reprint just these two pieces.
2. **Stud/hole fit** — render and print `footprints/medium_rect.scad` (smallest real baseplate) and `terrain/test_block.scad`. Lay-flat the test block in your slicer so the studs point up. Studs should drop into baseplate holes with a snug press fit. If too tight or loose, adjust `STUD_TOL` in `lib/studs.scad` by 0.1mm and reprint just the test block.

Once both fits are dialed in, commit to the full footprint set (see print quantities below).

## Tuning

All key dimensions live in `lib/` as named constants — stud diameter and height, socket clearance, finger depth and tolerance, grid spacing, baseplate thickness. Print the test block on a medium rectangle first; if the studs are too tight or too loose in the baseplate holes, adjust `STUD_TOL` in `lib/studs.scad` by 0.1mm and reprint.

**Known limitation (v1):** the stud grid is centered in each baseplate's rectangle, so different-sized baseplates have hole patterns at different absolute offsets. A given terrain piece will only lock cleanly at specific placement positions on each baseplate. For full placement freedom we'd switch to a denser, globally-anchored grid (closer to actual Lego); flag if you want that.
