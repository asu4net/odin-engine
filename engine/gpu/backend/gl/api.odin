package backend_gl

clear_screen :: #force_inline proc(color: [4]f32 = {0, 0, 0, 1}) {
	gl.ClearColor(color.r, color.g, color.b, 1)
	gl.Clear(gl.COLOR_BUFFER_BIT)
}

// ===================================================
// @Imports:
// ===================================================

import gl "vendor:OpenGL"