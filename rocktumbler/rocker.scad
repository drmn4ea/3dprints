
inch = 25.4;




peak_inner_dia = 156; // Inner diameter at widest point
wall_thickness = 3;
rib_dia = 10; // Diameter of strengthening ribs

total_height = 6*inch; // Total height including recess for protruding 'nubbin' on bottom of Lot-O barrel
bottom_nubbin_height = 0.75*inch; // Height of recess for nubbin
bottom_nubbin_clearance_dia = 1*inch; // Clearance diameter of nubbin recess (should slightly exceed actual nubbin diameter)

taper_start_height = 4 * inch; // Height where taper should begin. FIXME
taper_angle = 10; // degrees
fudge = 0.01; // Fudge factor for surfaces that exactly touch

// Mount plate
plate_thickness = 20; // Min thickness of mounting plate (where tangent to bucket; it will be thicker elsewhere)
bolt_pattern_width = 45;//45;
bolt_pattern_height = 92;
bolt_dia = .300*inch;
surround_width = 5;
bolt_head_recess_depth = 10;
bolt_head_recess_dia = 25;
// bounding 11 x 6cm

// Attachment features
// FIXME
//rope holes
rope_hole_dia = 8;
// rubber band mounts



// Math some stuff
wall_thickness_dia = wall_thickness * 2;
main_height = total_height - bottom_nubbin_height;
bottom_inner_dia = peak_inner_dia - ((taper_start_height) * tan(taper_angle)*2);//peak_inner_dia - ((total_height - taper_start_height-wall_thickness)
echo("Bottom inner dia: ",bottom_inner_dia);

// mount plate math
plate_h = bolt_pattern_height + bolt_head_recess_dia + (2*surround_width);
plate_w = bolt_pattern_width + bolt_head_recess_dia + (2*surround_width);
plate_distance_to_edge = (peak_inner_dia+wall_thickness_dia)/2; // distance from center to outer wall
plate_start_height = (main_height-plate_h)/2; // offset from the bottom of bucket
plate_end_height = main_height - plate_start_height; // assuming plate is centered
// "0" plane is where main bucket meets top of nubbin

rib_list = [plate_start_height+rib_dia, main_height/2, plate_end_height-rib_dia]; // rib placements

//rope holes
top_mountplate_hole_to_rope_hole = 15; // Distance below top mounting hole to start opening for rope, this should be below the 'foot' on the vibrating motor.

if(rib_dia > plate_thickness)
{
    echo("WARNING: Rib thickness should not exceed plate thickness");
}
if(rope_hole_dia > plate_thickness)
{
    echo("WARNING: Rope hole diameter should not exceed plate thickness");
}


difference()
{
    // Main bucket
    union()
    {
        translate([0, 0, -bottom_nubbin_height])
        {
            // bottom nubbin excursion
            cylinder(bottom_nubbin_height + fudge, d=bottom_nubbin_clearance_dia + wall_thickness_dia, center=false);
        }
        // bucket
        cylinder(main_height, d=peak_inner_dia+wall_thickness_dia, center=false);
        mountplate();
        
        // Horizontal load-bearing ribs
        for(i=rib_list)
        {
            translate([0, 0 , i])
            {
                rib();
            }
        }
        // Other strengthening members
        translate([0,-plate_distance_to_edge,0])
        {
            cylinder(plate_end_height, d=rib_dia*2); // double dia since half of it will be inside the wall
        }
        translate([0,plate_distance_to_edge,0])
        {
            cylinder(plate_end_height, d=rib_dia*2); // double dia since half of it will be inside the wall
        }
        rotate([90,00,00])
        {
            cylinder((plate_distance_to_edge + rib_dia)*2, d=rib_dia*2, center=true); // double dia since half of it will be inside the wall
            //cube([10,10,10]);
        }
        // bottom support
        translate([0, 0, -rib_dia])
        {
            cylinder(rib_dia, d=bottom_nubbin_clearance_dia + (2*rib_dia) );
        }
    }
    // cut out inner volume of bucket
    // straight upper part
    translate([0, 0, taper_start_height - fudge])
    {
        cylinder(main_height, d=peak_inner_dia, center=false);
    }
    // lower taper
    translate([0, 0, wall_thickness])
    {
        cylinder(taper_start_height - wall_thickness, d1=bottom_inner_dia, d2=peak_inner_dia, center=false);
    }
    
    translate([0, 0, -bottom_nubbin_height + wall_thickness])
    {
        // cutout for nubbin in bottom nubbin excursion
        cylinder(bottom_nubbin_height + fudge, d=bottom_nubbin_clearance_dia, center=false);
    }
    
    boltholes();
    
    // Far side rope holes; for convenience the mount plate rope feature is handled in the mountplate module
    translate([0, 0, rib_list[len(rib_list)-1]-rib_dia-(rope_hole_dia/2)])
    {
        ropeholes();
    }
    
}

module tiedown()
{
    
}
module mountplate()
{
    // begin at -y coordinate tangent to outer wall + actual thickness, extend all the way to center, that part will be cut away later
    translate([-plate_w/2, -(plate_distance_to_edge + plate_thickness), plate_start_height])
    {
        // the mount plate, extended into center of bucket
        cube([plate_w, plate_distance_to_edge + plate_thickness, plate_h], center=false);
    }
}

module ropeholes()
{
    for (i=[-45, 45])
    {
        rotate([-90, 0, i])
        {
            cylinder(plate_distance_to_edge + 10, d=rope_hole_dia);
        }
    }
}

module boltholes()
{
    // begin at -y coordinate tangent to outer wall + actual thickness, extend all the way into center of bucket, that part will be cut away later
    translate([-plate_w/2, -(plate_distance_to_edge + plate_thickness), (main_height-plate_h)/2])
    {
        // move to center of outside face of mount plate
        translate([plate_w/2, 0, plate_h/2])
        {
            for (x = [-bolt_pattern_width/2, bolt_pattern_width/2])
            {
                for (z = [-bolt_pattern_height/2, bolt_pattern_height/2])
                {
                    translate([x, -fudge, z])
                    {
                        rotate([-90, 0, 0])
                        {
                            // full depth thru-hole
                            cylinder(plate_h, d=bolt_dia);
                            // step in to add the inside countersink
                            translate([0, 0, plate_thickness - bolt_head_recess_depth])
                            {
                                cylinder(plate_h, d=bolt_head_recess_dia);
                            }
                        }
                    }
                }
            }
            // Opening for rope to pass under motor
            translate([0, 0, (bolt_pattern_height/2) - top_mountplate_hole_to_rope_hole - (rope_hole_dia/2)]) 
            {
                rotate([0,90,0])
                {
                    cylinder(plate_w+fudge, d=rope_hole_dia, center=true);
                }
                    
            }
        }
    }
}

module rib()
{
    rotate_extrude(convexity = 10)
    {
        translate([plate_distance_to_edge, 0, 0])
        {
            circle(r = rib_dia, $fn=4);
        }
    }
}

