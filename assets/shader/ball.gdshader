shader_type canvas_item;
render_mode blend_mix;

uniform float intensity = 1.0;
uniform vec4 main_color : source_color = vec4(0.53,0.51,0.49,1.0);
uniform sampler2D gradient: hint_default_black;
uniform bool contour_activated = false;
uniform vec4 contour_color : source_color = vec4(1.2,1.0,0.9,0.85);
uniform bool hurtbox_activated = false;

float lightness(vec3 x)
{
	return 0.2126 * x.r + 0.7152 * x.g + 0.0722 * x.b;
}

void fragment() {
	vec4 t = texture(TEXTURE, UV);
	vec4 c = t;
	c = mix(main_color, vec4(texture(gradient, vec2(t.r, 0.0)).rgba), intensity);
	//if (t.r < 0.1 || t.r > 0.95)
	float coeffmix = (t.r-0.5);
	coeffmix = 4.0*coeffmix*coeffmix;
	coeffmix = coeffmix*coeffmix;
	coeffmix = coeffmix*coeffmix;
	//c = mix(c,t,coeffmix);

	c.a *= t.a;
	if ((contour_activated || hurtbox_activated) && c.a < 0.5)
	{
		vec4 right = texture(TEXTURE,UV+vec2(TEXTURE_PIXEL_SIZE.x,0.));
		vec4 left = texture(TEXTURE,UV+vec2(-TEXTURE_PIXEL_SIZE.x,0.));
		vec4 down = texture(TEXTURE,UV+vec2(0.,TEXTURE_PIXEL_SIZE.y));
		vec4 up = texture(TEXTURE,UV+vec2(0.,-TEXTURE_PIXEL_SIZE.y));
		if ((right.a > 0.6 ) ||
			(left.a > 0.6 ) ||
			(down.a > 0.6 ) ||
			(up.a > 0.6 ) )
		{
			if (hurtbox_activated)
			{
				c = mix(vec4(1.0,0.1,0.0,1.0), vec4(1.1,0.9,0.7,1.0), fract(-2.0*TIME));
			}
			else {
				c = contour_color;
			}
		}
	}
    COLOR = c;
}
