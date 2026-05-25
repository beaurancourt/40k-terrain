// Large wedge footprint — 11.5" base × varying height (2" left, 8" right).
// Vertices: (0, 0), (11.5, 0), (11.5, 8), (0, 2).
// Top edge is a diagonal from (0, 2) to (11.5, 8).
//
// Two of these tile (rotated 180° about center) into a 10"×11.5" rectangle.
// With the corner-anchored 12.7mm grid, both polygons' grids align in the
// assembled rectangle — see notes below.
//
// 11.5" exceeds the 256mm bed; split into the male half (X 0..5.75") and the
// female half (X 5.75..11.5") with the same WOVEN finger joint as large_rect,
// oriented along the Y axis at the X=5.75" seam.

include <../lib/units.scad>;
include <../lib/studs.scad>;
include <../lib/joinery.scad>;

W       = inches(11.5);  // 292.1mm — base length
LEFT_Y  = inches(2);     // 50.8mm — left side height
RIGHT_Y = inches(8);     // 203.2mm — right side height
T       = 4;

SPLIT_AT       = W / 2;  // 146.05mm
SEAM_Y_AT_DIAG = LEFT_Y + (RIGHT_Y - LEFT_Y) * SPLIT_AT / W;  // = 127

// "preview" | "piece_male" | "piece_female"
RENDER = "preview";

TAB_W = 3;
N_HOLES_AT_SEAM = floor((SEAM_Y_AT_DIAG - 2*STUD_GRID_MARGIN) / STUD_GRID_SPACING + 1e-6) + 1;
function _tab_y(j) = STUD_GRID_MARGIN + (j + 0.5) * STUD_GRID_SPACING;
SEAM_TAB_YS = [for (j = [0:N_HOLES_AT_SEAM - 2]) _tab_y(j)];

// Male half: carries the protruding finger tabs at the seam.
module piece_male() {
    pts_male = [[0,0], [SPLIT_AT, 0], [SPLIT_AT, SEAM_Y_AT_DIAG], [0, LEFT_Y]];
    difference() {
        union() {
            linear_extrude(height=T) polygon(points=pts_male);
            // Woven tabs at the X=SPLIT_AT seam, extending in +X.
            for (y = SEAM_TAB_YS) {
                translate([SPLIT_AT - EPS, y - (TAB_W - 2*FINGER_TOL)/2, 0])
                    cube([FINGER_DEPTH + EPS, TAB_W - 2*FINGER_TOL, T]);
            }
        }
        // Global grid sockets (bounding-box-wide), X-clipped to the male half's
        // range. The polygon body clips Y/diagonal automatically; holes near
        // the diagonal become D-shapes whose complement lives in the other half
        // of the rectangle (when two wedges are placed together).
        intersection() {
            socket_grid_rect(W, RIGHT_Y, stud_h=T);
            translate([0, 0, -EPS])
                cube([SPLIT_AT, RIGHT_Y, T + 2*EPS]);
        }
    }
}

// Female half: receives the tabs in matching slots at the seam.
module piece_female() {
    pts_female = [[0,0], [SPLIT_AT, 0], [SPLIT_AT, RIGHT_Y], [0, SEAM_Y_AT_DIAG]];
    difference() {
        linear_extrude(height=T) polygon(points=pts_female);
        // Woven slots at X_local=0, cutting into +X_local.
        for (y = SEAM_TAB_YS) {
            translate([-EPS, y - TAB_W/2, -EPS])
                cube([FINGER_DEPTH + EPS, TAB_W, T + 2*EPS]);
        }
        // Same global grid, shifted into the female half's local frame.
        intersection() {
            translate([-SPLIT_AT, 0, 0])
                socket_grid_rect(W, RIGHT_Y, stud_h=T);
            translate([0, 0, -EPS])
                cube([SPLIT_AT, RIGHT_Y, T + 2*EPS]);
        }
    }
}

if (RENDER == "piece_male") piece_male();
else if (RENDER == "piece_female") piece_female();
else {
    piece_male();
    translate([SPLIT_AT, 0, 0]) piece_female();
}
