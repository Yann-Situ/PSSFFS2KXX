shader_type canvas_item;

//uniform float level : hint_range(0.0, 1.0) = 0.5;
uniform vec4 water_albedo : source_color = vec4(0.26, 0.23, 0.73, 1.0);
uniform float water_opacity : hint_range(0.0, 1.0) = 0.35;
uniform float water_speed = 0.05;
uniform float wave_distortion = 0.01;
uniform int wave_harmonics = 5;
uniform bool water_texture_on = true;
uniform float texture_height = 280.0;
uniform float blur = 0.5;
uniform sampler2D noise_texture : hint_default_white, repeat_enable;
uniform sampler2D noise_texture2 : hint_default_white, repeat_enable;

/* In Godot4, SCREEN_TEXTURE has been removed in favor of using
 * hint_screen_texture with a uniform. As a result the following line is needed
 * for the code to work:*/
uniform sampler2D SCREEN_TEXTURE : hint_screen_texture, filter_linear_mipmap;

void fragment() {
	vec2 uv = UV;
	COLOR = vec4(0.0);

	if (uv.y >= 0.5) {
		COLOR.a = 1.0;

		// distorted reflections
		vec2 water_uv = vec2(uv.x, uv.y * float(wave_harmonics));
		float noise = texture(noise_texture, vec2(water_uv.x + TIME * water_speed, water_uv.y)).x * wave_distortion;
		noise -= (0.5 * wave_distortion);

		// water texture
		if (water_texture_on) {
			float water_texture_limit = 0.35;
			vec4 water_texture = texture(noise_texture2, uv * vec2(0.5, 4.0) + vec2(noise, 0.0));
			float water_texture_value = (water_texture.x < water_texture_limit) ? 1.0 : 0.0;
			COLOR.xyz = vec3(water_texture_value);
		}

		// putting everything toghether
		float size_screen = float(textureSize(SCREEN_TEXTURE, 0).y);
		float mirror_screen_uv = SCREEN_UV.y + (texture_height/size_screen)*(1.0-2.0*UV.y);
		vec4 current_texture = textureLod(SCREEN_TEXTURE, vec2(SCREEN_UV.x + noise,
		mirror_screen_uv),blur);
		COLOR = mix(COLOR, current_texture, water_albedo.a);
		COLOR = mix(COLOR, water_albedo, water_opacity);
	}
}
