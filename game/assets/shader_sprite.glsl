#ifdef VERTEX_SHADER

layout(location = 0) in vec2 a_pos;
layout(location = 1) in vec2 a_uv;

layout(std140) uniform Global_Buffer {
  mat4 u_projection;
  mat4 u_view;
  mat4 u_projection_view;
  mat4 u_transform;
};

out vec2 v_uv;

void main() {
    gl_Position = u_projection_view * u_transform * vec4(a_pos.x, a_pos.y, 0.0, 1.0);
    v_uv = a_uv;
}
#endif

#ifdef FRAGMENT_SHADER

layout(location = 0) out vec4 o_col;

uniform vec4 u_color;
uniform sampler2D u_tex;

in vec2 v_uv;

void main() {
  o_col = u_color * texture(u_tex, v_uv);
}

#endif