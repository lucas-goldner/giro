// Toy-city scenery shading: one warm key light, soft ambient, and white
// clay with grey shading where the ground is unexplored (kept neutral so
// the fog pass leaves it alone).
#version 460 core

layout(location = 0) in vec3 v_color;
layout(location = 1) in vec3 v_normal;
layout(location = 2) in float v_explored;

layout(location = 0) out vec4 frag_color;

void main() {
    vec3 light = normalize(vec3(-0.45, 0.35, 0.82));
    float diffuse = max(dot(normalize(v_normal), light), 0.0);
    float shade = 0.58 + 0.42 * diffuse;
    vec3 lit = v_color * shade * vec3(1.0, 0.98, 0.94);
    vec3 clay = vec3(0.985) * (0.70 + 0.30 * diffuse);
    vec3 rgb = mix(clay, lit, clamp(v_explored, 0.0, 1.0));
    frag_color = vec4(rgb, 1.0);
}
