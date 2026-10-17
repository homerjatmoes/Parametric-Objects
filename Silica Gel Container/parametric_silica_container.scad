// Parametric Silica Gel / Desiccant Container
// Inspired by gdrag's "Silica gel spool container" and Bruno Cubateli's skinny remix
// Horizontal slots for faster printing, FDM-friendly threads, no supports needed

/* [Main Dimensions] */
outer_diameter = 40;     // Outer diameter of the body (mm) — try 30, 40, 50
body_height = 50;        // Height of the container body (excluding lid)
wall_thickness = 1.2;    // Wall thickness (mm)
bottom_thickness = 1.6;  // Bottom thickness (mm)
lid_height = 8;          // Overall lid height

/* [Ventilation Slots] */
// Slot height controls whether beads fall through.
// 1.6–1.8 mm is a good default for 3–5 mm silica beads.
// Drop to 1.2–1.4 mm if you use smaller beads or want extra safety.
// Raise it only if you’re using larger beads or want more airflow.
slot_height = 1.6;          // Height of each horizontal slot (mm)

// Vertical solid material between slots
slot_spacing = 2.2;         // Thickness of the solid rings between slots (mm)

slot_start_height = 6;      // Height where slots start (above bottom)
slot_end_clearance = 12;    // Clearance from top of body for threads

// Optional: how far the slots cut into the wall (usually leave this alone)
slot_depth_extra = 0.5;     // Extra depth so the slot fully breaks through

/* [Threads] */
thread_pitch = 2.5;      // Thread pitch (mm)
thread_depth = 1.0;      // Thread depth (mm)
thread_clearance = 0.3;  // Clearance between male and female threads (mm)
thread_turns = 3.5;      // Number of turns
thread_start_height = body_height - 10;  // Where threads start on body

/* [Quality] */
$fn = 80;                // Segments for circles (higher = smoother)

// Derived values
inner_diameter = outer_diameter - 2 * wall_thickness;
thread_major_dia = outer_diameter - 1.0;
thread_minor_dia = thread_major_dia - 2 * thread_depth;

module container_body() {
    difference() {
        // Outer body
        cylinder(h = body_height, d = outer_diameter);
        
        // Inner cavity
        translate([0, 0, bottom_thickness])
            cylinder(h = body_height - bottom_thickness + 0.1, d = inner_diameter);
        
        // Horizontal ventilation slots
        slot_count = floor((body_height - slot_start_height - slot_end_clearance) / (slot_height + slot_spacing));
        for (i = [0 : slot_count - 1]) {
            z = slot_start_height + i * (slot_height + slot_spacing);
            translate([0, 0, z])
                difference() {
                    cylinder(h = slot_height, d = outer_diameter + 1);
                    cylinder(h = slot_height + 0.1, d = inner_diameter - slot_depth_extra);
                }
        }
        
        // Male threads on outside of top
        translate([0, 0, thread_start_height])
            thread_male(thread_major_dia, thread_depth, thread_pitch, thread_turns);
    }
}

module lid() {
    difference() {
        // Outer lid body
        cylinder(h = lid_height, d = outer_diameter + 1.5);
        
        // Internal cavity for threads
        translate([0, 0, 1.5])
            cylinder(h = lid_height, d = thread_major_dia + thread_clearance * 2);
        
        // Female threads
        translate([0, 0, 2])
            thread_female(thread_major_dia, thread_depth, thread_pitch, thread_turns, thread_clearance);
    }
    
    // Optional grip ridges on top of lid
    translate([0, 0, lid_height - 1.2])
        difference() {
            cylinder(h = 1.2, d = outer_diameter + 1.5);
            cylinder(h = 1.3, d = outer_diameter - 4);
        }
}

// Simple FDM-friendly triangular thread approximation
module thread_male(dia, depth, pitch, turns) {
    length = turns * pitch;
    difference() {
        cylinder(h = length, d = dia);
        for (i = [0 : $fn * turns]) {
            angle = i * 360 / $fn;
            z = i * pitch / $fn;
            rotate([0, 0, angle])
                translate([dia/2 - depth/2, 0, z])
                    rotate([0, 90, 0])
                        cylinder(h = depth + 0.1, d1 = depth * 1.6, d2 = 0.2, $fn = 12);
        }
    }
}

module thread_female(dia, depth, pitch, turns, clearance) {
    length = turns * pitch + 2;
    intersection() {
        cylinder(h = length, d = dia + clearance * 2);
        for (i = [0 : $fn * turns]) {
            angle = i * 360 / $fn;
            z = i * pitch / $fn;
            rotate([0, 0, angle])
                translate([dia/2 + clearance, 0, z])
                    rotate([0, 90, 0])
                        cylinder(h = depth + 1, d1 = 0.2, d2 = depth * 1.8, $fn = 12);
        }
    }
}

// Export both parts
// Uncomment the one you want to render, or use the customizer
// container_body();
// translate([outer_diameter + 10, 0, 0]) lid();

// Default: show both
container_body();
translate([outer_diameter + 15, 0, 0]) lid();
