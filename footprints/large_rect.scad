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

SPLIT_AT = L / 2;
DEPTH_A = SPLIT_AT;
DEPTH_B = L - SPLIT_AT;

// "preview" | "piece_a" | "piece_b"
RENDER = "preview";

// Woven joint: tabs centered between adjacent grid X columns, each TAB_W wide.
// Width tuned so each tab fits the inter-hole gap (12.7mm spacing − 6.4mm hole
// diameter ≈ 6.3mm gap, leaving ~1.65mm of body material on each side of the
// tab between it and the adjacent hole).
TAB_W = 3;

N_HOLES_AT_SEAM = floor((W - 2*STUD_GRID_MARGIN) / STUD_GRID_SPACING + 1e-6) + 1;
function _tab_x(i) = STUD_GRID_MARGIN + (i + 0.5) * STUD_GRID_SPACING;
SEAM_TAB_XS = [for (i = [0:N_HOLES_AT_SEAM - 2]) _tab_x(i)];

module piece_a() {
    difference() {
        union() {
            cube([W, DEPTH_A, T]);
            translate([0, DEPTH_A, 0])
                finger_tabs_at(SEAM_TAB_XS, TAB_W, T);
        }
        // Global grid sockets clipped to piece_a's body Y range. Seam holes
        // (at Y = DEPTH_A) are kept — they become half-circles in piece_a.
        intersection() {
            socket_grid_rect(W, L, stud_h=T);
            translate([0, 0, -EPS])
                cube([W, DEPTH_A + EPS, T + 2*EPS]);
        }
    }
}

module piece_b() {
    difference() {
        cube([W, DEPTH_B, T]);
        finger_slots_at(SEAM_TAB_XS, TAB_W, T);
        // Shifted global grid sockets, clipped to piece_b's local Y range.
        // Seam holes (at Y_local = 0) become half-circles in piece_b that
        // align with piece_a's halves when assembled.
        intersection() {
            translate([0, -DEPTH_A, 0])
                socket_grid_rect(W, L, stud_h=T);
            translate([0, -EPS, -EPS])
                cube([W, DEPTH_B + EPS, T + 2*EPS]);
        }
    }
}

if (RENDER == "piece_a") piece_a();
else if (RENDER == "piece_b") piece_b();
else {
    piece_a();
    translate([0, DEPTH_A, 0]) piece_b();
}
