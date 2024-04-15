shader_type canvas_item;

// Uniforms to control the breathing properties
uniform float max_scale : hint_range(1.0, 1.5) = 1.1;
uniform float min_scale : hint_range(0.5, 1.0) = 0.9;
uniform float breath_speed : hint_range(0.1, 5.0) = 1.0;

void vertex() {
    float scale = mix(min_scale, max_scale, (sin(TIME * breath_speed) + 1.0) * 0.5);
    VERTEX = (VERTEX - vec2(0.5, 0.5) * TEXTURE_PIXEL_SIZE) * scale + vec2(0.5, 0.5) * TEXTURE_PIXEL_SIZE;
}
