extends Node

var distortion_scene = preload("res://src/Effects/Distortion.tscn")
var ground_wave_scene = preload("res://src/Effects/GroundWave.tscn")
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
var puff_scene = preload("res://src/Effects/PuffParticles.tscn")

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

func make_distortion(global_position : Vector2, time_scale : float = 1.3,\
animation_name : String = "subtle", size : Vector2 = Vector2(128,128),\
_z_index : int = Global.z_indices["foreground_3"]):
	var distortion = distortion_scene.instantiate()
	Global.get_current_room().add_child(distortion)
	distortion.global_position = global_position
	distortion.z_index = _z_index
	distortion.time_scale = time_scale
	distortion.size = size
	distortion.start(animation_name)
	
func make_ground_wave(global_position : Vector2, time_scale : float = 1.0,\
animation_name : String = "subtle", size_scale : Vector2 = Vector2(1,1),\
_z_index : int = Global.z_indices["foreground_3"]):
	var ground_wave = ground_wave_scene.instantiate()
	Global.get_current_room().add_child(ground_wave)
	ground_wave.global_position = global_position
	ground_wave.z_index = _z_index
	ground_wave.time_scale = time_scale
	ground_wave.size_scale = size_scale
	ground_wave.start(animation_name)

func make_impact(global_position : Vector2, impact_type : IMPACT_TYPE = IMPACT_TYPE.ZERO, normal : Vector2 = Vector2.UP, z_index = 100):
	assert(int(impact_type) >= 0)
	assert(int(impact_type) < impact_scenes.size())
	var impact = impact_scenes[impact_type].instantiate()
	Global.get_current_room().add_child(impact)
	impact.global_position = global_position
	impact.z_index = z_index
	impact.start(normal)

func make_puff(global_position : Vector2, amount : int = 6, length : float = 20.0, z_index = 100):
	var puff : GPUParticles2D = puff_scene.instantiate()
	Global.get_current_room().add_child(puff)
	puff.global_position = global_position
	puff.amount = amount
	puff.process_material.emission_box_extents.x = length
	puff.z_index = z_index
	puff.start()

func make_explosion(global_position : Vector2, explosion_data : ExplosionData):
	var explosion = Explosion.new()
	explosion.explosion_data = explosion_data
	explosion.global_position = global_position
	Global.get_current_room().add_child(explosion)

func make_simple_explosion(global_position : Vector2, radius : float,
duration : float = 0.5, explosion_steps = 3,
momentums : Array = [0.0,0.0,0.0],
damage : float = 0.0, damage_duration : float = 0.0,
path_exceptions : Array[NodePath] = []):
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
	explosion_data.path_exceptions = path_exceptions
	make_explosion(global_position, explosion_data)

######################### SOUND and AUDIO #####################################
func _set_bus_effect_enabled(bus_idx : int, effect : AudioEffect, enabled : bool):
	for effect_idx in AudioServer.get_bus_effect_count(bus_idx):
		if AudioServer.get_bus_effect(bus_idx, effect_idx) == effect:
			AudioServer.set_bus_effect_enabled(bus_idx, effect_idx, enabled)

#### LOWPASS
var bus_to_lowpass : Dictionary
var lowpass_to_tween : Dictionary

## if cutoff_hz_begin is negative, then start the tween with the current value
## if enable_lowpass_at_end is false, will disable the lowpass at the end
func bus_lowpass_fade(bus : StringName, duration : float, cutoff_hz_begin : float = 1760, cutoff_hz_end : float = 10000,
	  enable_lowpass_at_end : bool = false, trans_type : Tween.TransitionType = Tween.TRANS_EXPO):
	var bus_idx = AudioServer.get_bus_index(bus)
	if bus_idx < 0:
		push_error("no audio bus named : '"+bus+"'")
		return
	
	var filter : AudioEffectLowPassFilter = AudioEffectLowPassFilter.new()
	if bus_to_lowpass.has(bus_idx):
		filter = bus_to_lowpass[bus_idx]
		self._set_bus_effect_enabled(bus_idx, filter, true)
	else:
		filter = AudioEffectLowPassFilter.new()
		filter.cutoff_hz = cutoff_hz_begin
		filter.resonance = 0.66
		bus_to_lowpass[bus_idx] = filter
		AudioServer.add_bus_effect(bus_idx,filter)
		
	var tween_fade : Tween
	if lowpass_to_tween.has(filter):
		tween_fade = lowpass_to_tween[filter]
		if tween_fade:
			tween_fade.kill()
		tween_fade = self.create_tween().set_parallel(false)
		lowpass_to_tween[filter] = tween_fade
	else:
		tween_fade = self.create_tween().set_parallel(false)
		lowpass_to_tween[filter] = tween_fade
	
	if cutoff_hz_begin > 0.0:
		filter.cutoff_hz = cutoff_hz_begin
	if filter.cutoff_hz < cutoff_hz_end:
		tween_fade.tween_property(filter,"cutoff_hz",cutoff_hz_end, duration).set_trans(trans_type).set_ease(Tween.EASE_IN)
	else:
		tween_fade.tween_property(filter,"cutoff_hz",cutoff_hz_end, duration).set_trans(trans_type).set_ease(Tween.EASE_OUT)
	tween_fade.tween_callback(self._set_bus_effect_enabled.bind(bus_idx, filter, enable_lowpass_at_end))
	
