tool
extends Node2D

export (int) var initial_sample_number = 0
export (float) var x_radius = INF
export (float) var walk_speed_min = 50.0
export (float) var walk_speed_max = 80.0
export (float) var ai_timer_min = 1.0 #s
export (float) var ai_timer_max = 4.0 #s
export (float) var proba_idle = 0.2 #
export (float) var proba_stay_idle = 0.4 #
export (float) var proba_change_direction = 0.4 #
export (Resource) var palette_scheme_sampler

const pedestrian_scene = preload("res://src/Characters/NPC/Pedestrian.tscn")

var rng = RandomNumberGenerator.new()

func _ready():
	rng.seed = hash(get_instance_id())
	if Engine.editor_hint:
		set_process(true)
	else:
		set_process(false)
		for i in range(initial_sample_number):
			generate_random_pedestrian()

func _process(delta):
	update()
func _draw():
	if Engine.editor_hint:
		draw_line(x_radius*Vector2.LEFT, x_radius*Vector2.RIGHT, Color(0.4,0.8,0.9,0.25), 64.0)
func generate_pedestrian(global_pos : Vector2 = self.global_position, direction : int = 0) -> Node:
	var pedestrian = pedestrian_scene.instance()
	pedestrian.get_node("Sprite").texture = load("res://assets/art/characters/Pedestrian_"+str(randi()%7+1)+".png")

	add_child(pedestrian)
	if palette_scheme_sampler:
		var p = palette_scheme_sampler.sample(rng)
		pedestrian.apply_palette_scheme(p)

	pedestrian.global_position = global_pos
	pedestrian.walk_speed_min = walk_speed_min
	pedestrian.walk_speed_max = walk_speed_max
	pedestrian.x_min = self.global_position.x - x_radius
	pedestrian.x_max = self.global_position.x + x_radius
	pedestrian.ai.set_initial_direction(direction)
	pedestrian.ai.ai_timer_min = ai_timer_min
	pedestrian.ai.ai_timer_max = ai_timer_max
	pedestrian.ai.proba_idle = proba_idle
	pedestrian.ai.proba_stay_idle = proba_stay_idle
	pedestrian.ai.proba_change_direction = proba_change_direction
	return pedestrian

func generate_random_pedestrian() -> Node:
	var x_value = 0.0
	if x_radius >= INF:
		x_value = rng.randfn(0.0, 256)
	else:
		x_value = x_radius*(2*rng.randf()-1.0)
	var p = global_position+Vector2(x_value, 0.0)
	return generate_pedestrian(p, -1 if rng.randf() < 0.5 else 1)

func _input(event):
	if event is InputEventKey and event.pressed:
		if event.scancode == KEY_T:
			generate_random_pedestrian()
