extends KinematicBody2D
class_name Player, "res://assets/art/icons/popol.png"

onready var S = get_node("Player_State")
onready var SpecialActionHandler = get_node("Actions/Special_Action_Handler")
onready var ShootPredictor = get_node("Actions/Shoot_predictor")

export (bool) var physics_enabled = true

# Environment features (should be given by the map)
export (float) var gravity = ProjectSettings.get_setting("physics/2d/default_gravity") # pix/s²
export (float) var floor_friction = 0.2 # ratio/frame
export (float) var air_friction = 0.0 # ratio/frame
export (float) var attract_force = 800 # m.pix/s²

# Crouch features
export (float) var crouch_speed_max = 300 # pix/s
export (float) var crouch_instant_speed = 60 # pix/s
export (float) var crouch_return_thresh_instant_speed = 100 # pix/s
export (float) var crouch_accel = 200 # pix/s²
export (float) var landing_velocity_thresh = 400 # pix/s

# Aerial features
export (float) var sideaerial_speed_max = 400 # pix/s
export (float) var air_instant_speed = 60 # pix/s
export (float) var air_return_thresh_instant_speed = 50 # pix/s
export (float) var sideaerial_accel = 220 # pix/s²
export (float) var jump_speed = -425 # pix/s
export (float) var dunk_speed = -500 # pix/s
export (float) var max_speed_fall = 800 # pix/s
export (float) var max_speed_fall_onwall = 200 # pix/s
export (Vector2) var vecjump = Vector2(0.65, -1)

# Walk and run features
export (float) var run_speed_thresh = 350 # pix/s
export (float) var run_speed_max = 400 # pix/s
export (float) var walk_instant_speed = 150 # pix/s
export (float) var walk_return_thresh_instant_speed = 300 # pix/s
export (float) var walk_accel = 220 # pix/s²

export (bool) var flip_h = false

func disable_physics():
	physics_enabled = false
	S.velocity *= 0
	#S.applied_force *= 0

func enable_physics():
	physics_enabled = true

func _ready():
	if !Global.playing:
		Global.toggle_playing()
	Global.camera = $Camera

func set_flip_h(b):
	flip_h  = b
	$Sprite.set_flip_h(b)
	ShootPredictor.set_flip_h(b)
	SpecialActionHandler.set_flip_h(b)

func get_input(delta): #delta in s
	############### Change variables of Player_state.gd
	S.update_vars(delta, is_on_floor(), is_on_wall() and SpecialActionHandler.is_on_wall(), (abs(S.velocity.x) > run_speed_thresh))
	if S.is_onfloor :
		S.get_node("ToleranceJumpFloorTimer").start(S.tolerance_jump_floor)
	else :
		S.last_onair_velocity_y = S.velocity.y
	if S.is_onwall :
		S.get_node("ToleranceWallJumpTimer").start(S.tolerance_wall_jump)
		S.last_wall_normal_direction = -1#sign(get_slide_collision(get_slide_count()-1).normal.x)
		if $Sprite.flip_h:
			S.last_wall_normal_direction = 1

	############### Move from input
	if (S.direction_p != 0) and S.can_go :
		move_side(S.direction_p,delta)

	if not S.get_node("ToleranceJumpPressTimer").is_stopped() :
		if S.can_jump :
			move_jump(delta)
			if not S.jump_p:
				S.velocity.y = S.velocity.y/3.5
		elif S.can_walljump :
			move_walljump(S.last_wall_normal_direction,delta)
			if not S.jump_p:
				S.velocity.y = S.velocity.y/3.5
	if S.jump_jr and (S.is_jumping or S.is_walljumping) and not S.is_dunkjumping:
		S.velocity.y = S.velocity.y/3.5

	if S.crouch_p and S.can_crouch :
		move_crouch(delta)
	else :
		if S.can_stand:
			S.is_crouching = false # \todo verify if we can stand (maybe rays or is_on_ceil)

	if S.can_dunk :
			move_dunk(delta)
	if S.dunk_p and S.can_dunkjump :
			move_dunkjump(delta)

	if S.shoot_jr and S.can_shoot :
		#print("shoot")
		move_shoot(delta)

	if S.aim_jp and S.can_aim :
		#print("aim")
		move_aim(delta)

	if S.can_go :
		move_adherence(delta)
		
	if S.selected_ball != null:
		if S.power_p :
			S.selected_ball.power_p(self,delta)
		if S.power_jp :
			S.selected_ball.power_jp(self,delta)
		elif S.power_jr :
			S.selected_ball.power_jr(self,delta)
	
	if S.select_jp and Global.mouse_ball != null :
		move_select_ball(delta)
		
	############### Misc and Animation handling
	
	#shader :
	#$Sprite.material.set("shader_param/speed",S.velocity)
	
	if S.is_crouching or S.is_landing or not S.can_stand:
		$Collision.shape.set_extents(Vector2(8,22))
		$Collision.position.y = 10
	else :
		$Collision.shape.set_extents(Vector2(8,26))
		$Collision.position.y = 6
	
	if S.is_aiming:
		var shoot = ShootPredictor.shoot_vector()
		if S.power_p and S.selected_ball == S.active_ball :
			ShootPredictor.draw_attract($Ball_Handler.get_throw_position()-self.position, shoot+0.5*S.velocity,
				S.active_ball.get_gravity_scale()*Vector2(0,gravity), attract_force/S.active_ball.mass)
		else :
			ShootPredictor.draw($Ball_Handler.get_throw_position()-self.position, shoot+0.5*S.velocity,
				S.active_ball.get_gravity_scale()*Vector2(0,gravity))
		$Camera.set_offset_from_type("aim",shoot.normalized())
		if shoot.x > 0 :
			S.aim_direction = 1
		else :
			S.aim_direction = -1
	elif S.is_crouching :
		$Camera.set_offset_from_type("crouch")
	elif S.is_moving :
		$Camera.set_offset_from_type("move", Vector2(0.1*S.velocity.x, 0.0), 0.4)
	else :
		$Camera.set_offset_from_type("normal")

	$Sprite/AnimationTree.animate_from_state(S)

