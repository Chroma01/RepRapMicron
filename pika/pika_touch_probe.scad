// pika_touch_probe.scad - Scott-Russell flexure touch inidicator for attaching to PIKA Z Axis Driver
// This one has a wire probe point attached to it
// (C)2026 vik@diamondage.co.nz GPLv3 or later applies

flexure_thick=0.5;
flexure_length=3;
body_height=1.6;
small_gap=0.1;      // Smallest gap we can reliably print

wire_probe_rad=0.2;     // Wire probe tip that nestles in the point.
probe_length=3.5;
probe_width=2;
probe_height=body_height*2;     // This is the maximim height of the probe, giving room for tip.
probe_hinge_length=10;
probe_hinge_sep=26;
point_length=probe_width*1.3;
hinge_width=1.6;

first_joint_length=7.5;
first_joint_offset=0.5;
flag_clearance=1.5;
l_arm_length=10;
// This is the "handle" that all the flexures are attached to.
handle_length=probe_hinge_sep+first_joint_length+l_arm_length+2*flexure_thick-flexure_length;

handle_depth=5;    // Handle sticks out this much.
// The flag goes down to meet a protrusion stickign out just before the probe point
flag_length=flexure_length+probe_hinge_sep+hinge_width/2;

tab_rad=10/2+body_height;
tab_thick=3;
screw_rad=3.4/2;
tab_extends=tab_rad+1;

module flat_flexure() {
    translate([0,-flexure_thick/2,0])
        cube([flexure_length,flexure_thick,body_height]);
}

module probe_hinge() {
    // Blobs to encourage printer to join the flexure to things
    flexure_anchor();
    translate([probe_hinge_length,0,0]) flexure_anchor();
    flat_flexure();
    translate([flexure_length,-hinge_width/2,0])
        cube([probe_hinge_length-2*flexure_length,hinge_width,body_height]);
    translate([probe_hinge_length-flexure_length,0,0]) flat_flexure();
}

module flexure_anchor() {
    cylinder(h=body_height,r=flexure_thick*1.2,$fn=8);
}

l_base_arm_length=probe_hinge_length+first_joint_offset;
module l_arm() {
    flat_flexure();
    translate([flexure_length,-hinge_width/2,0])
        cube([l_arm_length-flexure_length,hinge_width,body_height]);
    translate([l_arm_length-hinge_width,flexure_length-probe_hinge_length-first_joint_offset-hinge_width/2,0]) {
        cube([hinge_width,probe_hinge_length+first_joint_offset-flexure_length,body_height]);
        // Flexure at far end of handle
        translate([hinge_width/2,0,0]) rotate([0,0,-90]) flat_flexure();
        // Anchors
        translate([hinge_width/2,0,0]) flexure_anchor();
        translate([hinge_width/2,-flexure_length,0]) flexure_anchor();
    }
}

// The first joint in the Stewart Russel flexure
stub_location=first_joint_length-hinge_width-flexure_length;
module first_joint() {
    rotate([0,0,90]) {
        flat_flexure();
        // Central pivoting part of Scott-Russel flexure
        translate([flexure_length,-hinge_width/2,0])
            cube([first_joint_length-2*flexure_length,hinge_width,body_height]);
        // L-shaped end hinge
        translate([first_joint_length-flexure_length,first_joint_offset,0]) l_arm();
        // Protruding stub for flag component
        translate([stub_location,0,0])
            cube([hinge_width,flag_clearance+probe_width/2+hinge_width/2,body_height]);
    }
}

// The probe
// Sideways protrusion used as alignment scale
translate([-flag_clearance-(probe_width+hinge_width)/2,-hinge_width,0])
    cube([flag_clearance+(hinge_width+probe_width)/2,hinge_width,body_height]);
// Pointy probe bit. Has a half-tough chopped out for a probe wire.
// This also stops adhesive going into the flexures...
difference() {
    // Body of probe
    translate([0,-probe_length,0]) {
        hull() {
            // Pointy end
            cylinder(h=probe_height,r=0.1);
            // Main arm of probe
            translate([-probe_width/2,point_length,0])
                cube([probe_width,probe_length+probe_hinge_sep+flexure_thick-point_length,probe_height]);
        }
    }
    // Cut half of the probe body away to leave a trough
    translate([wire_probe_rad-probe_width/2,0,body_height+probe_height/2])
        cube([probe_width,handle_length*4,probe_height],center=true);
}

// The flag arm
translate([(-probe_width-hinge_width)/2-flag_clearance,small_gap,0])
    hull() {
        // Pointy end
        translate([hinge_width/2,0.1,0]) cylinder(h=body_height/2,r=0.1);
        translate([0,point_length,0]) cube([hinge_width,flag_length-point_length,body_height]);
    }


// Flexure out front
translate([0,probe_hinge_sep+flexure_thick,0])
        first_joint();
// Two hinge flexuress anchoring the probe to the holder
translate([probe_width/2,0,0]) probe_hinge();
translate([probe_width/2,probe_hinge_sep,0]) probe_hinge();
// The bit that holds on to the flexures
translate([probe_hinge_length+probe_width/2,-flexure_thick,0]) {
    // Flat part attached to flexures
    cube([handle_depth,handle_length,body_height*2]);
    // Stiffening strip
    translate([handle_depth-body_height,0,0]) cube([body_height,handle_length,body_height*4]);
}
// Tab to attach to probe. Needs to be at roughly 90 degrees to the flexure
translate([probe_hinge_length+hinge_width,tab_thick-flexure_thick,0]) rotate([90,0,0]) difference() {
    hull() {
        // Nice, smooth transition to the handle
        translate([tab_rad,handle_depth+tab_rad,0]) cylinder(h=tab_thick,r=tab_rad);
        cube([handle_depth,tab_thick,tab_thick]);
    }
    // Perforate for a screw
    translate([tab_rad,handle_depth+tab_rad,0]) rotate([0,0,180/8])
        cylinder(h=tab_thick*3,r=screw_rad,center=true,$fn=8);
}
