#ifdef VERTEX_SHADER

// =====================
// Attributes.
// =====================
layout(location = 0) in vec4 a_pos;
layout(location = 1) in vec4 a_tint;
layout(location = 2) in vec2 a_uv;
layout(location = 3) in int  a_tex;
layout(location = 4) in int  a_id;

layout(std140) uniform Global_Buffer {
  mat4 u_projection;
  mat4 u_view;
  mat4 u_projection_view;
  mat4 u_transform;
};

// =====================
// Out Variables.
// =====================
out vec4     v_tint;
out vec2     v_uv;
flat out int v_tex; 

void main() {
    gl_Position = u_projection_view * a_pos;

    // Out variables assignment.
    v_tint = a_tint;
    v_uv   = a_uv;
    v_tex  = a_tex;
}
#endif

// -------------------------------------------------------------------------------------------

#ifdef FRAGMENT_SHADER

// =====================
// Out Variables.
// =====================
layout(location = 0) out vec4 o_col;

// =====================
// Uniforms.
// =====================
uniform sampler2D u_textures[32];

// =====================
// In Variables.
// =====================
in vec2     v_uv;
in vec4     v_tint;
flat in int v_tex;

void main() {
  o_col =  texture(u_textures[v_tex], v_uv) * v_tint;
}

#endif