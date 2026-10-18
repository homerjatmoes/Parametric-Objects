// Parametric Silica Gel / Desiccant Container
// Inspired by gdrag's "Silica gel spool container" and Bruno Cubateli's skinny remix
// Horizontal slots with vertical support columns, external FDM-friendly threads

/* [Main Dimensions] */
outer_diameter = 40;     // Outer diameter of the body (mm) — try 30, 40, 50
body_height = 50;        // Height of the container body (excluding lid)
wall_thickness = 1.2;    // Wall thickness (mm)
bottom_thickness = 1.6;  // Bottom thickness (mm)
lid_height = 8;          // Overall lid height

/* [Ventilation Slots] */
// Slot height controls whether beads fall through.
// 1.6–1.8 mm is a good default for 3–5 mm silica beads.
slot_height = 1.6;          // Height of each horizontal slot (mm)
slot_spacing = 2.2;         // Thickness of the solid rings between slots (mm)
slot_start_height = 6;      // Height where slots start (above bottom)
slot_end_clearance = 12;    // Clearance from top of body for threads
slot_depth_extra = 0.5;     // Extra depth so the slot fully breaks through

/* [Vertical Support Columns] */
num_columns = 4;            // Number of solid vertical columns
column_angle = 18;          // Angular width of each solid column (degrees)

/* [Threads] */
thread_pitch = 2.5;      // Thread pitch (mm)
thread_depth = 0.9;      // Thread depth (mm)
thread_clearance = 0.35; // Clearance between male and female threads (mm)
thread_turns = 3;        // Number of turns
thread_height = 8;       // Height of the threaded section

/* [Quality] */
$fn = 72;                // Segments for circles

// Derived
inner_diameter = outer_diameter - 2 * wall_thickness;
thread_start_z = body_height - thread_height;
thread_major_dia = outer_diameter;

module container_body() {
    union() {
        // Main body with slots only between columns
        difference() {
            cylinder(h = body_height, d = outer_diameter);
            
            // Inner cavity (stop before thread region so threads stay solid)
            translate([0, 0, bottom_thickness])
                cylinder(h = thread_start_z - bottom_thickness + 0.1, d = inner_diameter);
            
            // Slots only in the open sectors between columns
            slot_count = floor((thread_start_z - slot_start_height - 2) / (slot_height + slot_spacing));
            for (i = [0 : slot_count - 1]) {
                z = slot_start_height + i * (slot_height + slot_spacing);
                translate([0, 0, z])
                    slots_between_columns();
            }
        }
        
        // External male threads on the top
        translate([0, 0, thread_start_z])
            external_thread();
    }
}

// Cuts slots only in the angular gaps between the solid columns
module slots_between_columns() {
    sector_angle = 360 / num_columns;
    open_angle = sector_angle - column_angle;
    
    for (c = [0 : num_columns - 1]) {
        rotate([0, 0, c * sector_angle + column_angle / 2])
            rotate_extrude(angle = open_angle)
                translate([inner_diameter / 2 - slot_depth_extra / 2, 0])
                    square([wall_thickness + slot_depth_extra, slot_height]);
    }
}

module lid() {
    difference() {
        cylinder(h = lid_height, d = outer_diameter + 2);
        
        // Cavity
        translate([0, 0, 1.5])
            cylinder(h = lid_height, d = outer_diameter + thread_clearance * 2);
        
        // Internal threads
        translate([0, 0, 2])
            internal_thread();
    }
    
    // Grip ridges
    translate([0, 0, lid_height - 1.2])
        difference() {
            cylinder(h = 1.2, d = outer_diameter + 2);
            cylinder(h = 1.3, d = outer_diameter - 3);
        }
}

// External helical thread (male, stands proud on outside)
module external_thread() {
    length = thread_turns * thread_pitch;
    intersection() {
        cylinder(h = length, d = thread_major_dia + thread_depth * 2);
        // Helical ridge
        for (i = [0 : $fn * thread_turns]) {
            angle = i * 360 / $fn;
            z = i * thread_pitch / $fn;
            rotate([0, 0, angle])
                translate([thread_major_dia / 2, 0, z])
                    rotate([0, 90, 0])
                        cylinder(h = thread_depth + 0.1, d1 = 0.3, d2 = thread_depth * 1.6, $fn = 6);
        }
    }
}

// Internal helical thread (female)
module internal_thread() {
    length = thread_turns * thread_pitch + 1;
    difference() {
        cylinder(h = length, d = outer_diameter + thread_clearance * 2 + thread_depth);
        // Helical groove cut
        for (i = [0 : $fn * thread_turns]) {
            angle = i * 360 / $fn;
            z = i * thread_pitch / $fn;
            rotate([0, 0, angle])
                translate([outer_diameter / 2 + thread_clearance, 0, z])
                    rotate([0, 90, 0])
                        cylinder(h = thread_depth + 0.4, d1 = thread_depth * 1.6, d2 = 0.3, $fn = 6);
        }
    }
}

// Show both parts
container_body();
translate([outer_diameter + 20, 0, 0]) lid();
