#version 460 core

layout(location = 0) in vec4 v_shadow;
layout(location = 1) in vec2 v_mask;

layout(location = 0) out vec4 frag_color;

layout(binding = 1) uniform GroundLight {
    vec4 params; // x: shadow texel, y: bias, z: strength, w: unused
} light;

layout(binding = 2) uniform sampler2D shadow_map;
layout(binding = 3) uniform sampler2D mask_texture;

float unpack_depth(vec4 rgba) {
    return dot(rgba, vec4(1.0, 1.0 / 255.0, 1.0 / 65025.0, 1.0 / 16581375.0));
}

void main() {
    vec3 ndc = v_shadow.xyz / v_shadow.w;
    vec2 uv = ndc.xy * 0.5 + 0.5;
    uv.y = 1.0 - uv.y;
    float lit = 1.0;
    if (uv.x >= 0.0 && uv.x <= 1.0 && uv.y >= 0.0 && uv.y <= 1.0) {
        float depth = ndc.z - light.params.y;
        lit = 0.0;
        for (int i = -1; i <= 1; i++) {
            for (int j = -1; j <= 1; j++) {
                float stored = unpack_depth(texture(shadow_map, uv + vec2(i, j) * light.params.x));
                lit += depth <= stored ? 1.0 : 0.0;
            }
        }
        lit /= 9.0;
    }
    float explored = clamp(texture(mask_texture, v_mask).r, 0.0, 1.0);
    // Neutral grey shadow, lighter where the ground is still clay.
    float strength = light.params.z * mix(0.5, 1.0, explored);
    float shade = 1.0 - (1.0 - lit) * strength;
    frag_color = vec4(vec3(shade), 1.0);
}
