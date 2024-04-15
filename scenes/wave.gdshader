shader_type canvas_item;

uniform float amplitude : hint_range(0.0, 10.0) = 2.0;
uniform float frequency : hint_range(0.0, 10.0) = 4.0;
uniform float speed : hint_range(-10.0, 10.0) = 2.0;

void vertex() {
    // Simple wave effect modifying the y position of vertices
    VERTEX.y += sin(TIME * speed + VERTEX.x * frequency) * amplitude;
}