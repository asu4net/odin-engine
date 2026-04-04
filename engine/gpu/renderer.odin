package gpu

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
    projection    : Projection,
    viewport      : [2] f32,
    viewport_gui  : [2] f32,
    pv_matrix     : matrix[4,4] f32,
    pv_matrix_gui : matrix[4,4] f32,
    batch_quad    : Batch2D(Quad_Vertex, MAX_QUADS_PER_FRAME)
}

test :: proc(renderer: ^Renderer) {
    def: Batch2D_Def
    batch2d_init(&renderer.batch_quad, def)
}