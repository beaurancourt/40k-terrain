// Lego-inspired stud/socket pair for locking terrain onto baseplates.
// NOT Lego-compatible — sized for typical FDM print tolerance (0.4mm nozzle).
// Same params must be used on the baseplate (studs) and terrain (sockets).

include <units.scad>;

STUD_D = 6;             // stud outer diameter, mm
STUD_H = 3;             // stud height above baseplate top, mm
STUD_TOL = 0.4;         // diametrical clearance between stud and socket
SOCKET_DEPTH_PAD = 0.4; // extra depth so stud bottoms out cleanly

// 0.5"/0.25" grid: chosen so every baseplate dimension (2", 2.5", 4", 6", 7",
// 8", 10", 11.5") divides cleanly and produces a symmetric corner-anchored
// grid (6.35mm of edge material on all four sides of every baseplate).
// Also fits a 6mm-diameter stud inside a 10mm-thick wall (stud at Y=6.35
// extends Y=3.35-9.35, fully contained).
STUD_GRID_SPACING = 12.7; // 0.5"
STUD_GRID_MARGIN  = 6.35; // 0.25"

module stud(d=STUD_D, h=STUD_H) {
    cylinder(d=d, h=h, $fn=32);
}

module socket(d=STUD_D, h=STUD_H, tol=STUD_TOL) {
    translate([0, 0, -EPS])
        cylinder(d=d+tol, h=h+SOCKET_DEPTH_PAD+EPS, $fn=32);
}

// Corner-anchored grid: first stud at (margin, margin), then every `spacing` mm.
// Same anchor on every baseplate and terrain piece, so corner-aligned placement
// always lines up across any baseplate (including across split baseplate seams).
module stud_grid_rect(w, d, spacing=STUD_GRID_SPACING, margin=STUD_GRID_MARGIN,
                      stud_d=STUD_D, stud_h=STUD_H) {
    nx = max(1, floor((w - 2*margin) / spacing + 1e-6) + 1);
    ny = max(1, floor((d - 2*margin) / spacing + 1e-6) + 1);
    for (i = [0:nx-1], j = [0:ny-1])
        translate([margin + i*spacing, margin + j*spacing, 0])
            stud(d=stud_d, h=stud_h);
}

// Sockets matching stud_grid_rect with identical parameters.
// Subtract from the bottom of a terrain piece sitting at Z=0.
module socket_grid_rect(w, d, spacing=STUD_GRID_SPACING, margin=STUD_GRID_MARGIN,
                        stud_d=STUD_D, stud_h=STUD_H) {
    nx = max(1, floor((w - 2*margin) / spacing + 1e-6) + 1);
    ny = max(1, floor((d - 2*margin) / spacing + 1e-6) + 1);
    for (i = [0:nx-1], j = [0:ny-1])
        translate([margin + i*spacing, margin + j*spacing, 0])
            socket(d=stud_d, h=stud_h);
}
