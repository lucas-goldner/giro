// Ground shadow receiver: a quad over the tile at z = 0, multiplied onto
// the map where buildings shade it.
#version 460 core

layout(location = 0) in vec2 position; // tile units

layout(location = 0) out vec4 v_shadow;
layout(location = 1) out vec2 v_mask;

layout(binding = 0) uniform GroundUniforms {
    mat4 view_projection;
    mat4 light_vp;
    vec4 tile;
    vec4 mask;
    vec4 world;
} u;

void main() {
    vec3 p = vec3(u.tile.x + position.x * u.tile.z,
                  u.tile.y + position.y * u.tile.z, 0.0);
    gl_Position = u.view_projection * vec4(p, 1.0);
    v_shadow = u.light_vp * vec4(p, 1.0);
    v_mask = (p.xy / u.world.x + u.mask.xy) * u.mask.zw;
}
