package backend_gl

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

data_type_is_attribute :: proc(type: Data_Type) -> bool 
{
    switch type 
    {
        case .Float, .Float2, .Float3, .Float4, .Mat3, .Mat4, .Int, .Int2, .Int3, .Int4: 
        {
            return true
        }
        case .Sampler2D, .Bool, .None:
        {
            return false
        }
    }
    return false
}

to_data_type :: proc(type: i32) -> Data_Type 
{
    switch type 
    {
        case gl.FLOAT      : return .Float
        case gl.FLOAT_VEC2 : return .Float2
        case gl.FLOAT_VEC3 : return .Float3
        case gl.FLOAT_VEC4 : return .Float4
        case gl.FLOAT_MAT3 : return .Mat3
        case gl.FLOAT_MAT4 : return .Mat4
        case gl.INT        : return .Int
        case gl.INT_VEC2   : return .Int2
        case gl.INT_VEC3   : return .Int3
        case gl.INT_VEC4   : return .Int4
        case gl.SAMPLER_2D : return .Sampler2D
        case gl.BOOL       : return .Bool
    }
    return .None
}

from_data_type :: proc(type: Data_Type) -> u32 
{
    switch type 
    {
        case .Float     : return gl.FLOAT
        case .Float2    : return gl.FLOAT
        case .Float3    : return gl.FLOAT
        case .Float4    : return gl.FLOAT
        case .Mat3      : return gl.FLOAT
        case .Mat4      : return gl.FLOAT
        case .Int       : return gl.INT
        case .Int2      : return gl.INT
        case .Int3      : return gl.INT
        case .Int4      : return gl.INT
        case .Sampler2D : return gl.SAMPLER_2D
        case .Bool      : return gl.BOOL
        case .None      : return 0
    }
    return 0
}

// ===================================================
// @Imports:
// ===================================================

import gl "vendor:OpenGL"