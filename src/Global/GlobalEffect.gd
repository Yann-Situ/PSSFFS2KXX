extends Node

var distortion_scene = preload("res://src/Effects/Distortion.tscn")
enum IMPACT_TYPE {ZERO, JUMP0, JUMP1, SPIKES, SPARKS, BOUNCE, CIRCLE}
var impact_scenes = [\
	preload("res://src/Effects/Impacts/Impact0.tscn"),\
	preload("res://src/Effects/Impacts/ImpactJump0.tscn"),\
	preload("res://src/Effects/Impacts/ImpactJump1.tscn"),\
	preload("res://src/Effects/Impacts/ImpactSpikes.tscn"),\
	preload("res://src/Effects/Impacts/ImpactSparks.tscn"),\
	preload("res://src/Effects/Impacts/ImpactBounce.tscn"),\
	preload("res://src/Effects/Impacts/ImpactCircles.tscn")
	]

var tween_pause : Tween

func set_pause(b: bool):
	get_tree().paused = b
	#Engine.time_scale = time_scale

func stop_time(duration : float):
	if tween_pause:
		tween_pause.kill()
	tween_pause = self.create_tween().set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	tween_pause.tween_callback(self.set_pause.bind(true))
	tween_pause.tween_interval(duration)
	tween_pause.tween_callback(self.set_pause.bind(false))

func make_distortion(global_position : Vector2, animation_delay : float = 0.75,\
animation_name : String = "subtle", size : Vector2 = Vector2(128,128),\
_z_index : int = Global.z_indices["foreground_2"]):
	var distortion = distortion_scene.instantiate()
	Global.get_current_room().add_child(distortion)
	distortion.global_position = global_position
	distortion.z_index = _z_index
	distortion.animation_delay = animation_delay
	distortion.size = size
	distortion.start(animation_name)

func make_impact(global_position : Vector2, impact_type : IMPACT_TYPE = IMPACT_TYPE.ZERO, normal : Vector2 = Vector2.UP):
	assert(int(impact_type) >= 0)
	assert(int(impact_type) < impact_scenes.size())
	var impact = impact_scenes[impact_type].instantiate()
	Global.get_current_room().add_child(impact)
	impact.global_position = global_position
	impact.start(normal)

func make_explosion(global_position : Vector2, explosion_data : ExplosionData):
	var explosion = Explosion.new()
	explosion.explosion_data = explosion_data
	explosion.global_position = global_position
	Global.get_current_room().add_child(explosion)

func make_simple_explosion(global_position : Vector2, radius : float,
duration : float = 0.5, explosion_steps = 3,
momentums : Array = [0.0,0.0,0.0],
damage : float = 0.0, damage_duration : float = 0.0,
body_exceptions : Array[Node2D] = []):
	var explosion_data = ExplosionData.new()
	var shape = CircleShape2D.new()
	shape.radius = radius
	explosion_data.set_collision_shape(shape)
	explosion_data.use_default_explosion = true
	explosion_data.explosion_duration = duration
	explosion_data.explosion_steps = explosion_steps
	explosion_data.momentum_breakable = momentums[0]
	explosion_data.momentum_electric = momentums[1]
	explosion_data.momentum_physicbody = momentums[2]
	explosion_data.damage_value = damage
	explosion_data.damage_duration = damage_duration
	explosion_data.body_exceptions = body_exceptions
	make_explosion(global_position, explosion_data)
