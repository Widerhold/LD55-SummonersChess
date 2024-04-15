shader_type canvas_item;

uniform float movement_range : hint_range(0.0, 50.0) = 10.0;
uniform float movement_speed : hint_range(0.1, 5.0) = 2.0;

void vertex() {
    VERTEX.x += sin(TIME * movement_speed) * movement_range;
}