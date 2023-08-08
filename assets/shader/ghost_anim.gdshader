shader_type canvas_item;

uniform vec4 modulate : source_color = vec4(1.0);
uniform float alpha = 1.0;

void fragment(){
	COLOR = vec4(vec3(1.0),texture(TEXTURE,UV).a);
	COLOR = vec4(COLOR.r*modulate.r, COLOR.g*modulate.g, COLOR.b*modulate.b, COLOR.a*alpha);
}
