// Drip catcher for one of those small pentagonal terraria that are all the rage in kitch stores.
// Sorry, I don't have any more identifying information.

// By: Drmn4ea (drmn4ea at gmail)
// License: Creative Commons CC0 (or public domain to the extent permitted by law)

// I printed this on an STL printer using a 'flex' resin, which allowed it to be squished slightly for
// insertion into the terrarium.

sidelength = 100; // length on each side in mm
height = 30;
ratio = 1.2;

// calculations

r = sidelength / (2*sin(180/5));

difference()
{
    cylinder(height,r,r*ratio,$fn=5);

    translate([0, 0, 3])
    {
        cylinder(height,r-2,(r-2)*ratio,$fn=5);
    }
}