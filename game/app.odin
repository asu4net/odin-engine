package game

app_run :: proc() {
	
	// ===================================================
	// @Setup: SDL (Simple Direct Media Layer)
	// ===================================================

    log.info("SDL start.")
	sdl_initialized := sdl.Init(sdl.INIT_VIDEO | sdl.INIT_GAMEPAD)
    if !sdl_initialized {

        log.errorf("Error: sdl.Init(): %v\n", sdl.GetError())
        return
    } 
	
	defer {
		if sdl_initialized {
			sdl.Quit()
		}
	}

	// ===================================================
	// @Setup: SDL Window.
	// ===================================================

    log.info("SDL Window start.")
	window = sdl.CreateWindow(WINDOW_TITLE, WINDOW_WIDTH, WINDOW_HEIGHT, { .OPENGL, .RESIZABLE })

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

	// ===================================================
	// @Setup: Graphics Context
	// ===================================================
	
	gpu_context_init()
	defer gpu_context_done()

	when ODIN_OS != .Darwin {
		draw_init()
		defer draw_done()
	}

	// ===================================================
	// @Setup: Time
	// ===================================================

	start_tick := time.tick_now()
	last_time := time.duration_seconds(time.tick_since(start_tick))

	// ===================================================
	// @MainLoop
	// ===================================================

	quad_pos: float2

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
				}
                when ODIN_DEBUG {
                    if event.type == .KEY_DOWN && event.key.key == sdl.K_ESCAPE {
                        quit = true
                    }
                }
			}
		}

		// Draw the scene.
		gpu_clear_screen()

		when ODIN_OS != .Darwin {
			quad_pos += DIR_RIGHT.xy * dt
			draw_quad(quad_pos, COLOR_LIGHT_BLUE)
			//draw_quad({2, 0}, COLOR_GREEN)
			//draw_quad({4, 0}, COLOR_RED)
			draw_frame_done_2d()
		}

		// Present.		
		gpu_swap_buffers()

		// Clean: Temporary storage.
		free_all(context.temp_allocator)
	}
}

// ===================================================
// @Globals:
// ===================================================

quit: bool

window: ^sdl.Window

// ===================================================
// @Imports:
// ===================================================

// Odin.
import "core:time"
import "core:log"

// Vendor.
import sdl "vendor:sdl3"