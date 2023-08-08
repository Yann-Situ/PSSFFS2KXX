shader_type canvas_item;
render_mode blend_mix;

/* In Godot4, SCREEN_TEXTURE has been removed in favor of using
 * hint_screen_texture with a uniform. As a result the following line is needed
 * for the code to work:*/
uniform sampler2D Screen_Texture : hint_screen_texture, filter_linear_mipmap;

float lightness(vec3 x)
{
	return 0.2126 * x.r + 0.7152 * x.g + 0.0722 * x.b;
}

float blendOverlay(float base, float blend) {
	return base<0.5?(2.0*base*blend):(1.0-2.0*(1.0-base)*(1.0-blend));
}

vec3 blendOverlay_3(vec3 base, vec3 blend) {
	return vec3(blendOverlay(base.r,blend.r),blendOverlay(base.g,blend.g),blendOverlay(base.b,blend.b));
}

vec3 blendOverlay_op(vec3 base, vec3 blend, float opacity) {
	return (blendOverlay_3(base, blend) * opacity + base * (1.0 - opacity));
}

void fragment() {
	vec4 t = texture(TEXTURE, UV);
    vec3 c = textureLod(Screen_Texture, SCREEN_UV, 0.0).rgb;
    COLOR = 0.9*mix(vec4(blendOverlay_3(c,0.2+0.8*t.rgb),t.a),t,0.2);

}
