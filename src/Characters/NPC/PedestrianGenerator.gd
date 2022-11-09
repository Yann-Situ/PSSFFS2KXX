extends Node2D

export (Resource) var palette_scheme_sampler
const pedestrian_scene = preload("res://src/Characters/NPC/Pedestrian.tscn")

func _ready():
	randomize()

func generate_pedestrian(global_pos : Vector2 = self.global_position) -> Node:
	var pedestrian = pedestrian_scene.instance()
	#var pedestrian = Pedestrian.new()
	pedestrian.get_node("Sprite").texture = load("res://assets/art/characters/Pedestrian_"+str(randi()%3+1)+".png")

	add_child(pedestrian)
	if palette_scheme_sampler:
		var p = palette_scheme_sampler.sample()
		pedestrian.apply_palette_scheme(p)
	pedestrian.global_position = global_pos
	return pedestrian

func _input(event):
	if event is InputEventKey and event.pressed:
		if event.scancode == KEY_T:
			var p = global_position+Vector2(128*(2*randf()-1.0), 0.0)
			generate_pedestrian(p)
