shader_type canvas_item;

/* In Godot4, SCREEN_TEXTURE has been removed in favor of using
 * hint_screen_texture with a uniform. As a result the following line is needed
 * for the code to work:*/
uniform sampler2D Screen_Texture : hint_screen_texture, filter_linear_mipmap;

uniform float parameter; // v^2/g
uniform vec2 throw_position;
uniform float tolerance;

float lightness(vec4 x)
{
	//return 0.3333 * (x.r+x.b+x.g);
	return 0.2126 * x.r + 0.7152 * x.g + 0.0722 * x.b;
}


vec4 grey(vec4 col, float force){
	float l = lightness(col);
	return mix(col, vec4(vec3(l),col.a), force);
}

void fragment(){
	vec2 p = UV/SCREEN_PIXEL_SIZE - throw_position;

	vec4 screen_col = texture(Screen_Texture,SCREEN_UV);
	float force = smoothstep(-tolerance, tolerance, - 2.0*p.y + p.x*p.x/parameter - parameter);
	//COLOR = vec4(vec3(abs(p.x)),1.0);
	COLOR = grey(screen_col, force);
}
