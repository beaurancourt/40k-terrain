// Single-piece L-shaped ruin.
//
// STYLE = "small" — low solid L, under 2". No openings. Lego feet under both
//                    walls (same corner-anchored grid as big ruin).
// STYLE = "big"   — two-story L. Solid ground-floor walls, cantilevered
//                    platform at second-floor height, thin second-story walls
//                    with Gothic lancet windows. >5" tall.
//
// W, D = footprint dimensions in mm (bottom-wall length × left-wall length).
// LABEL = optional debossed text on the bottom of the bottom wall.

include <../lib/units.scad>;
include <../lib/studs.scad>;
include <../lib/labels.scad>;

STYLE = "big";
LABEL = "";

W = (STYLE == "small") ? inches(4) : inches(6);
D = (STYLE == "small") ? inches(3) : inches(5);

WALL_T = 10;

SMALL_HEIGHT   = inches(1.75);
GROUND_H       = inches(2.5);
PLATFORM_T     = 4;
SECOND_H       = inches(2.75);
PLATFORM_DEPTH = min(75, min(W, D) - 30);
BIG_HEIGHT     = GROUND_H + PLATFORM_T + SECOND_H;

WINDOW_W      = 18;
WINDOW_H_RECT = 20;
WINDOW_H_PEAK = 14;
WINDOW_Z      = GROUND_H + PLATFORM_T + 12;

function _n_windows(wall_len) = max(2, floor(wall_len / 40));

module _gothic_pent(w, h_rect, h_peak) {
    polygon([[0,0], [w, 0], [w, h_rect], [w/2, h_rect+h_peak], [0, h_rect]]);
}

module l_studs() {
    nx = max(1, floor((W - 2*STUD_GRID_MARGIN) / STUD_GRID_SPACING + 1e-6) + 1);
    ny = max(1, floor((D - 2*STUD_GRID_MARGIN) / STUD_GRID_SPACING + 1e-6) + 1);
    for (i = [0:nx-1])
        translate([STUD_GRID_MARGIN + i*STUD_GRID_SPACING, STUD_GRID_MARGIN, -STUD_H])
            stud(h=STUD_H + 0.5);
    for (j = [1:ny-1])  // j=0 corner already placed
        translate([STUD_GRID_MARGIN, STUD_GRID_MARGIN + j*STUD_GRID_SPACING, -STUD_H])
            stud(h=STUD_H + 0.5);
}

EPS = 0.01;

if (STYLE == "small") {
    difference() {
        union() {
            cube([W, WALL_T, SMALL_HEIGHT]);
            cube([WALL_T, D, SMALL_HEIGHT]);
        }
    }
    l_studs();
} else {
    difference() {
        union() {
            cube([W, WALL_T, BIG_HEIGHT]);
            cube([WALL_T, D, BIG_HEIGHT]);
            translate([0, 0, GROUND_H]) {
                cube([W, PLATFORM_DEPTH, PLATFORM_T]);
                cube([PLATFORM_DEPTH, D, PLATFORM_T]);
            }
        }
        for (i = [0:_n_windows(W) - 1]) {
            frac = (i + 1) / (_n_windows(W) + 1);
            translate([W * frac - WINDOW_W/2, WALL_T + EPS, WINDOW_Z])
                rotate([90, 0, 0])
                    linear_extrude(height=WALL_T + 2*EPS)
                        _gothic_pent(WINDOW_W, WINDOW_H_RECT, WINDOW_H_PEAK);
        }
        for (j = [0:_n_windows(D) - 1]) {
            frac = (j + 1) / (_n_windows(D) + 1);
            translate([-EPS, D * frac - WINDOW_W/2, WINDOW_Z])
                rotate([0, 0, 90])
                    rotate([90, 0, 0])
                        linear_extrude(height=WALL_T + 2*EPS)
                            _gothic_pent(WINDOW_W, WINDOW_H_RECT, WINDOW_H_PEAK);
        }
    }
    l_studs();
}
