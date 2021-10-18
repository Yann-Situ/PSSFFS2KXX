extends Node2D

const dash_delay = 0.4

var ghost_anim = preload("res://src/Effects/GhostAnim.tscn")
var ghost_sprite

func process_effects():
	pass

# DUST

func dust_start():
	$DustParticle.restart()

# GHOST / UBER
func instance_ghost():
	var ghost: Sprite = ghost_anim.instance()
	get_parent().get_parent().add_child(ghost) # add to environment
	ghost.global_position = global_position
	ghost.texture = ghost_sprite.texture
	ghost.vframes = ghost_sprite.vframes
	ghost.hframes = ghost_sprite.hframes
	ghost.frame = ghost_sprite.frame
	ghost.flip_h = ghost_sprite.flip_h
	
func ghost_start(duration, tick_delay):
	$Ghost_Timers/Ghost_Timer.start(duration)
	$Ghost_Timers/Ghost_Tick_Timer.start(tick_delay)

func _on_Ghost_Timer_timeout():
	$Ghost_Timers/Ghost_Tick_Timer.stop()

func _on_Ghost_Tick_Timer_timeout():
	ghost_sprite = get_parent().get_node("Sprite")
	instance_ghost()
