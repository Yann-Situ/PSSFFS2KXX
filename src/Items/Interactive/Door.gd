@tool
extends Activable

@export var visual_type :
	set = set_visual_type # (int, "type0", "type1")
@export var flip_h: bool = false : set = set_flip_h
@export var mass = 5.0 # kg
@export var momentum_threshold = 200.0 # m*pix/s
@export var explode_threshold = 500.0 # m*pix/s

@onready var momentum_threshold2 = momentum_threshold*momentum_threshold
@onready var explode_threshold2 = explode_threshold*explode_threshold
@onready var inv_mass = 1.0/mass
@onready var collision_layer_save = $Breakable.collision_layer
@onready var collision_mask_save = $Breakable.collision_mask
var only_breakable_collision_layer = 64 # only breakable

func set_visual_type(b):
	visual_type = b
	update_sprite(activated)

func set_flip_h(b):
	flip_h = b
	$Sprite2D.flip_h = flip_h

func _ready():
	self.z_as_relative = false
	self.z_index = Global.z_indices["background_4"]
	set_activated(activated)

func update_sprite(b):
	if b:
		$Sprite2D.set_frame(visual_type*2+1)
	else:
		$Sprite2D.set_frame(visual_type*2+0)

func apply_explosion(momentum : Vector2):
	var m2=momentum.length_squared()
	if m2 >= momentum_threshold2:
		enable()
		if m2 >= explode_threshold2:
			explode(momentum)
		return true
	return false

func on_enable():
	update_sprite(activated)
	if !Engine.is_editor_hint():
		$OccluderInstance3D.visible = false
		$Breakable.collision_layer = only_breakable_collision_layer
		$Breakable.collision_mask = 0

func explode(momentum : Vector2):
	print(name+" breaks")
	$DebrisParticle.direction = momentum
	$DebrisParticle.initial_velocity = inv_mass * momentum.length()
	$DebrisParticle.restart()
	$Sprite2D.visible = false
	$OccluderInstance3D.visible = false
	$Breakable.collision_layer = 0
	$Breakable.collision_mask = 0
	false # self.lock() # TODOConverter40, Image no longer requires locking, `false` helps to not break one line if/else, so it can freely be removed
	await get_tree().create_timer($DebrisParticle.lifetime*1.5).timeout
	queue_free()

func on_disable():
	update_sprite(activated)
	if !Engine.is_editor_hint() and is_inside_tree():
		$OccluderInstance3D.visible = true
		$Breakable.collision_layer = collision_layer_save
		$Breakable.collision_mask = collision_mask_save
