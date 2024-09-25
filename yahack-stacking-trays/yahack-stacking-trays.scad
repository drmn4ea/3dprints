// Yet-another hardware asset containment kit (YaHACK)
// (C)2024 drmn4ea at gmail
// License: CC BY-SA (https://creativecommons.org/licenses/by-sa/4.0/)

// Common settings
include <yahack-settings.scad>

// Inner x,y,z volume available for your project. Note the box is orented with the endcaps in the X direction
// All features grow outward from this volume, so the outer box dimensions will be somewhat larger.


box_inner_volume_x = 51; // depth (distance between endplates)
box_inner_volume_y = 15; // width
box_inner_volume_z = 10; // height



// Sidewall parameters.
shelf_ledge_width = 3; // Width of shelf mounting ledges (cut into wall);
wall_thickness = 2.5; // Solid outer wall portion, total wall thickness is the sum of this, shelf_ledge_width and any additional clearance
shelf_thickness = 1.7; // Thickness of the shelf material

shelf_pitch = 10; // put a shelf every this many mm


// Floor and ceiling settings. Keep at least one unless you really know what you're doing, otherwise
// you just have two disconnected walls. If you want the halves held together without getting in your way,
// try the 'open' style. Yeah, this could be prettier.

// Styles:
//   0: normal, solid surface
//   1: hexgrid, good to save plastic or if some airflow between boxes is needed
//   2: open, only connects the walls at the endcaps and leaves the area above the inner volume open

use_floor = true;
floor_style = 2; // 0: normal, 1: hexgrid, 2: open
use_ceiling = true;
ceiling_style = 2;
floor_ceiling_thickness = 5.5;

// Endplate slot settings
end_plate_slot_thickness = 0.9; // Nominal thickness of your endplate stock



//// global math
total_height = box_inner_volume_z + (floor_ceiling_thickness*2);
// Total width excluding stacking features
total_box_width = box_inner_volume_y + 2*(wall_thickness + shelf_ledge_width);
// Additional length at front/rear to accommodate endplates
endwall_total_thickness = end_plate_slot_thickness + end_plate_slot_clearance + end_plate_capture_thickness;

// shelf_clearance
shelfwall_total_thickness = wall_thickness + shelf_ledge_width + (1*shelf_clearance); // FIXME: was 2x, why?
shelfwall_total_length = box_inner_volume_x + (2*endwall_total_thickness);
// TODO: Fix invalid settings (e.g. stacking feature depth taller than total height

// For convenience, output the recommended shelf dimensions. Yes, the user basically just entered them, but
// they can be spat out together with the endplate dimensions, which are a bit less obvious.
// Dimension order assumes sitting/printing flat.
echo(str("Recommended shelf dimensions: X (length) = ", box_inner_volume_x, "Y (width) = ", box_inner_volume_y + (2* shelf_ledge_width), "Z (thickness) = ", shelf_thickness));


// do it!


difference()
{
    // Main body with no endslots
    main();
    // Cut the endslots from the whole thing
    translate([box_inner_volume_x/2,0,0])
    {
        endslot();
    }
    translate([-box_inner_volume_x/2,0,0])
    {
        mirror([1, 0, 0])
        {
            endslot();
        }
    }
}


module main()
{
    // Do some math
    // Offset stacking pillar center by total bolster receptacle radius from outside wall
    old_stacking_pillar_offset = ((stacking_pillar_bolster_dia/2)+shelf_ledge_width + shelf_clearance);
    
    stacking_pillar_edge_offset = shelfwall_total_thickness + (stacking_pillar_clearance + stacking_pillar_pin_dia)/2;
    stacking_pillar_abs_offset = (box_inner_volume_y/2) + stacking_pillar_edge_offset;
    
    echo("Old pillar offset:" , old_stacking_pillar_offset);
    echo("New pillar offset:" , stacking_pillar_edge_offset);
    
    echo("Pillar center-to-center distance:" , stacking_pillar_abs_offset*2);
    
    //((stacking_pillar_bolster_dia/2)+shelf_ledge_width + shelf_clearance  + (1*wall_thickness));

//stacking_pillar_pin_dia = 5; // Diameter of mating portion of stacking pins
//stacking_pillar_height = 5; // Height of mating portion
//stacking_pillar_bolster_dia = 10; // Diameter of bolster/receptacle for mating pins
//stacking_pillar_clearance = 0.6; // Clearance between pin & receptacle


    // For diagnostic purposes only, show the actual volume we are to enclose without interfering
    //cube([box_inner_volume_x, box_inner_volume_y, box_inner_volume_z], center=true);

    // Add the stacking pins on both sides along the depth volume, offset so that they are just outside it
    // "n_pillar_steps" is the number of pillars stepped and repeated beyond the required 1st, which occurs at a fixed depth offset
    // Enforce non-negative value in pathalogical cases where the minimum depth wasn't met and place the 0th pillars anyway
    n_pillar_steps = max(-1, floor((box_inner_volume_x+(2*endwall_total_thickness) - stacking_pillar_bolster_dia)/stacking_pillar_pitch));
    
