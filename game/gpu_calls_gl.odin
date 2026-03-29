package game

gpu_clear_screen :: #force_inline proc(color: float4 = COLOR_CORN_FLOWER_BLUE) {
	gl.ClearColor(color.r, color.g, color.b, 1)
	gl.Clear(gl.COLOR_BUFFER_BIT)
}

// ===================================================
// @Imports:
// ===================================================

// Vendor.
import gl "vendor:OpenGL"