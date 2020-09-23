extends KinematicBody2D

onready var S = get_node("Player_State")

#balls
const Ball = preload("res://src/Ball/Ball.tscn")


# Environment features (should be given by the map)
export (float) var gravity = 625 # pix/s²
export (float) var floor_friction = 0.2 # %/frame
export (float) var air_friction = 0.1 # %/frame

# Crouch features
export (float) var crouch_speed_max = 200 # pix/s
export (float) var crouch_accel = 150 # pix/s²

# Aerial features
export (float) var sideaerial_speed_max = 400 # pix/s
export (float) var air_instant_speed = 60 # pix/s
export (float) var air_return_thresh_instant_speed = air_instant_speed*0.5 # pix/s
export (float) var sideaerial_accel = 220 # pix/s²
export (float) var jump_speed = -450 # pix/s
export (Vector2) var vecjump = Vector2(0.65, -1)

# Walk and run features
export (float) var run_speed_thresh = 350 # pix/s
export (float) var run_speed_max = 400 # pix/s
export (float) var walk_instant_speed = 150 # pix/s
export (float) var walk_return_thresh_instant_speed = walk_instant_speed*1.5 # pix/s
export (float) var walk_accel = 220 # pix/s²

# Shoot features
export (float) var shoot_min_speed = 100 # pix/s
export (float) var shoot_max_speed = 600 # pix/s
export (float) var shoot_max_aim_time = 1000 # ms
var shoot_vector_save = Vector2(0,0)

#export var snap_vector_save = Vector2(0,1)
#var snap_vector = 

func get_input(delta):
	############### Change variables of Player_state.gd
	S.is_onfloor = is_on_floor()
	S.is_onwall = is_on_wall()
	S.is_moving_fast = (abs(S.velocity.x) > run_speed_thresh)
	S.update_vars(delta*1000)
	if S.is_onfloor :
		S.last_onfloor = S.time
	if S.is_onwall :
		S.last_onwall = S.time
		S.last_wall_normal_direction = sign(get_slide_collision(get_slide_count()-1).normal.x)
		
	############### Move from input
	if (S.direction_p != 0) and S.can_go :
		move_side(S.direction_p,delta)
		
	if S.jump_jp :
		if S.can_jump :
			print("jump")
			move_jump(delta)
		elif S.can_walljump :
			print("walljump")
			print(S.last_wall_normal_direction)
			move_walljump(S.last_wall_normal_direction,delta)
	elif S.jump_jr and S.is_jumping : 
		S.velocity.y = S.velocity.y/3.5
		
	if S.crouch_p and S.can_crouch :
		move_crouch(delta)
	else :
		S.is_crouching = false # \todo verify if we can stand (maybe rays or is_on_ceil)
	
	if S.shoot_jr and S.can_shoot :
		print("shoot")
		move_shoot(delta)
	
	if S.aim_jp and S.can_aim :
		print("aim")
		move_aim(delta)
	
	if S.can_go :
		move_adherence(delta)
	
	############### Misc and Animation handling

	if S.is_aiming:
		var shoot = shoot_vector()
		$Shoot_predictor.draw(Vector2(0.0,0.0), shoot+S.velocity, Vector2(0,625))
		if shoot.x > 0 :
			S.aim_direction = 1
		else :
			S.aim_direction = -1
			
	$Sprite/Player_Animation.animate_from_state(S)
	if S.has_ball and S.active_ball != null and not S.active_ball.physics_enabled:
		set_has_ball_position()
	if false : #COLOR INFORMATION
#		if S.is_aiming:
#			$Polygon2D.color = Color(1,0,0)
#		elif S.is_onfloor:
#			if S.is_moving_fast[0] or S.is_moving_fast[1] :
#				$Polygon2D.color = Color(1,1,0.6)
#			elif S.is_moving :
#				$Polygon2D.color = Color(0.8,0.8,0.3)
#			else :
#				$Polygon2D.color = Color(0.5,0.5,0)
#		elif S.is_onwall:
#			$Polygon2D.color = Color(0,1,1)
#		elif S.is_mounting:
#			$Polygon2D.color = Color(0,0,1)
#		elif S.is_falling:
#			$Polygon2D.color = Color(0.5,0.5,1)
#		elif S.is_crouching:
#			$Polygon2D.color = Color(0.5,0.5,0)
#		else :
#			$Polygon2D.color = Color(1,1,1)
		pass

