package gpu

// ====================================================================
// @Region: Camera
// ====================================================================

Renderer_Camera_Mode :: enum {
    nil,
    GUI,
    World_2D,
    World_3D,
    Custom,
}

Renderer_Camera :: struct {
    eye        : [3] f32,
    near       : f32,
    far        : f32,
    right      : [3] f32,
    up         : [3] f32,
    front      : [3] f32,
    zoom       : f32, // 2D Specific.
    fov        : f32, // 3D Specific.
}

DEFAULT_RENDERER_CAMERA_3D :: Renderer_Camera {
    eye         = { 0, 0, 40 },
    near        = 0.1,
    far         = 100,
    right       = { 1, 0, 0 },
    up          = { 0, 1, 0 },
    front       = { 0, 0, 1 },
    zoom        = 0,
    fov         = 60
}

DEFAULT_RENDERER_CAMERA_2D :: Renderer_Camera {
    eye        = { 0, 0, 0 },
    near       = -1,
    far        = +1,
    right      = { 1, 0, 0 },
    up         = { 0, 1, 0 },
    front      = { 0, 0, 1 },
    zoom       = 3,
    fov        = 0
}

// ====================================================================
// @Region: Batch2D
// ====================================================================

Batch2D_Def :: struct {
    attrs  : [] Data_Type,
    shader : Shader_Def,
}

Batch2D :: struct($Vertex: typeid, $Max: int) {
    vertices      : [] Vertex,
    vertex_buffer : Vertex_Buffer_Handle,
    curr_verts    : int,
    curr_elems    : int,
    curr_shader   : Shader_Handle,
    shader        : Shader_Handle,
}

@(private="file")
ELEMS_PER_VERTEX :: 6

@(private="file")
VERTS_PER_SHAPE :: 4

@(private="file")
DEFAULT_VERTEX_POS :: [VERTS_PER_SHAPE] [4]f32 {
    {-0.5, -0.5,  0.0,  1.0 }, // bottom-left
    { 0.5, -0.5,  0.0,  1.0 }, // bottom-right
    { 0.5,  0.5,  0.0,  1.0 }, // top-right
    {-0.5,  0.5,  0.0,  1.0 }, // top-left
}

@(private="file")
DEFAULT_VERTEX_UVS :: [VERTS_PER_SHAPE] [2]f32 {
    { 0.0, 0.0 }, // bottom-left
    { 1.0, 0.0 }, // bottom-right
    { 1.0, 1.0 }, // top-right
    { 0.0, 1.0 }, // top-left
}

@(private="file")
DEFAULT_VERTEX_EMS :: [ELEMS_PER_VERTEX] u32 {
    0, 1, 2, // triangle A
    2, 3, 0, // triangle B
}

batch2d_init :: proc(batch: ^Batch2D($Vertex, $Max), def: Batch2D_Def) {

    assert(len(batch.vertices) == 0)

    // Vertices Array.
    batch.vertices = make([]Vertex, VERTS_PER_SHAPE * Max)

    // Elems Array.
    ELEM_COUNT :: ELEMS_PER_VERTEX * Max
    elems := make([]u32, ELEM_COUNT)
    defer delete(elems)
    
    offset: u32
    for i := 0; i < ELEM_COUNT; i += ELEMS_PER_VERTEX {

        elems[i + 0] = offset + 0
        elems[i + 1] = offset + 1
        elems[i + 2] = offset + 2

        elems[i + 3] = offset + 2
        elems[i + 4] = offset + 3
        elems[i + 5] = offset + 0

        offset += VERTS_PER_SHAPE
    }

    // Vertex buffer creation.
    batch.vertex_buffer = vertex_buffer_add({
        data  = nil,
        count = Max * 4,
        vsize = size_of(Vertex),
        attrs = def.attrs,
        elems = elems,
    })

    batch.shader = shader_add(def.shader)
    batch.curr_shader = batch.shader
}