    echo(n_pillar_steps);
    
//        translate([0, box_inner_volume_y/2 + shelfwall_total_thickness, 0])
//    {
//        pinrow(2, 10);
//    }
    
    //endwall_total_thickness // +(endwall_total_thickness/2)
    //depth_offset = 0;
    // Nudge the edge of the pillars flush with the front face:
    // account for pillar's radius
    depth_offset = -(box_inner_volume_x/2) - endwall_total_thickness + (stacking_pillar_bolster_dia/2);
    translate([depth_offset, stacking_pillar_abs_offset, -total_height/2])
    {

        pinrow(n_pillar_steps, stacking_pillar_pitch);


    }

    translate([depth_offset, -stacking_pillar_abs_offset, -total_height/2])
    {
        pinrow(n_pillar_steps, stacking_pillar_pitch);
    }
    
    // Add the sidewalls with the shelf features
    both_shelfwalls();
    
    // Add the floor and ceiling
    // Funky names because floor/ceiling are reserved math keywords
    // Make the floor/ceil as wide as the sidewalls
    floor_ceil_x = box_inner_volume_x + (2*endwall_total_thickness);
    floor_ceil_y = total_box_width;
    
    translate([0,0,-box_inner_volume_z/2])
    {
        if(use_floor)
        {
            afloor(floor_ceil_x, floor_ceil_y, floor_ceiling_thickness, floor_style);
        }
    }
    translate([0,0,box_inner_volume_z/2])
    {
        if(use_ceiling)
        {
            mirror([0,0,1])
            {
                afloor(floor_ceil_x, floor_ceil_y, floor_ceiling_thickness, ceiling_style);
            }
        }
    }
}

module afloor(x, y, z, style)
{
    // Offset so floor grows outward from starting dimension
    translate([0,0,-z/2])
    {
        //cube([box_inner_volume_x, y, z+fudge], center=true);    //debug
        // Make the floor as wide as the sidewalls
        
        // WART: Building the floor/ceil as a single piece as long as the entire sidewall (including endslot areas),
        // but don't want any carving/greebling to extend into that area. So need to constrain any such operation
        // to box_inner_volume_x
        
        difference()
        {
            cube([x, y, z], center=true);
            //0: normal, 1: hexgrid, 2: open
            if(style==1) // hexgrid
            {
                intersection()
                {
                    hexgrid(x, y, z+fudge);
                    cube([box_inner_volume_x, y, z+fudge], center=true);    
                }
            }
            if(style==2) // open
            {
                // just subtract the entire inner volume and leave just the slot ends
                cube([box_inner_volume_x, y, z+fudge], center=true);    
            }
        }
    }

}


module endslot()
{
    // Offset so geometry grows outward from starting dimension

    slot_dia = end_plate_slot_thickness + end_plate_slot_clearance;
    // "inner" = without slot_dia
    slot_inner_width = box_inner_volume_y + (2*shelf_ledge_width)-slot_dia + (2*end_plate_slot_clearance);
    slot_inner_height = total_height-floor_ceiling_thickness-slot_dia;

    // Endplate slot is implemented by creating the endplate and subtracting it to form the slot cutouts
    // Nominally, the endplate slots are the same width as the shelf ledges, but extended by the clearance amount on each side.

    // The location for the endplate has shallow slots to hold it captive on 3 sides
    // and a larger (open) slot on top to allow for installation.
    // Compute height to add to form the installation slot
    extra_slot_height = floor_ceiling_thickness+fudge;


    // TODO: Support choice of slot install direction if folks are clamoring for it.
    // For now, KISS and slots (if used) are installed from the top while stacking modules.
    
        
    //echo(extra_slot_height);
    translate([slot_dia/2,0,0])
    {
        // slot
        // This is ugly. Want to round (actually bevel) the corners of the slot to provide a limited overhang
        // so it can be printed in a couple logical orientations without adding supports in the slot.
        // Using a rectangular plate to cut the slot, but faking it a bit by shrinking the plate slightly
        // and adding low-poly cylinders along the outer edges
        //cube([end_plate_slot_thickness + end_plate_slot_clearance, total_box_width, total_height], center=true);
        hull()
        {
            translate([0, (slot_inner_width )/2, extra_slot_height/2])
            {
                // righthand side
                cylinder(h=slot_inner_height + extra_slot_height, d=slot_dia, center=true, $fn=8);
            }
            translate([0, -(slot_inner_width )/2, extra_slot_height/2])
            {
                // lefthand side
                cylinder(h=slot_inner_height + extra_slot_height, d=slot_dia, center=true, $fn=8);
            }
            translate([0, 0, (slot_inner_height /2) + extra_slot_height])
            {
                // top
                rotate([90,00,0])
                {
                    cylinder(h=slot_inner_width, d=slot_dia, center=true, $fn=8);
                }
            }
            translate([0, 0, -(slot_inner_height)/2])
            {
                // bottom
                rotate([90,00,0])
                {
                    cylinder(h=slot_inner_width, d=slot_dia, center=true, $fn=8);
                }
            }
        }
    }
    // Output recommendation for endplate dimensions. Thickness is obvious, width is sum of project volume and shelf width; suggested height is shy of the top by 1/2 the ceiling thickness to ensure it's not left sticking out the top if there are tolerance issues here and there, interfering with the next module stacking.
    // Presumably the user will think of and print the plate flat (if printing), so orient the 'XYZ' order that way.
    echo(str("Recommended endplate dimensions: X (width) = ", box_inner_volume_y + (2*shelf_ledge_width), ", Y (height) = ", total_height-(floor_ceiling_thickness/2), ", Z (thickness) = ", end_plate_slot_thickness));
// debug, show bounding dimensions
//translate([15, 0, 05])
//    {
//        cube([end_plate_slot_thickness , box_inner_volume_y + (2*shelf_ledge_width), total_height-(floor_ceiling_thickness/2)], center=true);
//    }

}


