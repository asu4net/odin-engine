package game

// ===================================================
// @Setup: Shader Sources
// ===================================================

// @Pending: Auto-generate this file in comp-time using the sources folder.

// @Note: Types.
Shader_Type :: enum {
    FlatColor,
}

// @Note: Read-Only Array.
@(private="file") @rodata
shader_sources := [Shader_Type] string {
    .FlatColor = #load("gpu_shader_00_flat_color.glsl", string),
}

// ===================================================

gpu_use_shader :: proc(type: Shader_Type) -> u32 {
    shader := shaders[type]
    if shader == 0 {
        shader = gpu_add_shader(type)
    }
    gl.UseProgram(shader)
    return shader
}

gpu_add_shader :: proc(type: Shader_Type) -> u32 {
    shader := shaders[type]
    if shader != 0 {
        return shader        
    }
    created_shader := create_shader(type)
    shaders[type] = created_shader
    return created_shader
}

del_shader :: proc(type: Shader_Type) {
    shader := shaders[type]
    if shader == 0 do return
    gl.DeleteProgram(shader)
    shaders[type] = 0
}

del_all_shaders :: proc() {
    for &shader in shaders {
        if shader == 0 do continue
        gl.DeleteProgram(shader)
        shader = 0 
    }
}

@(private="file")
create_shader :: proc(type: Shader_Type) -> u32 {
	
    source := shader_sources[type]

    if len(source) == 0 {
		log.error("OpenGL: Error the shader source cannot be empty")
		return 0
	}

	VERT_PREFIX :: "#version 460 core \n#define VERTEX_SHADER \n"
	vert := compile_with_prefix(source, VERT_PREFIX, gl.VERTEX_SHADER)

	if vert == 0 {
		log.errorf("OpenGL: Error compiling the vertex shader")
		return 0
	}

	FRAG_PREFIX :: "#version 460 core \n#define FRAGMENT_SHADER \n"
	frag := compile_with_prefix(source, FRAG_PREFIX, gl.FRAGMENT_SHADER)

	if frag == 0 {
		log.errorf("OpenGL: Error compiling the fragment shader")
		return 0
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
		return 0
	}

	return prog
}

@(private="file")
compile_with_prefix :: proc(source: string, prefix: string, shader_type: u32) -> u32 {
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

// ===================================================
// @Globals:
// ===================================================

@(private="file")
shaders: [Shader_Type] u32

// ===================================================
// @Imports:
// ===================================================

// Odin.
import "core:log"
import "core:strings"

// Vendor.
import gl "vendor:OpenGL"