package game

Data_Type :: enum {
    None,
    Float, Float2, Float3, Float4,
    Mat3, Mat4,
    Int, Int2, Int3, Int4,
    Sampler2D,
    Bool
}

gpu_data_type_len :: proc(type: Data_Type) -> int {
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

gpu_data_type_size :: proc(type: Data_Type) -> int {
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

gpu_data_type_is_integer :: proc(type: Data_Type) -> bool {
    switch type {
        case .Float, .Float2, .Float3, .Float4, .Mat3, .Mat4:
            return false
        case .Int, .Sampler2D, .Int2, .Int3, .Int4, .Bool, .None:
            return true
    }
    return false
}