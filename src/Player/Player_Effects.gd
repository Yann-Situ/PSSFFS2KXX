extends Node2D

onready var Player = get_parent()
onready var S = Player.get_node("Player_State")

var ghost_anim = preload("res://src/Effects/GhostAnim.tscn")
var ghost_sprite

func _ready():
	$GhostHandler.set_ghost_sprite(Player.get_node("Sprite"))
	$GhostHandler.set_environment_node(Player.get_parent())

func process_effects():
	pass

# DUST

func dust_start():
	$DustParticle.restart()
#
func ghost_start(duration, tick_delay):
	$GhostHandler.start(duration, tick_delay)
