shader_type canvas_item;
render_mode unshaded;

uniform vec4 color : source_color = vec4(0.5, 0.5, 0.5, 1.0);
uniform float mix_value : hint_range(-0.5, 1.5) = 1.0;

float lightness(vec4 x)
{
	return 0.2126 * x.r + 0.7152 * x.g + 0.0722 * x.b;
}

vec4 color_gradient(float l){
	if (l <= 0.5) {
		return mix(vec4(vec3(0.0),1.0),color,2.0*l);
	}
	else {
		return mix(vec4(vec3(1.0),1.0),color,2.0-2.0*l);
	}
}

void fragment() {
	vec4 t = texture(TEXTURE, UV);

	COLOR = mix(t, color_gradient(lightness(t)), mix_value);

}
