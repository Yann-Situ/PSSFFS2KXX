@icon("res://assets/art/icons/popol.png")
extends CharacterBody2D
class_name NewPlayer

@export var movement : MovementData
## movement is modified by several nodes:
## statuslogic modify the direction_pressed variable
## movement.ambient_data is mofidied by AmbientHandler (TODO, work in progress)
## velocity is modified by the State nodes
#@export var ambient_data_floor : AmbientData ## TODO should be in the AmbientHandler
#@export var ambient_data_air : AmbientData ## TODO should be in the AmbientHandler
@export var physics_enabled : bool = true
@export var animation_player : AnimationPlayer

@export_group("DEBUG")
@export var label_state : Label # only for debug
@export var label_velocity : Label # only for debug
################################################################################

@onready var S = get_node("StateMachine/StatusLogic")
@onready var state_machine = get_node("StateMachine")
@onready var collision = get_node("Collision")
@onready var player_effects = get_node("PlayerEffects")
@onready var camera = get_node("Camera")

@onready var ball_handler = get_node("Flipper/BallHandler")
@onready var shoot_handler = get_node("Flipper/ShootHandler")
@onready var selectable_handler = get_node("Flipper/SelectableHandler")
@onready var ray_handler = get_node("Flipper/RayHandler")
#@onready var held_handler = get_node("Flipper/HeldHandler")
@onready var target_handler = get_node("Flipper/TargetHandler")
@onready var ambient_handler = get_node("Flipper/AmbientHandler")

@onready var life_handler = get_node("LifeHandler")
@onready var life_bar = get_node("UI/MarginContainer/HBoxContainer/VBoxContainer/Bar")
@onready var sprite = get_node("Flipper/Sprite2D")
@onready var flipper = get_node("Flipper")

################################################################################

@onready var start_position = global_position
@onready var foot_vector = Vector2(0,32)
@onready var collision_layer_save = 1
@onready var collision_mask_save = 514

################################################################################
var flip_h : bool = false : set = set_flip_h

func _ready():
	Global.list_of_physical_nodes.append(self)
	self.z_as_relative = false
	self.z_index = Global.z_indices["player_0"]
	sprite.z_as_relative = false
	sprite.z_index = Global.z_indices["player_0"]
	add_to_group("holders")
	add_to_group("characters")
	if !Global.playing:
		Global.toggle_playing()
	# movement.accel_alterable.add_alterer(Global.gravity_alterer)
	Global.camera = camera

	set_up_direction(Vector2.UP)
	set_floor_stop_on_slope_enabled(true)
	set_max_slides(4)
	set_floor_max_angle(0.785398)

func set_flip_h(b : bool):
	flip_h = b
#	shoot_predictor.set_flip_h(b) # TODO reuse shoot_predictor
	if b:
		flipper.scale.x = -1.0
	else:
		flipper.scale.x = 1.0

## For retro compatibility
func get_state_node()->Node:
	return get_node("StateMachine/StatusLogic") 
	# not S because S is instantiated in ready, so after every children's _ready
	
func disable_physics():
	physics_enabled = false

func enable_physics():
	physics_enabled = true

func set_start_position(_position):
	start_position = _position

func reset_position():
	global_position = start_position

################################################################################

func _process(delta):
	if Global.DEBUG and state_machine.current_state != null:
		label_state.text = state_machine.current_state.name + "\n" + str(state_machine.current_state.variation)
	update_life()
	# update_shooter()
	update_camera()
	update_target_handler()
	
func _physics_process(delta):
	if Global.DEBUG and state_machine.current_state != null:
		label_velocity.text = "("+str(movement.velocity.x).pad_decimals(1)+", "+str(movement.velocity.y).pad_decimals(1)+")"
	update_collision()
	update_ambient_data()
################################################################################
# updates of some sub nodes (mostly, handlers) whose behavior depends on S or each other

## should be called in _process()
func update_life() -> void:
	life_bar.set_life(life_handler.get_life()) # TODO : Maybe handle that with signals

## should be called in _process()
func update_shooter() -> void:
	if S.aim.ing:
		shoot_handler.update_screen_viewer_position()
	else :
		shoot_handler.disable_screen_viewer()

## should be called in _process()
func update_camera() -> void:
	# CAMERA:
	# TODO : change this whole part because it's messy
	if Global.is_cinematic_playing():
		return
	if S.aim.ing:
		pass
