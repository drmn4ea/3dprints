
// Replacement twinwall clip for Palram Mythos (possibly others) greehouses
// By: Drmn4ea (drmn4ea at gmail)
// License: Creative Commons CC BY-SA

// These small plastic clips snap into holes on the outside of the greenhouse near
// the base of each polycarbonate twinwall panel (window), holding it in place.
// This clip doesn't look as svelte (flimsy) as the original, but should get the job done while being easy to print.
// My best results were with printing this model oriented with the 'clip' prongs flush against the buildpate (no supports needed), but YMMV.

// In the below, 'contacting face' is the face of the clip that contacts the twinwall, and 'bottom face' is the bottom that sits flush with the greenhouse base when clipped in.

w = .700*25.4; // Width of the contacting face (the one touching the XZ plane)
h = .500*25.4; // .520 Height of the contacting face

foot = h-(.080*25.4); // Amount of extra recessed post to give it enough spring at the 'neck' where it clips in
ankle = .000*25.4; // Distance between the topmost part of the foot and where the post slot should begin. Should be a small but non-zero value for (maybe) extra mechanical stability.

post_dia = .340*25.4; //.310 //OD of the post
post_slimmed_diameter_percent = 30; // Post will be slimmed (trimmed down) on the axis perpendicular to the direction it squeezes, both to help it fit the hole and make it more springy. Here set the percentage diameter in the slimmed direction (0-100)

post_shoulder_width = .030*25.4; // Width clip retention "shoulders" extend beyond main post diameter on each side
post_length = .350*25.4; // Amount of usable post extending beyond bottom face
post_center_to_edge = .200*25.4; // Distance of post/hole center from contacting face 

post_taper_percent = 80; // Change in diameter between top & bottom of tapered portion
post_slot_percent = 50; // Post slot width, in percentage of total post diameter
neck_length = .040 * 25.4; // Length of click-in neck from bottom face. may be ~130-150
//neckdown = .020 * 25.4; // Depth (amount of radius reduction) of neck feature from post OD
overhang_degrees = 90; // Allowed overhang angle on neck, between 0 (none, stovepipe) and 90 (full, flat, non-printable by mortals). 45-60 is probably about right.

default_fn = 100; // Default value of $fn
fudge_factor = 0.001; // Tiny fudge factor where geometry exactly touches

// The contacting face is the one touching the XZ plane.

post_slimmed_dia = post_dia*(post_slimmed_diameter_percent/100);

d = post_center_to_edge + (post_slimmed_dia/2); //.550*25.4; // Thickness of the whole thing, must be suitably larger than post_center_to_edge below

// debugging area
translate([-2,0,0])
{


}


// The main body and recess for the post
difference()
{
    cube([w,d,h], false); // the main body
//    translate([-d_outer/2, (-d_inner/2)*(post_slimmed_diameter_percent/100), 0])
//    {
//        cube([d_outer, d_inner*(post_slimmed_diameter_percent/100), post_length+h], center=false);
//    }
    translate([(w/2)-(d_outer/2), post_center_to_edge-(post_slimmed_dia/2), -fudge_factor])
    {
        // clearance around the post where it connects to the main body
        // the actual connection point is raised up (or sunken in, if looking up from the bottom)
        // by 'foot' to allow for a bit of springiness and distribute stress, as in 
        // the original part
        // Cut a 'house' shape around the post, with the roof shaped to limit the overhang
        // on the side that will face up during printing
        cube([d_outer, d_inner*(post_slimmed_diameter_percent/100), foot+(fudge_factor*2)], center=false);
        rotate([0,0,-45])
        {

            translate([0, (d_outer/2)*0, 0])
            {
                    cube([sqrt((d_outer*d_outer)/2), sqrt((d_outer*d_outer)/2), foot+(fudge_factor*2)], center=false);


            }
        }        
    }
}

