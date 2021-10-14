shader_type canvas_item;
render_mode blend_mix;

uniform bool activated : true;
uniform vec4 contour_color : hint_color = vec4(1.2,1.0,0.9,0.65);
uniform float light_thresh : hint_range(0., 1.,0.05) = 0.4;
float lightness(vec4 x)
{
	return 0.2126 * x.r + 0.7152 * x.g + 0.0722 * x.b;
}


void fragment() {
	vec4 t = texture(TEXTURE, UV);

	if (activated && t.a < 0.5)
	{
		vec4 right = texture(TEXTURE,UV+vec2(TEXTURE_PIXEL_SIZE.x,0.));
		vec4 left = texture(TEXTURE,UV+vec2(-TEXTURE_PIXEL_SIZE.x,0.));
		vec4 down = texture(TEXTURE,UV+vec2(0.,TEXTURE_PIXEL_SIZE.y));
		vec4 up = texture(TEXTURE,UV+vec2(0.,-TEXTURE_PIXEL_SIZE.y));
		if ((right.a > 0.8 && lightness(right) > light_thresh) ||
			(left.a > 0.8 && lightness(left) > light_thresh) ||
			(down.a > 0.8 && lightness(down) > light_thresh) ||
			(up.a > 0.8 && lightness(up) > light_thresh) )
		{
			COLOR = contour_color;
		}
		else
		{
			COLOR = vec4(0.);
		}
	}
	else
	{
		COLOR = vec4(t.rgb, t.a);
	}
}
