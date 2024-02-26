# @icon("res://assets/art/icons/alterer.png")
extends Resource
## Abstract class for alterers
class_name FollowProperty

signal is_done # when the alterer won't be modified again, so it can be removed
signal has_changed # when the alterer was modified

@export var node : Node ## The object whose property follows this resource
@export var property : NodePath ## The property name (e.g "scale", or "position")
@export var duration : float = 0.5 ## time (s) for the tween
@export var following : bool = true : set=set_following ## If or not the property should follow this resource
var value : Variant : set = set_value, get = get_value
var tween : Tween
func set_following(b : bool):
	following = b
	if !following:
		if tween:
			tween.kill() # Abort the previous animation.


func set_value(v : Variant):
	if v == value:
		return
	value = v

	if tween:
		tween.kill() # Abort the previous animation.
	tween = node.get_tree().create_tween()
	tween.tween_property(node, property, value, duration)

func get_value() -> Variant:
	return value
