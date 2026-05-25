// Joinery test — two small plates joined by a finger seam.
// Uses the same FINGER_DEPTH and FINGER_TOL as the real footprints, so a fit
// dialed in here transfers directly to the large_rect / wedge splits.
// Print both pieces, glue along the seam, confirm tabs slide cleanly without
// filing and stay seated with superglue.

include <../lib/units.scad>;
include <../lib/joinery.scad>;

SEAM = 80;             // seam length, mm — gives 3 tabs at default density
DEPTH_PER_PIECE = 25;  // each plate's depth in Y, mm
T = 4;                 // plate thickness, mm (matches BASEPLATE_T)

// "preview" | "piece_male" | "piece_female"
RENDER = "preview";

// Male half: carries the protruding finger tabs.
module piece_male() {
    union() {
        cube([SEAM, DEPTH_PER_PIECE, T]);
        translate([0, DEPTH_PER_PIECE, 0])
            finger_tabs(seam_len=SEAM, thickness=T);
    }
}

// Female half: receives the tabs in matching slots.
module piece_female() {
    difference() {
        cube([SEAM, DEPTH_PER_PIECE, T]);
        finger_slots(seam_len=SEAM, thickness=T);
    }
}

if (RENDER == "piece_male") piece_male();
else if (RENDER == "piece_female") piece_female();
else {
    piece_male();
    translate([0, DEPTH_PER_PIECE, 0]) piece_female();
}
