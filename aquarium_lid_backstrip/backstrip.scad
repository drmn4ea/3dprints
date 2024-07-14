

inch = 25.4; // mm

wall_thickness = .045 * inch;
splashguard_depth = 2.2 * inch; // Overall depth to cover from edge of glass to edge of tank
extrude_len = 5 * inch; // Length of the splashguard/tank (or bed height of your printer and print multiple sections)

glass_capture_depth = .375 * inch; // Portion that captures onto the glass
glass_capture_thickness = (.125-.01) * inch; // actual glass thickness, may benefit from a tiny fudge factor
glass_capture_pocket_height = .03 * inch; // Add a small non-contacting pocket & lip over the back of the capture edge for a little extra give
glass_capture_pocket_length_ratio = 0.5; // non-contacting portion of the pocket (0.0 = 0% to 1.0 = 100%)

use_back_edge_stop = true; // If downward-hanging 'stop' desired near rear tank edge
back_edge_stop_setback = .250 * inch; // Setback from back edge of splashguard to relevant face of edge stop
back_edge_stop_depth = .100 * inch; // Depth (downward height) of feature

fudge = .0001;

linear_extrude(height=extrude_len)
{

    // capture; tracing the shape counterclockwise
    polygon([ [0,0], [glass_capture_depth+wall_thickness,0], [glass_capture_depth+wall_thickness, wall_thickness], [wall_thickness,wall_thickness], /* bottom*/
        [wall_thickness,wall_thickness+glass_capture_thickness + glass_capture_pocket_height], /*vertical, start of pocket*/ 
        [wall_thickness + (glass_capture_depth*glass_capture_pocket_length_ratio),wall_thickness+glass_capture_thickness + glass_capture_pocket_height],
        [wall_thickness + (glass_capture_depth*(1-glass_capture_pocket_length_ratio)),wall_thickness+glass_capture_thickness], /* capture lip, after pocket*/
        [wall_thickness+glass_capture_depth,wall_thickness+glass_capture_thickness], /*bottom-right edge of lip*/
        [wall_thickness+glass_capture_depth,wall_thickness*2+glass_capture_thickness+glass_capture_pocket_height], [0,wall_thickness*2+glass_capture_thickness+glass_capture_pocket_height], [0,0] /* up and back around*/
        ]);
        // FIXME: pocket
        
    // splashguard
    polygon([ [fudge,0], [-splashguard_depth, 0], [-splashguard_depth, wall_thickness], [fudge, wall_thickness] ]);

    // bottom rear edgestop
    if(use_back_edge_stop)
    {
        polygon([ [-splashguard_depth + back_edge_stop_setback, fudge], 
            [-splashguard_depth + back_edge_stop_setback, -back_edge_stop_depth],
            [-splashguard_depth + back_edge_stop_setback + wall_thickness, -back_edge_stop_depth],
            [-splashguard_depth + back_edge_stop_setback + wall_thickness + (back_edge_stop_depth), fudge],
        ]);     /*extra 'back_edge_stop_depth' x offset on final coordinate creates bevel allowing part to be printed */
                /* vertical or horizontal without supports */
        
        /*polygon([ [-splashguard_depth + back_edge_stop_setback, fudge], 
            [-splashguard_depth + back_edge_stop_setback, -back_edge_stop_depth],
            [-splashguard_depth + back_edge_stop_setback + wall_thickness, -back_edge_stop_depth],
            [-splashguard_depth + back_edge_stop_setback + wall_thickness, fudge],
        ]);*/ 
    }
}
