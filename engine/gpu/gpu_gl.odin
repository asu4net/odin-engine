package gpu

when OPENGL {

// ====================================================================
// @Region: Data_Type
// ====================================================================

data_type_from_gl :: proc(type: i32) -> Data_Type {
    switch type {
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

data_type_to_gl :: proc(type: Data_Type) -> u32 {
    switch type {
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

data_type_is_attribute_gl :: proc(type: Data_Type) -> bool {
    switch type {
        case .Float, .Float2, .Float3, .Float4, .Mat3, .Mat4, .Int, .Int2, .Int3, .Int4: {
            return true
        }
        case .Sampler2D, .Bool, .None: {
            return false
        }
    }
    return false
}

// ====================================================================
// @Region: Context
// ====================================================================

context_create_gl :: proc(window: ^sdl.Window) -> bool {
    log.info("GL Context start.")
    sdl.GL_SetAttribute(sdl.GL_CONTEXT_MAJOR_VERSION, GL_MAJOR)
    sdl.GL_SetAttribute(sdl.GL_CONTEXT_MINOR_VERSION, GL_MINOR)
    sdl.GL_SetAttribute(sdl.GL_CONTEXT_PROFILE_MASK, c.int(sdl.GL_CONTEXT_PROFILE_CORE))

    context_gl = sdl.GL_CreateContext(window)

    if context_gl == nil {
		log.errorf("Error: sdl.CreateContext: %v\n", sdl.GetError())
        return false
    }

    gl.load_up_to(GL_MAJOR, GL_MINOR, sdl.gl_set_proc_address)

    when ODIN_DEBUG && GL_LAST_FEATURES {
        gl.DebugMessageCallback(debug_callback_gl, nil)
    }

    window_gl = window
    
    return true
}

context_destroy_gl :: proc() {
    if context_gl != nil {

        // Clean the shaders.
        for i in 1..<shader_map_gl.used_len {
            shader_destroy_gl(&shader_map_gl.items[i])
        }
        handle_map.clear(&shader_map_gl)

        // Clean the vertex buffers.
        for i in 1..<vertex_buffer_map_gl.used_len {
            vertex_buffer_destroy_gl(&vertex_buffer_map_gl.items[i])
        }
        handle_map.clear(&vertex_buffer_map_gl)

        // Clean the global buffers.
        for i in 1..<global_buffer_map_gl.used_len {
            global_buffer_destroy_gl(&global_buffer_map_gl.items[i])
        }
        handle_map.clear(&global_buffer_map_gl)

        log.info("GL SDL Context finish.")
        if !sdl.GL_DestroyContext(context_gl) {
		    log.errorf("Error: sdl.DestroyContext: %v\n", sdl.GetError())
            return
        }
        context_gl = nil
        window_gl = nil
    }
}

swap_buffers_gl :: #force_inline proc() {
	sdl.GL_SwapWindow(window_gl)
}

clear_screen_gl :: #force_inline proc(color: [4]f32 = {0, 0, 0, 1}) {
	gl.ClearColor(color.r, color.g, color.b, 1)
	gl.Clear(gl.COLOR_BUFFER_BIT)
}

debug_callback_gl :: proc "c" (source: u32, type: u32, id: u32, severity: u32, length: i32, message: cstring, user_param: rawptr) {
    context = runtime.default_context()

    to_string_src :: #force_inline proc(source: u32) -> string {
        switch source {
            case gl.DEBUG_SOURCE_API:               return "API"
            case gl.DEBUG_SOURCE_WINDOW_SYSTEM:     return "Window System"
            case gl.DEBUG_SOURCE_SHADER_COMPILER:   return "Shader Compiler"
            case gl.DEBUG_SOURCE_THIRD_PARTY:       return "Third Party"
            case gl.DEBUG_SOURCE_APPLICATION:       return "Application"
            case gl.DEBUG_SOURCE_OTHER:             return "Unknown"
            case:                                   return "Unknown"
        }
    }

    to_string_type :: #force_inline proc(type: u32) -> string {
        switch type {
            case gl.DEBUG_TYPE_ERROR:               return "Error"
            case gl.DEBUG_TYPE_DEPRECATED_BEHAVIOR: return "Deprecated Behavior"
            case gl.DEBUG_TYPE_UNDEFINED_BEHAVIOR:  return "Undefined Behavior"
            case gl.DEBUG_TYPE_PORTABILITY:         return "Portability"
            case gl.DEBUG_TYPE_PERFORMANCE:         return "Performance"
            case gl.DEBUG_TYPE_OTHER:               return "Unknown"
            case:                                   return "Unknown"
        }
    }    

    Log_Proc :: #type proc(fmt_str: string, args: ..any, location := #caller_location)

    to_proc_severity :: #force_inline proc(severity: u32) -> Log_Proc {
        switch severity {
            case gl.DEBUG_SEVERITY_HIGH:            return log.errorf
            case gl.DEBUG_SEVERITY_MEDIUM:          return log.warnf
            case gl.DEBUG_SEVERITY_LOW:             return log.warnf
            case gl.DEBUG_SEVERITY_NOTIFICATION:    return log.infof
            case:                                   return log.infof
        }
    }

    log_proc := to_proc_severity(severity)
    str_type := to_string_type(type)
    str_src  := to_string_src(source)

    log_proc("OpenGL [%v %v] raised from %v: %v", str_type, id, str_src, message)
}

