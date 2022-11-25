extends Node

var distortion_scene = preload("res://src/Effects/Distortion.tscn")
var impact_scenes = [preload("res://src/Effects/ImpactParticle1.tscn"),
	preload("res://src/Effects/ImpactParticle0.tscn")]

func make_distortion(global_position : Vector2, animation_delay : float = 0.75,\
animation_name : String = "subtle"):
	var distortion = distortion_scene.instance()
	Global.get_current_room().add_child(distortion)
	distortion.global_position = global_position
	distortion.z_index = Global.z_indices["foreground_2"]
	distortion.animation_delay = animation_delay
	distortion.start(animation_name)

func make_impact(global_position : Vector2, effect_index : int = 0):
	if effect_index < 0:
		effect_index = 0
	elif effect_index >= impact_scenes.size():
		effect_index = impact_scenes.size()-1
	var impact = impact_scenes[effect_index].instance()
	Global.get_current_room().add_child(impact)
	impact.global_position = global_position
	impact.start()

func make_simple_explosion(global_position : Vector2, radius : float,
duration : float = 0.5, explosion_steps = 3,
momentums : Array = [0.0,0.0,0.0],
damage : float = 0.0, damage_duration : float = 0.0,
body_exceptions : Array = []):
	var explosion = Explosion.new()
	#explosion.simple_explosion = true
	var shape = CircleShape2D.new()
	shape.radius = radius
	explosion.set_collision_shape(shape)
	explosion.duration = duration
	explosion.breakable_momentum = momentums[0]
	explosion.electric_momentum = momentums[1]
	explosion.physicbody_momentum = momentums[2]
	explosion.damage = damage
	explosion.damage_duration = damage_duration
	explosion.duration = duration
	explosion.explosion_steps = explosion_steps
	explosion.body_exceptions = body_exceptions
	explosion.global_position = global_position
	Global.get_current_room().add_child(explosion)
