shader_type canvas_item;
render_mode blend_mix;

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
		COLOR = textureLod(SCREEN_TEXTURE,SCREEN_UV - disp,0.0);
		//COLOR.r = textureLod(SCREEN_TEXTURE,SCREEN_UV - 1.3*disp,0.0).r;
		//COLOR.g = textureLod(SCREEN_TEXTURE,SCREEN_UV - disp,0.0).g;
		//COLOR.b = textureLod(SCREEN_TEXTURE,SCREEN_UV - 0.8*disp,0.0).b;
		//COLOR.a = textureLod(SCREEN_TEXTURE,SCREEN_UV - disp,0.0).a;
	}
	//COLOR.rgb = vec3(mask);
	
}