// ====================================================================
// @Region: Vertex Buffer
// ====================================================================

@(private="file")
Vertex_Buffer_GL :: struct {
    handle: Vertex_Buffer_Handle,
    vao, vbo, ebo: u32, 
    elem_count: i32,
}

vertex_buffer_add_gl :: #force_inline proc(def: Vertex_Buffer_Def) -> (handle: Vertex_Buffer_Handle, ok: bool) #optional_ok {
    return handle_map.add(&vertex_buffer_map_gl, vertex_buffer_create_gl(def))
}

vertex_buffer_get_gl :: proc(handle: Vertex_Buffer_Handle) -> ^Vertex_Buffer_GL {
    vb, ok := handle_map.get(&vertex_buffer_map_gl, handle)
    assert(ok, "Error: Vertex Buffer not found")
    assert(vb.vao != 0 && vb.vbo != 0 && vb.ebo != 0, "Error: Invalid vertex buffer.")
    return vb
}

vertex_buffer_rem_gl :: #force_inline proc(handle: Vertex_Buffer_Handle) {
    vb := vertex_buffer_get_gl(handle)
    vertex_buffer_destroy_gl(vb)
    handle_map.remove(&vertex_buffer_map_gl, handle)
}

vertex_buffer_create_gl :: proc(def: Vertex_Buffer_Def) -> Vertex_Buffer_GL {
    vao, vbo, ebo: u32

    gl.GenVertexArrays(1, &vao)
    gl.BindVertexArray(vao)

    gl.GenBuffers(1, &vbo)
    gl.BindBuffer(gl.ARRAY_BUFFER, vbo)

    usage  := u32(def.data != nil ? gl.STATIC_DRAW : gl.DYNAMIC_DRAW)
    stride := i32(def.count > 0 ? def.vsize : 0)
    offset := 0
    
    gl.BufferData(gl.ARRAY_BUFFER, def.vsize * def.count, def.data, usage)
    
    for &attr, i in def.attrs {
        if !data_type_is_attribute_gl(attr) do continue

        gl.EnableVertexAttribArray(u32(i))
        if !data_type_is_integer(attr) {
            gl.VertexAttribPointer(u32(i), i32(data_type_len(attr)), data_type_to_gl(attr), gl.FALSE, stride, uintptr(offset))
        } else {
            gl.VertexAttribIPointer(u32(i), i32(data_type_len(attr)), data_type_to_gl(attr), stride, uintptr(offset))
        }
        offset += data_type_size(attr)
    }

    gl.GenBuffers(1, &ebo)
    gl.BindBuffer(gl.ELEMENT_ARRAY_BUFFER, ebo)
    gl.BufferData(gl.ELEMENT_ARRAY_BUFFER, len(def.elems) * size_of(u32), raw_data(def.elems), gl.STATIC_DRAW)

    // Clenaup.
    gl.BindVertexArray(0)
    gl.BindBuffer(gl.ARRAY_BUFFER, 0)
    gl.BindBuffer(gl.ELEMENT_ARRAY_BUFFER, 0)
    
    return {
        vao = vao,
        vbo = vbo,
        ebo = ebo,
        elem_count = i32(len(def.elems))
    }
}

vertex_buffer_destroy_gl :: proc(vb: ^Vertex_Buffer_GL) {
    gl.DeleteVertexArrays(1, &vb.vao)
    gl.DeleteBuffers(1, &vb.vbo)
    gl.DeleteBuffers(1, &vb.ebo)
    vb^ = {}
}

vertex_buffer_draw_gl :: proc(handle: Vertex_Buffer_Handle, count: i32 = 0, index_offset: u32 = 0) {
    vb := vertex_buffer_get_gl(handle)
    gl.BindVertexArray(vb.vao)
    gl.DrawElements(gl.TRIANGLES, count == 0 ? vb.elem_count : count, gl.UNSIGNED_INT, rawptr(uintptr(index_offset * size_of(u32))))
    gl.BindVertexArray(0)
}

vertex_buffer_set_data_gl :: #force_inline proc(handle: Vertex_Buffer_Handle, size: i32, data: rawptr) {
    vb := vertex_buffer_get_gl(handle)
    gl.BindBuffer(gl.ARRAY_BUFFER, vb.vbo)
    gl.BufferSubData(gl.ARRAY_BUFFER, 0, int(size), data)
    gl.BindBuffer(gl.ARRAY_BUFFER, 0)
}

