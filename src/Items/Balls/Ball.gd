@icon("res://assets/art/icons/ball.png")
extends SituBody
class_name Ball

signal is_destroyed
signal is_picked_up
signal is_thrown

@export var impact_effect : GlobalEffect.IMPACT_TYPE = GlobalEffect.IMPACT_TYPE.ZERO ## impact visual
@export var dust_threshold : float = 100.0 ## threshold after which a collision makes dust (in pix/(s kg) (impulse))
@export var impact_threshold : float = 200.0#
@export var damage_destruction_threshold : float = 2.0
@export var attract_force : float = 1000.0
var selectors = {}
var _is_reparenting = false : get = is_reparenting

@onready var holder = Global.get_current_room()
@onready var Highlighter = $Highlighter
@onready var dust_threshold2 : float = dust_threshold*dust_threshold#
@onready var impact_threshold2 : float = impact_threshold*impact_threshold#
@onready var attract_alterer = AltererAdditive.new(Vector2.ZERO)

func _ready():
	super()# call _ready() of SituBody

	self.z_as_relative = false
	self.z_index = Global.z_indices["ball_0"]
	add_to_group("balls")
	add_to_group("damageables")
	assert(holder != null)

# Warning: workaround because of https://www.reddit.com/r/godot/comments/vjkaun/reparenting_node_without_removing_it_from_tree/
func is_reparenting():
	return _is_reparenting

func get_main_color() -> Color:
	return $Visuals.col2
func get_main_gradient() -> Gradient:
	return $Visuals.gradient_main.duplicate()
func get_dash_gradient() -> Gradient:
	return $Visuals.gradient_dash.duplicate()
#func _draw():
#	# draw collision normal
#	draw_line(Vector2(0.0,0.0), Vector2(0.0,0.0)+50.0*normal_colision, color_colision)

################### SITUBODY override ###################################

func collision_effect(collider, collider_velocity, collision_point, collision_normal):
	var speed = (linear_velocity-collider_velocity).dot(collision_normal)
	if speed >= dust_threshold:
		$Visuals/DustParticle.restart()
		if speed >= impact_threshold:
			GlobalEffect.make_impact(collision_point, impact_effect, collision_normal)

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
	self.transform.origin = Vector2.ZERO
	self.z_index = holder_node.z_index+1
	on_pickup(holder_node)
	is_picked_up.emit()
	$Visuals/Reconstruction.restart()

func throw(_position, velo):
	#$TrailHandler.set_node_to_trail(self)
	#$TrailHandler.start(2.0,0.1)
	var previous_holder = holder
	change_holder(Global.get_current_room())
	assert(self.is_freeze_enabled())
	global_position = _position
	linear_velocity = velo
	self.z_index = Global.z_indices["ball_0"]
	self.enable_physics()
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

# call by the dunkdash script
func on_dunkdash_start(player: Player):
	pass
# call by the dunkdash script
func on_dunkdash_end(player: Player):
	pass

func on_destruction(): # call before changing holder, disable_physics and deleting selectors
	pass

func apply_damage(damage : float, duration : float = 0.0):
	if damage >= damage_destruction_threshold:
		destruction(0.0)

################################################################################

func power_p(player,delta):
	if holder == Global.get_current_room() :
		attract_alterer.set_value(attract_force*(player.global_position - global_position).normalized())


func power_jp(player,delta):
	if holder == Global.get_current_room() :
		add_force(attract_alterer)

func power_jr(player,delta):
	if has_force(attract_alterer) :
		remove_force(attract_alterer)
