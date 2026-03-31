package gpu

when OPENGL
{

// ====================================================================
// @Region: Data_Type
// ====================================================================

to_data_type_gl :: proc(type: i32) -> Data_Type 
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

from_data_type_gl :: proc(type: Data_Type) -> u32 
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

data_type_is_attribute_gl :: proc(type: Data_Type) -> bool 
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

// ====================================================================
// @Region: Context
// ====================================================================

create_context_gl :: proc(window: ^sdl.Window) -> bool
{
    log.info("GL Context start.")
    sdl.GL_SetAttribute(sdl.GL_CONTEXT_MAJOR_VERSION, GL_MAJOR)
    sdl.GL_SetAttribute(sdl.GL_CONTEXT_MINOR_VERSION, GL_MINOR)
    sdl.GL_SetAttribute(sdl.GL_CONTEXT_PROFILE_MASK, c.int(sdl.GL_CONTEXT_PROFILE_CORE))

    context_gl = sdl.GL_CreateContext(window)

    if context_gl == nil 
    {
		log.errorf("Error: sdl.CreateContext: %v\n", sdl.GetError())
        return false
    }

    gl.load_up_to(GL_MAJOR, GL_MINOR, sdl.gl_set_proc_address)

    when ODIN_DEBUG && GL_LAST_FEATURES 
    {
        gl.DebugMessageCallback(debug_callback_gl, nil)
    }

    window_gl = window
    
    return true
}

destroy_context_gl :: proc() 
{
    if context_gl != nil 
    {
        log.info("GL SDL Context finish.")
        if !sdl.GL_DestroyContext(context_gl) 
        {
		    log.errorf("Error: sdl.DestroyContext: %v\n", sdl.GetError())
            return
        }
        context_gl = nil
        window_gl = nil
    }
}

swap_buffers_gl :: #force_inline proc() 
{
	sdl.GL_SwapWindow(window_gl)
}

clear_screen_gl :: #force_inline proc(color: [4]f32 = {0, 0, 0, 1}) 
{
	gl.ClearColor(color.r, color.g, color.b, 1)
	gl.Clear(gl.COLOR_BUFFER_BIT)
}

debug_callback_gl :: proc "c" (source: u32, type: u32, id: u32, severity: u32, length: i32, message: cstring, user_param: rawptr) 
{
    context = runtime.default_context()

    to_string_src :: #force_inline proc(source: u32) -> string 
    {
        switch source 
        {
            case gl.DEBUG_SOURCE_API:               return "API"
            case gl.DEBUG_SOURCE_WINDOW_SYSTEM:     return "Window System"
            case gl.DEBUG_SOURCE_SHADER_COMPILER:   return "Shader Compiler"
            case gl.DEBUG_SOURCE_THIRD_PARTY:       return "Third Party"
            case gl.DEBUG_SOURCE_APPLICATION:       return "Application"
            case gl.DEBUG_SOURCE_OTHER:             return "Unknown"
            case:                                   return "Unknown"
        }
    }

    to_string_type :: #force_inline proc(type: u32) -> string 
    {
        switch type 
        {
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

    to_proc_severity :: #force_inline proc(severity: u32) -> Log_Proc 
    {
        switch severity 
        {
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
Vertex_Buffer_GL :: struct 
{
    handle: Vertex_Buffer_Handle,
    vao, vbo, ebo: u32, 
    elem_count: i32,
}

add_vertex_buffer_gl :: #force_inline proc(def: Vertex_Buffer_Def) -> (handle: Vertex_Buffer_Handle, ok: bool) #optional_ok
{
    return handle_map.add(&vertex_buffers_gl, create_vertex_buffer_gl(def))
}

remove_vertex_buffer_gl :: #force_inline proc(handle: Vertex_Buffer_Handle)
{
    vb, ok := handle_map.get(&vertex_buffers_gl, handle)
    assert(ok, "Error: Invalid vertex buffer.")
    destroy_vertex_buffer_gl(vb)
    handle_map.remove(&vertex_buffers_gl, handle)
}

create_vertex_buffer_gl :: proc(def: Vertex_Buffer_Def) -> Vertex_Buffer_GL
{
    vao, vbo, ebo: u32

    gl.GenVertexArrays(1, &vao)
    gl.BindVertexArray(vao)

    gl.GenBuffers(1, &vbo)
    gl.BindBuffer(gl.ARRAY_BUFFER, vbo)

    usage  := u32(def.data != nil ? gl.STATIC_DRAW : gl.DYNAMIC_DRAW)
    stride := i32(def.len > 0 ? def.vsize : 0)
    offset := 0
    
    gl.BufferData(gl.ARRAY_BUFFER, def.vsize * def.len, def.data, usage)
    
    for &attr, i in def.attrs {
        if !data_type_is_attribute_gl(attr) do continue

        gl.EnableVertexAttribArray(u32(i))
        if !data_type_is_integer(attr) {
            gl.VertexAttribPointer(u32(i), i32(data_type_len(attr)), from_data_type_gl(attr), gl.FALSE, stride, uintptr(offset))
        } else {
            gl.VertexAttribIPointer(u32(i), i32(data_type_len(attr)), from_data_type_gl(attr), stride, uintptr(offset))
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

destroy_vertex_buffer_gl :: proc(vb: ^Vertex_Buffer_GL)
{
    assert(vb.vao != 0 && vb.vbo != 0 && vb.ebo != 0, "Error: Invalid vertex buffer.")
    gl.DeleteVertexArrays(1, &vb.vao)
    gl.DeleteBuffers(1, &vb.vbo)
    gl.DeleteBuffers(1, &vb.ebo)
    vb^ = {}
}

draw_vertex_buffer_gl :: proc(handle: Vertex_Buffer_Handle, count: i32 = 0, index_offset: u32 = 0)
{
    vb, ok := handle_map.get(&vertex_buffers_gl, handle)
    assert(ok, "Error: Invalid vertex buffer.")
    gl.BindVertexArray(vb.vao)
    gl.DrawElements(gl.TRIANGLES, count == 0 ? vb.elem_count : count, gl.UNSIGNED_INT, rawptr(uintptr(index_offset * size_of(u32))))
}

// ====================================================================
// @Region: Shader
// ====================================================================

Shader_GL :: struct
{
    handle: Shader_Handle,
    program: u32,
}

add_shader_gl :: #force_inline proc(source: string) -> (handle: Shader_Handle, ok: bool) #optional_ok
{
    return handle_map.add(&shaders_gl, create_shader_gl(source))
}

remove_shader_gl :: #force_inline proc(handle: Shader_Handle)
{
    shader, ok := handle_map.get(&shaders_gl, handle)
    assert(ok, "Error: Invalid shader.")
    destroy_shader_gl(shader^)
    handle_map.remove(&shaders_gl, handle)
}

create_shader_gl :: proc(source: string) -> Shader_GL
{	
    if len(source) == 0 
    {
		log.error("Error: The shader source cannot be empty.")
		return {}
	}

	VERT_PREFIX :: "#version 410 core \n#define VERTEX_SHADER \n"
	vert := compile_shader_with_prefix_gl(source, VERT_PREFIX, gl.VERTEX_SHADER)

	if vert == 0 
    {
		log.errorf("Error: Vertex Shader compilation failed.")
		return {}
	}

	FRAG_PREFIX :: "#version 410 core \n#define FRAGMENT_SHADER \n"
	frag := compile_shader_with_prefix_gl(source, FRAG_PREFIX, gl.FRAGMENT_SHADER)

	if frag == 0 
    {
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

	if success == 0 
    {
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

destroy_shader_gl :: proc(shader: Shader_GL)
{
    assert(shader.program != 0, "Error: Invalid shader.")
    gl.DeleteProgram(shader.program)
}

use_shader_gl :: proc(handle: Shader_Handle)
{
    shader, ok := handle_map.get(&shaders_gl, handle)
    assert(ok && shader.program != 0, "Error: Invalid shader.")
    gl.UseProgram(shader.program)
}

compile_shader_with_prefix_gl :: proc(source: string, prefix: string, shader_type: u32) -> u32 
{
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

	if success == 0 
    {
		LOG_BUFFER_SIZE :: 512
		log_buffer: [LOG_BUFFER_SIZE]u8
		log_length: i32
		gl.GetShaderInfoLog(shader, LOG_BUFFER_SIZE, &log_length, &log_buffer[0])
		log.errorf("OpenGL: Error compiling the shader:\n\n%v\n", string(log_buffer[0:log_length - 1]))
		return 0
	}

	return shader
}

// ===================================================
// @Constants:
// ===================================================

when ODIN_OS != .Darwin 
{
    GL_LAST_FEATURES :: true
    GL_MAJOR         :: 4
    GL_MINOR         :: 6
} 
else 
{
    GL_LAST_FEATURES :: false
    GL_MAJOR         :: 4
    GL_MINOR         :: 1
}

// ===================================================
// @Globals:
// ===================================================

context_gl: sdl.GLContext
window_gl: ^sdl.Window
shaders_gl: handle_map.Static_Handle_Map(MAX_SHADERS, Shader_GL, Shader_Handle)
vertex_buffers_gl: handle_map.Static_Handle_Map(MAX_VERTEX_BUFFERS, Vertex_Buffer_GL, Vertex_Buffer_Handle)

} // when OPENGL

// ===================================================
// @Imports:
// ===================================================

import "base:runtime"
import "core:log"
import "core:c"
import "core:strings"
import "core:container/handle_map"

import gl "vendor:OpenGL"
import sdl "vendor:sdl3"