####################################### Utilities
func move_side(direction,delta):
	if S.is_onfloor :
		if S.is_crouching :
			if (S.velocity.x*direction > crouch_speed_max) : 
				pass # in the same direction as velocity and faster than max
			else :
				S.velocity.x += direction*crouch_accel*delta
				if (S.velocity.x*direction > crouch_speed_max) : 
					S.velocity.x = direction*crouch_speed_max
		else : #standing on the floor, maybe moving
			if (S.velocity.x*direction >= run_speed_max) : 
				pass # in the same direction as velocity and faster than max
			else :
				S.velocity.x += direction*walk_accel*delta
				if (S.velocity.x*direction > run_speed_max) : 
					S.velocity.x = direction*run_speed_max
					
			if -walk_return_thresh_instant_speed < S.velocity.x*direction and S.velocity.x*direction < walk_instant_speed :
				S.velocity.x = direction*walk_instant_speed
	else : # is in the air
		if (S.velocity.x*direction >= sideaerial_speed_max) : 
			pass
		else :
			S.velocity.x += direction * sideaerial_accel * delta
			if (S.velocity.x*direction > sideaerial_speed_max) : 
				S.velocity.x = direction * sideaerial_speed_max
		if -air_return_thresh_instant_speed < S.velocity.x*direction and S.velocity.x*direction < air_instant_speed :
				S.velocity.x = direction*air_instant_speed

func move_jump(delta):
	S.velocity.y = jump_speed
	S.is_jumping = true
	S.last_jump = S.time

func move_walljump(direction,delta):
	S.velocity.x = -vecjump.x * direction * jump_speed
	S.velocity.y = -vecjump.y * jump_speed
	S.is_jumping = true
	S.last_walljump = S.time
	
func move_crouch(delta):# TODO
	# Change hitbox + other animation things like sliding etc.
	S.is_crouching = true

func move_aim(delta):
	S.is_aiming = true
	S.last_aim_jp = S.time
	#Engine.time_scale = 0.5
	
func move_shoot(delta):
	S.is_aiming = false
	S.aim_direction = 0
	S.is_shooting = true
	S.last_shoot = S.time
	shoot_vector_save = shoot_vector()
	#Engine.time_scale = 1.0
	$Shoot_predictor.clear()
	#throw_ball()	#done by animation
	
func move_adherence(delta):
	var friction = 0 #get adh from environment
	if S.is_onfloor:
		friction = floor_friction
	else : #in the air
		friction = air_friction
	if S.move_direction != S.direction_p: # if not moving in the same dir as input
		S.velocity.x = lerp(S.velocity.x, 0, friction)
		
func shoot_vector(): # return shoot vector if player not moving
	var t = S.time-S.last_aim_jp
	t = min(shoot_max_aim_time, t)/shoot_max_aim_time
	t = shoot_min_speed+t*(shoot_max_speed-shoot_min_speed)
	return t * ($Camera.get_global_mouse_position() - position).normalized()

func throw_ball(): # called by animation
	#var new_ball = Ball.instance()
	#new_ball.position = position
	#new_ball.set_linear_velocity(shoot_vector_save + 0.8*S.velocity)
	#get_parent().add_child(new_ball)
	if S.has_ball and S.active_ball != null :
		set_has_ball_position()
		S.active_ball.enable_physics()
		S.active_ball.set_linear_velocity(shoot_vector_save + 0.8*S.velocity)
		print("throw ball at "+str(S.active_ball.position.x)+" vs "+str(position.x))
		
func set_has_ball_position():
	#if $Sprite.flip_h :
	#	S.active_ball.position.x = position.x - $Ball_Pickup/Has_Ball_Position.position.x
	#	S.active_ball.position.y = position.y + $Ball_Pickup/Has_Ball_Position.position.y
	#else :
	#	S.active_ball.set_position(position + $Ball_Pickup/Has_Ball_Position.position)
	if $Sprite.flip_h :
		S.active_ball.transform.origin.x = position.x - $Ball_Pickup/Has_Ball_Position.position.x
		S.active_ball.transform.origin.y = position.y + $Ball_Pickup/Has_Ball_Position.position.y
	else :
		S.active_ball.transform.origin = position + $Ball_Pickup/Has_Ball_Position.position

func _physics_process(delta):
	get_input(delta)
	S.velocity.y += gravity * delta
	S.velocity = move_and_slide(S.velocity, Vector2(0, -1), true, 4, 0.9)