func bus_lowpass_fade_in(bus : StringName, duration : float):
	bus_lowpass_fade(bus, duration, -1, 10000, false)
func bus_lowpass_fade_out(bus : StringName, duration : float, cutoff_hz : float = 1760):
	bus_lowpass_fade(bus, duration, -1, cutoff_hz, true)

#### HIGHPASS
var bus_to_highpass : Dictionary
var highpass_to_tween : Dictionary

## if cutoff_hz_begin is negative, then start the tween with the current value
## if enable_highpass_at_end is false, will disable the highpass at the end
func bus_highpass_fade(bus : StringName, duration : float, cutoff_hz_begin : float = 1760, cutoff_hz_end : float = 40, 
	  enable_highpass_at_end : bool = false, trans_type : Tween.TransitionType = Tween.TRANS_EXPO):
	var bus_idx = AudioServer.get_bus_index(bus)
	if bus_idx < 0:
		push_error("no audio bus named : '"+bus+"'")
		return
	
	var filter : AudioEffectHighPassFilter = AudioEffectHighPassFilter.new()
	if bus_to_highpass.has(bus_idx):
		filter = bus_to_highpass[bus_idx]
		self._set_bus_effect_enabled(bus_idx, filter, true)
	else:
		filter = AudioEffectHighPassFilter.new()
		if cutoff_hz_begin < 40.0:
			filter.cutoff_hz = 40.0
		else: 
			filter.cutoff_hz = cutoff_hz_begin
		filter.resonance = 0.66
		bus_to_highpass[bus_idx] = filter
		AudioServer.add_bus_effect(bus_idx,filter)
		
	var tween_fade : Tween
	if highpass_to_tween.has(filter):
		tween_fade = highpass_to_tween[filter]
		if tween_fade:
			tween_fade.kill()
		tween_fade = self.create_tween().set_parallel(false)
		highpass_to_tween[filter] = tween_fade
	else:
		lowpass_to_tween[filter] = tween_fade
		tween_fade = self.create_tween().set_parallel(false)
		highpass_to_tween[filter] = tween_fade
	
	if cutoff_hz_begin > 0.0:
		filter.cutoff_hz = cutoff_hz_begin
	if filter.cutoff_hz < cutoff_hz_end:
		tween_fade.tween_property(filter,"cutoff_hz",cutoff_hz_end, duration).set_trans(trans_type).set_ease(Tween.EASE_IN)
	else:
		tween_fade.tween_property(filter,"cutoff_hz",cutoff_hz_end, duration).set_trans(trans_type).set_ease(Tween.EASE_OUT)
	tween_fade.tween_callback(self._set_bus_effect_enabled.bind(bus_idx, filter, enable_highpass_at_end))
	
func bus_highpass_fade_in(bus : StringName, duration : float):
	bus_highpass_fade(bus, duration, -1, 40, false)
func bus_highpass_fade_out(bus : StringName, duration : float, cutoff_hz : float = 1760):
	bus_highpass_fade(bus, duration, -1, cutoff_hz, true)

# Fade in using volume TODO: use only one tween
func bus_fade(bus : StringName, duration : float = 0.5, db_begin : float = 0.0, db_end : float = -60.0):
	var bus_idx = AudioServer.get_bus_index(bus)
	if bus_idx < 0:
		push_error("no audio bus named : '"+bus+"'")
		return
	var tween_fade : Tween
	tween_fade = self.create_tween()
	var callable: Callable = func(value): AudioServer.set_bus_volume_db(bus_idx, value) # lambda function to bypass the lack of bind_left
	if is_nan(db_begin):
		db_begin = AudioServer.get_bus_volume_db(bus_idx)
	tween_fade.tween_method(callable, db_begin, db_end, duration)
	
func bus_fade_in(bus : StringName, duration : float = 0.5):
	bus_fade(bus, duration, -60.0, 0.0)

func bus_fade_out(bus : StringName, duration : float = 0.5):
	bus_fade(bus, duration, 0.0, -60.0)
	
	#for effect_idx in AudioServer.get_bus_effect_count(bus_idx):
		#AudioServer.set_bus_effect_enabled(bus_idx, effect_idx, true)
	
#func bus_fade_out()
