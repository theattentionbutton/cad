include <MCAD/utilities.scad>
include <BOSL/shapes.scad>
include <BOSL/sliders.scad>
include <nutsnbolts/cyl_head_bolt.scad>;

$fa=2;
$fs=0.2;

SIDE=52;
HEIGHT=2;
OUTER_WALL=1;
OUTER_FILLET_OFFSET=4;

module rail(height=44, gap=2.2, depth=10, wall=6) {
    difference() {
        translate([0, 0, 0.5]) cuboid([height - 3, wall, depth + 1]);
        // rail cutout
        translate([0,0,2]) cuboid([height, gap, depth]);
        // middle cutout
        translate([0, 0, 2]) cuboid([height/2, wall, depth]);
        translate([-20, 0, 2]) cuboid([6, wall, depth]);
        translate([20, 0, 2]) #cuboid([6, wall, depth]);
    }
}

module nub() {
    difference() {
        cyl(l=12, d=3.75, fillet=1, orient=ORIENT_Y);
        translate([-1.5, 0]) cuboid([4, 14, 5]);
    }
}

module exterior(dim=[SIDE, SIDE, HEIGHT], fillet=4, wall=OUTER_WALL) {
    difference() {
        union() {
            cuboid(dim, fillet=fillet, edges=EDGES_ALL-EDGES_X_TOP - EDGES_Y_TOP - EDGES_X_BOT - EDGES_Y_BOT);
            flange_height = 8;
            // -0.5 gives 46.5
            // -0 gives 47
            outer_side = SIDE - fillet/2 - wall;
        }
        translate([-8,-5,-2]) linear_extrude(6) square(36);
        
        translate([-8,-32,-2]) linear_extrude(6) square([36, 20]);
        
        translate([-39,-32,-2]) linear_extrude(6) square([20, 72]);
    }
}

module screwposts() difference() {
    x = 18;
    y = 4;
    z = 8;
    cuboid([20, y, z]);
    translate([-0.5, 0]) cuboid([10, y + 1, z + 1]);
    translate([10, 0]) cuboid([3, y + 1, z + 1]);
    translate([0, -3.5]) cuboid([20, y, z + 1]);
    translate([x/2 - 2.5, 0.2, z/2 + 4.5]) {
        translate([0, 0]) screw("M2.5x8");
        translate([-14, 0]) screw("M2.5x8");
    }
}

difference() {
    union() {
        exterior();
        translate([-13.2,0,3]) rotate([0, 0, 90]) rail(depth=8);
        translate([3, -8.3, 4]) screwposts();
    }
    translate([-32,-10,-2]) #linear_extrude(6) square([20, 20]);
}