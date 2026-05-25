// Barricade — crenellated structure that fills its W×D footprint.
//
// STYLE = "short" — ~1.75" tall, under the 2" "drive over" rule.
// STYLE = "tall"  — ~5.4" tall, above the 5" LoS rule. Same crenellated
//                    silhouette with deeper notches.
//
// W = footprint X (long axis), D = footprint Y (short axis).
//
// If D has room for inner space (D − 2·WALL_T ≥ 15mm), the barricade is a
// HOLLOW rectangle — walls on all four sides with crenel notches around the
// top, hollow interior. Otherwise the barricade is a SOLID block of full D
// thickness with crenel notches across the top.
//
// LABEL = optional debossed text on the bottom face.
//
// Print orientation: flip 180° around X so the crenel blocks sit on the bed
// and the studs print last (no supports needed).

include <../lib/units.scad>;
include <../lib/studs.scad>;
include <../lib/labels.scad>;

STYLE = "short";
LABEL = "";
W = inches(10);
D = inches(2.5);

WALL_T_DEFAULT = 10;
HOLLOW = (D - 2*WALL_T_DEFAULT) >= 15;
WALL_T = HOLLOW ? WALL_T_DEFAULT : D;   // solid blocks fill the full D

SHORT_HEIGHT = inches(1.75);
TALL_HEIGHT  = inches(2.5) + 4 + inches(2.75);  // 137mm, matches big L-ruin

HEIGHT      = (STYLE == "short") ? SHORT_HEIGHT : TALL_HEIGHT;
NOTCH_DEPTH = (STYLE == "short") ? 10 : 25;

IDEAL_BLOCK_W = 28;
IDEAL_GAP_W   = 20;

function _n_gaps(L)     = max(1, round((L - IDEAL_BLOCK_W) / (IDEAL_BLOCK_W + IDEAL_GAP_W)));
function _block_w(L, n) = (L - n * IDEAL_GAP_W) / (n + 1);

EPS = 0.01;

if (HOLLOW) {
    n_bot       = _n_gaps(W);
    block_w_bot = _block_w(W, n_bot);
    n_left      = _n_gaps(D);
    block_w_lft = _block_w(D, n_left);

    difference() {
        cube([W, D, HEIGHT]);
        // Hollow interior
        translate([WALL_T, WALL_T, -EPS])
            cube([W - 2*WALL_T, D - 2*WALL_T, HEIGHT + 2*EPS]);
        // Bottom wall notches
        for (i = [0:n_bot - 1]) {
            x = (i+1)*block_w_bot + i*IDEAL_GAP_W;
            translate([x, -EPS, HEIGHT - NOTCH_DEPTH])
                cube([IDEAL_GAP_W, WALL_T + 2*EPS, NOTCH_DEPTH + EPS]);
        }
        // Top wall notches
        for (i = [0:n_bot - 1]) {
            x = (i+1)*block_w_bot + i*IDEAL_GAP_W;
            translate([x, D - WALL_T - EPS, HEIGHT - NOTCH_DEPTH])
                cube([IDEAL_GAP_W, WALL_T + 2*EPS, NOTCH_DEPTH + EPS]);
        }
        // Left wall notches
        for (j = [0:n_left - 1]) {
            y = (j+1)*block_w_lft + j*IDEAL_GAP_W;
            translate([-EPS, y, HEIGHT - NOTCH_DEPTH])
                cube([WALL_T + 2*EPS, IDEAL_GAP_W, NOTCH_DEPTH + EPS]);
        }
        // Right wall notches
        for (j = [0:n_left - 1]) {
            y = (j+1)*block_w_lft + j*IDEAL_GAP_W;
            translate([W - WALL_T - EPS, y, HEIGHT - NOTCH_DEPTH])
                cube([WALL_T + 2*EPS, IDEAL_GAP_W, NOTCH_DEPTH + EPS]);
        }
        // Label on the bottom wall's centerline
    }

    // Studs around the perimeter (corner-anchored grid).
    nx = max(1, floor((W - 2*STUD_GRID_MARGIN) / STUD_GRID_SPACING + 1e-6) + 1);
    ny = max(1, floor((D - 2*STUD_GRID_MARGIN) / STUD_GRID_SPACING + 1e-6) + 1);
    // Bottom row
    for (i = [0:nx-1])
        translate([STUD_GRID_MARGIN + i*STUD_GRID_SPACING, STUD_GRID_MARGIN, -STUD_H])
            stud(h=STUD_H + 0.5);
    if (ny > 1) {
        // Top row
        for (i = [0:nx-1])
            translate([STUD_GRID_MARGIN + i*STUD_GRID_SPACING,
                       STUD_GRID_MARGIN + (ny-1)*STUD_GRID_SPACING, -STUD_H])
                stud(h=STUD_H + 0.5);
        if (ny > 2)
            for (j = [1:ny-2]) {
                translate([STUD_GRID_MARGIN, STUD_GRID_MARGIN + j*STUD_GRID_SPACING, -STUD_H])
                    stud(h=STUD_H + 0.5);
                translate([STUD_GRID_MARGIN + (nx-1)*STUD_GRID_SPACING,
                           STUD_GRID_MARGIN + j*STUD_GRID_SPACING, -STUD_H])
                    stud(h=STUD_H + 0.5);
            }
    }
} else {
    // Solid block — wall fills the full D thickness. Crenel notches cut
    // across the top from front to back.
    n       = _n_gaps(W);
    block_w = _block_w(W, n);

    difference() {
        cube([W, D, HEIGHT]);
        for (i = [0:n - 1]) {
            x_start = (i+1)*block_w + i*IDEAL_GAP_W;
            translate([x_start, -EPS, HEIGHT - NOTCH_DEPTH])
                cube([IDEAL_GAP_W, D + 2*EPS, NOTCH_DEPTH + EPS]);
        }
    }

    // Studs along centerline (single row, since D is too thin for two)
    nx = max(1, floor((W - 2*STUD_GRID_MARGIN) / STUD_GRID_SPACING + 1e-6) + 1);
    for (i = [0:nx-1])
        translate([STUD_GRID_MARGIN + i*STUD_GRID_SPACING, D/2, -STUD_H])
            stud(h=STUD_H + 0.5);
}
