shader_type canvas_item;
render_mode blend_mix;

uniform vec4 color_light : hint_color = vec4(0.8, 0.3, 0.6, 1.0);
uniform vec4 color_dark : hint_color = vec4(0.4, 0.1, 0.3, 1.0);

void fragment() {
	vec4 t = texture(TEXTURE, UV);
	vec4 c = t;
	if (t.r == 1.0 && t.b == 0.0 && t.g == 0.0) {
		c = color_light;
	}
	else if (t.r == 0.0 && t.b == 1.0 && t.g == 0.0) {
		c = color_dark;
	}
    COLOR = c;
}
