// Yet-another hardware asset containment kit (YaHACK)
// (C)2024 drmn4ea at gmail
// License: CC BY-SA (https://creativecommons.org/licenses/by-sa/4.0/)

// Common settings file. This keeps the less-likely-to-change variables and interoperability 'standards'
// separate from the per-project settings. Of course, there is nothing set in stone, but if you modify this,
// ensure any projects you want to stack are using the same settings.

shelf_clearance = 0.6; // width/thickness clearances



// Endplate slot settings

end_plate_slot_clearance = 0.6;
end_plate_capture_thickness = 3; // Additional wall thickness beyond endplate to hold it in place


// Stacking feature settings
stacking_pillar_pin_dia = 5; // Diameter of mating portion of stacking pins
stacking_pillar_height = 5; // Height of mating portion
stacking_pillar_bolster_dia = 10; // Diameter of bolster/receptacle for mating pins
stacking_pillar_clearance = 0.9; // Clearance between pin & receptacle
stacking_pillar_pitch = 50; // Add a pillar every this many mm

// All-important openSCAD fudge factor added to face geometry that would otherwise exactly touch
// (makes preview less of a mess)
fudge = 0.01;
