package main

import "core:math"
import "core:fmt"

G :: 9.80665

Force :: struct {
    scalar          : [3]f64,
    static          : bool,
}

Entity :: struct {
    mass            : f64, // kg

    position        : [3]f64,
    angle           : [3]f64,

    velocity        : [3]f64,
    acceleration    : [3]f64,

    applied_forces  : [dynamic]Force
}

apply_force :: proc(ent: ^Entity, f: Force) {
    append(&ent.applied_forces, f)
}

dot_product :: proc(a, b: [3]f64) -> f64 {
    return a[0] * b[0] + a[1] * b[1] + a[2] * b[2]
}

rotate_force :: proc(f: Force, angles: [3]f64) -> Force {
    roll_matrix := matrix[3, 3]f64 {
        1, 0, 0,
        0, math.cos_f64(angles[0]), -math.sin_f64(angles[0]),
        0, math.sin_f64(angles[0]), math.cos_f64(angles[0]),
    }

    pitch_matrix := matrix[3, 3]f64 {
        math.cos_f64(angles[1]), 0, math.sin_f64(angles[1]),
        0, 1, 0,
        -math.sin_f64(angles[1]), 0, math.cos_f64(angles[1]),
    }

    yaw_matrix := matrix[3, 3]f64 {
        math.cos_f64(angles[2]), -math.sin_f64(angles[2]), 0,
        math.sin_f64(angles[2]), math.cos_f64(angles[2]), 0,
        0, 0, 1,
    }
    
    rotation_matrix := roll_matrix * pitch_matrix * yaw_matrix
    nf := Force {
        scalar = {
            dot_product(f.scalar, rotation_matrix[0]),
            dot_product(f.scalar, rotation_matrix[1]),
            dot_product(f.scalar, rotation_matrix[2]),
        },
        static = f.static,
    }
    
    return nf
}
