extends Node2D

signal move_offset(offset)

@export var free_pedestrian : bool = true # if true, connect move_offset to walk_offset

@export var walk_speed_min : float = 50.0
@export var walk_speed_max : float = 80.0
@export var x_min : float = -INF
@export var x_max : float = INF
@export var ai_timer_min : float = 1.0 #s
@export var ai_timer_max : float = 4.0 #s
@export var proba_idle : float = 0.2 #
@export var proba_stay_idle : float = 0.4 #
@export var proba_change_direction : float = 0.4 #
var walk_speed

@onready var ai = get_node("AI")

func _ready():
	ai.direction_changed.connect(self.update_animation)
	walk_speed = ai.rng.randf_range(walk_speed_min, walk_speed_max)
	if free_pedestrian:
		move_offset.connect(self.walk_offset)

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
		$AnimationPlayer.speed_scale = 2.0*walk_speed/(walk_speed_max+walk_speed_min)
		$Sprite2D.flip_h = false
	elif direction < 0:
		$AnimationPlayer.play("walk")
		walk_speed = ai.rng.randf_range(walk_speed_min, walk_speed_max)
		$AnimationPlayer.speed_scale = 2.0*walk_speed/(walk_speed_max+walk_speed_min)
		$Sprite2D.flip_h = true
	else:
		$AnimationPlayer.play("idle")
		$AnimationPlayer.speed_scale = 1.0

func _process(delta):
	var direction_vector = Vector2.ZERO
	if ai.direction > 0:
		direction_vector = Vector2.RIGHT
	elif ai.direction < 0:
		direction_vector = Vector2.LEFT
	move_offset.emit(walk_speed*direction_vector*delta)
