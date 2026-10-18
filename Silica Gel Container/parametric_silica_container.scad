// Parametric Silica Gel / Desiccant Container
// Inspired by gdrag's "Silica gel spool container" and Bruno Cubateli's skinny remix
// Horizontal slots with vertical support columns, FDM-friendly threads

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
num_columns = 4;            // Number of solid vertical columns that interrupt the slots
column_width = 4;           // Width of each solid column (mm, chord length)

/* [Threads] */
thread_pitch = 2.5;      // Thread pitch (mm)
thread_depth = 0.8;      // Thread depth (mm)
thread_clearance = 0.35; // Clearance between male and female threads (mm)
thread_turns = 3;        // Number of turns
thread_start_height = body_height - 9;  // Where threads start on body

/* [Quality] */
$fn = 80;                // Segments for circles (higher = smoother)

// Derived values
inner_diameter = outer_diameter - 2 * wall_thickness;
thread_major_dia = outer_diameter - 0.4;

module container_body() {
    difference() {
        // Outer body
        cylinder(h = body_height, d = outer_diameter);
        
        // Inner cavity
        translate([0, 0, bottom_thickness])
            cylinder(h = body_height - bottom_thickness + 0.1, d = inner_diameter);
        
        // Horizontal ventilation slots interrupted by vertical columns
        slot_count = floor((body_height - slot_start_height - slot_end_clearance) / (slot_height + slot_spacing));
        for (i = [0 : slot_count - 1]) {
            z = slot_start_height + i * (slot_height + slot_spacing);
            translate([0, 0, z])
                slot_ring();
        }
        
        // Male threads on outside of top
        translate([0, 0, thread_start_height])
            thread_male();
    }
}

// Creates a ring of slots with solid columns left in place
module slot_ring() {
    difference() {
        cylinder(h = slot_height, d = outer_diameter + 1);
        cylinder(h = slot_height + 0.1, d = inner_diameter - slot_depth_extra);
        
        // Solid columns that interrupt the slots
        for (a = [0 : 360 / num_columns : 359]) {
            rotate([0, 0, a])
                translate([0, -column_width / 2, -0.1])
                    cube([outer_diameter, column_width, slot_height + 0.2]);
        }
    }
}

module lid() {
    difference() {
        // Outer lid body
        cylinder(h = lid_height, d = outer_diameter + 1.6);
        
        // Internal cavity for threads
        translate([0, 0, 1.5])
            cylinder(h = lid_height, d = thread_major_dia + thread_clearance * 2);
        
        // Female threads
        translate([0, 0, 2])
            thread_female();
    }
    
    // Optional grip ridges on top of lid
    translate([0, 0, lid_height - 1.2])
        difference() {
            cylinder(h = 1.2, d = outer_diameter + 1.6);
            cylinder(h = 1.3, d = outer_diameter - 4);
        }
}

// FDM-friendly helical thread (male, external)
module thread_male() {
    length = thread_turns * thread_pitch;
    difference() {
        cylinder(h = length, d = thread_major_dia);
        // Helical cut for the thread groove
        for (i = [0 : $fn * thread_turns]) {
            angle = i * 360 / $fn;
            z = i * thread_pitch / $fn;
            rotate([0, 0, angle])
                translate([thread_major_dia / 2 - thread_depth / 2, 0, z])
                    rotate([0, 90, 0])
                        cylinder(h = thread_depth + 0.2, d1 = thread_depth * 1.8, d2 = 0.3, $fn = 8);
        }
    }
}

// FDM-friendly helical thread (female, internal)
module thread_female() {
    length = thread_turns * thread_pitch + 1;
    intersection() {
        cylinder(h = length, d = thread_major_dia + thread_clearance * 2);
        // Helical ridge for the internal thread
        for (i = [0 : $fn * thread_turns]) {
            angle = i * 360 / $fn;
            z = i * thread_pitch / $fn;
            rotate([0, 0, angle])
                translate([thread_major_dia / 2 + thread_clearance, 0, z])
                    rotate([0, 90, 0])
                        cylinder(h = thread_depth + 0.5, d1 = 0.3, d2 = thread_depth * 1.8, $fn = 8);
        }
    }
}

// Default: show both parts
container_body();
translate([outer_diameter + 15, 0, 0]) lid();
