package game

gpu_context_init :: proc() {

    log.info("GL Context start.")

    sdl.GL_SetAttribute(sdl.GL_CONTEXT_MAJOR_VERSION, OPENGL_MAJOR)
    sdl.GL_SetAttribute(sdl.GL_CONTEXT_MINOR_VERSION, OPENGL_MINOR)
    sdl.GL_SetAttribute(sdl.GL_CONTEXT_PROFILE_MASK, c.int(sdl.GL_CONTEXT_PROFILE_CORE))

    gl_context = sdl.GL_CreateContext(window)

    if gl_context == nil {
		log.errorf("Error: sdl.CreateContext: %v\n", sdl.GetError())
        return
    }

    gl.load_up_to(OPENGL_MAJOR, OPENGL_MINOR, sdl.gl_set_proc_address)

    when ODIN_DEBUG && OPENGL_LAST_FEATURES {
        gl.DebugMessageCallback(gl_debug_callback, nil)
    }
}

gpu_context_done :: proc() {

    if gl_context != nil {
        log.info("GL SDL Context finish.")
        if !sdl.GL_DestroyContext(gl_context) {
		    log.errorf("Error: sdl.DestroyContext: %v\n", sdl.GetError())
            return
        }
        gl_context = nil
    }
}

gpu_swap_buffers :: #force_inline proc() {
	sdl.GL_SwapWindow(window)
}

@(private="file")
gl_debug_callback :: proc "c" (source: u32, type: u32, id: u32, severity: u32, length: i32, message: cstring, user_param: rawptr) {
    
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

// ===================================================
// @Globals:
// ===================================================

@(private="file")
gl_context: sdl.GLContext

// ===================================================
// @Imports:
// ===================================================

// Odin.
import "base:runtime"
import "core:log"
import "core:c"

// Vendor.
import gl "vendor:OpenGL"
import sdl "vendor:sdl3"