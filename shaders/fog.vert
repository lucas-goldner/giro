// Fog of war: a full-screen quad in clip space. The fragment shader
// reconstructs the map position of every pixel from the camera matrix.
#version 460 core

layout(location = 0) in vec2 a_position;

layout(location = 0) out vec2 v_clip;

void main() {
    v_clip = a_position;
    gl_Position = vec4(a_position, 0.0, 1.0);
}
