#ifdef VERTEX_SHADER                                               

    layout (location = 0) in vec3 a_pos;                           

    layout(std140, binding = 0) uniform Global_Data {              
        mat4 u_transform;                                              
        mat4 u_projection;
        vec4 u_tint;
    };                                                             

    out vec4 v_tint;

    void main() {                                                              
        gl_Position = u_projection * u_transform * vec4(a_pos, 1.0);    
        v_tint = u_tint;
    }

#endif                                                      

#ifdef FRAGMENT_SHADER                                         

    layout (location = 0) out vec4 o_color;                        

    in vec4 v_tint;

    void main() {                                                              
        o_color = v_tint;
    }                                                              

#endif
