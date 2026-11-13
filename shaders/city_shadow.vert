// Shadow pass: buildings seen from the sun.
#version 460 core

layout(location = 0) in vec3 position;
layout(location = 1) in vec3 normal;
layout(location = 2) in vec2 extra;

layout(binding = 0) uniform ShadowUniforms {
    mat4 light_vp;
    vec4 tile; // x, y origin px; z px per tile unit; w unused
} u;

void main() {
    vec3 p = vec3(u.tile.x + position.x * u.tile.z,
                  u.tile.y + position.y * u.tile.z,
                  position.z);
    gl_Position = u.light_vp * vec4(p, 1.0);
}
