#ifdef VERTEX_SHADER

layout(location = 0) in vec2 a_pos;
layout(location = 1) in vec2 a_uv;

void main() {
    gl_Position = vec4(a_pos.x, a_pos.y, 0.0, 1.0);
}
#endif

#ifdef FRAGMENT_SHADER

layout(location = 0) out vec4 o_col;

void main() {
  o_col = vec4(0, 1, 0, 1);
}

#endif