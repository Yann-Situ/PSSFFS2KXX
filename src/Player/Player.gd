extends KinematicBody2D
class_name Player, "res://assets/art/icons/popol.png"

onready var S = get_node("State")
onready var SpecialActionHandler = get_node("Actions/Special_Action_Handler")
onready var ShootPredictor = get_node("Actions/Shoot_predictor")
onready var PlayerEffects = get_node("Player_Effects")
onready var BallHandler = get_node("Ball_Handler")

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
export (Vector2) var vec_walljump = Vector2(0.65, -1)

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
	self.z_index = Global.z_indices["player_0"]
	add_to_group("holders")
	add_to_group("characters")
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
	S.update_vars(delta)
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
		$Actions/Side.move(delta,S.direction_p)

	if not S.get_node("ToleranceJumpPressTimer").is_stopped() :
		if S.can_jump :
			$Actions/Jump.move(delta)
			if not S.jump_p:
				S.velocity.y = S.velocity.y/3.5
		elif S.can_walljump :
			$Actions/Walljump.move(delta,S.last_wall_normal_direction)
			if not S.jump_p:
				S.velocity.y = S.velocity.y/3.5
	if S.jump_jr and (S.is_jumping or S.is_walljumping) and not S.is_dunkjumping:
		S.velocity.y = S.velocity.y/3.5

	if S.crouch_p and S.can_crouch :
		$Actions/Crouch.move(delta)
	else :
		if S.can_stand:
			S.is_crouching = false

	if S.can_dunk :
		$Actions/Dunk.move(delta)

	if not S.get_node("ToleranceDunkJumpPressTimer").is_stopped() :
		if S.can_dunkjump :
			$Actions/Dunkjump.move(delta)

	if S.shoot_jr and S.can_shoot :
		$Actions/Shoot.move(delta)

	if S.aim_jp and S.can_aim :
		$Actions/Aim.move(delta)

	if S.can_go :
		$Actions/Adherence.move(delta)

	if S.selected_ball != null:
		if S.power_p :
			S.selected_ball.power_p(self,delta)
		if S.power_jp :
			S.selected_ball.power_jp(self,delta)
		elif S.power_jr :
			S.selected_ball.power_jr(self,delta)

	if S.select_jp and Global.mouse_ball != null :
		$Actions/SelectBall.move(delta)

	if S.release_jp :
		$Actions/Release.move(delta)
	# SHADER:
	#$Sprite.material.set("shader_param/speed",S.velocity)

	# HITBOX:
	if S.is_crouching or S.is_landing or not S.can_stand:
		$Collision.shape.set_extents(Vector2(8,22))
		$Collision.position.y = 10
	else :
		$Collision.shape.set_extents(Vector2(8,26))
		$Collision.position.y = 6

	# CAMERA:
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

	# ANIMATION:
	$Sprite/AnimationTree.animate_from_state(S)

	S.jump_jp = false
	S.jump_jr = false
	S.aim_jp = false
	S.shoot_jr = false
	S.dunk_jr = false
	S.dunk_jp = false
	S.select_jp = false
	S.power_jp = false
	S.power_jr = false
	S.release_jp = false

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
		if SpecialActionHandler.is_on_slope() and S.velocity.y > - abs(S.velocity.x) :
			S.velocity.y = 0.5*sqrt(2) * move_and_slide_with_snap(S.velocity, 33*Vector2.DOWN, Vector2.UP, true, 4, 0.785398, false).y
		else :
			S.velocity = move_and_slide(S.velocity, Vector2.UP, true, 4, 0.785398, false)

################################################################################
# For `holders` group
func free_ball(ball):
	# set out  active_ball and has_ball
	BallHandler.free_ball(ball)
