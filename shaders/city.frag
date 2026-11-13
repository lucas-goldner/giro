// Advanced graphics: sun with cast shadows (shadow map), hemisphere sky
// light, per-vertex ambient occlusion, materials by building class, and
// white clay where the ground is unexplored (neutral so the fog pass
// leaves it alone).
#version 460 core

layout(location = 0) in vec3 v_normal;
layout(location = 1) in vec3 v_world;
layout(location = 2) in vec2 v_extra;
layout(location = 3) in vec4 v_shadow;
layout(location = 4) in vec2 v_mask;

layout(location = 0) out vec4 frag_color;

layout(binding = 1) uniform LightUniforms {
    // xyz: direction towards the sun (x east, y south, z up), w: intensity.
    vec4 sun;
    // x: shadow texel, y: shadow bias, z: window grid on/off, w: time.
    vec4 params;
} light;

layout(binding = 2) uniform sampler2D shadow_map;
layout(binding = 3) uniform sampler2D mask_texture;

float unpack_depth(vec4 rgba) {
    return dot(rgba, vec4(1.0, 1.0 / 255.0, 1.0 / 65025.0, 1.0 / 16581375.0));
}

float shadow_at(vec4 clip) {
    vec3 ndc = clip.xyz / clip.w;
    vec2 uv = ndc.xy * 0.5 + 0.5;
    uv.y = 1.0 - uv.y;
    if (uv.x < 0.0 || uv.x > 1.0 || uv.y < 0.0 || uv.y > 1.0) {
        return 1.0;
    }
    float depth = ndc.z - light.params.y;
    float lit = 0.0;
    for (int i = -1; i <= 1; i++) {
        for (int j = -1; j <= 1; j++) {
            float stored = unpack_depth(texture(shadow_map, uv + vec2(i, j) * light.params.x));
            lit += depth <= stored ? 1.0 : 0.0;
        }
    }
    return lit / 9.0;
}

void main() {
    vec3 n = normalize(v_normal);
    float ao = v_extra.x;
    float kind = floor(v_extra.y + 0.05);
    float tint = fract(v_extra.y);
    bool roof = n.z > 0.7;

    // Materials.
    vec3 base;
    float gloss;
    if (kind >= 1.5) {
        // Glass tower: cool blue-grey, strong highlight, window bands.
        base = mix(vec3(0.56, 0.68, 0.82), vec3(0.62, 0.72, 0.80), tint);
        gloss = 0.85;
    } else if (kind >= 0.5) {
        // Office: warm concrete.
        base = mix(vec3(0.86, 0.82, 0.74), vec3(0.80, 0.78, 0.76), tint);
        gloss = 0.25;
    } else {
        // House: pastel plaster.
        vec3 a = vec3(0.95, 0.87, 0.76);
        vec3 b = vec3(0.86, 0.90, 0.96);
        vec3 c = vec3(0.93, 0.82, 0.84);
        base = tint < 0.33 ? mix(a, b, tint * 3.0) : mix(b, c, (tint - 0.33) * 1.5);
        gloss = 0.12;
    }
    if (roof) {
        base = mix(base, vec3(0.70, 0.70, 0.72), kind >= 1.5 ? 0.6 : 0.35);
        gloss *= 0.5;
    }

    // Window grid on walls, 3.2 m bays and 3.4 m storeys, fades with distance.
    if (!roof && light.params.z > 0.5) {
        float along = dot(v_world.xy, vec2(-n.y, n.x));
        vec2 cell = vec2(along / (3.2 * 0.5), v_world.z / 3.4);
        vec2 f = fract(cell);
        float window = step(0.22, f.x) * step(f.x, 0.78) * step(0.25, f.y) * step(f.y, 0.80);
        float detail = 1.0 - smoothstep(0.12, 0.35, fwidth(cell.x) + fwidth(cell.y));
        vec3 glass = kind >= 1.5 ? vec3(0.30, 0.40, 0.55) : vec3(0.32, 0.36, 0.44);
        base = mix(base, glass, window * detail * (kind >= 1.5 ? 0.75 : 0.55));
    }

    // Lighting: hemisphere sky + sun with shadows + highlight.
    vec3 sun = normalize(light.sun.xyz);
    float shadow = shadow_at(v_shadow);
    float sky = 0.42 + 0.30 * (n.z * 0.5 + 0.5);
    float diffuse = max(dot(n, sun), 0.0) * light.sun.w * shadow;
    vec3 view = vec3(0.0, -0.55, 0.83); // roughly the tilted camera
    vec3 half_v = normalize(sun + view);
    float spec = pow(max(dot(n, half_v), 0.0), mix(8.0, 48.0, gloss)) * gloss * shadow;
    vec3 lit = base * (sky * ao + diffuse * vec3(1.0, 0.96, 0.90)) + spec * vec3(1.0, 0.97, 0.92);

    // Clay: neutral white with the same light, so the fog pass keeps it.
    float clay_shade = (sky * ao + diffuse * 0.9) * 0.85 + spec * 0.4;
    vec3 clay = vec3(0.985) * clamp(clay_shade, 0.0, 1.0);

    float explored = texture(mask_texture, v_mask).r;
    vec3 rgb = mix(clay, lit, clamp(explored, 0.0, 1.0));
    frag_color = vec4(clamp(rgb, 0.0, 1.0), 1.0);
}
