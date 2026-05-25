// Large rectangle footprint — 7" × 11.5" (177.8 × 292.1 mm).
// Exceeds the 256mm bed along the long axis. Split into two halves with a
// WOVEN finger joint: narrow tabs sit in the inter-hole gaps at midpoints
// between grid X columns. Holes (including seam holes) stay on the grid, so
// the lego grid is continuous across the seam — a terrain piece can span the
// joint with feet at any grid X.

include <../lib/units.scad>;
include <../lib/studs.scad>;
include <../lib/joinery.scad>;
include <../lib/labels.scad>;

W = inches(7);    // 177.8 mm — short axis, fits the bed
L = inches(11.5); // 292.1 mm — long axis, exceeds the bed
T = 4;            // baseplate thickness, mm
LABEL = "7x11.5";

SPLIT_AT     = L / 2;
DEPTH_MALE   = SPLIT_AT;
DEPTH_FEMALE = L - SPLIT_AT;

// "preview" | "piece_male" | "piece_female"
RENDER = "preview";

// Woven joint: tabs centered between adjacent grid X columns, each TAB_W wide.
// Width tuned so each tab fits the inter-hole gap (12.7mm spacing − 6.4mm hole
// diameter ≈ 6.3mm gap, leaving ~1.65mm of body material on each side of the
// tab between it and the adjacent hole).
TAB_W = 3;

N_HOLES_AT_SEAM = floor((W - 2*STUD_GRID_MARGIN) / STUD_GRID_SPACING + 1e-6) + 1;
function _tab_x(i) = STUD_GRID_MARGIN + (i + 0.5) * STUD_GRID_SPACING;
SEAM_TAB_XS = [for (i = [0:N_HOLES_AT_SEAM - 2]) _tab_x(i)];

// Male half: carries the protruding finger tabs at the seam.
module piece_male() {
    difference() {
        union() {
            cube([W, DEPTH_MALE, T]);
            translate([0, DEPTH_MALE, 0])
                finger_tabs_at(SEAM_TAB_XS, TAB_W, T);
        }
        // Global grid sockets clipped to the male half's body Y range. Seam
        // holes (at Y = DEPTH_MALE) are kept — they become half-circles here.
        intersection() {
            socket_grid_rect(W, L, stud_h=T);
            translate([0, 0, -EPS])
                cube([W, DEPTH_MALE + EPS, T + 2*EPS]);
        }
    }
}

// Female half: receives the tabs in matching slots at the seam.
module piece_female() {
    difference() {
        cube([W, DEPTH_FEMALE, T]);
        finger_slots_at(SEAM_TAB_XS, TAB_W, T);
        // Shifted global grid sockets, clipped to the female half's local Y
        // range. Seam holes (at Y_local = 0) become half-circles that align
        // with the male half's halves when assembled.
        intersection() {
            translate([0, -DEPTH_MALE, 0])
                socket_grid_rect(W, L, stud_h=T);
            translate([0, -EPS, -EPS])
                cube([W, DEPTH_FEMALE + EPS, T + 2*EPS]);
        }
    }
}

if (RENDER == "piece_male") piece_male();
else if (RENDER == "piece_female") piece_female();
else {
    piece_male();
    translate([0, DEPTH_MALE, 0]) piece_female();
}