####################################### Utilities
func move_side(direction_p,delta):
	if S.is_onfloor :
		if S.is_crouching :
			if (S.velocity.x*direction_p > crouch_speed_max) :
				pass # in the same direction_p as velocity and faster than max
			else :
				S.velocity.x += direction_p*crouch_accel*delta
				if (S.velocity.x*direction_p > crouch_speed_max) :
					S.velocity.x = direction_p*crouch_speed_max
					
			if -crouch_return_thresh_instant_speed < S.velocity.x*direction_p and S.velocity.x*direction_p < crouch_instant_speed :
				S.velocity.x = direction_p*crouch_instant_speed
		else : #standing on the floor, maybe moving
			if (S.velocity.x*direction_p >= run_speed_max) :
				pass # in the same direction_p as velocity and faster than max
			else :
				S.velocity.x += direction_p*walk_accel*delta
				if (S.velocity.x*direction_p > run_speed_max) :
					S.velocity.x = direction_p*run_speed_max

			if -walk_return_thresh_instant_speed < S.velocity.x*direction_p and S.velocity.x*direction_p < walk_instant_speed :
				S.velocity.x = direction_p*walk_instant_speed

	else : # is in the air
		if (S.velocity.x*direction_p >= sideaerial_speed_max) :
			pass
		else :
			S.velocity.x += direction_p * sideaerial_accel * delta
			if (S.velocity.x*direction_p > sideaerial_speed_max) :
				S.velocity.x = direction_p * sideaerial_speed_max
		if -air_return_thresh_instant_speed < S.velocity.x*direction_p and S.velocity.x*direction_p < air_instant_speed :
				S.velocity.x = direction_p*air_instant_speed

func move_jump(delta):
	S.velocity.y = jump_speed
	S.is_jumping = true
	S.get_node("ToleranceJumpPressTimer").stop()
	S.get_node("CanJumpTimer").start(S.jump_countdown)
	$Player_Effects.dust_start()

func move_walljump(direction,delta):
	S.velocity.x = -vecjump.x * direction * jump_speed
	S.velocity.y = -vecjump.y * jump_speed
	S.is_walljumping = true
	S.get_node("ToleranceJumpPressTimer").stop()
	S.get_node("CanJumpTimer").start(S.jump_countdown)
	S.get_node("CanGoTimer").start(S.walljump_move_countdown)
	$Player_Effects.dust_start()

