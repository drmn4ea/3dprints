// Replacement stem driver (plastic insert / coupler) for Kohler(R) Rite-Temp(R) shower trim kit (faucet handle).
// The author of this file is not affiliated with Kohler(R), all trademarks are the property of their respective owners and used nominatively.

// By Tim (drmn4ea at google's mail service)
// License: Creative Commons - Attribution - Share-Alike

// The stem driver is a small plastic bit that couples the shower handle to a mating feature on the valve stem (a square peg/key on the actual valve in the wall). On my said unit, this coupler broke (corners cracked) at just over a year old (note the warranty period is 1 year). Judging by the reviews for this unit (9 reviews, all 1-2-star and complaining of a cracked stem driver as of 7/14/2024) this is a common problem:  https://www.kohler.com/en/support/find-a-service-part/shop-parts/assembly-handle-1332384?skuId=1332384-BL

// Dimensions below are for the  K-TS22028-4-BN and other K-TS22028-4 , but it appears a similar part is used in other handles with minor variation in e.g. lengths. Hopefully, the below is generic enough to accomodate those variations.

// The coupler has two ends that press-fit onto mating features on the faucet or wall valve respectively, which I'll call the "faucet key" side and "wall key" side. None of the features on this part have official names, so here is an exquisite ASCII art diagram of a sample part to assist entering the needed dimensions.

// In the diagram and parameters, the part is oriented sideways as shown with the 'faucet key' side to the left. (The finished part may be generated in a more print-friendly orientation.) There is normally a rubber O-ring butted up against the lefthand edge of the 'wall key' part (shown by n/u on the diagram), be sure not to lose this - transfer it from the old part.

// Parameters for this model are organized first by critical lengths, followed by outer dimensions, follwed by inner dimensions. 

// Faucet key side                Wall key side
//
//                  n||-----------------|
//       |-----------||-----------------|
//  /----      |-----||
//  |==========
//  \----      |-----||
//       |-----------||-----------------|
//                  u||-----------------|
//
//  0    A     B     CD                 E

// Lengths (A-E)
// There are five critical length values that may vary between Kohler stems, the below is organized by them.
// based on absolute distance from "0" at the face that pushes into the faucet handle.
// In other words, A is the distance from 0 to A, B is the distance from 0 to B, etc.
// If you prefer to use measurements of each section separately, you can define variables in terms of previous ones.


inch = 25.4; // inch to mm conversion - not a political statement; my calipers are imperial

// From '0' edge of square faucet key
A = .240 * inch; // Distance to end of faucet key
C = A+(.810*inch); // Distance to near edge of 'wall CD'
D = C+(.128*inch); // Distance to far edge of 'wall CD' (beginning of the wall key)
B = D-(.755*inch) ; // Distance to face of screw countersink

E = C+(.965 * inch); // Total length to outer edge of wall key // .375 inch extra fudge factor

// Outer dimensions (F-H)

// Faucet key side                Wall key side
//                       |
//         |             v
//    |    v        n||-----------------|
//    v  |-----------||-----------------|
//  /----      |-----||
//  |==========
//  \----      |-----||
//    ^  |-----------||-----------------|
//    |    ^        u||-----------------|
//    |    |             ^
//    |    |             |
//    F    G             H

F = .410 * inch; // Width (face-to-face) of square faucet key
G = .580 * inch; // Diameter of cylinder F // .590
H = .925 * inch; // Diameter of wall key outer cylinder // .875

// Note, wall key G's outer dimension is not critical, in my unit the outermost feature of the part is .875", but
// the actual clearance is more like 1.15". Feel free to oversize this a bit for some extra strength.
// In the OEM part the outer walls of the wall key are a rounded-square with thin corners, roughly tracking
// the shape of the square inner key aperture. Maybe an injection molding consideration, maybe an intentional weak point so it crumbles here just out of warranty?... >:O
// Here it is approximated by a plain cylinder since we in 3d printing land are free of either said pressure.

// Finally, inner ("cutout") dimensions (I-K)

// Faucet key side                Wall key side
//
//                  n||-----------------|
//       |-----------||-----------------|
//  /----      |-----||
//  |=====(I)==  (J)     (K)
//  \----      |-----||
//       |-----------||-----------------|
//                  u||-----------------|
//

I = .175 * inch; // ID of screw hole H
J = .350 * inch; // ID of screw countersink I
K = .545 * inch; // Interior width (face-to-face) of square wall key receptacle. Assuming the original is broken, you can just measure the wall key itself and oversize it a smidge.

fudge = 0.001; // Fudge factor for faces that exactly touch, to avoid leaving 0-thickness skins in between during e.g. difference operations
$fn=50; // Number of segments to approximate circular objects with

// Output the model upside-down so any needed supports are inserted in the less-dimensionally-needy insides.
// In particular, don't want support junk clinging to the O-ring mating face.
translate([0, 0, E])
{
    rotate([0,-180,0])
    {
        difference()
        {
            solids();
            cutouts();
        }

    }
}

module solids()
{
    // Faucet key
    translate([0,0,A/2])
    {
        cube([F, F, A], center=true);
    }
    // Center spacer
    sh = C-A ; // Spacer cylinder actual height
    translate([0,0,A+(sh/2)])
    {
        cylinder(h=sh, d=G, center=true);
    }
    // Wall key 
    // Total height of wall key cylinder, including wall thickness
    kh = E - C;
    translate([0, 0, C + (kh/2)])
    {
        cylinder(h=kh, d=H, center=true);
    }
}

module cutouts()
{
    // Screw hole (I)
    translate([0, 0, E/2])
    {
        cylinder(h=E+fudge, d=I, center=true);
    }
    // Scew countersink
    csink_len = E-B; // length of countersink to end
    translate([0, 0, B + (csink_len/2)])
    {
        cylinder(h=csink_len, d=J, center=true);
    }
    // Wall key receptacle
    wallkey_len = E-D; // length of countersink to end
    translate([0, 0, D + (wallkey_len/2)])
    {
        cube([K, K, wallkey_len+fudge], center=true);
    }
}

