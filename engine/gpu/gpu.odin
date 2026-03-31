package gpu

// ====================================================================
// @Region: Data_Type
// ====================================================================

Data_Type :: enum {
    None,
    Float, Float2, Float3, Float4,
    Mat3, Mat4,
    Int, Int2, Int3, Int4,
    Sampler2D,
    Bool
}

data_type_len :: proc(type: Data_Type) -> int {
    switch type {
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

data_type_size :: proc(type: Data_Type) -> int {
    switch type {
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
    switch type {
        case .Int, .Sampler2D, .Int2, .Int3, .Int4, .Bool, .None: {
            return true
        }
        case .Float, .Float2, .Float3, .Float4, .Mat3, .Mat4: {
            return false
        }
    }
    return false
}

// ====================================================================
// @Region: Context
// ====================================================================

context_create :: #force_inline proc(window: ^sdl.Window) -> bool
{
    when OPENGL {
        return context_create_gl(window)
    } else {
        #assert(false, "Error! Missing implementation.")
        return false
    }
}

context_destroy :: #force_inline proc()
{
    when OPENGL {
        context_destroy_gl()
    } else {
        #assert(false, "Error! Missing implementation.")
        return false
    }
}

present :: #force_inline proc()
{
    when OPENGL {
        swap_buffers_gl()
    } else {
        #assert(false, "Error! Missing implementation.")
    }
}

clear_screen :: #force_inline proc(color: [4]f32 = {0, 0, 0, 1}) 
{
    when OPENGL {
        clear_screen_gl(color)
    } else {
        #assert(false, "Error! Missing implementation.")
    }
}

// ====================================================================
// @Region: Shader
// ====================================================================

Shader_Def :: struct {
    source: string
}

Shader_Handle :: handle_map.Handle32

shader_add :: #force_inline proc(def: Shader_Def) -> (handle: Shader_Handle, ok: bool) #optional_ok {
    when OPENGL {
        return shader_add_gl(def)
    } else {
        #assert(false, "Error! Missing implementation.")
        return {}
    }
}

shader_rem :: #force_inline proc(handle: Shader_Handle) {
    when OPENGL {
        shader_rem_gl(handle)
    } else {
        #assert(false, "Error! Missing implementation.")
    }
}

shader_use :: #force_inline proc(handle: Shader_Handle) {
    when OPENGL {
        shader_use_gl(handle)
    } else {
        #assert(false, "Error! Missing implementation.")
    }
}

shader_set_param_float :: #force_inline proc(handle: Shader_Handle, name: string, value: f32) {
    when OPENGL {
        shader_set_param_float_gl(handle, name, value)
    } else {
        #assert(false, "Error! Missing implementation.")
    }
}

shader_set_param_vec2 :: #force_inline proc(handle: Shader_Handle, name: string, value: [2] f32) {
    when OPENGL {
        shader_set_param_vec2_gl(handle, name, value)
    } else {
        #assert(false, "Error! Missing implementation.")
    }
}

shader_set_param_vec3 :: #force_inline proc(handle: Shader_Handle, name: string, value: [3] f32) {
    when OPENGL {
        shader_set_param_vec3_gl(handle, name, value)
    } else {
        #assert(false, "Error! Missing implementation.")
    }
}

shader_set_param_vec4 :: #force_inline proc(handle: Shader_Handle, name: string, value: [4] f32) {
    when OPENGL {
        shader_set_param_vec4_gl(handle, name, value)
    } else {
        #assert(false, "Error! Missing implementation.")
    }
}

shader_set_param_m4 :: #force_inline proc(handle: Shader_Handle, name: string, value: matrix[4, 4] f32) {
    when OPENGL {
        shader_set_param_m4_gl(handle, name, value)
    } else {
        #assert(false, "Error! Missing implementation.")
    }
}

shader_set_param_int :: #force_inline proc(handle: Shader_Handle, name: string, value: i32) {
    when OPENGL {
        shader_set_param_int_gl(handle, name, value)
    } else {
        #assert(false, "Error! Missing implementation.")
    }
}

shader_set_param_int_array :: #force_inline proc(handle: Shader_Handle, name: string, value: [^]i32, count: i32) {
    when OPENGL {
        shader_set_param_int_array_gl(handle, name, value, count)
    } else {
        #assert(false, "Error! Missing implementation.")
    }
}

// ====================================================================
// @Region: Vertex Buffer
// ====================================================================

Vertex_Buffer_Def :: struct {
    data: rawptr,
    count: int,
    vsize: int, 
    attrs: [] Data_Type,
    elems: [] u32,
}

Vertex_Buffer_Handle :: handle_map.Handle32

vertex_buffer_add :: #force_inline proc(def: Vertex_Buffer_Def) -> (handle: Vertex_Buffer_Handle, ok: bool) #optional_ok {
    when OPENGL {
        return vertex_buffer_add_gl(def)
    } else {
        #assert(false, "Error! Missing implementation.")
        return {}
    }
}

vertex_buffer_rem :: #force_inline proc(handle: Vertex_Buffer_Handle) {
    when OPENGL {
        vertex_buffer_rem_gl(handle)
    } else {
        #assert(false, "Error! Missing implementation.")
        return {}
    }
}

vertex_buffer_draw :: #force_inline proc(handle: Vertex_Buffer_Handle, count: i32 = 0, index_offset: u32 = 0) {
    when OPENGL {
        vertex_buffer_draw_gl(handle, count, index_offset)
    } else {
        #assert(false, "Error! Missing implementation.")
        return {}
    }
}

// ====================================================================
// @Region: Overloads
// ====================================================================

use :: proc {
    shader_use,
}

set_param :: proc {
    shader_set_param_float,
    shader_set_param_vec2,
    shader_set_param_vec3,
    shader_set_param_vec4,
    shader_set_param_m4,
    shader_set_param_int,
    shader_set_param_int_array,
}

draw :: proc {
    vertex_buffer_draw,
}

// ===================================================
// @Constants:
// ===================================================

// @Robustness: For now we force OpenGL implemetation.
OPENGL             :: true
MAX_SHADERS        :: 100
MAX_VERTEX_BUFFERS :: 100

// ===================================================
// @Imports:
// ===================================================

import "core:container/handle_map"
import sdl "vendor:sdl3"