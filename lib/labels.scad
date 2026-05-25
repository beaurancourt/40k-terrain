// Debossed labels for identifying terrain pieces by their dimensions.
//
// Text is recessed into the bottom face (z=0) and mirrored in X so it reads
// correctly when the printed piece is flipped over to view its bottom.

include <units.scad>;

LABEL_SIZE  = 6;     // text height, mm
LABEL_DEPTH = 0.6;   // depth of the recess, mm
LABEL_FONT  = "Liberation Sans:style=Bold";

// Recessed text centered at (x, y) on the z=0 face. Subtract from the piece
// body. Empty string is a no-op.
module label_cut(text_str, x, y, size=LABEL_SIZE) {
    if (text_str != "")
        translate([x, y, -EPS])
            linear_extrude(height=LABEL_DEPTH + EPS)
                mirror([1, 0, 0])
                    text(text_str, size=size, halign="center", valign="center",
                         font=LABEL_FONT);
}
