shader_type canvas_item;
render_mode unshaded;


/* In Godot4, SCREEN_TEXTURE has been removed in favor of using
 * hint_screen_texture with a uniform. As a result the following line is needed
 * for the code to work:*/
uniform sampler2D SCREEN_TEXTURE : hint_screen_texture, filter_linear_mipmap;

uniform float texture_height = 280.0;
uniform float time;
uniform float xscale = 10.0;
uniform float force = 1.0;

float wave(float x, float t){
	x = abs(xscale*x);
	float w = x*sin(0.5*x-16.0*t);
	w = w*w;
	w = w*w;
	return force * 0.1 * exp(-x-4.0*t) * w;
}

void fragment(){
	//float ratio = TEXTURE_PIXEL_SIZE.x / TEXTURE_PIXEL_SIZE.y;
	//vec2 scaledUV = (UV - vec2(0.5,0.0)) / vec2(ratio, 1) + vec2(0.5,0.0);
	vec2 XY = -2.0*(UV - 0.5);
	if (force < 1.1 && abs(XY.y) > 0.5) {
		COLOR = vec4(1.0,1.0,1.0,0.0);
	}
	else {
		//smoothstep(size-thickness-0.1,size-thickness, length(XY - center));
		//vec2 disp = normalize(XY - center) * force * mask;
		float y = wave(XY.x, time);
		//if (abs(XY.y-y)<0.01) {
		//	COLOR = vec4(1.0,1.0,1.0,1.0);
		//}
		if (y < XY.y) {
			COLOR = vec4(1.0,1.0,1.0,0.0);
		}
		else {
			float begin_distort = 0.5;
			float shiftXY = smoothstep(-begin_distort, y, XY.y);

			float size_screen = float(textureSize(SCREEN_TEXTURE, 0).y);
			float shiftUV =  (texture_height/size_screen)* (y) * (shiftXY);
			//float mirror_screen_uv = SCREEN_UV.y + (texture_height/size_screen)*(1.0-2.0*UV.y);
			COLOR = textureLod(SCREEN_TEXTURE,vec2(SCREEN_UV.x, SCREEN_UV.y + shiftUV),0.0);
		}

		//COLOR.r = textureLod(Screen_Texture,SCREEN_UV - 1.3*disp,0.0).r;
		//COLOR.g = textureLod(Screen_Texture,SCREEN_UV - disp,0.0).g;
		//COLOR.b = textureLod(Screen_Texture,SCREEN_UV - 0.8*disp,0.0).b;
		//COLOR.a = textureLod(Screen_Texture,SCREEN_UV - disp,0.0).a;
	}
}
