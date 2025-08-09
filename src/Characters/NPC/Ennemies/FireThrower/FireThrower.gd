extends CharacterBody2D

@export var max_balls : int = 3 : set = set_max_balls
@export var throw_speed : float = 400 ##pix/s

var positioner_count : int = 0 ## cyclic counter %max_balls
var positioners : Array[RemoteTransform2D]
var ball_to_positioner_count : Dictionary

@export var flipper : Marker2D
@export var holder : BallHolder
@export var spawning_timer : Timer

var fire_ball_scene : PackedScene = preload("res://src/Items/Balls/BallFire.tscn")

func _ready():
	add_to_group("holders")
	assert(is_instance_valid(flipper))
	assert(is_instance_valid(holder))
	assert(is_instance_valid(spawning_timer))
	for i in range(max_balls):
		var positioner : RemoteTransform2D = RemoteTransform2D.new()
		$BallPositioners.add_child(positioner)
		positioner.update_rotation = false
		positioner.position = 24.0*Vector2.from_angle(i*2*PI/max_balls)
		positioners.append(positioner)
	
func set_max_balls(n : int):
	max_balls = n
	holder.max_ball = n

func has_ball() -> bool:
	return holder.is_holding()

func get_ball(i : int = 0) -> Ball:
	if has_ball():
		return holder.get_held_ball(i)
	return null

func spawn_balls():
	for i in range(max_balls):
		spawn_ball()
func spawn_ball():
	if holder.can_hold():
		var ball = fire_ball_scene.instantiate()
		Global.get_current_room().add_child(ball)
		if ball.pick(holder):
			positioners[positioner_count].remote_path = ball.get_path() 
			ball_to_positioner_count[ball] = positioner_count
			positioner_count = (positioner_count+1)%max_balls
	else :
		push_warning("spawn_ball but holder.can_hold() returned false")

func throw_ball(throw_global_position : Vector2, speed : Vector2) -> bool:
	if !has_ball():
		printerr("throw_ball but ball_handler.has_ball() is false")
		return false
	var ball : Ball = get_ball()
	var ball_positioner_count = ball_to_positioner_count[ball]
	ball.throw(positioners[ball_positioner_count].global_position, speed)
	positioners[ball_positioner_count].remote_path = NodePath("")
	ball_to_positioner_count.erase(ball)
	ball.add_collision_exception_with(self)
	Global.one_shot_call(ball.remove_collision_exception_with.bind(self), 0.4)
	if !has_ball():
		spawning_timer.start()
	return true

func set_flipper(b):
	if b<0:
		flipper.scale.x = -1.0
	elif b>0:
		flipper.scale.x = 1.0

func _on_player_detector_body_entered(body: Node2D) -> void:
	#$Flipper/Sprite2D/AnimationPlayer.play("exclamation")
	#$Flipper/Sprite2D/AnimationPlayer.queue("idle")
	#print("-----DETECT")
	pass

func player_is_detected() -> bool:
	return Global.get_current_player() in $Flipper/PlayerDetector.get_overlapping_bodies()
