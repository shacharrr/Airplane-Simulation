package main

import "core:math"
import "core:math/linalg"
import "core:testing"
import "core:fmt"
import "csv"

CTX :: struct {
    tick    : f64,
    cticks  : int,
    mticks  : int,

    entity: Entity,
}

ctx := CTX {
    tick = 0.1,
    mticks = 1000,

    // Cessna 152
    entity = Entity { 
        mass = CESSNA152_MASS, 
        angle = [3]f64 {
            0, CESSNA152_AOA, 0
        },
    },
}

sim_setup :: proc() {
    mg := Force {
        scalar = [3]f64 { 0, 0,  ctx.entity.mass * G},
        static = true,
    }

    thrust := Force {
        scalar = [3]f64 { 35 * (745.7 / G), 0, 0 },
        static = false,
    }

    apply_force(&ctx.entity, mg)
    apply_force(&ctx.entity, thrust)
}

sim_update :: proc() {
    sforce: [3]f64
    for force in ctx.entity.applied_forces {
        if force.static {
            sforce += rotate_force(force, ctx.entity.angle).scalar
        } else {
            sforce += force.scalar
        }
    }

    ctx.entity.acceleration = sforce / ctx.entity.mass

    ctx.entity.position += ctx.entity.velocity * ctx.tick + 0.5 * ctx.entity.acceleration * ctx.tick * ctx.tick
    ctx.entity.velocity += ctx.entity.acceleration * ctx.tick
}

sim_document :: proc() {
    csv.row("posvel.csv", []f64 {
        (f64)(ctx.cticks)*ctx.tick,                      // Time

        ctx.entity.position[0],                          // Position X
        ctx.entity.position[1],                          // Position Y
        ctx.entity.position[2],                          // Position Z
                             
        ctx.entity.velocity[0],                          // Velocity X
        ctx.entity.velocity[1],                          // Velocity Y
        ctx.entity.velocity[2],                          // Velocity Z
                         
        ctx.entity.acceleration[0],                      // Acceleration X
        ctx.entity.acceleration[1],                      // Acceleration Y
        ctx.entity.acceleration[2],                      // Acceleration Z
        
        math.to_degrees_f64(ctx.entity.angle[0]),        // Roll
        math.to_degrees_f64(ctx.entity.angle[1]),        // Pitch
        math.to_degrees_f64(ctx.entity.angle[2]),        // Yaw
    })
}

main :: proc() {
    csv.create("posvel.csv", []string{
        "Time [s]",

        "Position X [m]",
        "Position Y [m]",
        "Position Z [m]",

        "Velocity X [m/s]",
        "Velocity Y [m/s]",
        "Velocity Z [m/s]",
        
        "Acceleration X [m/s^2]",
        "Acceleration Y [m/s^2]",
        "Acceleration Z [m/s^2]",

        "Roll [°]",
        "Pitch [°]",
        "Yaw [°]",
    })

    sim_setup()

    sim_loop: for (ctx.cticks < ctx.mticks) {
        sim_update()
        sim_document()

        ctx.cticks += 1
    }
}

@(test)
test_dada :: proc(t: ^testing.T) {
    f1 := [3]f64 { 2, 4, 3 }
    fmt.println(f1 / 2.2)
}