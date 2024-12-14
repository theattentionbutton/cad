include <Chamfers-for-OpenSCAD/Chamfer.scad>;

$fs = 0.2;
$fa = 2;

module cyl(h, r) {
    cylinder (h = h, r1 = r, r2 = r);
}

module ccyl(h, r) {
    chamferCylinder(h, r, r, 2);
}


module capsule(h, r) {
    hull() {
      translate([0,0,r]) sphere(r=r);
      translate([0,0,h-r]) sphere(r=r);
    }
}

module exterior(height, radius, wall) {
    difference() {
        ccyl(height, radius);
        // cut off the rounded top
        translate([0, 0, height - 2]) cyl(height, radius + 0.005);
        // hollow out the inside
        translate([0, 0, wall]) ccyl(height, radius - wall);
    }
}

// shaft is 6mm wide 8mm tall
// cutout is 4.5 mm wide
// shaft step is at 2.5mm up from the base
// 1.4mm wall
module shaft(inner_rad=3.1, cut_width=1.8, outer_rad=4, outer_height=10) {
    difference() {
        // the -2.5 is to ensure the shaft ends up inside the base
        translate([0, 0, 0]) cyl(outer_height, outer_rad);
        translate([0, 0, 2]) difference() {
                cyl(14, inner_rad);
                translate([-3, cut_width, -2.5]) cube([6,6,6]);
        }
    }
}

module ridges(height = 14, depth = 0.4, count = 100, pos = [0, 17, 1]) {
    for (i=[1:1:count]) {
        rotate([0, 0, i * 360/count]) translate(pos) cyl(height, depth);
    }
}

module knob(height = 16, radius = 18, wall = 2) { 
    union() {
        exterior(height, radius, wall);
        shaft();
        ridges(pos=[0, radius, 3], height = height - 6);
    }
}

// knob(wall = 1.5, radius=18);
knob(wall=1.5, radius=18, height=16);