extends Node2D

signal move_offset(offset)

@export (bool) var free_pedestrian = true # if true, connect move_offset to walk_offset

@export (float) var walk_speed_min = 50.0
@export (float) var walk_speed_max = 80.0
@export (float) var x_min = -INF
@export (float) var x_max = INF
@export (float) var ai_timer_min = 1.0 #s
@export (float) var ai_timer_max = 4.0 #s
@export (float) var proba_idle = 0.2 #
@export (float) var proba_stay_idle = 0.4 #
@export (float) var proba_change_direction = 0.4 #
var walk_speed

@onready var ai = get_node("AI")

func _ready():
	ai.connect("direction_changed",Callable(self,"update_animation"))
	walk_speed = ai.rng.randf_range(walk_speed_min, walk_speed_max)
	if free_pedestrian:
		connect("move_offset",Callable(self,"walk_offset"))

func apply_palette_scheme(palette : PaletteScheme):
	if palette.gradients.size() < 4:
		push_warning("not enough gradients ("+str(palette.gradients.size())+"<4)")
		return
	var m : ShaderMaterial = $Sprite2D.material
	var gt_skin = GradientTexture2D.new()
	gt_skin.width = 64
	gt_skin.set_gradient(palette.get_gradient(0))
	m.set_shader_parameter("grad_skin", gt_skin)
	var gt_1 = GradientTexture2D.new()
	gt_1.width = 64
	gt_1.set_gradient(palette.get_gradient(1))
	m.set_shader_parameter("grad_1", gt_1)
	var gt_2 = GradientTexture2D.new()
	gt_2.width = 64
	gt_2.set_gradient(palette.get_gradient(2))
	m.set_shader_parameter("grad_2", gt_2)
	var gt_3 = GradientTexture2D.new()
	gt_3.width = 64
	gt_3.set_gradient(palette.get_gradient(3))
	m.set_shader_parameter("grad_3", gt_3)

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
		$Sprite2D.flip_h = false
	elif direction < 0:
		$AnimationPlayer.play("walk")
		walk_speed = ai.rng.randf_range(walk_speed_min, walk_speed_max)
		$Sprite2D.flip_h = true
	else:
		$AnimationPlayer.play("idle")

func _process(delta):
	var direction_vector = Vector2.ZERO
	if ai.direction > 0:
		direction_vector = Vector2.RIGHT
	elif ai.direction < 0:
		direction_vector = Vector2.LEFT
	emit_signal("move_offset", walk_speed*direction_vector*delta)
