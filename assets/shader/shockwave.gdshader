shader_type canvas_item;
render_mode unshaded;

/* In Godot4, SCREEN_TEXTURE has been removed in favor of using
 * hint_screen_texture with a uniform. As a result the following line is needed
 * for the code to work:*/
uniform sampler2D Screen_Texture : hint_screen_texture, filter_linear_mipmap;

uniform vec2 center;
uniform float force;
uniform float size;
uniform float thickness;

void fragment(){
	//float ratio = TEXTURE_PIXEL_SIZE.x / TEXTURE_PIXEL_SIZE.y;
	//vec2 scaledUV = (UV - vec2(0.5,0.0)) / vec2(ratio, 1) + vec2(0.5,0.0);

	if(force == 0.0){
		COLOR = vec4(1.0,1.0,1.0,0.0);
	}
	else {
		vec2 scaledUV = UV;
		float mask = (1.0 - smoothstep(size-0.1,size, length(scaledUV - center))) *
		smoothstep(size-thickness-0.1,size-thickness, length(scaledUV - center));
		vec2 disp = normalize(scaledUV - center) * force * mask;
		COLOR = textureLod(Screen_Texture,SCREEN_UV - disp,0.0);
		//COLOR.r = textureLod(Screen_Texture,SCREEN_UV - 1.3*disp,0.0).r;
		//COLOR.g = textureLod(Screen_Texture,SCREEN_UV - disp,0.0).g;
		//COLOR.b = textureLod(Screen_Texture,SCREEN_UV - 0.8*disp,0.0).b;
		//COLOR.a = textureLod(Screen_Texture,SCREEN_UV - disp,0.0).a;
	}
	//COLOR.rgb = vec3(mask);
}
