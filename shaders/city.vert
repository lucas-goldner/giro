// Advanced graphics: Giro's own buildings. Positions are tile units for x/y
// and metres for z; the tile uniform places them in origin-relative world
// pixels (MapLibre's convention, z stays metres).
#version 460 core

layout(location = 0) in vec3 position;
layout(location = 1) in vec3 normal;
layout(location = 2) in vec2 extra; // ao, kind + tint

layout(location = 0) out vec3 v_normal;
layout(location = 1) out vec3 v_world;
layout(location = 2) out vec2 v_extra;
layout(location = 3) out vec4 v_shadow;
layout(location = 4) out vec2 v_mask;

layout(binding = 0) uniform CityUniforms {
    mat4 view_projection;
    mat4 light_vp;
    // x, y: tile origin in origin-relative world px; z: px per tile unit;
    // w: px per metre at the tile.
    vec4 tile;
    // Explored mask: x, y = origin offset in world fraction minus mask
    // origin; z, w = 1 / mask span. world.x = world size in px.
    vec4 mask;
    vec4 world;
} u;

void main() {
    vec3 p = vec3(u.tile.x + position.x * u.tile.z,
                  u.tile.y + position.y * u.tile.z,
                  position.z);
    gl_Position = u.view_projection * vec4(p, 1.0);
    v_shadow = u.light_vp * vec4(p, 1.0);
    v_normal = vec3(normal.x, normal.y, normal.z / max(u.tile.w, 1e-6));
    v_world = p;
    v_extra = extra;
    v_mask = (p.xy / u.world.x + u.mask.xy) * u.mask.zw;
}
