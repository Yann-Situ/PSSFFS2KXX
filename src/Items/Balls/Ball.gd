extends PhysicBody
class_name Ball
# @icon("res://assets/art/ball/ball_test.png")

signal is_destroyed
signal is_picked_up
signal is_thrown

enum IMPACT_EFFECT {SPIKY, METALLIC}

@export var impact_effect : IMPACT_EFFECT = IMPACT_EFFECT.SPIKY
@export var dust_threshold : float = 300.0
@export var impact_threshold : float = 500.0
@export var damage_destruction_threshold : float = 2.0
var selectors = {}
var impact_particles = [preload("res://src/Effects/ImpactParticle1.tscn"),
	preload("res://src/Effects/ImpactParticle0.tscn")]
var _is_reparenting = false : get = is_reparenting

@onready var holder = Global.get_current_room()
@onready var Highlighter = $Highlighter

func _ready():
	self.z_as_relative = false
	self.z_index = Global.z_indices["ball_0"]
	add_to_group("balls")
	add_to_group("damageables")
	assert(holder != null)

# Warning: workaround because of https://www.reddit.com/r/godot/comments/vjkaun/reparenting_node_without_removing_it_from_tree/
func is_reparenting():
	return _is_reparenting

func get_main_color() -> Color:
	return $Effects.col2

func get_main_gradient() -> Gradient:
	return $Effects.gradient_main.duplicate()

func get_dash_gradient() -> Gradient:
	return $Effects.gradient_dash.duplicate()
#func _draw():
#	# draw collision normal
#	draw_line(Vector2(0.0,0.0), Vector2(0.0,0.0)+50.0*normal_colision, color_colision)

###########################################################
func reset_position():
	if holder != Global.get_current_room():
		throw(Vector2.ZERO,Vector2.ZERO)
	global_position = start_position

func collision_effect(collider, collider_velocity, collision_point, collision_normal):
	var speed = (linear_velocity-collider_velocity).length()
	if speed >= dust_threshold:
		$Effects/DustParticle.restart()
		if speed >= impact_threshold:
			GlobalEffect.make_impact(collision_point, impact_effect)
#			var impact = impact_particles[impact_effect].instantiate()
#			get_parent().add_child(impact)
#			impact.global_position = collision_point
#			impact.start()
	return true

###########################################################

# Ball Holder call order:
# Pickup:
#- holder.pickup_ball(ball)
#	- ball.pickup(holder)
#		- old_holder.free_ball(ball) # if the old_holder was not the current room
#		- reparenting system
#		- ball.disable_physics()
#		- ball.on_pickup(holder) # additional effect
# Throw:
#- old_holder.throw_ball(...) # or any function that calls ball.throw(...)
#	- ball.throw(position, velocity)
#		- ball.enable_physics()
#		- old_holder.free_ball(ball)
#		- reparenting system
#		- ball.on_throw(old_holder) # additional effect

func change_holder(new_holder : Node):
	assert(new_holder != null)
	# assert(get_parent() != null) # this assertion can fail if reparenting multiple times quickly. Workaround:
	if get_parent() == null:
		push_error(name+".get_parent() return null because last reparenting is not yet done.")
		return

	if new_holder == holder:
		print_debug(self.name+" reparent from "+holder.name+" to "+new_holder.name+" is ignored")
		return
	if holder != Global.get_current_room():
		holder.free_ball(self)
	print_debug(self.name+" reparent from "+holder.name+" to "+new_holder.name)
	holder = new_holder
	# WARNING : the game seems to crash when calling change_holder(null) with# holder = null on the following line
	_is_reparenting = true
	get_parent().remove_child(self) # if reparenting multiple times quickly, this can result in error cause get_parent is null

	# Warning : the following part reparent the node and will trigger again
	# every area/body_entered signal. This can lead to weird things when
	# multiple nodes are retriggering their functions.
	# see https://github.com/godotengine/godot/issues/14578

	#new_holder.add_child(self)
	new_holder.call_deferred("add_child", self)
	self.set_deferred("_is_reparenting", false)

func pickup(holder_node):
	if not holder_node.is_in_group("holders"):
		printerr("["+name+"], holder_node is not in group `holders`.")
	assert(holder_node != null)
	change_holder(holder_node)
	self.disable_physics()
	self.z_index = holder_node.z_index+1
	on_pickup(holder_node)
	is_picked_up.emit()

func throw(_position, velo):
	#$TrailHandler.set_node_to_trail(self)
	#$TrailHandler.start(2.0,0.1)
	self.enable_physics()
	var previous_holder = holder
	change_holder(Global.get_current_room())
	global_position = _position
	linear_velocity = velo
	self.z_index = Global.z_indices["ball_0"]
	on_throw(previous_holder)
	is_thrown.emit()

func destruction(delay : float = 0.0):
	if delay > 0.0:
		await get_tree().create_timer(delay).timeout
	on_destruction()
	if holder != Global.get_current_room():
		change_holder(Global.get_current_room())
	self.disable_physics()
	for selector in selectors.keys():
		deselect(selector) # will also call selectors.erase(selector)
	$Animation.play("destruction") # will call _queue_free

func _queue_free():
	print(self.name+" is DESTROYED")
	is_destroyed.emit()
	queue_free()

################################################################################
func select(selector : Node):
	if selectors.has(selector):
		push_warning(selector.name+" already in 'selectors'")
		return
	selectors[selector] = true # or whatever
	$Highlighter.toggle_selection(true)
	if selector.has_method("select_ball"):
		selector.select_ball(self)

func deselect(selector : Node):
	if !selectors.erase(selector):
		push_warning(selector.name+" is not in 'selectors'")
		return
	if selectors.keys().is_empty():
		Highlighter.toggle_selection(false)
	if selector.has_method("deselect_ball"):
		selector.deselect_ball(self)

func is_selected() -> bool:
	return !selectors.keys().is_empty()

################################################################################

func on_pickup(holder_node : Node):
	pass

func on_throw(previous_holder : Node):
	pass

func on_dunk(basket : Node = null):
	$Animation.stop()
	$Animation.play("dunk")

func on_goal():
	pass

func on_destruction(): # call before changing holder, disable_physics and deleting selectors
	pass

func apply_damage(damage : float, duration : float = 0.0):
	if damage >= damage_destruction_threshold:
		destruction(0.0)

################################################################################


