package game

main :: proc() {

	// ===================================================
	// Logger and Tracking allocator. ┌( ಠ_ಠ)┘
	// ===================================================

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

	// ===================================================
	// @Setup: Application.
	// ===================================================
	
	app_run()
}

// ===================================================
// @Imports:
// ===================================================

// Odin.
import "core:log"
import "core:mem"