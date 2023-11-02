@icon("res://assets/art/icons/star-location.png")
extends TileMap
class_name HiddenPlace

@export var transition_duration : float = 0.5#s
@export var connect_area2D : bool = false : set = set_connect_area2D
#@export var collision_shape : CollisionShape2D : set = set_collision_shape
# Implementation choice: CollisionShape2D need to be child of HiddenPlace and
# will be reparented at runtime (in _ready) to be child of Area2D.
@export_flags_2d_physics var collision_mask : int = 1 : set = set_collision_mask
var tween_modulate : Tween

func set_connect_area2D(b : bool):
	connect_area2D = b
	if connect_area2D:
		if !$Area2D.body_entered.is_connected(self._on_body_entered):
			$Area2D.body_entered.connect(self._on_body_entered)
		if !$Area2D.body_exited.is_connected(self._on_body_exited):
			$Area2D.body_exited.connect(self._on_body_exited)
	else:
		if $Area2D.body_entered.is_connected(self._on_body_entered):
			$Area2D.body_entered.disconnect(self._on_body_entered)
		if $Area2D.body_exited.is_connected(self._on_body_exited):
			$Area2D.body_exited.disconnect(self._on_body_exited)
func set_collision_mask(mask : int):
	collision_mask = mask
	$Area2D.collision_mask = mask

# Called when the node enters the scene tree for the first time.
func _ready():
	for node in get_children():
		if node is CollisionShape2D:
			node.reparent($Area2D, true)

func _on_body_entered(body):
	reveal_behind()
func _on_body_exited(body):
	# WARNING: weird behaviour: when a ball exit but is reparenting, it can appear in the list
	# returned by get_overlapping_bodies .
	# This is probably because of the complicated reparenting implementation (see Ball.gd)
	# to avoid that easily we check also if the list is not [body]
	var l = $Area2D.get_overlapping_bodies()
	if l.is_empty() or l == [body]:
		hide_behind()

func hide_behind():
	if tween_modulate:
		tween_modulate.kill()
	tween_modulate = self.create_tween().set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN_OUT)
	tween_modulate.tween_property(self, "modulate", Color.WHITE, transition_duration)
	# twee_modulate.start() start automatically
func reveal_behind():
	if tween_modulate:
		tween_modulate.kill()
	tween_modulate = self.create_tween().set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN_OUT)
	tween_modulate.tween_property(self, "modulate", Color.TRANSPARENT, transition_duration)
	# twee_modulate.start() start automatically
