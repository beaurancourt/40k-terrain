// Medium rectangle footprint — 6" × 4" (152.4 × 101.6 mm). Single piece.

include <../lib/units.scad>;
include <../lib/footprint.scad>;

W = inches(6);
D = inches(4);

rect_footprint(W, D);
