extends Node2D

@onready var Character = get_parent()
@onready var S = Character.get_node("State")

func _ready():
	$GhostHandler.set_ghost_sprite(Character.get_node("Sprite2D"))
	$GhostHandler.set_environment_node(Character.get_parent())
	$TrailHandler.set_node_to_trail(Character)

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
	$GhostHandler.start(duration,tick_delay)
func ghost_stop(duration, tick_delay):
	$GhostHandler.stop()

#func trail_start(duration,tick_delay):
#	$TrailHandler.start(duration,tick_delay)
#func trail_stop():
#	$TrailHandler.stop()