func move_crouch(delta):# TODO
	# Change hitbox + other animation things like sliding etc.
	S.is_aiming = false # cancel aiming for the moment
	S.aim_direction = 0
	ShootPredictor.clear()
	S.is_crouching = true

func move_dunkjump(delta):# TODO
	# Change hitbox + other animation things like sliding etc.
	S.is_aiming = false # cancel aiming for the moment
	S.aim_direction = 0
	ShootPredictor.clear()
	S.is_dunkjumping = true
	$Player_Effects.dust_start()
	$Player_Effects.ghost_start(0.35,0.07)
	#print(S.selected_basket)
	var q = S.selected_basket.position - position
	var B = dunk_speed * q.x / q.y
	var C = -gravity * 0.5 * q.x*q.x/q.y
	var vox1 = 0.5*(B - sqrt(B*B-4*C))
	var vox2 = 0.5*(B + sqrt(B*B-4*C))
	if (abs(vox2) < abs(vox1)):
		S.velocity.x = vox2
	else :
		S.velocity.x = vox1
	S.velocity.y = dunk_speed
	print("Velocity: "+str(S.velocity))
	S.get_node("CanDunkJumpTimer").start(S.dunk_countdown)
	#S.get_node("CanGoTimer").start(1.0) # can_go always false if is dunkjumping (to change ?)
	self.get_node("Camera").screen_shake(0.2,10)
	#yield(get_tree().create_timer(0.2), "timeout")
	#self.get_node("Camera").screen_shake(0.8,5)

func move_dunk(delta): #TODO
	# Change hitbox + other animation things like sliding etc.
	S.is_aiming = false # cancel aiming for the moment
	S.aim_direction = 0
	ShootPredictor.clear()
	S.is_dunking = true
	S.is_dunkjumping = false
	S.velocity.x = 0
	S.velocity.y = 0
	S.get_node("CanDunkJumpTimer").start(S.dunk_countdown)
	S.get_node("CanDunkTimer").start(S.dunk_countdown)
	S.get_node("CanGoTimer").start(0.3)
	yield(get_tree().create_timer(0.3), "timeout")
	self.get_node("Camera").screen_shake(0.3,30)
	S.selected_basket.get_node("DunkParticles").restart()

func move_aim(delta):
	S.is_aiming = true
	S.last_aim_jp = S.time
	#Engine.time_scale = 0.5

func move_shoot(delta):
	S.is_aiming = false
	S.aim_direction = 0
	S.is_shooting = true
	S.get_node("CanShootTimer").start(S.shoot_countdown)
	ShootPredictor.shoot_vector_save = ShootPredictor.shoot_vector()
	#Engine.time_scale = 1.0
	ShootPredictor.clear()	
	#throw_ball()+free_ball in Ball_handler	called by animation

func move_select_ball(delta):
	if S.selected_ball == null:
		S.selected_ball = Global.mouse_ball
		S.selected_ball.selector.toggle_selection(true)
	elif S.selected_ball != Global.mouse_ball :
		S.selected_ball.selector.toggle_selection(false)
		if S.power_p:
			S.selected_ball.power_jr(self,delta)
		S.selected_ball = Global.mouse_ball
		S.selected_ball.selector.toggle_selection(true)
	else : #S.selected_ball == Global.mouse_ball
		S.selected_ball.selector.toggle_selection(false)
		if S.power_p:
			S.selected_ball.power_jr(self,delta)
		S.selected_ball = null
		
func move_adherence(delta):
	if S.move_direction != S.direction_p: # if not moving in the same dir as input
		if S.is_onfloor:
			S.velocity.x = lerp(S.velocity.x, 0, floor_friction)
		else : #in the air
			S.velocity.x = lerp(S.velocity.x, 0, air_friction)

################################################################################
func _physics_process(delta):
	get_input(delta)
	if S.is_onwall and S.velocity.y > 0: #fall on a wall
		S.velocity.y += gravity/2.0 * delta
		S.velocity.y = min(S.velocity.y,max_speed_fall_onwall)
	else :
		S.velocity.y += gravity * delta
		if S.velocity.y > max_speed_fall:
			S.velocity.y = max_speed_fall
	if physics_enabled:
		S.velocity = move_and_slide(S.velocity, Vector2(0, -1), true, 4, 0.9)
