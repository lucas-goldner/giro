// Fill-extrusion material for maplibre_flutter_gpu: the toy-city facade.
//
// Walls carry a procedural window grid (metres along the wall from the ring
// distance, metres up from the height), a warm key light and a lighter roof.
// v_custom0.x is how explored the vertex is: unexplored buildings are white
// clay, explored ones get their pastel colour and windows.
#version 460 core

layout(location = 0) in vec4 v_color;      // MapLibre's lit colour, premultiplied
layout(location = 1) in vec3 v_position;   // tile x, y, height in metres
layout(location = 2) in vec4 v_surface;    // normal xy, roof flag, 0 base..1 top
layout(location = 3) in vec4 v_extrusion;  // ring distance, metres per unit, base, top
layout(location = 4) in vec4 v_custom0;
layout(location = 5) in vec4 v_custom1;

layout(location = 0) out vec4 frag_color;

float hash(vec2 p) {
    return fract(sin(dot(p, vec2(127.1, 311.7))) * 43758.5453);
}

void main() {
    float explored = clamp(v_custom0.x, 0.0, 1.0);
    float alpha = v_color.a;
    vec3 base = alpha > 0.0 ? v_color.rgb / alpha : v_color.rgb;
    bool roof = v_surface.z > 0.5;

    // Warm key light from the upper left; roofs are flat and a bit lighter.
    vec2 normal = v_surface.xy;
    float key = 1.0;
    if (!roof) {
        float facing = dot(normalize(normal + vec2(1e-4)), normalize(vec2(-0.6, 0.8)));
        key = 0.70 + 0.30 * max(facing, 0.0);
    }
    float top = v_extrusion.w;
    float height = v_position.z;

    // Contact shadow: walls darken towards the ground, which is what makes
    // a block read as standing on the street instead of floating.
    float contact = 1.0;
    if (!roof) {
        float rise = clamp(height / max(min(top, 24.0), 1.0), 0.0, 1.0);
        contact = 0.74 + 0.26 * smoothstep(0.0, 0.5, rise);
    }
    vec3 wall = roof ? mix(base, vec3(1.0), 0.22) : base * key * contact;

    // A lighter crown on the top two metres, like a parapet.
    if (!roof && height > top - 2.0 && top > 8.0) {
        wall = mix(wall, vec3(1.0), 0.30);
    }

    // Windows: 3.2 m wide bays, 3.4 m storeys, inset within each cell. They
    // fade out once a cell is only a few pixels wide, so far facades stay a
    // calm flat colour instead of shimmering.
    if (!roof && top > 6.0) {
        float along = v_extrusion.x * v_extrusion.y;
        vec2 cell = vec2(along / 3.2, height / 3.4);
        float cells_per_pixel = fwidth(cell.x) + fwidth(cell.y);
        float detail = 1.0 - smoothstep(0.12, 0.3, cells_per_pixel);
        vec2 f = fract(cell);
        bool inside = f.x > 0.28 && f.x < 0.72 && f.y > 0.32 && f.y < 0.74
            && height > 1.6 && height < top - 2.4;
        if (inside && detail > 0.0) {
            float r = hash(floor(cell) + floor(v_position.xy * 0.02));
            vec3 glass = mix(wall * 0.45, vec3(0.20, 0.26, 0.40), 0.6);
            vec3 lit = vec3(1.0, 0.88, 0.58);
            wall = mix(wall, r < 0.28 ? lit : glass, detail);
        }
    }

    // Unexplored: plain white clay, walls shaded grey by the key light and
    // the same contact shadow, no windows. Kept strictly neutral so the fog
    // pass can tell it from the coloured ground and leave the shading alone.
    float shade = roof ? 1.0 : (0.62 + 0.38 * (key - 0.70) / 0.30) * contact;
    vec3 clay = vec3(0.985) * shade;
    vec3 rgb = mix(clay, wall, explored);
    frag_color = vec4(rgb * alpha, alpha);
}