// The post
// For convenience and mainly legacy reasons, the post and retention shoulders are defined in terms of a larger OD that gets carved or necked down to the real diameter.
outer_post_dia = post_dia + (post_shoulder_width * 2);
// Set up a couple vars related to the necked-down portion of the post.
// Mainly we need to know the height of an anti-overhang bevel ahead of time.
d_inner = post_dia;
d_outer = outer_post_dia;
// reach through the cobwebs back to highschool math, trig identities
// and get the cylinder height that produces the specified angle vs. the known diameter change (depth of the cut)
delta_d = d_outer - d_inner;
bevel_h = delta_d / tan(overhang_degrees);
//neck_length_full = neck_length + bevel_h;
neck_length_full = neck_length + foot - ankle;



translate([w/2, post_center_to_edge, 0-post_length])
{
    intersection()
    {
        // Post can be oversized in the direction it can squeeze, but not the other.
        // Bound the two non-squeezy sides post by a bounding box only as wide as the 
        // necked down portion of the post, so the non-squeezy sides still fit the hole.
        // This should make it easier to install. 
        // The original part had very thin blades rather than a rounded post at all...
        translate([-d_outer/2, (-d_inner/2)*(post_slimmed_diameter_percent/100), 0])
        {
            cube([d_outer, d_inner*(post_slimmed_diameter_percent/100), post_length+h], center=false);
        }
        difference()
        {
            union()
            {
                // The main body of the post, with a bit of taper to aid assembly
                // Make the tapered post by stacking a straight cylinder atop a tapered one, and adding the neck to the straight part. This simplifies adding an anti-overhang bevel to it later
                cylinder(post_length-neck_length, d1=outer_post_dia*(1-post_taper_percent/100.0), d2=outer_post_dia, false, $fn=default_fn);

                translate([0, 0, post_length-neck_length])
                {
                    cylinder(post_length+foot, d=outer_post_dia, false, $fn=default_fn);
                }
            }
            // Slot in the middle of the post
            slot_width = post_dia*(post_slot_percent/100.0);
            translate([-slot_width/2,(-post_dia/2),0]) // center the slot
            {
                // Actual slot cutout, extend most of the way down the foot
                cube([slot_width ,post_dia,post_length+(foot-ankle)], false);
            }
            // Stretched pyramid to carve the slot wider near the bottom so the sides can squeeze together more flush
            // (actually a cylinder with very low $fn rotated the right way)
            scale([1,10,1])
            {
                rotate([0,0,45])
                    {
                        // Assuming the post should be able to fully squeeze together at the bottom of the neck, the angle we need to carve out basically undoes the squeeze (slot width going from normal to zero between over the distance of post_length + foot).
                       // Consider the angle formed by a zero-width wedge starting at the top of the slot and reaching its edges at the bottom of the neck, and extending with that same angle to infinity (or at least to the bottom of the post). Its total width at the bottom of the post would be the slot width times the ratio of the slot length to the bottom of the neck to the total post/slot length.
                        cylinder(post_length+(foot-ankle), d1=slot_width/((foot)/(post_length+foot)), d2=0, $fn=4);
                    }
            }
            
            // The neckdown feature where it snaps into the greenhouse
            translate([0,0,post_length - neck_length])
            {
                // Trim a small depth (the difference of two cylinders) in the main cylinder
                difference()
                {
                    // WART: Getting inconsistent/backward taper direction when using radius parameters for cylinder, so using diameter instead.

                    //echo(bevel_h, delta_d);
                    cylinder(neck_length_full, d=d_outer+0.1, false, $fn=default_fn);
                    cylinder(neck_length_full, d=d_inner, false, $fn=default_fn);
                    cylinder(bevel_h, d1=d_outer, d2=d_inner, false, $fn=default_fn); // small bevel on lower surface of neckdown to make a reasonable overhang that can print without supports
                    translate([0,0,neck_length_full - bevel_h])
                    {
                        // WART: Encountered issues on at least one slicer not producing a solid 'wall' between the necked post and the part it protrudes from, so add a taper there too
                        cylinder(bevel_h, d1=d_inner, d2=d_outer, false, $fn=default_fn); // small bevel on lower surface of neckdown to make a reasonable overhang that can print without supports
                    }

                }
     
            }
        }
    }
}
