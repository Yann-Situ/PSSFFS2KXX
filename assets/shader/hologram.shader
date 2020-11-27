shader_type canvas_item;
render_mode blend_mix;

const float wavelength1 = 3.;// all in seconds
const float duration1 = 0.3;
const float proba1 = 0.1;

const float wavelength2 = 1.2;
const float duration2 = 0.1;
const float proba2 = 0.2;

float random1 (float st) {
    return fract(sin(12.9898+st*
        3758.5453123));
}

float random2 (vec2 st) {
    return fract(sin(dot(st.xy,
                         vec2(12.9898,78.233)))*
        4358.5453123);
}

float lightness(vec3 x)
{
	return 0.2126 * x.r + 0.7152 * x.g + 0.0722 * x.b;
}

vec4 hologram_color(vec4 c)
{
    vec4 cres = vec4(0.25,0.5,0.6,0.8*c.a);
    float l = lightness(c.rgb);
    return cres + vec4(0.4*c.r,0.5*c.g,0.4*c.b,0.);
}


void fragment() {
	vec4 t = texture(TEXTURE, UV);

	vec4 right = texture(TEXTURE,UV+vec2(2.*TEXTURE_PIXEL_SIZE.x,0.));
	vec4 left = texture(TEXTURE,UV+vec2(-TEXTURE_PIXEL_SIZE.x,0.));

    vec4 col = hologram_color(t);

    if (mod(TIME,wavelength1)<= duration1)
    {
        if (random1(floor(0.5*UV.y/TEXTURE_PIXEL_SIZE.y))< proba1)
        {
            col = hologram_color(right);
        }
    }

    if (mod(TIME,wavelength2)<= duration2)
    {
        if (random1(UV.y+0.9746)< proba2)
        {
            col = hologram_color(left);
        }
    }
    COLOR = col;

}
