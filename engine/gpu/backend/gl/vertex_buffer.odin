package backend_gl
/*
Vert_View :: struct {
    data: rawptr,
    len: int,
    vsize: int, 
}

@(private="file")
Vertex_Buffer_GL :: struct {
    vao, vbo, ebo: u32, 
    len: int,
}

@(private="file")
vertex_buffer_init_gl :: proc(vb: ^Vertex_Buffer_GL, verts: Vert_View, attrs: [] shared.Data_Type, elems: []u32) {

    vao, vbo, ebo: u32

    gl.GenVertexArrays(1, &vao)
    gl.BindVertexArray(vao)

    gl.GenBuffers(1, &vbo)
    gl.BindBuffer(gl.ARRAY_BUFFER, vbo)

    usage  := u32(verts.data != nil ? gl.STATIC_DRAW : gl.DYNAMIC_DRAW)
    stride := i32(verts.len > 0 ? verts.vsize : 0)
    offset := 0
    
    gl.BufferData(gl.ARRAY_BUFFER, verts.vsize * verts.len, verts.data, usage)
    
    for &attr, i in attrs {
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
    gl.BufferData(gl.ELEMENT_ARRAY_BUFFER, len(elems) * size_of(u32), raw_data(elems), gl.STATIC_DRAW)

    vb.vao = vao
    vb.vbo = vbo
    vb.ebo = ebo
    vb.len = len(elems)

    // Clenaup.
    gl.BindVertexArray(0)
    gl.BindBuffer(gl.ARRAY_BUFFER, 0)
    gl.BindBuffer(gl.ELEMENT_ARRAY_BUFFER, 0)
}

// ===================================================
// @Imports:
// ===================================================

import gl "vendor:OpenGL"
import shared "engine:gpu/shared"
*/