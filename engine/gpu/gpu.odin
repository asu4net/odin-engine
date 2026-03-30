package gpu

// ====================================================================
// @Region: Data_Type
// ====================================================================

Data_Type :: enum 
{
    None,
    Float, Float2, Float3, Float4,
    Mat3, Mat4,
    Int, Int2, Int3, Int4,
    Sampler2D,
    Bool
}

data_type_len :: proc(type: Data_Type) -> int 
{
    switch type 
    {
        case .Float     : return 1         
        case .Float2    : return 2
        case .Float3    : return 3
        case .Float4    : return 4
        case .Mat3      : return 3 * 3
        case .Mat4      : return 4 * 4
        case .Int       : return 1
        case .Sampler2D : return 32
        case .Int2      : return 2
        case .Int3      : return 3
        case .Int4      : return 4
        case .Bool      : return 1
        case .None      : return 0
    }
    return 0
}

data_type_size :: proc(type: Data_Type) -> int 
{
    switch type 
    {
        case .Float:      return 4
        case .Float2    : return 4 * 2
        case .Float3    : return 4 * 3
        case .Float4    : return 4 * 4
        case .Mat3      : return 4 * 3 * 3
        case .Mat4      : return 4 * 4 * 4
        case .Int       : return 4
        case .Sampler2D : return 32
        case .Int2      : return 4 * 2
        case .Int3      : return 4 * 3
        case .Int4      : return 4 * 4
        case .Bool      : return 1
        case .None      : return 0
    }
    return 0
}

data_type_is_integer :: proc(type: Data_Type) -> bool 
{
    switch type 
    {
        case .Int, .Sampler2D, .Int2, .Int3, .Int4, .Bool, .None:
        {
            return true
        }
        case .Float, .Float2, .Float3, .Float4, .Mat3, .Mat4:
        {
            return false
        }
    }
    return false
}

// ====================================================================
// @Region: Context
// ====================================================================

create_context :: #force_inline proc(window: ^sdl.Window) -> bool
{
    when OPENGL 
    {
        return create_context_gl(window)
    }
    else
    {
        #assert(false, "Error! Missing implementation.")
        return false
    }
}

destroy_context :: #force_inline proc()
{
    when OPENGL 
    {
        destroy_context_gl()
    }
    else
    {
        #assert(false, "Error! Missing implementation.")
        return false
    }
}

swap_buffers :: #force_inline proc()
{
    when OPENGL
    {
        swap_buffers_gl()
    }
    else
    {
        #assert(false, "Error! Missing implementation.")
    }
}

clear_screen :: #force_inline proc(color: [4]f32 = {0, 0, 0, 1}) 
{
    when OPENGL
    {
        clear_screen_gl(color)
    }
    else
    {
        #assert(false, "Error! Missing implementation.")
    }
}

// ====================================================================
// @Region: Shader
// ====================================================================

Shader_Handle :: handle_map.Handle32

// ===================================================
// @Constants:
// ===================================================

// @Robustness: For now we force OpenGL implemetation.
OPENGL :: true
MAX_SHADERS :: 100

// ===================================================
// @Imports:
// ===================================================

import "core:container/handle_map"
import sdl "vendor:sdl3"