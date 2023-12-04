shader_type canvas_item;
render_mode unshaded;

uniform float ratio : hint_range(0.0, 1.0);
uniform float margin_size : hint_range(0.0, 0.5);
uniform vec2 center_offset;

void fragment() {
	if (0.5-abs(UV.y-0.5)>margin_size*ratio)
		COLOR.a = 0.0;
}