#		var shoot = Vector2.ZERO
#		var target = (camera.get_global_mouse_position() - global_position)
#		shoot_handler.update_target(target)
#		if shoot_handler.can_shoot_to_target():
#			shoot_handler.update_effective_can_shoot(0.0,0)
#			shoot = shoot_handler.effective_v
#		else :
#			shoot_handler.update_effective_cant_shoot(0.0,0)
#			shoot = shoot_handler.effective_v
#
#		shoot_predictor.draw_prediction(Vector2.ZERO, shoot,
#			(shoot_handler.global_gravity_scale_TODO*Global.default_gravity.y)*Vector2.DOWN)
#		camera.set_offset_from_aim(target)
#		if shoot.x > 0 :
#			S.aim_direction = 1
#		else :
#			S.aim_direction = -1
	elif S.crouch.ing :
		camera.set_offset_x_from_velocity(movement.velocity.x, 0.4)
		camera.set_offset_y_from_crouch(0.2)
	else :
		camera.set_offset_x_from_velocity(movement.velocity.x, 0.4)
		camera.set_offset_y_from_velocity(movement.velocity.y, 0.4)

## update the SelectorTargets depending on S and using the selectables from selectable_handler.
## should be called in _process()
func update_target_handler() -> void:
	if S.dunkjump.can:
		target_handler.update_selection(Selectable.SelectionType.JUMP, selectable_handler.selectable_dunkjump)
	else:
		target_handler.update_selection(Selectable.SelectionType.JUMP, null)

	if S.dunkdash.can:
		target_handler.update_selection(Selectable.SelectionType.DASH, selectable_handler.selectable_dunkdash)
	else:
		target_handler.update_selection(Selectable.SelectionType.DASH, null)
	# target_handler.update_selection(Selectable.SelectionType.SHOOT, selectable_handler.selectable_shoot)

## TODO maybe this should be handled by State nodes.
## should be called in _physics_process()
func update_collision() -> void:
	# HITBOX:
	if S.crouch.ing or not S.stand.can:
		collision.shape.set_size(Vector2(17,31))
		collision.position.y = 16.5
	else :
		collision.shape.set_size(Vector2(17,57))
		collision.position.y = 3.5
		
## update movement.ambient_data depending on logic and AmbientHandler.
## This should be called in physics_process.
func update_ambient_data() -> void:
	if ambient_handler.has_ambient():
		movement.ambient = ambient_handler.ambient_data
	else:
		if S.floor.ing:
			movement.ambient = ambient_handler.ambient_data_floor
		elif S.wall.ing:
			movement.ambient = ambient_handler.ambient_data_wall
		else:
			movement.ambient = ambient_handler.ambient_data_air

################################################################################
# For physicbody

func add_impulse(impulse : Vector2):
	movement.velocity += movement.invmass * impulse

func has_force(force_alterer : Alterer):
	return movement.force_alterable.has_alterer(force_alterer)
func add_force(force_alterer : Alterer):
	movement.force_alterable.add_alterer(force_alterer)
func remove_force(force_alterer : Alterer):
	movement.force_alterable.remove_alterer(force_alterer)

func has_accel(accel_alterer : Alterer):
	return movement.accel_alterable.has_alterer(accel_alterer)
func add_accel(accel_alterer : Alterer):
	movement.accel_alterable.add_alterer(accel_alterer)
func remove_accel(accel_alterer : Alterer):
	movement.accel_alterable.remove_alterer(accel_alterer)

func has_speed(speed_alterer : Alterer):
	return movement.speed_alterable.has_alterer(speed_alterer)
func add_speed(speed_alterer : Alterer):
	movement.speed_alterable.add_alterer(speed_alterer)
func remove_speed(speed_alterer : Alterer):
	movement.speed_alterable.remove_alterer(speed_alterer)

################################################################################
# For `characters` group
## TODO: change to put character_holder in S (status_logic node)
## Rework all of this with the new state_system
# my idea is to create a "held" state that will call the functions of a state
# that is linked by the character holder.
# Example: player enter the condition for a trail -> trail is a character
# holder and has a variable "State", which corresponds to the grind state ->
# trail is set to be the character holder and the state machine goes to state
# "held", which will call the functions of the "State" of the character holder.
# The player get_out of the holder when exitting the state.

# func is_hold() -> bool:
# 	return character_holder != null
#
# func get_in(new_holder : Node):
# 	if not new_holder.is_in_group("characterholders"):
# 		printerr("new_holder ("+new_holder.name+") is not in group `characterholders`.")
# 	if is_hold():
# 		character_holder.free_character(self)
# 	self.disable_physics()
# 	character_holder = new_holder
#
# func get_out(out_global_position : Vector2, _velocity : Vector2):
# 	self.enable_physics()
# 	global_position = out_global_position
# 	S.set_velocity_safe(_velocity)
# 	if is_hold():
# 		character_holder.free_character(self)
# 	character_holder = null

################################################################################
# For `holders` group
func free_ball(ball : Ball):
	# set out  active_ball and has_ball
	ball_handler.free_ball(ball)

################################################################################
# For ball selection
func select_ball(ball : Ball):
	ball_handler.select_ball(ball)
func deselect_ball(ball : Ball):
	ball_handler.deselect_ball(ball)
