// Casement window operator track slider for Andersen windows
// by Drmn4ea (drmn4ea at gmail)
// License: CC BY-SA

// This is a replacement for the small plastic slider whatchamacallit at the end of the 'operator arm'
// for Andersen casement windows. The original part tends to become brittle over time and eventually break off, especially on the sun-facing side of a house.

// This is a dirt simple design based on the original part's dimensions, with a couple 
// minor adjustments for 3D printing. I had the best results, or at least minimal post-finishing,
// printing the part vertically (i.e. with the P-shaped track slot against the buildplate) with a brim.

// Note to actually replace the original part requires cutting off the rivet that used to hold the original
// (unless it also crumbled away). Due to the tight clearance in the channel this retracts into when the window is closed,
// a special low-clearance nut+bolt may be needed (and/or the connector_thickness below tweaked to account for a taller standard bolt head).
// The suitable parts I found has several common names such as barrel nut, binding nut, binding barrel,
// sex bolt (yes, really), surface-mount nut or weld nut.
// Finding barrel nuts (sex nuts etc.) with a small enough diameter to pass through the ~.190" dia hole in the crank operator arm to use it as a bearing may be a challenge though, so you may be better off sizing the 'barrel'
// (smooth on the outside) part to the connector_thickness or vice versa and passing the smaller threaded bolt through as the 'bearing'. It's a little ugly, but seems to work well enough.

// Bounding box dimensions
// The entire part is basically carved out of a cube with the following outside dimensions
y = 1.45 * 25.4; // total track slide length
x = .875 * 25.4; // total depth ("window to crank operator" axis)
z = .350 * 25.4; // total height

slider_total_width = .350 * 25.4; // Portion of the total depth comprising the slotted slider portion as opposed to the thinner crank connection part
slot_edge_distance = .210 * 25.4; // slot distance from front (window side) edge of slider
slot_start_width = .065 * 25.4; // slot width for the narrower bottom part
slot_end_width = .155 * 25.4; // slot width for the wider, upper portion of slot accommodating a bend or similar retention feature in the window track
slot_height = .200 * 25.4; // total height of the guide slot

// Details about the window crank arm connection part
connector_height_offset = .073 * 25.4; // distance between bounding box bottom edge and connector bottom edge
connector_thickness = .160 * 25.4; // thickness (height) of connector part
connector_hole_dia = .250 * 25.4;
connector_hole_edge_offset = .280 * 25.4; // distance between hole center and rear (operator side) edge of crank connector


// Fudge factors for edges that exactly touch, to prevent openscad previews blocking your view with 0-thickness walls
fudge = .001;
double_fudge = 2*fudge;

difference()
{
    // main solid the thingy will get carved from
    cube([x, y, z], center=false);
    
    // thin off the crank connector part
    translate([slider_total_width, -fudge, -fudge])
    {
        cube([x+double_fudge, y+double_fudge, connector_height_offset], center=false);
        translate([0,0,connector_height_offset + connector_thickness])
        {
            cube([x+double_fudge, y+double_fudge, z], center=false);
        }
    }
    
    translate([slot_edge_distance, -fudge, -fudge])
    {
        // Cut the slot...
        // Starting (lower/narrower) portion
        cube([slot_start_width, y+double_fudge, slot_height+double_fudge], center=false);
        
        // Larger opening, kind of tangent to the far edge of the narrow part of the slot
        translate([-((slot_end_width/2)-slot_start_width),0,slot_height])
        {
            // Already at the start of the slot
            rotate([-90, -30, 0])
            {
                cylinder(h=y+double_fudge, d=slot_end_width, center=false, $fn=30);
            }

        }
    }
    
    // Crank connection hole
    translate([x-connector_hole_edge_offset, y/2, 0])
    {
        cylinder(h=z, d=connector_hole_dia, center=false, $fn=100);
    }
}
