shader_type canvas_item;
render_mode blend_mix;
//render_mode unshaded;
// https://github.com/godotengine/godot/issues/49781
uniform bool activated = true;
uniform vec4 contour_color : source_color = vec4(1.2,1.0,0.9,0.65);

//void vertex() {
	//COLOR = 0.5*COLOR;
//}

void fragment() {
	vec4 t = texture(TEXTURE, UV);
  	if (activated && t.a < 0.5)
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
			COLOR = contour_color;
		}
		else
		{
			//COLOR = vec4(0.0)*modulate; // TODO not yet supported on Godot4
			//COLOR = vec4(0.0);
		}
	}
	else
	{
		//COLOR = vec4(t.rgb, COLOR.a)*modulate; // TODO not yet supported on Godot4
		//COLOR = vec4(t.rgb, t.a);
	}
}

void light() {
	if (activated && COLOR == contour_color && LIGHT_ENERGY <= 0.02)
	{
		LIGHT = COLOR * LIGHT_COLOR;
	}
	else
	{
		LIGHT = vec4(LIGHT_COLOR.rgb * COLOR.rgb * LIGHT_ENERGY, LIGHT_COLOR.a);
	}
}