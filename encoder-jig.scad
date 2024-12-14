dim = [62,30,26.8];

module basic() difference() {
    cube(dim);
    translate([0,-1]) rotate([0,-23.38,0]) cube([74-6.45, dim.y + 2, dim.z]);
}

difference() {
    rotate([0, 23.38]) rotate([0, 180]) basic();
    translate([0, 2.2, 0]) scale([0.9, 0.84, 1.]) rotate([0, 23.38]) rotate([0, 180]) basic(); basic();
    translate([-68.7, 9.3/2, -2]) rotate([0, 23.38, 0]) cube([2.8,20,30]);
}