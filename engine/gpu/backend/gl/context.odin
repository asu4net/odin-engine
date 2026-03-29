package backend_gl

when ODIN_OS != .Darwin {
    LAST_FEATURES :: true
    MAJOR         :: 4
    MINOR         :: 6
} else {
    LAST_FEATURES :: false
    MAJOR         :: 4
    MINOR         :: 1
}

create_context :: proc(window: ^sdl.Window) -> bool
{
    log.info("GL Context start.")
    sdl.GL_SetAttribute(sdl.GL_CONTEXT_MAJOR_VERSION, MAJOR)
    sdl.GL_SetAttribute(sdl.GL_CONTEXT_MINOR_VERSION, MINOR)
    sdl.GL_SetAttribute(sdl.GL_CONTEXT_PROFILE_MASK, c.int(sdl.GL_CONTEXT_PROFILE_CORE))

    gl_context = sdl.GL_CreateContext(window)

    if gl_context == nil 
    {
		log.errorf("Error: sdl.CreateContext: %v\n", sdl.GetError())
        return false
    }

    gl.load_up_to(MAJOR, MINOR, sdl.gl_set_proc_address)

    when ODIN_DEBUG && LAST_FEATURES 
    {
        gl.DebugMessageCallback(debug_callback, nil)
    }

    the_window = window
    
    return true
}

destroy_context :: proc() 
{
    if gl_context != nil 
    {
        log.info("GL SDL Context finish.")
        if !sdl.GL_DestroyContext(gl_context) 
        {
		    log.errorf("Error: sdl.DestroyContext: %v\n", sdl.GetError())
            return
        }
        gl_context = nil
        the_window = nil
    }
}

swap_buffers :: #force_inline proc() 
{
	sdl.GL_SwapWindow(the_window)
}

@(private="file")
debug_callback :: proc "c" (source: u32, type: u32, id: u32, severity: u32, length: i32, message: cstring, user_param: rawptr) 
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

// ===================================================
// @Globals:
// ===================================================

@(private="file")
gl_context: sdl.GLContext

@(private="file")
the_window: ^sdl.Window

// ===================================================
// @Imports:
// ===================================================

import "base:runtime"
import "core:log"
import "core:c"

import gl "vendor:OpenGL"
import sdl "vendor:sdl3"