batch2d_destroy :: proc(batch: ^Batch2D($Vertex, $Max)) {
    assert(len(batch.vertices) != 0)
    delete(batch.vertices)
    vertex_buffer_rem(batch.vertex_buffer)
    shader_rem(batch.shader)
    batch^ = {}
}

// ====================================================================
// @Region: Renderer
// ====================================================================

Primitive_Type :: enum {
    nil,
    Quad,
    Circle
}

MAX_QUADS_PER_FRAME :: 1000

Quad_Vertex :: struct {
    pos  : [4] f32,
    tint : [4] f32,
    uv   : [2] f32,
    tex  : int,
    id   : int,
}

Quad_Flag :: enum {
    None,
    Autosize,
    FlipX,
    FlipY,
}

MAX_TEXTURES_PER_FRAME :: 32

Renderer_Textures :: struct {
    white      : Texture_Handle,
    slot_array : [MAX_TEXTURES_PER_FRAME] int,
    bind_array : [MAX_TEXTURES_PER_FRAME] Texture_Handle,
    last_slot  : int,
}

Renderer :: struct {
    textures      : Renderer_Textures,
    blending      : Blending_Mode,
    primitive     : Primitive_Type,
    camera_mode   : Renderer_Camera_Mode,
    camera        : Renderer_Camera,
    viewport      : [2] f32,
    viewport_gui  : [2] f32,
    pv_matrix     : matrix[4,4] f32,
    quad_batch    : Batch2D(Quad_Vertex, MAX_QUADS_PER_FRAME)
}

@(private="file")
renderer: Renderer

renderer_create :: proc() {
    renderer.camera = DEFAULT_RENDERER_CAMERA_2D
    batch2d_init(&renderer.quad_batch, {
        shader = { source = #load("assets/shaders/shader_quad.glsl", string) },
        attrs  = {
            .Float4, // pos
            .Float4, // tint
            .Float2, // uv
            .Int,    // tex
            .Int     // id
        }
    })
}

renderer_destroy :: proc() {
    batch2d_destroy(&renderer.quad_batch)
}

renderer_change_primitive :: proc(primitive: Primitive_Type) {
    if renderer.primitive == primitive {
        return
    }
    renderer.primitive = primitive
    renderer_flush()
}

renderer_change_blending :: proc(blending: Blending_Mode) {
    if renderer.blending == blending {
        return
    }
    renderer.blending = blending
    renderer_flush()
}

renderer_set_viewport :: #force_inline proc(viewport: [2] f32) {
    renderer.viewport = viewport
}

renderer_set_pv_matrix :: #force_inline proc(pv_matrix: matrix [4, 4] f32) {
    renderer.pv_matrix = pv_matrix
}

renderer_update_pv_matrix :: proc() {
    switch renderer.camera_mode {
        case .Custom:

        case .nil:
            renderer.pv_matrix = alg.identity(matrix [4, 4] f32)

        case .GUI:
            viewport := renderer.viewport 
            renderer.pv_matrix = alg.matrix_ortho3d(0, viewport.x, viewport.y, 0, -1, +1)

        case .World_2D:
            viewport  := renderer.viewport 
            aspect    := viewport.x / viewport.y
            near, far := renderer.camera.near, renderer.camera.far
            zoom      := renderer.camera.zoom
            width     := zoom * aspect
            height    := zoom
            renderer.pv_matrix = alg.matrix_ortho3d(-width, width, -height, height, near, far)
            
        case .World_3D:
            fov       := renderer.camera.fov
            viewport  := renderer.viewport 
            aspect    := viewport.x / viewport.y
            near, far := renderer.camera.near, renderer.camera.far
            renderer.pv_matrix = alg.matrix4_perspective(fov, aspect, near, far)
    }
}

renderer_flush :: proc() {
    renderer_update_pv_matrix()
}

// ====================================================================
// @Imports:
// ====================================================================

import alg "core:math/linalg"