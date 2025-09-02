extends Node2D
class_name GhostHandler

var ghost_anim = preload("res://src/Effects/GhostAnim.tscn")
@export var ghost_sprite : Sprite2D ## The sprite to be ghosted
@export var use_gradient : bool = true ## if false, use the self modulate of this node
@export var gradient : Gradient : set = set_gradient ## eventually to use this gradient to fade away the ghost
@export var flipper : Node2D ## eventually to flip the ghost according to the scale of this node

func _ready() -> void:
	assert(ghost_sprite != null)

func is_running():
	return !$Ghost_Tick_Timer.is_stopped()

func set_gradient(grad : Gradient):
	gradient = grad

func set_gradient_from_ball(ball : Ball):
	gradient = ball.get_dash_gradient()

func set_gradient_to_null():
	gradient = null
################################################################################

func instance_ghost():
	assert(ghost_sprite != null)
	var ghost: Sprite2D = ghost_anim.instantiate()
	ghost.texture = ghost_sprite.texture
	ghost.vframes = ghost_sprite.vframes
	ghost.hframes = ghost_sprite.hframes
	ghost.frame = ghost_sprite.frame
	if flipper:
		ghost.flip_h = flipper.scale.x < 0
	else:
		ghost.flip_h = ghost_sprite.flip_h
	ghost.use_gradient = false
	ghost.self_modulate = self.self_modulate
	ghost.global_position = self.global_position + Vector2(194,152)
	ghost.z_as_relative = false
	ghost.z_index = ghost_sprite.z_index - 1
	Global.get_current_room().add_child(ghost) # add to environment

func instance_ghost_gradient(gradient : Gradient):
	assert(ghost_sprite != null)
	assert(gradient != null)
	var ghost: Sprite2D = ghost_anim.instantiate()
	ghost.texture = ghost_sprite.texture
	ghost.vframes = ghost_sprite.vframes
	ghost.hframes = ghost_sprite.hframes
	ghost.frame = ghost_sprite.frame
	if flipper:
		ghost.flip_h = flipper.scale.x < 0
	else:
		ghost.flip_h = ghost_sprite.flip_h
	ghost.use_gradient = true
	ghost.gradient = gradient
	ghost.global_position = self.global_position + Vector2(194,152)
	ghost.z_as_relative = false
	ghost.z_index = ghost_sprite.z_index - 1
	Global.get_current_room().add_child(ghost) # add to environment

## negative duration implies that it won't stop automatically
func start(duration, tick_delay : float = 0.1):
	if duration > 0.0:
		$Ghost_Timer.start(duration)
	$Ghost_Tick_Timer.start(tick_delay)

func stop():
	$Ghost_Timer.stop()
	_on_Ghost_Timer_timeout()

func _on_Ghost_Timer_timeout():
	$Ghost_Tick_Timer.stop()

func _on_Ghost_Tick_Timer_timeout():
	if use_gradient and gradient != null:
		instance_ghost_gradient(gradient)
	else :
		instance_ghost()
