shader_type canvas_item;
uniform sampler2D screen_texture : hint_screen_texture, repeat_disable, filter_nearest;

// Configurable parameters
uniform float distortion_amount = 1.1;
uniform float brightness = 0.6;
uniform float contrast = 1.0;
uniform float scanline_intensity = 0.35;
uniform float noise_intensity = 0.01;
uniform float vignette_strength = 0.3;
uniform vec3 color_tint = vec3(0.95, 1.05, 0.95);
uniform float scanline_frequency = 3.5;

vec2 curve(vec2 uv) {
    uv = (uv - 0.5) * 2.0;
    uv *= distortion_amount;
    uv.x *= 1.0 + pow((abs(uv.y) / 5.0), 2.0);
    uv.y *= 1.0 + pow((abs(uv.x) / 4.0), 2.0);
    uv  = (uv / 2.0) + 0.5;
    uv =  uv * 0.92 + 0.04;
    return uv;
}

void fragment() {
    vec2 iResolution = 1.0 / SCREEN_PIXEL_SIZE;
    vec2 q = FRAGCOORD.xy / iResolution.xy;
    vec2 uv = curve(q);
    vec3 col = texture(screen_texture, q).xyz;
    /*float x = sin(0.3 * TIME + uv.y * 21.0) * sin(0.7 * TIME + uv.y * 29.0) * sin(0.3 + 0.33 * TIME + uv.y * 31.0) * noise_intensity;

    col.r = texture(screen_texture, vec2(x + uv.x + 0.001, uv.y + 0.001)).x + 0.05;
    col.g = texture(screen_texture, vec2(x + uv.x, uv.y - 0.002)).y + 0.05;
    col.b = texture(screen_texture, vec2(x + uv.x - 0.002, uv.y)).z + 0.05;*/

    col = clamp(col * brightness + contrast * col * col, 0.0, 1.0);

    float vig = vignette_strength * 16.0 * uv.x * uv.y * (1.0 - uv.x) * (1.0 - uv.y);
    col *= pow(vig, 0.3);

    col *= color_tint;
    col *= 2.8;

    if(scanline_intensity > 0.1) {
        float scans = clamp(scanline_intensity + scanline_intensity * sin(scanline_frequency * TIME + uv.y * iResolution.y * 1.5), 0.0, 1.0);
        float s = pow(scans, 1.7);
        col = col * vec3(0.4 + 0.7 * s);
    }


    col *= 1.0 + noise_intensity * sin(110.0 * TIME);
    if (uv.x < 0.0 || uv.x > 1.0) col *= 0.0;
    if (uv.y < 0.0 || uv.y > 1.0) col *= 0.0;

    col *= 1.0 - 0.65 * vec3(clamp((mod(FRAGCOORD.x, 2.0) - 1.0) * 2.0, 0.0, 1.0));

    COLOR = vec4(col, 1.0);
}
