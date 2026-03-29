package game

main :: proc()
{
	// ====================================================================
	// @Region: Logger and Tracking allocator. ┌( ಠ_ಠ)┘
	// ====================================================================

	when ODIN_DEBUG 
    {
        logger := log.create_console_logger()
        context.logger = logger

		track: mem.Tracking_Allocator
		mem.tracking_allocator_init(&track, context.allocator)
		context.allocator = mem.tracking_allocator(&track)

		defer 
        {
			if len(track.allocation_map) > 0 
            {
				log.errorf("=== %v allocations not freed: ===", len(track.allocation_map))
				for _, entry in track.allocation_map 
                {
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

    if !sdl_initialized 
    {
        log.errorf("Error: sdl.Init(): %v\n", sdl.GetError())
        return
    } 
	
	defer 
    {
		if sdl_initialized 
        {
			sdl.Quit()
		}
	}

	// ====================================================================
	// @Region: SDL Window.
	// ====================================================================

    log.info("SDL Window start.")
	window = sdl.CreateWindow("Game", 1270, 720, { .OPENGL, .RESIZABLE })

	if window == nil 
    {
		log.errorf("Error: sdl.CreateWindow(): %v\n", sdl.GetError())
		sdl.Quit()
		return
	} 

	defer 
    {
		if window != nil 
        {
			log.info("SDL Window finish.")
			sdl.DestroyWindow(window)
			window = nil
		}
	}

	// ====================================================================
	// @Region: GPU.
	// ====================================================================

    context_created := gpu.create_context(window)
    if !context_created
    {
        log.error("Error: Failed to create the context")
        return
    }

    defer
    {
        if context_created
        {
            gpu.destroy_context()
        }
    }

    // ====================================================================
	// @Region: Time
    // ====================================================================

	start_tick := time.tick_now()
	last_time := time.duration_seconds(time.tick_since(start_tick))

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
				}
                when ODIN_DEBUG {
                    if event.type == .KEY_DOWN && event.key.key == sdl.K_ESCAPE {
                        quit = true
                    }
                }
			}
		}

		gpu.clear_screen({1, 0, 0, 1})
        gpu.swap_buffers()

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