// Finger/box joinery for splitting thin baseplates across the printer bed limit.
// Tabs and slots cut through the full plate thickness — flat puzzle-piece edges.
//
// Convention: both finger_tabs and finger_slots operate at Y=0 of their caller's
// local frame, extending into +Y. Position each piece in its own local frame:
//   - Tab-side piece: body at y ∈ [0, depth_a]; UNION finger_tabs translated to y=depth_a.
//   - Slot-side piece: body at y ∈ [0, depth_b], seam edge at y=0;
//                      DIFFERENCE finger_slots at y=0 (cuts into +Y).
//
// Tabs are shrunk by tol on each side so they slip into nominal-width slots
// without filing.

include <units.scad>;

FINGER_DEPTH = 8;  // how far tabs protrude / slots recess, mm
FINGER_TOL = 0.2;  // per-side clearance between tab and slot, mm

// Pattern: gap, tab, gap, tab, …, gap (N tabs, N+1 gaps = 2N+1 segments).
function _seg_w(seam_len, n_tabs) = seam_len / (2 * n_tabs + 1);

// One tab per ~25mm of seam, minimum 3.
function default_tab_count(seam_len) = max(3, floor(seam_len / 25));

// Tabs protruding from y=0 into +Y. Union with the body.
module finger_tabs(seam_len, thickness, n_tabs=undef,
                   finger_depth=FINGER_DEPTH, tol=FINGER_TOL) {
    n = is_undef(n_tabs) ? default_tab_count(seam_len) : n_tabs;
    w = _seg_w(seam_len, n);
    for (i = [0:n-1]) {
        x = (2*i + 1) * w;
        translate([x + tol, -EPS, 0])
            cube([w - 2*tol, finger_depth + EPS, thickness]);
    }
}

// Slot cutouts from y=0 into +Y. Difference from the body.
module finger_slots(seam_len, thickness, n_tabs=undef,
                    finger_depth=FINGER_DEPTH, tol=FINGER_TOL) {
    n = is_undef(n_tabs) ? default_tab_count(seam_len) : n_tabs;
    w = _seg_w(seam_len, n);
    for (i = [0:n-1]) {
        x = (2*i + 1) * w;
        translate([x, -EPS, -EPS])
            cube([w, finger_depth + EPS, thickness + 2*EPS]);
    }
}

// Woven variant: tab/slot at explicit X centers, each a given (narrow) width.
// Lets the joinery route AROUND a row of holes — tabs occupy the inter-hole
// gaps and the holes stay clean on the grid. Pair finger_tabs_at on one piece
// with finger_slots_at on the matching piece using the same x_centers.

module finger_tabs_at(x_centers, tab_w, thickness,
                      finger_depth=FINGER_DEPTH, tol=FINGER_TOL) {
    for (x = x_centers)
        translate([x - (tab_w - 2*tol)/2, -EPS, 0])
            cube([tab_w - 2*tol, finger_depth + EPS, thickness]);
}

module finger_slots_at(x_centers, tab_w, thickness,
                       finger_depth=FINGER_DEPTH, tol=FINGER_TOL) {
    for (x = x_centers)
        translate([x - tab_w/2, -EPS, -EPS])
            cube([tab_w, finger_depth + EPS, thickness + 2*EPS]);
}
