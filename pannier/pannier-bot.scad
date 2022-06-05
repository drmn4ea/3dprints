// Replacement bracket for Bontrager 'City Shopping (2008)' bicycle pannier (bike bag).
// By: Drmn4ea (drmn4ea at gmail)
// This is the 'bag' side of the clip assembly that mates with the original clip, and can be fixed to the bag with bolts (or riveted like the original).
// License: Creative Commons CC BY-SA


$fn=25;

// Scale factor (inches to mm)
s = 25.4;

bolt_od = 0.162; // diameter of the bolt (formerly rivet) holes

bolt_offset = 0.45; // bolt center distance from bottom edge

clipholder_bolt_insert_od = .300; // diameter of bolt insert; needs to be known and consistent to main script and clipholder module


difference()
{
    // making the main plate 2.3 wide x 2.8 tall.
    linear_extrude(height = .190*s, center = false, convexity = 10)
    {
        polygon(points=[[-0.40*s,0], [0.40*s,0], [1.45*s,2.8*s], [-1.45*s,2.8*s] ]);
    }

    // add the 3 outer bolt holes
    // The baseplate is intentionally a bit larger than the original (+.266,.35) for robustness,
    // split the difference a bit for the hole placements
    translate([0,bolt_offset*s,0])
    {
        translate([0,0,0])
        {
            cylinder(h=20, r=bolt_od*s/2, center=true);
        }

        translate([(1.5/2)*s, 1.8*s, 0])
        {
            cylinder(h=20, r=bolt_od*s/2, center=true);
        }

        translate([(-1.5/2)*s, 1.8*s, 0])
        {
            cylinder(h=20, r=bolt_od*s/2, center=true);
        }

        // FIXME: hole for clip holder bolt insert
        translate([0, 1.8*s, 0])
        {
            cylinder(h=50, r=clipholder_bolt_insert_od*s/2, center=true);
        }
        // Add the opening for the retention latch, beginning ~0.9" above the bottom screwhole; .460 x .600
        translate([0, (0.9+.3)*s, 0])
        {
            cube([.46*s, .6*s, 20], center=true);
        }
        

    }
}

// Add the retention latch

// Add the clip holder
// start at the same offset as the bolt holes
translate([0,(bolt_offset+0.9+.3)*s,0])
{
    latch(s);
}

translate([0,(bolt_offset+1.8)*s,(.190*s)-.001])
{
    clipholder(s, clipholder_bolt_insert_od);
}


module latch(s)
{
    size = [0.4*s, 0.6*s, .125*s]; // bounding dimensions of the latch feature
    t = 0.05*s; // thickness
    attach_angle = 30; // angle on the attaching side
    detach_angle = 15; // angle on the detaching side
    x = size[0];
    y = size[1];
    z = size[2];
    translate([-x/2,-y/2,z])
    {
        rotate([attach_angle,0,0])
        {
            // WARNING: Major fudging here since this is a one-off and I can't be arsed to do the math
            attach_len = z*(1/sin(attach_angle));
            cube(size=[x, attach_len, t], center=false);
            translate([0, attach_len, 0])
            {
                rotate([-detach_angle-attach_angle,0,0])
                {

                    translate([0, -t/1.5, -t/3]) // fudge 2nd cube into 2st one in easier frame of reference
                    {
                        detach_len = z*(1/sin(detach_angle));
                        cube(size=[x, detach_len-(t*2), t], center=false);
                    }
                }
            }
        }
    }
}

module clipholder(s, clipholder_bolt_insert_od)
{

    size = [0.69*s, 0.375*s, 0.275*s]; // outer dimensions of the clip holder feature
    notch_size = [.075*s, .1*s]; // [x, y] dimensions of the notches on either end
    center_hole_dia = 0.193*s; 
    center_spring_face_dia = 0.350*s;

    // FIXME: clipholder_bolt_insert_od

    translate([0, 0, size[2]/2])
    {
        difference()
        {
            // the main feature
            roundedcube(size, center=true, radius=0.125*s, apply_to = "z");
            
            // hole for bolt insert - goes *almost* all the way through!
            translate([0, 0, -0.06*s])
            {
                cylinder(h=size[2], r=clipholder_bolt_insert_od*s/2, center=true);
            }
            
            //bolt hole
            cylinder(h=size[2]+1, r=center_hole_dia/2, center=true);
            

        
            //spring retention feature
            translate([0,0,size[2]/2])
            {
                cylinder(h=.035*s*2, r=center_spring_face_dia/2, center=true);
            }
            
            // the slots on either side
            translate([-(size[0]/2 - notch_size[0]/2), 0 , 0])
            {
                cube([notch_size[0]+.001, notch_size[1]+.001, size[2]+1], center=true);
            }
            translate([+(size[0]/2 - notch_size[0]/2), 0 , 0])
            {
                cube([notch_size[0]+.001, notch_size[1]+.001, size[2]+1], center=true);
            }
        }
    }
}

// from https://danielupshaw.com/openscad-rounded-corners/
module roundedcube(size = [1, 1, 1], center = false, radius = 0.5, apply_to = "all") {
	// If single value, convert to [x, y, z] vector
	size = (size[0] == undef) ? [size, size, size] : size;

	translate_min = radius;
	translate_xmax = size[0] - radius;
	translate_ymax = size[1] - radius;
	translate_zmax = size[2] - radius;

	diameter = radius * 2;

	obj_translate = (center == false) ?
		[0, 0, 0] : [
			-(size[0] / 2),
			-(size[1] / 2),
			-(size[2] / 2)
		];

	translate(v = obj_translate) {
		hull() {
			for (translate_x = [translate_min, translate_xmax]) {
				x_at = (translate_x == translate_min) ? "min" : "max";
				for (translate_y = [translate_min, translate_ymax]) {
					y_at = (translate_y == translate_min) ? "min" : "max";
					for (translate_z = [translate_min, translate_zmax]) {
						z_at = (translate_z == translate_min) ? "min" : "max";

						translate(v = [translate_x, translate_y, translate_z])
						if (
							(apply_to == "all") ||
							(apply_to == "xmin" && x_at == "min") || (apply_to == "xmax" && x_at == "max") ||
							(apply_to == "ymin" && y_at == "min") || (apply_to == "ymax" && y_at == "max") ||
							(apply_to == "zmin" && z_at == "min") || (apply_to == "zmax" && z_at == "max")
						) {
							sphere(r = radius);
						} else {
							rotate = 
								(apply_to == "xmin" || apply_to == "xmax" || apply_to == "x") ? [0, 90, 0] : (
								(apply_to == "ymin" || apply_to == "ymax" || apply_to == "y") ? [90, 90, 0] :
								[0, 0, 0]
							);
							rotate(a = rotate)
							cylinder(h = diameter, r = radius, center = true);
						}
					}
				}
			}
		}
	}
}



