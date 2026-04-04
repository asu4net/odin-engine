package gpu

Batch2D_Def :: struct {
    attrs  : [] Data_Type,
    shader : Shader_Def,
}

Batch2D :: struct($Vertex: typeid, $Max: int) {
    vertices      : [] Vertex,
    vertex_buffer : Vertex_Buffer_Handle,
    shape_count   : int,
    elem_count    : int,
    shader        : Shader_Handle,
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
}

batch2d_destroy :: proc(batch: ^Batch2D) {
    assert(len(batch.vertices) != 0)
    delete(batch.vertices)
    vertex_buffer_rem(batch.vertex_buffer)
    shader_rem(batch.shader)
    batch^ = {}
}

// ====================================================================
// @Constants:
// ====================================================================

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