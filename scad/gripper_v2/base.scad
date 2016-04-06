use <buildvars.scad>
use <util.scad>
use <arm.scad>
use <servo.scad>
use <gear.scad>
use <servo_horn_enclosing.scad>


function back_x() = 4.31*2;
function back_y() = -gear_r()-10;
function base_rounding_radius() = 7;
function nut_h() = 2.3;
function back_h() = nut_h()+servo_elevation()+2*servo_base_height();
function turn_h() = 25;
function turn_gap_h() = 5;
function turn_gap_d() = 2;

module dup(vec=[0,1,0]) {
    children();
    mirror(vec) children();
}


module base(servo_hole = true) {
    module main() {
        r = base_rounding_radius();
        module circles(r,a) {
            translate([0,arm_c2c()/2,0])
            circle(r=a?r:r*2);

// // Not needed anymore
//            translate([arm_inset_y(),arm_c2c()/2-arm_inset_x(),0])
//            circle(r=r);
                       
            // divide by 6 for 1/3 distance
            translate([back_y(),back_x()/2,0])
            circle(r=r);
        }
        linear_extrude(height=servo_base_height())
        difference() {
            hull() dup() circles(r,false);
            dup() circles(screw_r()+tolerance(),true, $fn=30);
            
        }
    }
    difference() {
        main();
        if (servo_hole) {
            translate([-servo_d()/2-tolerance(),-arm_c2c()/2+servo_w()-servo_r()+tolerance(),0]){
                rotate([0,0,-90]) {
                    cube([servo_w()+2*tolerance(),servo_d()+2*tolerance(),servo_base_height()]);
                }
            }
            translate([0,-arm_c2c()/2,0]){
                rotate([0,0,-90]) {
                    servo_screws();
                }
            }
        }
    }
}

module top() {
    base(false);
}

module show_servo() {
    translate([0,-arm_c2c()/2,0]){
        translate([0,0,-servo_base_height()*1])
        rotate([0,0,-90]) {
            translate([0,0,servo_base_height()]) servo();
        }
        translate([0,0,servo_elevation()+servo_base_height()])
        enclosing();
    }
}

module inset_arms(angle = 0) {
    linear_extrude(height=servo_base_height())
    dup() {
        translate([arm_inset_y(),arm_c2c()/2-arm_inset_x(),0])
        rotate([0,0,angle])
        arm(length=arm_length());
    }
}

module grippers(angle=0) {
    x = arm_inset_x();
    y = arm_inset_y();
    l = sqrt(x*x + y*y);
    translate([0,0,servo_base_height()])
    linear_extrude(height=servo_elevation()+servo_base_height()*0)
    dup() {
        translate([-arm_length()+cos(angle)*arm_length(),sin(angle)*arm_length(),0])
        translate([arm_length()+y,arm_c2c()/2-x,0]) {
            rotate(-atan(x/y)+180)
            arm(length=l);
            arm(length=l/2);
        }
    }
}


module pusher() {
    linear_extrude(height=servo_elevation())
    arm();
}
module pusher_big() {
    linear_extrude(height=servo_elevation()+servo_base_height())
    arm(r=gear_r()/3*2);
}


/**


OUTPUTS



*/


module display_gripper() {
    tgt = 90;
    arm_angle = $t < 0.5 ? $t*2*tgt : tgt-($t-0.5)*2*tgt;
    arm_angle = 0;
    
    // BASE
    color("red")
    base();
    show_servo();
    
    translate([0,0,servo_elevation()+servo_base_height()*3+nut_h()])
    %top();


    // GEAR ARMS
    translate([0,0,servo_elevation()+servo_base_height()*2])
    arms(height = servo_base_height(), center = true, angle=arm_angle);
  

    // PUSHERS
    color("orange") {
        translate([0,arm_c2c()/2,servo_base_height()*1])
        pusher_big();
    }
    
    turner();
}

module turner() {
    sr = base_rounding_radius()/2;
    br = base_rounding_radius();
    mr = (br+sr)/2;
    h = back_h();
    
    turner_height = 10;
    translate([back_y(),0,servo_base_height()]) {
        linear_extrude(height=h)
        difference() {
            hull()
            dup()
            translate([-(br+sr)/2+sr,back_x()/2,0])
            circle(r=mr);

            dup()
            translate([0, back_x()/2,0])
            circle(r=screw_r());
        }
        
        gap_h = turn_gap_h();
        gap_d = turn_gap_d();
        translate([-br+sr,0,h/2])
        rotate([0,-90,0]) {
            difference() {
                cylinder(r=h/2, h=turn_h()+sr);
                translate([0,0,sr+(turn_h())/2-gap_h/2])
                difference() {
                    cylinder(h=gap_h, r=h/2+1);
                    cylinder(h=gap_h, r=h/2-gap_d);
                }
            }
            translate([0,0,turn_h()+sr])
            gear(r=6, teeth=15, h = 4);
        }
    }
}

// to print:
module print() {
    arm_angle = 0;

    $fn=80;
    
    translate([-50,30,servo_base_height()])
    base();
    
    translate([-50,130,servo_base_height()])
    top();
    
    
    translate([0,-50,0])
    arms(height = servo_base_height(), center = true, extrasep = 5);
    
    pusher_big();
    
    !turner();

}


//display_gripper();

//translate([-150,0,0])
print();
