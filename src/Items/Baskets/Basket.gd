extends Node2D
class_name Basket
# @icon("res://assets/art/icons/basket.png")

signal is_dunked
signal is_goaled

@export var speed_ball_threshold = 380 #velocity value
@export var dunk_position_offset = 16 * Vector2.DOWN
@export var dunk_position_radius = 24
@export var hang_position_offset_y = 16
@export var can_receive_dunk = true
@export var can_receive_dunkjump = true
@export var can_receive_goal = true
@export var can_receive_hang = true

@export var dunk_cooldown = 0.75#s
@export var dunk_free_character_cooldown = 0.4#s

var inside_bodies = []
var bodies_positions = []
var distortion_scene = preload("res://src/Effects/Distortion.tscn")
var tween_light : Tween

@onready var start_position = global_position

# Should be in any items that can be picked/placed :
func set_start_position(_position):
	start_position = _position
	global_position = _position

func _ready():
	self.z_index = Global.z_indices["foreground_1"]
	add_to_group("characterholders")

func _draw():
	pass
	#draw_line(position+$basket_area/CollisionShape2D.shape.a, position+$basket_area/CollisionShape2D.shape.b, color2)

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	queue_redraw()
func _physics_process(delta):
	var j = 0 # int because we're deleting nodes in a list we're browsing
	for i in range(inside_bodies.size()):
		var body = inside_bodies[i-j]
		if !body.S.is_hanging:
			body.get_out(body.global_position, Vector2.ZERO)
			j += 1
		else :
			body.global_position = bodies_positions[i-j]

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
	print_debug("DUUUNK!")
	if ball != null:
		goal_effects(ball, 3)
	else :
		Global.camera.screen_shake(0.3,8)

	if (dunker.global_position.x - global_position.x) > 0:
		$AnimationPlayer.play("dunk_right")
	else :
		$AnimationPlayer.play("dunk_left")

	$DunkCooldown.stop()
	can_receive_dunk = false
	$DunkCooldown.start(dunk_cooldown)
	is_dunked.emit()


func get_hanged(character : Node):
	if !character.has_node("Actions/Hang"):
		printerr(character.name + " doesn't have a node called Actions/Hang")
		return 1
	if !character.S.can_hang:
		print(character.name+" cannot hang on "+self.name)
		return 1
	pickup_character(character)

func goal(ball : Ball, score):
	print("GOOOAL!")
	if score > speed_ball_threshold:
		goal_effects(ball, 2)
	else :
		goal_effects(ball, 1)
	is_goaled.emit()

func goal_effects(ball : Ball, force : int = 0):
	$Effects/LineParticle.amount = force * 16
	$Effects/LineParticle.process_material.initial_velocity = -40 + force * 80
	$Effects/LineParticle.process_material.color_ramp.gradient = ball.get_main_gradient()
	$Effects/LineParticle.restart()
	if force > 1:
		Global.camera.screen_shake(0.3,5.0+(force-2)*20.0)
	if force > 2:
		GlobalEffect.make_distortion(self.global_position, 0.75, "fast_subtle")

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
# For `characterholders` group
func pickup_character(character : Node):
	character.get_in(self)
	print(character.name+" on "+self.name)
	inside_bodies.push_back(character)
	bodies_positions.push_back(Vector2(character.global_position.x, \
		self.global_position.y+hang_position_offset_y))

	character.get_node("Actions/Hang").move(0.01)

	$DunkCooldown.stop()
	can_receive_dunk = false

func free_character(character : Node):
	# called by character when getting out
	var i = 0
	for body in inside_bodies:
		if body == character:
			print(name+" free_character("+character.name+")")
			if character.has_node("Actions/Hang"):
				character.get_node("Actions/Hang").move_stop()
			else :
				printerr(body.name + " doesn't have a node called Actions/Hang")
			remove_body(i)
		i += 1
	$DunkCooldown.stop()
	can_receive_dunk = false
	$DunkCooldown.start(dunk_free_character_cooldown)

func _on_DunkCooldown_timeout():
	can_receive_dunk = true

func remove_body(i : int):
	assert(i < inside_bodies.size())
	inside_bodies.remove_at(i)
	bodies_positions.remove_at(i)

################################################################################

func set_selection(type : int, value : bool):
	if $basket_area.selected:
		enable_contour()
	else:
		disable_contour()

func enable_contour():
	var light = $LightSmall
	if tween_light:
		tween_light.kill()
	tween_light = self.create_tween()
	tween_light.tween_property(light, "energy", 0.8, 0.15).set_ease(Tween.EASE_OUT)


func disable_contour():
	var light = $LightSmall
	if tween_light:
		tween_light.kill()
	tween_light = self.create_tween()
	tween_light.tween_property(light, "energy", 0.0, 0.15).set_ease(Tween.EASE_OUT)
