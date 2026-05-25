// Shared baseplate helper for footprints that fit in a single print.

include <units.scad>;
include <studs.scad>;

BASEPLATE_T = 4; // default baseplate thickness, mm

// Rectangular footprint, single piece. Corner at origin, extends in +X, +Y, +Z.
// Top surface is flat; through-holes on the corner-anchored grid accept studs
// hanging from terrain pieces.
module rect_footprint(w, d, t=BASEPLATE_T) {
    difference() {
        cube([w, d, t]);
        socket_grid_rect(w, d, stud_h=t);
    }
}
