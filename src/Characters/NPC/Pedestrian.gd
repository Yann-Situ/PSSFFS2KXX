extends Node2D

signal move_offset(offset)

export (bool) var free_pedestrian = true # if true, connect move_offset to walk_offset

export (float) var walk_speed_min = 50.0
export (float) var walk_speed_max = 80.0
export (float) var x_min = -INF
export (float) var x_max = INF
var walk_speed

onready var ai = get_node("AI")

func _ready():
	ai.connect("direction_changed", self, "update_animation")
	walk_speed = ai.rng.randf_range(walk_speed_min, walk_speed_max)
	if free_pedestrian:
		connect("move_offset", self, "walk_offset")

func apply_palette_scheme(palette : PaletteScheme):
	if palette.gradients.size() < 4:
		push_warning("not enough gradients ("+str(palette.gradients.size())+"<4)")
		return
	var m : ShaderMaterial = $Sprite.material
	var gt_skin = GradientTexture.new()
	gt_skin.width = 64
	gt_skin.set_gradient(palette.get_gradient(0))
	m.set_shader_param("grad_skin", gt_skin)
	var gt_1 = GradientTexture.new()
	gt_1.width = 64
	gt_1.set_gradient(palette.get_gradient(1))
	m.set_shader_param("grad_1", gt_1)
	var gt_2 = GradientTexture.new()
	gt_2.width = 64
	gt_2.set_gradient(palette.get_gradient(2))
	m.set_shader_param("grad_2", gt_2)
	var gt_3 = GradientTexture.new()
	gt_3.width = 64
	gt_3.set_gradient(palette.get_gradient(3))
	m.set_shader_param("grad_3", gt_3)

func walk_offset(offset : Vector2):
	global_position.x += offset.x
	if global_position.x > x_max:
		global_position.x = x_max
		ai.change_direction(-1)
	if global_position.x < x_min:
		global_position.x = x_min
		ai.change_direction(1)

func update_animation(direction : int):
	if direction > 0:
		$AnimationPlayer.play("walk")
		walk_speed = ai.rng.randf_range(walk_speed_min, walk_speed_max)
		$Sprite.flip_h = false
	elif direction < 0:
		$AnimationPlayer.play("walk")
		walk_speed = ai.rng.randf_range(walk_speed_min, walk_speed_max)
		$Sprite.flip_h = true
	else:
		$AnimationPlayer.play("idle")

func _process(delta):
	var direction_vector = Vector2.ZERO
	if ai.direction > 0:
		direction_vector = Vector2.RIGHT
	elif ai.direction < 0:
		direction_vector = Vector2.LEFT
	emit_signal("move_offset", walk_speed*direction_vector*delta)
