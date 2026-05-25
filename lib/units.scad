// Shared units and constants for the 40k terrain project.

INCH = 25.4;
PRINTER_BED = 256; // mm — max single-piece dimension before splitting
EPS = 0.01;        // small offset for clean boolean operations

function inches(n) = n * INCH;
