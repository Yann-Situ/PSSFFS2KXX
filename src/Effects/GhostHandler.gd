extends Node2D

var ghost_anim = preload("res://src/Effects/GhostAnim.tscn")
@export var ghost_sprite : Sprite2D
@export var environment_node : Node2D
@export var use_gradient : bool = false
@export var gradient : Gradient

func is_running():
	return !$Ghost_Tick_Timer.is_stopped()

func set_ghost_sprite(sprite_node):
	ghost_sprite = sprite_node

func set_environment_node(env_node):
	environment_node = env_node
################################################################################

func instance_ghost():
	var ghost: Sprite2D = ghost_anim.instantiate()
	ghost.texture = ghost_sprite.texture
	ghost.vframes = ghost_sprite.vframes
	ghost.hframes = ghost_sprite.hframes
	ghost.frame = ghost_sprite.frame
	ghost.flip_h = ghost_sprite.flip_h
	ghost.use_gradient = false
	ghost.self_modulate = self.self_modulate
	ghost.global_position = self.global_position + Vector2(194,152)
	ghost.z_as_relative = false
	ghost.z_index = ghost_sprite.z_index - 1
	environment_node.add_child(ghost) # add to environment

func instance_ghost_gradient(gradient : Gradient):
	assert(gradient != null)
	var ghost: Sprite2D = ghost_anim.instantiate()
	ghost.texture = ghost_sprite.texture
	ghost.vframes = ghost_sprite.vframes
	ghost.hframes = ghost_sprite.hframes
	ghost.frame = ghost_sprite.frame
	ghost.flip_h = ghost_sprite.flip_h
	ghost.use_gradient = true
	ghost.gradient = gradient
	ghost.global_position = self.global_position + Vector2(194,152)
	ghost.z_as_relative = false
	ghost.z_index = ghost_sprite.z_index - 1
	environment_node.add_child(ghost) # add to environment

func start(duration, tick_delay):
	if duration > 0.0:
		$Ghost_Timer.start(duration)
	$Ghost_Tick_Timer.start(tick_delay)

func stop():
	$Ghost_Timer.stop()
	_on_Ghost_Timer_timeout()

func _on_Ghost_Timer_timeout():
	$Ghost_Tick_Timer.stop()

func _on_Ghost_Tick_Timer_timeout():
	if use_gradient :
		instance_ghost_gradient(gradient)
	else :
		instance_ghost()
