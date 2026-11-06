// Fog of war over a MapLibre Flutter GPU map.
//
// Every pixel is unprojected onto the ground plane with the inverse of the
// frame's view-projection matrix, converted to normalised Mercator
// coordinates and looked up in the explored mask (white = walked). Unexplored
// ground is painted white.
//
// Two modes, selected by params.y:
//   0: blend mode. The pass draws over the finished map, so the shader
//      outputs premultiplied white with alpha = strength * (1 - explored).
//   1: sketch mode (fork of maplibre_flutter_gpu). The finished map is bound
//      as map_texture and this pass renders the final image: unexplored
//      ground becomes a pale grey line drawing of the map on white, explored
//      ground keeps its colours.
#version 460 core

layout(location = 0) in vec2 v_clip;

layout(location = 0) out vec4 frag_color;

layout(binding = 0) uniform FogUniforms {
    mat4 inverse_view_projection;
    // xy = mask origin offset in normalised Mercator (origin / worldSize - u0),
    // zw = 1 / mask span.
    vec4 mask;
    // rgb = fog colour, a = fog strength (0..1).
    vec4 fog_color;
    // x = 1 / worldSize, y = mode (0 blend, 1 sketch),
    // z = sketch contrast (how dark the lines stay), w = unused.
    vec4 params;
    // xy = 1 / physical size of the map texture.
    vec4 screen;
} fog;

uniform sampler2D mask_texture;
uniform sampler2D map_texture;

float explored_at(vec2 clip) {
    vec4 near = fog.inverse_view_projection * vec4(clip, 0.0, 1.0);
    vec4 far = fog.inverse_view_projection * vec4(clip, 1.0, 1.0);
    if (abs(near.w) < 1e-9 || abs(far.w) < 1e-9) {
        return 0.0;
    }
    vec3 p0 = near.xyz / near.w;
    vec3 p1 = far.xyz / far.w;
    float dz = p1.z - p0.z;
    if (abs(dz) < 1e-9) {
        return 0.0;
    }
    float t = -p0.z / dz;
    if (t < 0.0 || t > 1.0) {
        // Above the horizon: nothing to reveal.
        return 0.0;
    }
    vec2 world = p0.xy + t * (p1.xy - p0.xy);
    vec2 uv = (world * fog.params.x + fog.mask.xy) * fog.mask.zw;
    if (uv.x < 0.0 || uv.y < 0.0 || uv.x > 1.0 || uv.y > 1.0) {
        return 0.0;
    }
    return texture(mask_texture, uv).a;
}

void main() {
    float explored = explored_at(v_clip);
    float strength = fog.fog_color.a;

    if (fog.params.y < 0.5) {
        float alpha = strength * (1.0 - explored);
        frag_color = vec4(fog.fog_color.rgb * alpha, alpha);
        return;
    }

    vec2 screen_uv = gl_FragCoord.xy * fog.screen.xy;
    // Tilt-shift: the top and bottom of the frame go soft, like a model
    // photographed up close. Nine taps, radius grows towards the edges.
    float band = max(abs(v_clip.y) - 0.35, 0.0) / 0.65;
    float radius = band * band * 3.5;
    vec4 map = texture(map_texture, screen_uv);
    if (radius > 0.3) {
        vec2 px = fog.screen.xy * radius;
        vec4 sum = map * 2.0;
        sum += texture(map_texture, screen_uv + vec2(px.x, 0.0));
        sum += texture(map_texture, screen_uv - vec2(px.x, 0.0));
        sum += texture(map_texture, screen_uv + vec2(0.0, px.y));
        sum += texture(map_texture, screen_uv - vec2(0.0, px.y));
        sum += texture(map_texture, screen_uv + px * 0.7);
        sum += texture(map_texture, screen_uv - px * 0.7);
        sum += texture(map_texture, screen_uv + vec2(px.x, -px.y) * 0.7);
        sum += texture(map_texture, screen_uv + vec2(-px.x, px.y) * 0.7);
        map = sum / 10.0;
    }
    // The map texture is premultiplied; un-premultiply for the luminance.
    vec3 rgb = map.a > 0.0 ? map.rgb / map.a : map.rgb;
    float luma = dot(rgb, vec3(0.2126, 0.7152, 0.0722));
    // Explored ground: a touch more saturation and warmth, toy-camera style.
    vec3 graded = mix(vec3(luma), rgb, 1.18) * vec3(1.0, 0.985, 0.95);
    // Lines and text are the dark parts of the map; lift everything else to
    // the fog colour so unexplored ground reads as white clay.
    float ink = (1.0 - luma) * fog.params.z;
    vec3 sketch = fog.fog_color.rgb * (1.0 - ink);
    vec3 result = mix(mix(graded, sketch, strength), graded, explored);
    // A soft vignette keeps the eye in the middle of the model.
    float vignette = 1.0 - 0.12 * smoothstep(0.55, 1.25, length(v_clip));
    frag_color = vec4(result * vignette, 1.0);
}
