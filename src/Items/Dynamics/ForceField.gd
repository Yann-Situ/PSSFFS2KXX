extends Node2D

@export var base_force : Vector2 = Vector2(200.0,0) :
	set = set_force
@export var amplitude : float = 20.0  # pix/s
@export var period : float = 2.0  # s
@export var rectangle_extents : Vector2 = Vector2(256,128) : set = set_extents

@onready var direction = base_force.normalized()
@onready var force_alterer = AltererAdditive.new(base_force)
@onready var tween_force = self.create_tween()

func set_force(f : Vector2):
	base_force = f
	direction = base_force.normalized()

func set_extents(e : Vector2):
	rectangle_extents = e
	$Area2D/CollisionShape2D.shape.size = rectangle_extents
	$Sprite2D.texture.width = e.x
	$Sprite2D.texture.height = e.y
	
func _ready():
	tween_force.set_trans(Tween.TRANS_SINE)
	tween_force.set_parallel(false)
	tween_force.set_loops() # run infinitely
	tween_force.tween_property(force_alterer, "value", base_force+amplitude*direction, 0.5*period)
	tween_force.tween_property(force_alterer, "value", base_force-amplitude*direction, 0.5*period)
	tween_force.pause()

func _on_Area2D_body_entered(body):
	if body.has_method("add_force"):
		body.add_force(force_alterer)
		if not tween_force.is_running():
			tween_force.play()

func _on_Area2D_body_exited(body):
	if body.has_method("remove_force"): # temprarily we use only players TODO
	#if body is Player:dd
		body.remove_force(force_alterer)
		if $Area2D.get_overlapping_bodies().is_empty():
			tween_force.pause()
