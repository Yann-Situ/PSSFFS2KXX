shader_type canvas_item;
render_mode blend_mix;

uniform vec2 speed = vec2(100.,100.);// in pix/s
const int harmonics = 4;
uniform float max_speed = 400.;// in pix/s
uniform float thresh_speed_coeff = 0.6;
const float max_queue_size = 8.;// in pixels
const float harmonics_attenuation = 0.9;// coefficient
uniform float glow_coeff = 1.2;// coefficient

void fragment() {
	vec4 t = texture(TEXTURE, UV);

	if (t.a < 0.5)
	{

		float l = length(speed);
		float queue_size = max_queue_size*smoothstep(thresh_speed_coeff,1.0,l/max_speed);// in pixels
		vec2 uv_increment = TEXTURE_PIXEL_SIZE*speed/l; // in uv coord
		uv_increment.x = abs(uv_increment.x);// handle flip_h

		vec2 uv2 = UV;
		float coeff = 1.;
		for (float i = 0.; i < queue_size ; i+=1.)
		{
			uv2 += uv_increment;
			coeff *= harmonics_attenuation;
			t += coeff*(texture(TEXTURE,uv2));
		}
		float normalize_value = (1.-harmonics_attenuation*coeff)/(1.-harmonics_attenuation);
		t *= glow_coeff/normalize_value;

	}
	COLOR = t;
}
