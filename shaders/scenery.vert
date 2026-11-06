// Instanced scenery (trees, landmarks) in MapLibre's geographic 3D space.
// Models are in metres with +Z up, +X east, +Y north, origin on the ground.
// Each instance: xy = origin-relative world pixels, z = world pixels per
// metre times the model scale, w = model scale in metres (for height).
#version 460 core

layout(location = 0) in vec3 position;
layout(location = 1) in vec3 normal;
layout(location = 2) in vec3 color;

layout(location = 0) out vec3 v_color;
layout(location = 1) out vec3 v_normal;
layout(location = 2) out float v_explored;

layout(binding = 0) uniform SceneryUniforms {
    mat4 view_projection;
    // x, y world px; z = px per metre * scale; w = scale (metres).
    vec4 instances[160];
    // x = rotation, y = explored (0..1), z = tint, w = unused.
    vec4 params[160];
} u;

void main() {
    vec4 inst = u.instances[gl_InstanceIndex];
    vec4 prm = u.params[gl_InstanceIndex];
    float c = cos(prm.x);
    float s = sin(prm.x);
    vec2 xy = vec2(position.x * c - position.y * s, position.x * s + position.y * c);
    vec2 n_xy = vec2(normal.x * c - normal.y * s, normal.x * s + normal.y * c);
    // Map +Y is south, so north goes to -y.
    vec3 map_position = vec3(inst.x + xy.x * inst.z, inst.y - xy.y * inst.z, position.z * inst.w);
    gl_Position = u.view_projection * vec4(map_position, 1.0);
    v_color = color * prm.z;
    v_normal = normalize(vec3(n_xy.x, -n_xy.y, normal.z));
    v_explored = prm.y;
}
