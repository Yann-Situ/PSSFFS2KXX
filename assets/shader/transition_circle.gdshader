shader_type canvas_item;
render_mode unshaded;

uniform float circle_size : hint_range(0.0, 1.42);
uniform float screen_width;
uniform float screen_height;
uniform vec2 center_offset;

void fragment() {
	float ratio = screen_width / screen_height;
	float dist = distance(vec2(0.5)-vec2(center_offset.x/screen_width, center_offset.y/screen_height), vec2(mix(0.5, UV.x, ratio), UV.y));
	COLOR.a = step(circle_size, dist);
}