extends PhysicBody
class_name Ball, "res://assets/art/ball/ball_test.png"

signal is_destroyed

enum IMPACT_EFFECT {SPIKY, METALLIC}
export (IMPACT_EFFECT) var impact_effect = IMPACT_EFFECT.SPIKY
export (float) var dust_threshold = 300
export (float) var impact_threshold = 500

var selected = false # if selected by mouse
var selectors = {}
var impact_particles = [preload("res://src/Effects/ImpactParticle1.tscn"),
	preload("res://src/Effects/ImpactParticle0.tscn")]
var _is_reparenting = false setget ,is_reparenting

onready var holder = Global.get_current_room()
onready var Highlighter = $Highlighter

func _ready():
	self.z_as_relative = false
	self.z_index = Global.z_indices["ball_0"]
	add_to_group("balls")
	add_to_group("damageables")
	assert(holder != null)

# func _enter_tree():
# 	print(name+" _enter_tree")
# func _exit_tree():
# 	print(name+" _exit_tree")

# Warning: workaround because of https://www.reddit.com/r/godot/comments/vjkaun/reparenting_node_without_removing_it_from_tree/
func is_reparenting():
	return _is_reparenting

func get_main_color() -> Color:
	return $Effects.col2

func get_main_gradient() -> Gradient:
	return $Effects.gradient_main
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
			var impact = impact_particles[impact_effect].instance()
			get_parent().add_child(impact)
			impact.global_position = collision_point
			impact.start()
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
	if new_holder == holder:
		print_debug(self.name+" reparent from "+holder.name+" to "+new_holder.name+" is ignored")
		return
	if holder != Global.get_current_room():
		holder.free_ball(self)
	print_debug(self.name+" reparent from "+holder.name+" to "+new_holder.name)
	holder = new_holder
	# WARNING : the game seems to crash when calling change_holder(null) with# holder = null on the following line
	_is_reparenting = true
	get_parent().remove_child(self)
	# Warning : the following part reparent the node and will trigger again
	# every area/body_entered signal. This can lead to weird things when
	# multiple nodes are retriggering their functions.
	# see https://github.com/godotengine/godot/issues/14578
	new_holder.add_child(self)
	_is_reparenting = false

func pickup(holder_node):
	if not holder_node.is_in_group("holders"):
		print("error["+name+"], holder_node is not in group `holders`.")
	assert(holder_node != null)
	change_holder(holder_node)
	self.disable_physics()
	self.z_index = holder_node.z_index+1
	on_pickup(holder_node)

func throw(position, velo):
	#$TrailHandler.set_node_to_trail(self)
	#$TrailHandler.start(2.0,0.1)
	self.enable_physics()
	var previous_holder = holder
	change_holder(Global.get_current_room())
	global_position = position
	linear_velocity = velo
	self.z_index = Global.z_indices["ball_0"]
	on_throw(previous_holder)

func destruction(delay : float = 0.0):
	if delay > 0.0:
		yield(get_tree().create_timer(delay), "timeout")
	if holder != Global.get_current_room():
		change_holder(Global.get_current_room())
	#TODO need to handle the selector of the player
	self.disable_physics()
	for selector in selectors.keys():
		deselect(selector) # will also call selectors.erase(selector)
	$Animation.play("destruction") # will call _queue_free
	
func _queue_free():
	print(self.name+" is DESTROYED")
	emit_signal("is_destroyed")
	queue_free()

################################################################################
func select(selector : Node):
	if selectors.has(selector):
		printerr(selector.name+" already in 'selectors'")
		return
	selectors[selector] = true # or whatever
	$Highlighter.toggle_selection(true)
	if selector.has_method("select_ball"):
		selector.select_ball(self)

func deselect(selector : Node):
	if !selectors.erase(selector):
		printerr(selector.name+" is not in 'selectors'")
		return
	if selectors.keys().empty():
		Highlighter.toggle_selection(false)
	if selector.has_method("deselect_ball"):
		selector.deselect_ball(self)

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

func on_destruction():
	pass

func apply_damage(damage : float, duration : float = 0.0):
	destruction(0.0)

################################################################################

func power_p(player,delta):
	if holder == Global.get_current_room() :
		add_force("attract", player.attract_force*(player.position - position).normalized())

func power_jp(player,delta):
	pass

func power_jr(player,delta):
	if holder == Global.get_current_room() :
		remove_force("attract")
