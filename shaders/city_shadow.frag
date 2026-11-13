// Shadow pass: depth packed into RGBA8 so the main pass can sample it.
#version 460 core

layout(location = 0) out vec4 frag_color;

void main() {
    float d = clamp(gl_FragCoord.z, 0.0, 1.0);
    vec4 enc = fract(d * vec4(1.0, 255.0, 65025.0, 16581375.0));
    enc -= enc.yzww * vec4(1.0 / 255.0, 1.0 / 255.0, 1.0 / 255.0, 0.0);
    frag_color = enc;
}
