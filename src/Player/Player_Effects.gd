extends Node2D

@export var P: Player
@onready var S = P.get_state_node()

var ghost_anim = preload("res://src/Effects/GhostAnim.tscn")
var distortion_scene = preload("res://src/Effects/Distortion.tscn")
#var jump_particles1 = preload("res://src/Effects/JumpParticles1.tscn")

var ghost_sprite

func _ready():
	$GhostHandler.set_ghost_sprite(P.get_node("Sprite2D"))
	#$TrailHandler.set_node_to_trail(P)

func process_effects():
	pass

func jump_start():
	GlobalEffect.make_impact(P.global_position + P.foot_vector, \
		GlobalEffect.IMPACT_TYPE.JUMP1, Vector2.UP)
#	var jump = jump_particles1.instantiate()
#	get_parent().add_child(jump)
#	jump.global_position = P.global_position + P.foot_vector + Vector2(0,-9)
#	jump.start()

func dust_start():
	$DustParticle.restart()
func dust_stop():
	$DustParticle.emitting = false

func cloud_start():
	$CloudParticles.restart()
func cloud_stop():
	$CloudParticles.emitting = false

func grind_start():
	$GrindParticles.restart()
func grind_stop():
	$GrindParticles.emitting = false

func ghost_start(duration, tick_delay, selfmodulate : Color = Color(1.2,1.8,2.2,0.39), gradient : Gradient = null):
	$GhostHandler.set_environment_node(Global.get_current_room())
	$GhostHandler.use_gradient = gradient != null
	if gradient == null:
		$GhostHandler.self_modulate = selfmodulate
	else :
		$GhostHandler.gradient = gradient
	$GhostHandler.start(duration,tick_delay)
func ghost_stop(duration, tick_delay):
	$GhostHandler.stop()

func trail_start(duration, tick_delay):
	$TrailHandler.start(duration,tick_delay)
func trail_stop():
	$TrailHandler.stop()

func distortion_start(animation_name : String = "subtle", duration : float = 0.75):
	var distortion = distortion_scene.instantiate()
	P.get_parent().add_child(distortion)
	distortion.animation_delay = duration#s
	distortion.global_position = P.global_position
	distortion.z_index = Global.z_indices["foreground_2"]
	distortion.start(animation_name)
