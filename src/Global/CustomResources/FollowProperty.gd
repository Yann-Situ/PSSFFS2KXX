# @icon("res://assets/art/icons/alterer.png")
extends Resource
## Resource to simulate the tween.follow_property that was in Godot 3.X
class_name FollowProperty

@export var duration : float = 0.5 ## time (s) for the tween
@export var following : bool = true : set=set_following ## If or not the property should follow this resource
# @export var node : Node ## The object whose property follows this resource
# @export var property : NodePath ## The property name (e.g "scale", or "position")
var node : Node ## The object whose property follows this resource
var property : NodePath ## The property name (e.g "scale", or "position")

var value : Variant : set = set_value, get = get_value
var tween : Tween
func set_following(b : bool):
	following = b
	if !following:
		if tween:
			tween.kill() # Abort the previous animation.

func _init(_node : Node, _property : NodePath, initial_value : Variant, _duration = 0.5):
	node = _node
	property = _property
	duration = _duration
	value = initial_value

func set_value(v : Variant):
	if v == value:
		return
	value = v

	if tween:
		tween.kill() # Abort the previous animation.
	tween = node.create_tween()
	tween.tween_property(node, property, value, duration)

func get_value() -> Variant:
	return value
