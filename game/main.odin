package game

main :: proc() {
	// ====================================================================
	// @Region: Logger and Tracking allocator. ┌( ಠ_ಠ)┘
	// ====================================================================

	when ODIN_DEBUG {
        logger := log.create_console_logger()
        context.logger = logger

		track: mem.Tracking_Allocator
		mem.tracking_allocator_init(&track, context.allocator)
		context.allocator = mem.tracking_allocator(&track)

		defer {
			if len(track.allocation_map) > 0 {
				log.errorf("=== %v allocations not freed: ===", len(track.allocation_map))
				for _, entry in track.allocation_map {
					log.errorf("- %v bytes @ %v\n", entry.size, entry.location)
				}
			}
			mem.tracking_allocator_destroy(&track)
		}
	}

	// ====================================================================
	// @Region: SDL (Simple Direct Media Layer)
	// ====================================================================

    log.info("SDL start.")
	sdl_initialized := sdl.Init(sdl.INIT_VIDEO | sdl.INIT_AUDIO | sdl.INIT_GAMEPAD)

    if !sdl_initialized {
        log.errorf("Error: sdl.Init(): %v\n", sdl.GetError())
        return
    } 
	
	defer {
		if sdl_initialized {
			sdl.Quit()
		}
	}

	// ====================================================================
	// @Region: SDL Window.
	// ====================================================================

    log.info("SDL Window start.")
	window = sdl.CreateWindow("Game", 1270, 720, { .OPENGL, .RESIZABLE })

	if window == nil {
		log.errorf("Error: sdl.CreateWindow(): %v\n", sdl.GetError())
		sdl.Quit()
		return
	} 

	defer {
		if window != nil {
			log.info("SDL Window finish.")
			sdl.DestroyWindow(window)
			window = nil
		}
	}

	// ====================================================================
	// @Region: GPU.
	// ====================================================================

    context_created := gpu.context_create(window)
    if !context_created {
        log.error("Error: Failed to create the context")
        return
    }

    defer {
        if context_created {
            gpu.context_destroy()
        }
    }

    // ====================================================================
	// @Region: Time
    // ====================================================================

	start_tick := time.tick_now()
	last_time := time.duration_seconds(time.tick_since(start_tick))
	
	// Test
	QUAD_VERTS :: []f32{
		-0.5, -0.5, 0.0, 0.0, 
		+0.5, -0.5, 1.0, 0.0,
		+0.5, +0.5, 1.0, 1.0,
		-0.5, +0.5, 0.0, 1.0,
	}

	vb := gpu.vertex_buffer_add({
		data  = raw_data(QUAD_VERTS),
		count = len(QUAD_VERTS),
		vsize = size_of(f32) * 4,
		attrs = {
			.Float2,
			.Float2,
		},
		elems = {
			0, 1, 2, // Triangle 1
			2, 3, 0, // Triangle 2
		}
	})
	
	shader := gpu.shader_add({#load("shader_sprite.glsl", string)})

    // ====================================================================
	// @Region: Main Loop
    // ====================================================================

	main_loop: for !quit {
		// Time step.
		current_time := time.duration_seconds(time.tick_since(start_tick))
		dt := clamp(f32(current_time - last_time), 0, 0.1) 
		last_time = current_time

		// Process events.
		{
			event: sdl.Event
			for sdl.PollEvent(&event) {
				if event.type == .QUIT {
					quit = true
                    break main_loop
				}
                when ODIN_DEBUG {
                    if event.type == .KEY_DOWN && event.key.key == sdl.K_ESCAPE {
                        quit = true
                        break main_loop
                    }
                }
			}
		}

		gpu.clear_screen({1, 0, 0, 1})
		gpu.use(shader)
		gpu.set_param(shader, "u_color", [4]f32{0, 0, 1, 0})
		gpu.draw(vb)
        gpu.present()

		// Clean: Temporary storage.
		free_all(context.temp_allocator)
	}
}

// ====================================================================
// @Globals:
// ====================================================================

quit: bool
window: ^sdl.Window

// ====================================================================
// @Imports:
// ====================================================================

import "core:time"
import "core:log"
import "core:mem"

import sdl "vendor:sdl3"
import gpu "engine:gpu"