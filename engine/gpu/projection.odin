package gpu

Projection_Type :: enum {
    nil,
    Ortho_Screen,
    Ortho_World,
    Perspective,
}

Projection :: struct {
    type   : Projection_Type,
    eye    : [3] f32,
    near   : f32,
    far    : f32,
    right  : [3] f32,
    up     : [3] f32,
    front  : [3] f32,
    zoom   : f32, // 2D Specific.
    fov    : f32, // 3D Specific.
}

DEFAULT_PROJECTION_3D :: Projection {
    type  = .Perspective,
    eye   = { 0, 0, 40 },
    near  = 0.1,
    far   = 100,
    right = { 1, 0, 0 },
    up    = { 0, 1, 0 },
    front = { 0, 0, 1 },
    zoom  = 0,
    fov   = 60
}

DEFAULT_PROJECTION_2D :: Projection {
    type  = .Ortho_World,
    near  = 0,
    far   = 1,
    right = { 1, 0, 0 },
    up    = { 0, 1, 0 },
    front = { 0, 0, 1 },
    zoom  = 3,
    fov   = 0
}