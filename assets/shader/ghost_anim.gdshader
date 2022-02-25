shader_type canvas_item;

void fragment(){
	//COLOR = vec4(vec3(0.0),1.0);
	COLOR = vec4(vec3(1.0),texture(TEXTURE,UV).a);
}