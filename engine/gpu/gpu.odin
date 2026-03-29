package gpu

create_context :: #force_inline proc(window: ^sdl.Window) -> bool
{
    return gl.create_context(window)
}

destroy_context :: #force_inline proc()
{
    gl.destroy_context()
}

swap_buffers :: #force_inline proc()
{
    gl.swap_buffers()
}

clear_screen :: #force_inline proc(color: [4] f32 = { 0, 0, 0, 1 })
{
    gl.clear_screen(color)
}

// ===================================================
// @Imports:
// ===================================================

import sdl "vendor:sdl3"
import gl "engine:gpu/backend/gl"