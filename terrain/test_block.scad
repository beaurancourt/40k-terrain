// Test block — a simple rectangular terrain piece with studs hanging from its
// underside. Validates the stud/hole lock system. The studs slot into the
// through-holes on any baseplate; the block's flat top is unused by the lock.
//
// Print orientation: studs-up is easiest (no overhangs). Flip in your slicer.

include <../lib/units.scad>;
include <../lib/studs.scad>;

W = 60; // block footprint X, mm
D = 60; // block footprint Y, mm
H = 25; // block height, mm

module test_block() {
    cube([W, D, H]);
    // Studs grow from z=-STUD_H up to z=0, flush with the block bottom.
    translate([0, 0, -STUD_H])
        stud_grid_rect(W, D);
}

test_block();
