package game

@(private="file")
Global_Shader_Data :: struct {
    transform: matrix[4, 4] f32,
    projection: matrix[4, 4] f32,
    tint: [4] f32,
}

@(private="file")
Scene2D :: struct {
    vao: u32,
    vbo: u32,
    ebo: u32,
    ubo: u32,
}

// @Note: Anti clock wise elements.
QUAD_ELEMENTS :: []u32 {
    0, 1, 2, // Triangle 1.
    2, 3, 0, // Triangle 2.            
}

draw_init :: proc() {

    log.info("Scene2D start.")

    // @Note Global data defaults.
    global_data.tint = {1, 1, 1, 1}
    global_data.transform = linalg.identity(matrix[4, 4]f32)
    global_data.projection = linalg.identity(matrix[4, 4]f32)

    // @Note: Programs to load.
    gpu_add_shader(.FlatColor)
    
    // @Note: Create the vertex array.
    gl.CreateVertexArrays(1, &scene2d.vao)
    
    // @Note: Create the element buffer.
    gl.CreateBuffers(1, &scene2d.ebo)
    gl.NamedBufferData(scene2d.ebo, size_of(u32) * len(QUAD_ELEMENTS), raw_data(QUAD_ELEMENTS), gl.STATIC_DRAW)

    // @Note: Create the vertex buffer.
    QUAD_VERTICES :: []f32 {
        -0.5, -0.5,
        +0.5, -0.5,
        +0.5, +0.5,
        -0.5, +0.5,
    }
    
    QUAD_VERTEX_SIZE :: size_of(f32) * 2

    gl.CreateBuffers(1, &scene2d.vbo)
    gl.NamedBufferData(scene2d.vbo, QUAD_VERTEX_SIZE * len(QUAD_VERTICES), raw_data(QUAD_VERTICES), gl.STATIC_DRAW)

    // @Note: This is the slot of our vertex buffer inside the vertex array.
    binding_index: u32
    
    // @Note: Vertex layout

    // Position.
    {
        gl.EnableVertexArrayAttrib(scene2d.vao, index = 0)
        gl.VertexArrayAttribFormat(scene2d.vao, attribindex = 0, size = 2, type = gl.FLOAT, normalized = false, relativeoffset = 0)
        gl.VertexArrayAttribBinding(scene2d.vao, attribindex = 0, bindingindex = binding_index)
    }

    // @Note: Link the vertex buffer and the element buffer to the vertex array.
    gl.VertexArrayElementBuffer(scene2d.vao, scene2d.ebo)
    gl.VertexArrayVertexBuffer(scene2d.vao, bindingindex = binding_index, buffer = scene2d.vbo, offset = 0, stride = size_of(f32) * 2)

    // @Note: Create the uniform buffer.
    gl.CreateBuffers(1, &scene2d.ubo)
    gl.NamedBufferData(scene2d.ubo, size_of(Global_Shader_Data), nil, gl.DYNAMIC_DRAW)
}

draw_done :: proc() {

    log.info("Scene2D finish.")

    del_all_shaders()

    gl.DeleteVertexArrays(1, &scene2d.vao)
    gl.DeleteBuffers(1, &scene2d.ebo)
    gl.DeleteBuffers(1, &scene2d.vbo)
    gl.DeleteBuffers(1, &scene2d.ubo)
}

Scene2D_Args :: struct {   
    viewport_w: i32,
    viewport_h: i32,
    view: [2]f32,
    zoom: f32,
}

DEFAULT_SCENE2D_ARGS :: Scene2D_Args {
    viewport_w = 1280,
    viewport_h = 720,
    view = { 0, 0 },
    zoom = 3,
}

draw_frame_init_2d :: proc(args := DEFAULT_SCENE2D_ARGS) {
    aspect := f32(args.viewport_w) / f32(args.viewport_h)
    w := args.zoom * aspect
    h := args.zoom
    global_data.projection = linalg.matrix_ortho3d(-w, w, -h, h, 0, 1) 
    gl.Viewport(0, 0, width = args.viewport_w, height = args.viewport_h)
}

draw_frame_done_2d :: proc() {}

draw_quad :: proc(pos: [2]f32 = {1, 1}, col := COLOR_WHITE) {
    global_data.transform = linalg.matrix4_translate([3]f32{pos.x, pos.y, 0})
    global_data.tint = col
    gl.NamedBufferSubData(scene2d.ubo, offset = 0, size = size_of(Global_Shader_Data), data = &global_data)
    gl.BindBufferBase(gl.UNIFORM_BUFFER, index = 0, buffer = scene2d.ubo)
    gpu_use_shader(.FlatColor)
    gl.BindVertexArray(scene2d.vao)
    gl.DrawElements(gl.TRIANGLES, auto_cast len(QUAD_ELEMENTS), gl.UNSIGNED_INT, nil)
}

// ===================================================
// @Globals:
// ===================================================

@(private="file")
scene2d: Scene2D
global_data: Global_Shader_Data

// ===================================================
// @Imports:
// ===================================================

// Odin.
import "core:log"
import "core:math/linalg"

// Vendor.
import gl "vendor:OpenGL"