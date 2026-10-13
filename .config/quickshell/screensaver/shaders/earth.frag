#version 440

layout(location = 0) in vec2 qt_TexCoord0;
layout(location = 0) out vec4 fragColor;

layout(std140, binding = 0) uniform buf {
    mat4 qt_Matrix;
    float qt_Opacity;
    float spin;
    float tilt;
    vec4 ocean;
    vec4 land;
    vec4 grid;
    vec4 shade;
    vec4 rim;
};

layout(binding = 1) uniform sampler2D mask;

const float PI = 3.14159265;

float gridLine(float deg, float width) {
    float f = mod(deg, 30.0);
    float d = min(f, 30.0 - f);
    return 1.0 - smoothstep(width * 0.5, width, d);
}

void main() {
    vec2 p = qt_TexCoord0 * 2.0 - 1.0;
    p.y = -p.y;
    float rho = length(p);
    float aa = fwidth(rho) * 1.5;
    float alpha = 1.0 - smoothstep(1.0 - aa, 1.0, rho);
    if (alpha <= 0.0) {
        fragColor = vec4(0.0);
        return;
    }

    float z = sqrt(max(0.0, 1.0 - rho * rho));
    float ct = cos(tilt);
    float st = sin(tilt);
    vec3 v = vec3(p.x, ct * p.y + st * z, -st * p.y + ct * z);

    float lat = asin(clamp(v.y, -1.0, 1.0));
    float lon = atan(v.x, v.z) + spin;
    vec2 uv = vec2(fract(lon / (2.0 * PI) + 0.5), 0.5 - lat / PI);

    vec3 col = mix(ocean.rgb, land.rgb, texture(mask, uv).r);
    float g = max(gridLine(degrees(lat) + 90.0, 0.8), gridLine(degrees(lon) + 360.0, 0.8 / max(0.15, cos(lat))));
    col = mix(col, grid.rgb, g * 0.25);
    col = mix(col, shade.rgb, (1.0 - z) * 0.55);
    float edge = smoothstep(1.0 - aa * 3.0, 1.0 - aa, rho);
    col = mix(col, rim.rgb, edge);

    fragColor = vec4(col, 1.0) * alpha * qt_Opacity;
}