// ====================================================================
// @Region: Shader
// ====================================================================

Shader_GL :: struct {
    handle: Shader_Handle,
    program: u32,
}

shader_add_gl :: #force_inline proc(def: Shader_Def) -> (handle: Shader_Handle, ok: bool) #optional_ok {
    return handle_map.add(&shader_map_gl, shader_create_gl(def))
}

shader_get_gl :: #force_inline proc(handle: Shader_Handle) -> ^Shader_GL {
    shader, ok := handle_map.get(&shader_map_gl, handle)
    assert(ok, "Error: Shader not found")
    assert(shader.program != 0, "Error: Invalid shader.")
    return shader
} 

shader_rem_gl :: #force_inline proc(handle: Shader_Handle) {
    shader := shader_get_gl(handle)
    shader_destroy_gl(shader)
    handle_map.remove(&shader_map_gl, handle)
}

shader_create_gl :: proc(def: Shader_Def) -> Shader_GL {	
    if len(def.source) == 0 {
		log.error("Error: The shader source cannot be empty.")
		return {}
	}

	VERT_PREFIX :: "#version 410 core \n#define VERTEX_SHADER \n"
	vert := shader_compile_with_prefix_gl(def.source, VERT_PREFIX, gl.VERTEX_SHADER)

	if vert == 0 {
		log.errorf("Error: Vertex Shader compilation failed.")
		return {}
	}

	FRAG_PREFIX :: "#version 410 core \n#define FRAGMENT_SHADER \n"
	frag := shader_compile_with_prefix_gl(def.source, FRAG_PREFIX, gl.FRAGMENT_SHADER)

	if frag == 0 {
		log.errorf("Error: Fragment Shader compilation failed.")
		return {}
	}

	prog := gl.CreateProgram()

	gl.AttachShader(prog, vert)
	gl.AttachShader(prog, frag)
	gl.LinkProgram(prog)

	gl.DeleteShader(vert)
	gl.DeleteShader(frag)

	success: i32
	gl.GetProgramiv(prog, gl.LINK_STATUS, &success)

	if success == 0 {
		LOG_BUFFER_SIZE :: 512
		log_buffer: [LOG_BUFFER_SIZE]u8
		log_length: i32
		gl.GetProgramInfoLog(prog, LOG_BUFFER_SIZE, &log_length, &log_buffer[0])
		log.errorf("OpenGL: Error linking the shader:\n\n%v\n", string(log_buffer[0:log_length - 1]))
		return {}
	}

	return {
        program = prog
    }
}

shader_destroy_gl :: proc(shader: ^Shader_GL) {
    gl.DeleteProgram(shader.program)
    shader^ = {}
}

shader_use_gl :: proc(handle: Shader_Handle) {
    shader := shader_get_gl(handle)
    gl.UseProgram(shader.program)
}

shader_get_param_location_gl :: #force_inline proc(shader: Shader_GL, name: string) -> i32 {
    return gl.GetUniformLocation(shader.program, cstring(raw_data(name)))
}

shader_set_param_float_gl :: proc(handle: Shader_Handle, name: string, value: f32) {
    shader := shader_get_gl(handle)
    location := shader_get_param_location_gl(shader^, name)
    gl.Uniform1f(location, value)
}

shader_set_param_vec2_gl :: proc(handle: Shader_Handle, name: string, value: [2] f32) {
    shader := shader_get_gl(handle)
    location := shader_get_param_location_gl(shader^, name)
    value := value
    gl.Uniform2fv(location, 1, raw_data(value[:]))
}

shader_set_param_vec3_gl :: proc(handle: Shader_Handle, name: string, value: [3] f32) {
    shader := shader_get_gl(handle)
    location := shader_get_param_location_gl(shader^, name)
    value := value
    gl.Uniform3fv(location, 1, raw_data(value[:]))
}

shader_set_param_vec4_gl :: proc(handle: Shader_Handle, name: string, value: [4] f32) {
    shader := shader_get_gl(handle)
    location := shader_get_param_location_gl(shader^, name)
    value := value
    gl.Uniform4fv(location, 1, raw_data(value[:]))
}

shader_set_param_m4_gl :: proc(handle: Shader_Handle, name: string, value: matrix[4, 4] f32) {
    shader := shader_get_gl(handle)
    location := shader_get_param_location_gl(shader^, name)
    arg := value
    gl.UniformMatrix4fv(location, 1, transpose = false, value = raw_data(&arg))
}

shader_set_param_int_gl :: proc(handle: Shader_Handle, name: string, value: i32) {
    shader := shader_get_gl(handle)
    location := shader_get_param_location_gl(shader^, name)
    gl.Uniform1i(location, value)
}

