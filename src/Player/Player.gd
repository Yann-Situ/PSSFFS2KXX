extends KinematicBody2D

onready var S = get_node("Player_State")

#balls
const Ball = preload("res://src/Ball/Ball.tscn")

# Environment features (should be given by the map)
export (float) var gravity = ProjectSettings.get_setting("physics/2d/default_gravity") # pix/s²
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
export (float) var max_speed_fall_onwall = 200
export (Vector2) var vecjump = Vector2(0.65, -1)

# Walk and run features
export (float) var run_speed_thresh = 350 # pix/s
export (float) var run_speed_max = 400 # pix/s
export (float) var walk_instant_speed = 150 # pix/s
export (float) var walk_return_thresh_instant_speed = walk_instant_speed*1.5 # pix/s
export (float) var walk_accel = 220 # pix/s²

export (bool) var flip_h = false
#export var snap_vector_save = Vector2(0,1)
#var snap_vector =

func set_flip_h(b):
	flip_h  = b
	$Sprite.set_flip_h(b)
	$Shoot_predictor.set_flip_h(b)	
	$Special_Action_Handler.set_flip_h(b)

func get_input(delta):
	############### Change variables of Player_state.gd
	#S.update_vars(delta*1000, is_on_floor(), is_on_wall(), (abs(S.velocity.x) > run_speed_thresh))
	S.update_vars(delta*1000, is_on_floor(), is_on_wall() and $Special_Action_Handler.is_on_wall(), (abs(S.velocity.x) > run_speed_thresh))
	if S.is_onfloor :
		S.last_onfloor = S.time
	else :
		S.last_onair = S.time
	if S.is_onwall :
		S.last_onwall = S.time
		S.last_wall_normal_direction = -1#sign(get_slide_collision(get_slide_count()-1).normal.x)
		if $Sprite.flip_h:
			S.last_wall_normal_direction = 1

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
	elif S.jump_jr and (S.is_jumping or S.is_walljumping) :
		S.velocity.y = S.velocity.y/3.5

	if S.crouch_p and S.can_crouch :
		move_crouch(delta)
	else :
		S.is_crouching = false # \todo verify if we can stand (maybe rays or is_on_ceil)

	if S.dunk_p and S.can_dunk :
		move_dunk(delta)
	else :
		S.is_dunking = false # \todo verify if we can stand (maybe rays or is_on_ceil)

	if S.shoot_jr and S.can_shoot :
		print("shoot")
		move_shoot(delta)

	if S.aim_jp and S.can_aim :
		print("aim")
		move_aim(delta)

	if S.can_go :
		move_adherence(delta)

	############### Misc and Animation handling
	
	#shader :
	#$Sprite.material.set("shader_param/speed",S.velocity)
	
	if S.is_aiming:
		var shoot = $Shoot_predictor.shoot_vector()
		$Shoot_predictor.draw($Ball_Handler.get_throw_position()-self.position, shoot+0.5*S.velocity,
				S.active_ball.get_gravity_scale()*Vector2(0,gravity))
		$Camera.set_offset_from_type("aim",shoot.normalized())
		if shoot.x > 0 :
			S.aim_direction = 1
		else :
			S.aim_direction = -1
	else :
		$Camera.set_offset_from_type("normal")

	$Sprite/AnimationTree.animate_from_state(S)
	#$Sprite/Player_Animation.animate_from_state(S)
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
	S.is_walljumping = true
	S.last_walljump = S.time

func move_crouch(delta):# TODO
	# Change hitbox + other animation things like sliding etc.
	S.is_aiming = false # cancel aiming for the moment
	S.aim_direction = 0
	$Shoot_predictor.clear()
	S.is_crouching = true

func move_dunk(delta):# TODO
	# Change hitbox + other animation things like sliding etc.
	S.is_aiming = false # cancel aiming for the moment
	S.aim_direction = 0
	$Shoot_predictor.clear()
	S.is_dunking = true
	self.get_node("Camera").screen_shake(0.1,6)

func move_aim(delta):
	S.is_aiming = true
	S.last_aim_jp = S.time
	#Engine.time_scale = 0.5

func move_shoot(delta):
	S.is_aiming = false
	S.aim_direction = 0
	S.is_shooting = true
	S.last_shoot = S.time
	$Shoot_predictor.shoot_vector_save = $Shoot_predictor.shoot_vector()
	#Engine.time_scale = 1.0
	$Shoot_predictor.clear()	
	#throw_ball()+free_ball in Ball_handler	called by animation

func move_adherence(delta):
	var friction = 0 #get adh from environment
	if S.is_onfloor:
		friction = floor_friction
	else : #in the air
		friction = air_friction
	if S.move_direction != S.direction_p: # if not moving in the same dir as input
		S.velocity.x = lerp(S.velocity.x, 0, friction)

func _physics_process(delta):
	get_input(delta)
	if S.is_onwall and S.velocity.y > 0: #fall on a wall
		S.velocity.y += gravity/2.0 * delta
		S.velocity.y = min(S.velocity.y,max_speed_fall_onwall)
	else:
		S.velocity.y += gravity * delta
	S.velocity = move_and_slide(S.velocity, Vector2(0, -1), true, 4, 0.9)
