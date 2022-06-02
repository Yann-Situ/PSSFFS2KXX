extends Node2D

onready var Player = get_parent()
onready var S = Player.get_node("State")

var ghost_anim = preload("res://src/Effects/GhostAnim.tscn")
var distortion_scene = preload("res://src/Effects/Distortion.tscn") 
var jump_particles1 = preload("res://src/Effects/JumpParticles1.tscn")

var ghost_sprite

func _ready():
	$GhostHandler.set_ghost_sprite(Player.get_node("Sprite"))
	$GhostHandler.set_environment_node(Player.get_parent())
	$TrailHandler.set_node_to_trail(Player)

func process_effects():
	pass

func jump_start():
	var jump = jump_particles1.instance()
	get_parent().add_child(jump)
	jump.global_position = Player.global_position + Player.foot_vector + Vector2(0,-9)
	jump.start()

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
	
func ghost_start(duration, tick_delay, selfmodulate : Color = Color(1.2,1.8,2.2,0.39)):
	$GhostHandler.self_modulate = selfmodulate
	$GhostHandler.start(duration, tick_delay)
func ghost_stop(duration, tick_delay):
	$GhostHandler.stop()

func trail_start(duration, tick_delay):
	$TrailHandler.start(duration, tick_delay)
func trail_stop():
	$TrailHandler.stop()
	
func distortion_start(animation_name : String = "subtle", duration : float = 0.75):
	var distortion = distortion_scene.instance()
	Player.get_parent().add_child(distortion)
	distortion.animation_delay = duration#s
	distortion.global_position = Player.global_position
	distortion.z_index = Global.z_indices["foreground_2"]
	distortion.start(animation_name)