shader_set_param_int_array_gl :: proc(handle: Shader_Handle, name: string, value: [^]i32, count: i32) {
    shader := shader_get_gl(handle)
    location := shader_get_param_location_gl(shader^, name)
    gl.Uniform1iv(location, count, value)
}

shader_compile_with_prefix_gl :: proc(source: string, prefix: string, shader_type: u32) -> u32 {
	shader := gl.CreateShader(shader_type)

	sources := [] cstring {
		strings.clone_to_cstring(prefix, context.temp_allocator),
		strings.clone_to_cstring(source, context.temp_allocator),
	}

	lengths := [] i32 {
		i32(len(prefix)),
		i32(len(source)),
	}

	gl.ShaderSource(shader, 2, raw_data(sources), raw_data(lengths))
	gl.CompileShader(shader)

	success: i32
	gl.GetShaderiv(shader, gl.COMPILE_STATUS, &success)

	if success == 0 {
		LOG_BUFFER_SIZE :: 512
		log_buffer: [LOG_BUFFER_SIZE]u8
		log_length: i32
		gl.GetShaderInfoLog(shader, LOG_BUFFER_SIZE, &log_length, &log_buffer[0])
		log.errorf("OpenGL: Error compiling the shader:\n\n%v\n", string(log_buffer[0:log_length - 1]))
		return 0
	}

	return shader
}

// ====================================================================
// @Region: Global Buffer
// ====================================================================

Global_Buffer_GL :: struct {
    handle: Global_Buffer_Handle,
    ubo: u32,
    size: int, 
}

global_buffer_add_gl :: #force_inline proc(def: Global_Buffer_Def) -> (handle: Global_Buffer_Handle, ok: bool) #optional_ok {
    return handle_map.add(&global_buffer_map_gl, global_buffer_create_gl(def))
}

global_buffer_get_gl :: #force_inline proc(handle: Global_Buffer_Handle) -> ^Global_Buffer_GL {
    gb, ok := handle_map.get(&global_buffer_map_gl, handle)
    assert(ok, "Error: Global buffer not found.")
    assert(gb.ubo != 0, "Error: Invalid global buffer.")
    return gb
}

global_buffer_rem_gl :: #force_inline proc(handle: Global_Buffer_Handle) {
    gb := global_buffer_get_gl(handle)
    global_buffer_destroy_gl(gb)
    handle_map.remove(&global_buffer_map_gl, handle)
}

global_buffer_set_data_gl :: proc(handle: Global_Buffer_Handle, size: i32, data: rawptr) {
    gb := global_buffer_get_gl(handle)
    gl.BindBuffer(gl.UNIFORM_BUFFER, gb.ubo)
    gl.BufferData(gl.UNIFORM_BUFFER, int(size), data, gl.DYNAMIC_DRAW)
    gl.BindBuffer(gl.UNIFORM_BUFFER, 0)
}

global_buffer_create_gl :: proc(def: Global_Buffer_Def) -> Global_Buffer_GL {
    ubo: u32
    gl.GenBuffers(1, &ubo)
    gl.BindBuffer(gl.UNIFORM_BUFFER, ubo)
    gl.BufferData(gl.UNIFORM_BUFFER, def.size, nil, gl.DYNAMIC_DRAW)
    gl.BindBuffer(gl.UNIFORM_BUFFER, 0)
    return { 
        ubo = ubo 
    }
}

global_buffer_destroy_gl :: proc(gb: ^Global_Buffer_GL) {
    gl.DeleteBuffers(1, &gb.ubo)
    gb^ = {}
}

// ====================================================================
// @Constants:
// ====================================================================

when ODIN_OS != .Darwin {
    GL_LAST_FEATURES :: true
    GL_MAJOR         :: 4
    GL_MINOR         :: 6
} else {
    GL_LAST_FEATURES :: false
    GL_MAJOR         :: 4
    GL_MINOR         :: 1
}

// ====================================================================
// @Globals:
// ====================================================================

context_gl: sdl.GLContext
window_gl: ^sdl.Window
shader_map_gl: handle_map.Static_Handle_Map(MAX_SHADERS, Shader_GL, Shader_Handle)
vertex_buffer_map_gl: handle_map.Static_Handle_Map(MAX_VERTEX_BUFFERS, Vertex_Buffer_GL, Vertex_Buffer_Handle)
global_buffer_map_gl: handle_map.Static_Handle_Map(MAX_GLOBAL_BUFFERS, Global_Buffer_GL, Global_Buffer_Handle)

} // when OPENGL

// ====================================================================
// @Imports:
// ====================================================================

import "base:runtime"
import "core:log"
import "core:c"
import "core:strings"
import "core:container/handle_map"

import gl "vendor:OpenGL"
import sdl "vendor:sdl3"