module both_shelfwalls()
{
        // Add the sidewalls with shelf notches
    translate([0,box_inner_volume_y/2,0])
    {
        shelfwall();
    }
    mirror([0,1,0])
    {
    translate([0,box_inner_volume_y/2,0])
    {

        {
            shelfwall();
        }
    }
}
}


module shelfwall()
{

    
    // Shift so that wall is built outward from starting Y dimension
    translate([0,shelfwall_total_thickness/2,0])
    {
        difference()
        {
            cube([shelfwall_total_length, shelfwall_total_thickness, box_inner_volume_z+floor_ceiling_thickness+floor_ceiling_thickness], center=true);

            //offset to outside face of box
            translate([0,(-shelfwall_total_thickness/2)-fudge,0])
            {
                //raise off floor by shelf_pitch
                // FIXME: Prevent partial top shelf
                for(i=[0:shelf_pitch:box_inner_volume_z])
                {
                    // Top of lowest shelf starts flush with defined inner volume. This is an arguable decision...
                    translate([0,0,(-box_inner_volume_z/2) + i])
                    {
                        // KISS/TODO: It would look nicer if the shelf slots didn't extend beyond the endplates,
                        // but then you couldn't install the shelves...
                        // Could split the difference and only leave it open in the back, but it's more work.
                        shelfnotch(shelfwall_total_length + fudge);
                    }
                }
            }
        }
    }
}

module shelfnotch(length)
{
    shelf_extent = shelf_ledge_width + shelf_clearance;
    {    
        rotate([00,00,90])
        {
            rotate([90,0,00])
            {
                linear_extrude(height=length+fudge, center=true)
                {
                    // last point gives a 45 degree angle that should print safely without support
                    polygon([[0, 0], [shelf_extent,0], [shelf_extent,shelf_thickness], [0,shelf_thickness+shelf_extent]]);
                }
            }
        }
    }
}


module pinrow(n, pitch)
{
    for(k=[0:n])
    {
        translate([k*pitch, 0, 0])
        {
            pin();
        }
    }
}


module pin()
{
    
    union() {
        difference() 
        {
            // bolster
            cylinder(d=stacking_pillar_bolster_dia, h=total_height, $fn=100);
            translate([0,0,-fudge]) //-total_height/2
            {
                // receiving hole
                cylinder(d=stacking_pillar_pin_dia+stacking_pillar_clearance, h=stacking_pillar_height+(2*fudge), $fn=100);
            }
        }
        translate([0, 0, total_height])
       {
           // small mating pin
           cylinder(d=stacking_pillar_pin_dia, h=stacking_pillar_height, $fn=100);
       }
    }
}


module hexgrid(x, y, z, cell_size=10, cell_spacing=3)
{


    cell_pitch_x = (cell_size + cell_spacing)*(sqrt(3)/2);
    cell_pitch_y = (cell_size + cell_spacing);
    cell_offset_y = (cell_size + cell_spacing)/2;


    // want the pattern to extend beyond the surface to be cut by it
    num_x = ceil(x/cell_pitch_x);
    num_y = ceil(y/cell_pitch_y);
    pattern_size_x = ((num_x + 1) * cell_pitch_x);
    pattern_size_y = ((num_y + 1) * cell_pitch_y + cell_offset_y);

    //cube([pattern_size_x, pattern_size_y, 0.1], center=true); // debug, show enclosed area calculation

    translate([-(pattern_size_x-cell_pitch_x)/2, -(pattern_size_y-cell_pitch_y)/2, -z/2])
    {
        
        for (i=[0:num_x])
        {
            for (j=[0:num_y])
            {
                translate([i*cell_pitch_x, (j*cell_pitch_y) +(i%2)*cell_offset_y , 0])
                {
                    // constant compensates for effective diameter loss vs. a perfect circle ($fn=99999)
                    cylinder(d=cell_size*1.15, h=z, $fn=6);
                }
            }
        }
    }
}