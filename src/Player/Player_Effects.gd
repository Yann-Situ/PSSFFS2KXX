extends Node2D

onready var Player = get_parent()
onready var S = Player.get_node("Player_State")

var ghost_anim = preload("res://src/Effects/GhostAnim.tscn")
var ghost_sprite

func _ready():
	$GhostHandler.set_ghost_sprite(Player.get_node("Sprite"))
	$GhostHandler.set_environment_node(Player.get_parent())
	$TrailHandler.set_node_to_trail(Player)

func process_effects():
	pass

func jump_start():
	$JumpParticles0.restart()
func jump_stop():
	$JumpParticles0.stop()

func dust_start():
	$DustParticle.restart()
func dust_stop():
	$DustParticle.stop()

func ghost_start(duration, tick_delay):
	$GhostHandler.start(duration, tick_delay)
func ghost_stop(duration, tick_delay):
	$GhostHandler.stop()

func trail_start(duration, tick_delay):
	$TrailHandler.start(duration, tick_delay)
func trail_stop():
	$TrailHandler.stop()
