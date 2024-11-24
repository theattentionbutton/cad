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
            translate([0, 0, 4]) difference() {
                cuboid([outer_side - 2, outer_side - 2, flange_height], fillet=fillet, edges=EDGES_Z_ALL);
                cuboid([outer_side - wall - 5,  outer_side - wall - 5, flange_height+1], fillet=fillet, edges=EDGES_Z_ALL);
                cuboid([outer_side - 15, outer_side, flange_height+1]);
            }


            nub_x = SIDE/2 - OUTER_WALL - 2.8;
            nub_y = 5;

            translate([nub_x, 0, nub_y]) nub(); 
            translate([-nub_x, 0, nub_y]) rotate(180) nub();
        }

        translate([3, 0, -4]) linear_extrude(8) difference() {
            circle(16);
            translate([0, -(16 + 9.4/2 - 9.2)]) square([32, 10.5], center=true);
        }
    }
}

module screwposts() difference() {
    x = 18;
    y = 4;
    z = 8;
    cuboid([20, y, z]);
    translate([-0.5, 0]) cuboid([10, y + 1, z + 1]);
    translate([10, 0]) cuboid([3, y + 1, z + 1]);
    translate([-11, 0]) cuboid([3, y + 1, z + 1]);
    translate([0, -3.5]) cuboid([20, y, z + 1]);
    translate([x/2 - 2.5, 0.2, z/2 + 4.5]) {
        translate([0, 0]) screw("M2.5x8");
        translate([-14, 0]) screw("M2.5x8");
    }
}


union() {
    exterior();
    translate([3, -8.3, 4]) screwposts();
}