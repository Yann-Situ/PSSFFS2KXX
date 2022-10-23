extends Node2D

export (Resource) var palette_scheme_sampler
const pedestrian_scene = preload("res://src/Characters/NPC/Pedestrian.tscn")

func _ready():
	randomize()

func generate_pedestrian(global_pos : Vector2 = self.global_position) -> Node:
	var pedestrian = pedestrian_scene.instance()
	if palette_scheme_sampler:
		var p = palette_scheme_sampler.sample()
		p.display()
		pedestrian.apply_palette_scheme(p)
	pedestrian.global_position = global_pos
	add_child(pedestrian)
	return pedestrian
	
func _input(event):
	if event is InputEventKey and event.pressed:
		if event.scancode == KEY_T:
			var p = Vector2(128*(2*randf()-1.0), 128*(2*randf()-1.0))
			generate_pedestrian(p)
