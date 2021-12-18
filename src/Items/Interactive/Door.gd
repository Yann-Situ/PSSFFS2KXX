tool
extends Activable

export(int, "type0", "type1") var visual_type setget set_visual_type
export(bool) var flip_h = false setget set_flip_h
export var mass = 5.0 # kg
export var momentum_threshold = 0.0 # m*pix/s
export var explode_threshold = 600.0 # m*pix/s

onready var momentum_threshold2 = momentum_threshold*momentum_threshold
onready var explode_threshold2 = explode_threshold*explode_threshold
onready var inv_mass = 1.0/mass
onready var collision_layer_save = $Breakable.collision_layer
onready var collision_mask_save = $Breakable.collision_mask
var only_breakable_collision_layer = 64 # only breakable

func set_visual_type(b):
	visual_type = b
	update_sprite(activated)

func set_flip_h(b):
	flip_h = b
	$Sprite.flip_h = flip_h

func _ready():
	self.z_as_relative = false
	self.z_index = Global.z_indices["background_4"]
	set_activated(activated)

func update_sprite(b):
	if b:
		$Sprite.set_frame(visual_type*2+1)
	else:
		$Sprite.set_frame(visual_type*2+0)

func apply_explosion(momentum : Vector2):
	var m2=momentum.length_squared()
	if m2 >= momentum_threshold2:
		enable()
		if m2 >= explode_threshold2:
			explode(momentum)

func on_enable():
	update_sprite(activated)
	if !Engine.editor_hint:
		$Occluder.visible = false
		$Breakable.collision_layer = only_breakable_collision_layer
		$Breakable.collision_mask = 0

func explode(momentum : Vector2):
	print(name+" breaks")
	$DebrisParticle.direction = momentum
	$DebrisParticle.initial_velocity = inv_mass * momentum.length()
	$DebrisParticle.restart()
	$Sprite.visible = false
	$Occluder.visible = false
	$Breakable.collision_layer = 0
	$Breakable.collision_mask = 0
	self.lock()
	yield(get_tree().create_timer($DebrisParticle.lifetime*1.5), "timeout")
	queue_free()

func on_disable():
	update_sprite(activated)
	if !Engine.editor_hint:
		$Occluder.visible = true
		$Breakable.collision_layer = collision_layer_save
		$Breakable.collision_mask = collision_mask_save
