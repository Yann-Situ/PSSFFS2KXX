shader_type canvas_item;
uniform vec2 direction;

void fragment() {
	float dist = dot(vec2(-UV.y,UV.x), direction);
	COLOR.rgb = vec3(0.92,0.9,0.8);
	COLOR.a = 0.5*smoothstep(abs(fract(10.0*dist)-0.5), 0.1, 0.3);
}

//void light() {
	// Called for every pixel for every light affecting the CanvasItem.
	// Uncomment to replace the default light processing function with this one.
//}
