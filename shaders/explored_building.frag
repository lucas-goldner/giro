// Fill-extrusion material for maplibre_flutter_gpu: buildings are white
// until the user has walked past them, then they keep MapLibre's lit colour.
// v_custom0.x is the explored value sampled per vertex from the mask.
#version 460 core

layout(location = 0) in vec4 v_color;
layout(location = 1) in vec3 v_position;
layout(location = 2) in vec4 v_surface;
layout(location = 3) in vec4 v_extrusion;
layout(location = 4) in vec4 v_custom0;
layout(location = 5) in vec4 v_custom1;

layout(location = 0) out vec4 frag_color;

void main() {
    float explored = clamp(v_custom0.x, 0.0, 1.0);
    float alpha = v_color.a;
    vec3 lit = alpha > 0.0 ? v_color.rgb / alpha : v_color.rgb;
    float luma = dot(lit, vec3(0.2126, 0.7152, 0.0722));
    // Keep a hint of the lighting so white blocks still read as 3D.
    vec3 white = vec3(1.0 - (1.0 - luma) * 0.18);
    vec3 rgb = mix(white, lit, explored);
    frag_color = vec4(rgb * alpha, alpha);
}
