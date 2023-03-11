shader_type canvas_item;
render_mode blend_mix;

uniform sampler2D grad_skin: hint_default_black;
uniform sampler2D grad_1: hint_default_black;
uniform sampler2D grad_2: hint_default_black;
uniform sampler2D grad_3: hint_default_black;

float lightness(vec3 x)
{
	return 0.2126 * x.r + 0.7152 * x.g + 0.0722 * x.b;
}

void fragment() {
	vec4 t = texture(TEXTURE, UV);
	vec4 c = t;
	if (t.r == t.b && t.r == t.g) {
		c = vec4(texture(grad_skin, vec2(t.r, 0.0)).rgb, t.a);
	}
	else if (t.r == 1.0) {
		c = vec4(texture(grad_1, vec2(t.g, 0.0)).rgb, t.a);
	}
	else if (t.g == 1.0) {
		c = vec4(texture(grad_2, vec2(t.b, 0.0)).rgb, t.a);
	}
	else if (t.b == 1.0) {
		c = vec4(texture(grad_3, vec2(t.r, 0.0)).rgb, t.a);
	}
    COLOR = c;
}
