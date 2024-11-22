include <MCAD/utilities.scad>
include <BOSL/shapes.scad>
include <BOSL/sliders.scad>

$fa=2;
$fs=0.2;

SIDE=52;
HEIGHT=75;
OUTER_WALL=2.5;
OUTER_FILLET_OFFSET=4;

module exterior(dim=[SIDE, SIDE, HEIGHT], fillet=4, wall=OUTER_WALL) {
    difference() {
        cuboid(dim, fillet=fillet, edges=EDGES_ALL-EDGES_X_TOP - EDGES_Y_TOP - EDGES_X_BOT - EDGES_Y_BOT);
        translate([0, 0, wall]) cuboid([dim.x - fillet/2 - wall, dim.y - fillet/2 - wall, dim.z - wall], fillet=fillet, edges=EDGES_Z_ALL);
    }
}

module rail(height=72, gap=2.2, depth=5) {
    difference() {
        cuboid([6, 6, height]);
        translate([0, 2]) cuboid([gap, 5, height + 0.2]);
        translate([0, -2]) cuboid([8, 3, height]);
    }
}

module retainer_wall(height=15, gap=2.2, depth=5) {
    difference() {
        translate([-2.5, 6]) cuboid([2, 15, height]);
    }
}



module speaker_holder() {
    union() {
        difference() {
            rotate([0, 0, -90]) tube(h=11, ir=6, wall=1.5, orient=ORIENT_X, align=ALIGN_POS);
            translate([0, -11/2, 4]) cuboid([18, 12, 8]);
        }

        translate([0, -11/2, -10]) cuboid([3, 11, 6]);
    }
}

module interior() {
    translate([
        SIDE/2 - 3, /* move the rail to the edge but out of the wall */
        -SIDE/2+OUTER_WALL+11 /* leave room for the buzzer and display */
    ]) rotate([0, 0, 90]) rail();

    translate([
        -SIDE/2 + 3, /* move the rail to the edge but out of the wall */
        -SIDE/2+OUTER_WALL+11, /* leave room for the buzzer and display */
        -HEIGHT/2+OUTER_WALL+5
    ]) rotate([0, 0, -90]) retainer_wall();

    translate([
        0, 
        -SIDE/2 + OUTER_WALL + 10, 
        -HEIGHT/2 
            + OUTER_WALL 
            // + OUTER_FILLET_OFFSET
            + 2.85 /* buzzer to pcb edge offset */ 
            + 8 /* holder diameter + wall */
    ]) speaker_holder();
}

module sector(radius, angles, fn = 24) {
    r = radius / cos(180 / fn);
    step = -360 / fn;

    points = concat([[0, 0]],
        [for(a = [angles[0] : step : angles[1] - 360]) 
            [r * cos(a), r * sin(a)]
        ],
        [[r * cos(angles[1]), r * sin(angles[1])]]
    );

    difference() {
        circle(radius, $fn = fn);
        polygon(points);
    }
}

module rounded_rect(dim, center=false) {
/*     w = dim[0] > dim[1] ? dim[0] : dim[1];
    h = dim[0] > dim[1] ? dim[1] : dim[0]; */
    w = dim[0];
    h = dim[1];

    translate(center ? [-w/2, -h/2] : [0, 0]) {
        translate([h/2, h]) rotate(90) sector(h/2, [0, 180]);
        translate([h/2, h/2]) square([w - h, h]);
        translate([w-h/2, h]) rotate(-90) sector(h/2, [0, 180]);
    }
}

function quicksort(list) = !(len(list)>0) ? [] : let(
    pivot   = list[floor(len(list)/2)],
    lesser  = [ for (i = list) if (i  < pivot) i ],
    equal   = [ for (i = list) if (i == pivot) i ],
    greater = [ for (i = list) if (i  > pivot) i ]
) concat(
    quicksort(lesser), equal, quicksort(greater)
);


module grille(r = 6, width = 1, spacing = 1, vertical=false) {
    d = r * 2;
    m = width + spacing;
    n = round(d / m);
    lengths = quicksort([
        for (i=[floor(n/2)*m:m:n*m]) 
            if (i != r) sqrt(abs(r^2 - i^2))
    ]);
    
    initial = 1;
    union() {
        for(i=[0:n]) {
            idx = i == n/2 ? n/2 - 1 : (i > n/2) ? n - i : i;
            translate([0, (i - initial) * m]) rounded_rect([lengths[idx] + 1, width], center=true);
        }
    }
}

module speaker_grille() {
    difference() {
        rotate([90, 0, 0]) linear_extrude(5) grille();
/*         translate([0, -2, 11]) cuboid([10, 4, 2]);
        translate([0, -2, -2]) cuboid([10, 4, 2]); */
    }
}

union() {
    difference() {
        exterior();

        /* clips for the lid */
        translate([0, SIDE/2-OUTER_WALL-1, HEIGHT/2-4]) cyl(l=12, d=4, fillet=1, orient=ORIENT_X);
        translate([0, -SIDE/2+OUTER_WALL+1,HEIGHT/2-4]) cyl(l=12, d=4, fillet=1, orient=ORIENT_X);
        
        /* speaker grille */
        translate([
                0, 
                -SIDE/2 + OUTER_WALL + 1, 
                -HEIGHT/2 
                    + OUTER_WALL 
                    // + OUTER_FILLET_OFFSET
                    // + 2.85 // buzzer to pcb edge offset
                    + 8 // holder diameter + wall
        ]) speaker_grille();
        
        /* microUSB cutout */
        translate([
            -SIDE/2 + 1, // move to the edge but out of the wall
            -SIDE/2+OUTER_WALL+ 11 - 1.6,
            -HEIGHT/2 + OUTER_WALL + OUTER_FILLET_OFFSET + 4.5
        ]) cuboid([10, 4, 10], fillet=1);

        translate([
            0, // leave the display centered
            -SIDE/2+OUTER_WALL, // move to the box wall
            HEIGHT/2 - 16 - 12, // HEIGHT/2 - 16 moves it to the top edge. then -12 brings it down 12mm corresponding to the pcb 
        ]) cuboid([34, 10, 35]);
    }

    interior();
}
