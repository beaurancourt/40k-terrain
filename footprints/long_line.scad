// Long line footprint — 10" × 2.5" (254 × 63.5 mm). Single piece.
// 254mm leaves ~2mm of margin on a 256mm bed: print without a brim and
// confirm your printer's actual usable area before committing a long print.

include <../lib/units.scad>;
include <../lib/footprint.scad>;

W = inches(10);
D = inches(2.5);

rect_footprint(W, D);
