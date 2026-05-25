// Short line footprint — 6" × 2" (152.4 × 50.8 mm). Single piece.

include <../lib/units.scad>;
include <../lib/footprint.scad>;

W = inches(6);
D = inches(2);

rect_footprint(W, D);
