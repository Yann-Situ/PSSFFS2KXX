extends Node2D
class_name NewBasket
# @icon("res://assets/art/icons/basket.png")

signal is_dunked
signal is_goaled

@export var speed_ball_threshold = 380 ## speed threshold for power goal
@export var character_offset : Vector2 = Vector2(0.0, 0.0) ## character offset for hanging
@export var dunk_position_offset = 16 * Vector2.DOWN ## offset for the dunk position (different from hanging position)
@export var dunk_position_radius = 24 ## maximum horizontal radius for dunk position
#@export var hang_position_offset_y = 16 ## vertical offset for hanging # TODO

@export_group("cooldowns")
@export var dunk_cooldown = 0.75 ## between two consecutive dunks
@export var dunk_free_character_cooldown = 0.5 ## after a character left the basket

@export_group("can_receive_* booleans", "can_receive_")
@export var can_receive_dunk = true : set = set_can_receive_dunk
@export var can_receive_dunkjump = true
@export var can_receive_goal = true
@export var can_receive_hang = true : set = set_can_receive_hang

@onready var character_holder : CharacterHolder = $CharacterHolder
@onready var basket_area : Selectable = $BasketArea
var dunk_cooldown_timer : Timer

var character_offsets = {} ## belong_handler current offset
var character_dunk_positions = {} ## belong_handler dunk position (relative to dunk.global_position)

func set_can_receive_hang(b):
	can_receive_hang = b
	#if character_holder == null:
		#printerr("character_holder is null")
		#return
	character_holder.can_hold = can_receive_hang

func set_can_receive_dunk(b):
	can_receive_dunk = b
	basket_area.is_dunk_selectable = can_receive_dunk
	#print(" --- receivedunk "+str(b))

func _ready():
	self.z_index = Global.z_indices["foreground_1"]
	add_to_group("characterholders")
	assert(character_holder != null)
	assert(basket_area != null)
	character_holder.getting_in.connect(_on_character_holder_getting_in)
	character_holder.getting_out.connect(_on_character_holder_getting_out)
	character_holder.processing_character.connect(_on_character_holder_processing_character)
	character_holder.physics_processing_character.connect(_on_character_holder_physics_processing_character)

	dunk_cooldown_timer = Timer.new()
	dunk_cooldown_timer.autostart = false
	dunk_cooldown_timer.one_shot = true
	dunk_cooldown_timer.timeout.connect(_on_DunkCooldown_timeout)
	add_child(dunk_cooldown_timer)

# func _draw():
# 	pass
	#draw_line(position+$basket_area/CollisionShape2D.shape.a, position+$basket_area/CollisionShape2D.shape.b, color2)

func _on_basket_area_body_entered(body):
	#print("basket :"+body.name)
	if body.is_in_group("balls"):
		if body.is_reparenting():
			print(" - basket "+body.name+" is ignored because reparenting")
			return # Workaround because of https://www.reddit.com/r/godot/comments/vjkaun/reparenting_node_without_removing_it_from_tree/
		var dunk_dir = Vector2.DOWN.rotated(global_rotation)
		var score = body.linear_velocity.dot(dunk_dir)
		if score > 0.0:
			goal(body,score)

func dunk(dunker : Node2D, ball : Ball = null):
	if not can_receive_dunk:
		push_warning("can_receive_dunk is false but basket.dunk() was called.")
		return
	print_debug(self.name + "dunk! with dunker "+dunker.name)
	if ball != null:
		goal_effects(ball, 3)
		## WARNING the call to on_dunk has been moved to this script, it is now supposed
		## to be called at the moment of the dunk impact. It used to be called by the
		## player Dunk node at the beginning of the player's dunk animation
		ball.on_dunk(self)
	else :
		Global.camera.screen_shake(0.3,8)

	if (dunker.global_position.x - global_position.x) > 0:
		$AnimationPlayer.play("dunk_right")
	else :
		$AnimationPlayer.play("dunk_left")

	can_receive_dunk = false
	dunk_cooldown_timer.start(dunk_cooldown) # restart timer
	is_dunked.emit()

func goal(ball : Ball, score):
	print_debug(self.name + "goal! with ball "+ball.name)
	if score > speed_ball_threshold:
		goal_effects(ball, 2)
	else :
		goal_effects(ball, 1)
	ball.on_goal()
	is_goaled.emit()

func goal_effects(ball : Ball, force : int = 0):
	$Effects/LineParticle.amount = force * 16
	$Effects/LineParticle.process_material.initial_velocity_min = -60.0 + force * 80.0
	$Effects/LineParticle.process_material.initial_velocity_max = -20.0 + force * 80.0
	$Effects/LineParticle.process_material.color_ramp.gradient = ball.get_main_gradient()
	$Effects/LineParticle.restart()
	if force > 1:
		Global.camera.screen_shake(0.3,5.0+(force-2)*20.0)
	if force > 2:
		GlobalEffect.make_distortion(self.global_position, 0.75, "fast_subtle")

################################################################################

func get_closest_point(point_global_position : Vector2):
	var p = point_global_position - self.global_position
	var basket_dir = Vector2.RIGHT.rotated(global_rotation)
	var d = p.dot(basket_dir)
	if abs(d) >= dunk_position_radius:
		return self.global_position + sign(d) * dunk_position_radius * basket_dir
	return self.global_position + d * basket_dir

func get_dunk_position(player_global_position : Vector2):
	return get_closest_point(player_global_position) + dunk_position_offset

################################################################################
## For `characterholders` group
## functions are connected to character_holder signals in _ready()

func _on_character_holder_getting_in(belong_handler : BelongHandler):
	print(belong_handler.character.name+" on "+self.name)
	# bodies_positions.push_back(Vector2(character.global_position.x, \
	#     self.global_position.y+hang_position_offset_y))
	
	# /!\ important, the timer is probably already running because it was by the
	# dunk function. The following line prevent an additional call to _on_DunkCooldown_timeout() 
	dunk_cooldown_timer.stop()
	can_receive_dunk = false
	
	var character = belong_handler.character
	character_dunk_positions[belong_handler] = \
		get_dunk_position(character.global_position)-self.global_position
	character_offsets[belong_handler] = character.global_position-global_position-\
		character_dunk_positions[belong_handler]


func _on_character_holder_getting_out(belong_handler : BelongHandler):
	# when getting out
	print(belong_handler.character.name+" out "+self.name)

	can_receive_dunk = false
	dunk_cooldown_timer.start(dunk_free_character_cooldown)  # restart timer

## should update position and velocity (like move and slide)
func _on_character_holder_physics_processing_character(belong_handler : BelongHandler, delta):
	var character = belong_handler.character
	assert("velocity" in character)
	character.set_velocity(Vector2.ZERO)
	# just zero velocity
	
	var offset = character_offsets[belong_handler]
	offset = lerp(offset, character_offset, 0.1)
	character.global_position = self.global_position +\
		character_dunk_positions[belong_handler] + offset
	character_offsets[belong_handler] = offset

func _on_character_holder_processing_character(belong_handler : BelongHandler, delta):
	pass

func _on_DunkCooldown_timeout():
	can_receive_dunk = true

################################################################################

func set_selection(type : int, value : bool):
	pass # TODO
