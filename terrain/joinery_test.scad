// Joinery test — two small plates joined by a finger seam.
// Uses the same FINGER_DEPTH and FINGER_TOL as the real footprints, so a fit
// dialed in here transfers directly to the large_rect / large_triangle splits.
// Print both pieces, glue along the seam, confirm tabs slide cleanly without
// filing and stay seated with superglue.

include <../lib/units.scad>;
include <../lib/joinery.scad>;

SEAM = 80;             // seam length, mm — gives 3 tabs at default density
DEPTH_PER_PIECE = 25;  // each plate's depth in Y, mm
T = 4;                 // plate thickness, mm (matches BASEPLATE_T)

// "preview" | "piece_a" | "piece_b"
RENDER = "preview";

module piece_a() {
    union() {
        cube([SEAM, DEPTH_PER_PIECE, T]);
        translate([0, DEPTH_PER_PIECE, 0])
            finger_tabs(seam_len=SEAM, thickness=T);
    }
}

module piece_b() {
    difference() {
        cube([SEAM, DEPTH_PER_PIECE, T]);
        finger_slots(seam_len=SEAM, thickness=T);
    }
}

if (RENDER == "piece_a") piece_a();
else if (RENDER == "piece_b") piece_b();
else {
    piece_a();
    translate([0, DEPTH_PER_PIECE, 0]) piece_b();
}
