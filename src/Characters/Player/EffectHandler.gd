@icon("res://assets/art/icons/star-r-16.png")
extends Node2D
class_name EffectHandler

@export var player: Player
var ghost_anim = preload("res://src/Effects/GhostAnim.tscn")
var distortion_scene = preload("res://src/Effects/Distortion.tscn")
#var jump_particles1 = preload("res://src/Effects/JumpParticles1.tscn")

func dust_start():
	$DustParticle.restart()
func dust_stop():
	$DustParticle.emitting = false

func cloud_start(amount : int = 6, length : float = 32.0):
	GlobalEffect.make_puff(global_position, amount, length)
	#$CloudParticles.restart()
func cloud_stop():
	#$CloudParticles.emitting = false
	pass

func grind_emitting() -> bool:
	return $GrindParticles.emitting
func grind_start():
	$GrindParticles.restart()
func grind_stop():
	$GrindParticles.emitting = false

func ghost_start(duration, tick_delay, selfmodulate : Color = Color(1.2,1.8,2.2,0.39), gradient : Gradient = null):
	$GhostHandler.set_ghost_sprite(player.sprite)
	$GhostHandler.set_environment_node(Global.get_current_room()) # using Global.get_current_room() results in ghost not flipped
	$GhostHandler.use_gradient = gradient != null
	if gradient == null:
		$GhostHandler.self_modulate = selfmodulate
	else :
		$GhostHandler.gradient = gradient
	$GhostHandler.start(duration,tick_delay)
func ghost_stop(duration, tick_delay):
	$GhostHandler.stop()
