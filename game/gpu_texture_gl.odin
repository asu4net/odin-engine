package game

Texture_Kind :: enum {
    Single,
    Multiple,
}

Texture_Filter :: enum {
    Nearest,
    Linear,
}

create_gl_texture_from_image :: proc(image: Image_Type, filter: Texture_Filter = .Nearest) -> (texture: u32) {
    w, h, c: c.int
    pixels := stb_image.load_from_memory(raw_data(images[image]), len(images), &w, &h, &c, 4)
    if pixels == nil do return
    gl.CreateTextures(gl.TEXTURE_2D, 1, &texture)
    storage_format: u32 = c == 4 ? gl.RGBA8 : c == 3 ? gl.RGB8 : 0
    assert(storage_format != 0 && w > 0 && h > 0)
    gl.TextureStorage2D(texture, 1, storage_format, w, h)
    gl_filter: i32 = filter == .Nearest ? gl.NEAREST : filter == .Linear ? gl.LINEAR : 0  
    gl.TextureParameteri(texture, gl.TEXTURE_MIN_FILTER, gl_filter)
    gl.TextureParameteri(texture, gl.TEXTURE_MAG_FILTER, gl_filter)
    gl.TextureParameteri(texture, gl.TEXTURE_WRAP_S, gl.REPEAT)
    gl.TextureParameteri(texture, gl.TEXTURE_WRAP_T, gl.REPEAT)
    return
}

// ===================================================
// @Imports:
// ===================================================

// Odin.
import "core:c"

// Vendor.
import stb_image "vendor:stb/image"
import gl "vendor:OpenGL"
