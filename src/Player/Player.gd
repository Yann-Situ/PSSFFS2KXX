extends KinematicBody2D
class_name Player, "res://assets/art/icons/popol.png"

export (bool) var physics_enabled = true

# Environment features (should be given by the map)
export (float) var floor_friction = 0.2 # ratio/frame
export (float) var air_friction = 0.0 # ratio/frame
export (float) var attract_force = 800 # m.pix/s²
export (Vector2) var gravity # pix/s²

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
export (float) var dunkjump_speed = -500 # pix/s
export (float) var dunkdash_speed = 600 # pix/s
export (float) var max_dunkdash_distance2 = 180*180 # pix^2
export (float) var max_speed_fall = 800 # pix/s
export (float) var max_speed_fall_onwall = 200 # pix/s
export (Vector2) var vec_walljump = Vector2(0.65, -1)

# Walk and run features
export (float) var run_speed_thresh = 350 # pix/s
export (float) var run_speed_max = 400 # pix/s
export (float) var walk_instant_speed = 150 # pix/s
export (float) var walk_return_thresh_instant_speed = 300 # pix/s
export (float) var walk_accel = 220 # pix/s²

# Other features
export (float) var throw_impulse = 600 # kg.pix/s

export (bool) var flip_h = false

################################################################################

onready var S = get_node("State")
onready var SpecialActionHandler = get_node("Actions/SpecialActionHandler")
onready var ShootPredictor = get_node("Actions/ShootPredictor")
onready var Shooter = get_node("Shooter")
onready var PlayerEffects = get_node("PlayerEffects")
onready var BallHandler = get_node("BallHandler")
onready var Camera = get_node("Camera")
onready var LifeHandler = get_node("LifeHandler")

onready var start_position = global_position
onready var foot_vector = Vector2(0,32)
onready var based_gravity = Vector2(0.0,ProjectSettings.get_setting("physics/2d/default_gravity")) # pix/s²
onready var invmass = 1.0/4.0
onready var collision_layer_save = 1

var character_holder = null

var shoot = Vector2.ZERO
var snap_vector = Vector2.ZERO

################################################################################

func disable_physics():
	physics_enabled = false
	collision_layer_save = collision_layer
	collision_layer = 0
	S.velocity *= 0
	#S.applied_force *= 0

func enable_physics():
	physics_enabled = true
	collision_layer = collision_layer_save

func set_start_position(position):
	start_position = position

func reset_position():
	global_position = start_position

func reset_holder():
	get_out(global_position, S.velocity)
	#BallHandler.throw_ball(global_position, Vector2.ZERO)

func reset_move():
	reset_holder()
	S.reset_state()
	#LifeHandler.reset_life()
	set_flip_h(false)
	reset_position()

################################################################################

func _ready():
	Global.list_of_physical_nodes.append(self)
	self.z_as_relative = false
	self.z_index = Global.z_indices["player_0"]
	$Sprite.z_as_relative = false
	$Sprite.z_index = Global.z_indices["player_0"]
	add_to_group("holders")
	add_to_group("characters")
	if !Global.playing:
		Global.toggle_playing()
	Global.camera = Camera

	gravity = based_gravity

func set_flip_h(b):
	flip_h  = b
	$Sprite.set_flip_h(b)
	ShootPredictor.set_flip_h(b)
	SpecialActionHandler.set_flip_h(b)

func get_input(delta): #delta in s
	############### Change variables of Player_state.gd
	S.update_vars(delta)
	if S.is_onfloor or S.is_grinding:
		S.get_node("ToleranceJumpFloorTimer").start(S.tolerance_jump_floor)
	if !S.is_onfloor:
		S.last_onair_velocity_y = S.velocity.y
	if S.is_onwall :
		S.get_node("ToleranceWallJumpTimer").start(S.tolerance_wall_jump)
		S.last_wall_normal_direction = -1#sign(get_slide_collision(get_slide_count()-1).normal.x)
		if $Sprite.flip_h:
			S.last_wall_normal_direction = 1

	############### Move from input
	if physics_enabled and (S.direction_p != 0) and S.can_go :
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
	if physics_enabled and S.jump_jr and S.is_jumping and not S.is_dunkjumping:
		S.velocity.y = S.velocity.y/3.5

	if S.crouch_p and S.can_crouch :
		$Actions/Crouch.move(delta)
	else :
		if S.can_stand:
			S.is_crouching = false

	if S.can_dunk :
		$Actions/Dunk.move(delta)

	if not S.get_node("ToleranceDunkJumpPressTimer").is_stopped() :
		if S.crouch_p and S.can_dunkjump :
			$Actions/Dunkjump.move(delta)
		elif S.can_dunkdash :
			$Actions/Dunkdash.move(delta)

	if S.shoot_jr and S.can_shoot :
		$Actions/Shoot.move(delta)

	if S.aim_jp and S.can_aim :
		$Actions/Aim.move(delta)

	if physics_enabled and S.can_go :
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

	# GRAVITY:

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
		#var shoot = Vector2.ZERO
		var target = (Camera.get_global_mouse_position() - global_position)
		Shooter.update_target(target)
		if Shooter.can_shoot_to_target():
			Shooter.update_effective_can_shoot(0.0,0)
			shoot = Shooter.effective_v
		else :
			Shooter.update_effective_cant_shoot(0.0,0)
			shoot = Shooter.effective_v
#			shoot = ShootPredictor.shoot_vector()
#			if S.power_p and S.selected_ball == S.active_ball :
#				ShootPredictor.draw_attract(BallHandler.get_throw_position()-self.position, shoot+0.5*S.velocity,
#					S.active_ball.get_gravity_scale()*gravity, attract_force/S.active_ball.mass)
#			else :
#				ShootPredictor.draw(BallHandler.get_throw_position()-self.position, shoot+0.5*S.velocity,
#					S.active_ball.get_gravity_scale()*gravity)
		ShootPredictor.draw(Vector2.ZERO, shoot,
			S.active_ball.gravity*Vector2.DOWN)
		Camera.set_offset_from_type("aim",target)
		if shoot.x > 0 :
			S.aim_direction = 1
		else :
			S.aim_direction = -1
	elif S.is_crouching :
		var tx = Camera.move_max_offset.x * smoothstep(0.0, \
			Camera.move_speed_threshold.x, abs(S.velocity.x)) \
			* sign(S.velocity.x)
		Camera.set_offset_from_type("move", Vector2(tx,Camera.crouch_offset), 0.2)
	elif S.is_moving :
		var tx = Camera.move_max_offset.x * smoothstep(0.0, \
			Camera.move_speed_threshold.x, abs(S.velocity.x)) \
			* sign(S.velocity.x)
		var ty = Camera.move_max_offset.y * smoothstep(0.0, \
			Camera.move_speed_threshold.y, abs(S.velocity.y)) \
			* sign(S.velocity.y)
		Camera.set_offset_from_type("move", Vector2(tx,ty), 0.4)
	else :
		Camera.set_offset_from_type("normal")

	# ANIMATION:
	$Sprite/AnimationTree.animate_from_state(S)

	if S.is_aiming:
		Shooter.update_screen_viewer_position()
	else :
		Shooter.disable_screen_viewer()

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
# For physicbody
func apply_impulse(impulse):
	S.velocity += invmass * impulse

func apply_gravity(delta):
	if S.is_onwall and S.velocity.y > 0: #fall on a wall
		S.velocity += gravity/2.0 * delta
		S.velocity.y = min(S.velocity.y,max_speed_fall_onwall)
	else :
		S.velocity += gravity * delta
		if S.velocity.y > max_speed_fall:
			S.velocity.y = max_speed_fall

func _physics_process(delta):
	get_input(delta)
#	if S.velocity == Vector2.ZERO and !S.is_onfloor:
#		print("ZERO")
	if physics_enabled:
		apply_gravity(delta)
		if SpecialActionHandler.is_on_slope() and S.velocity.y > - abs(S.velocity.x) :
			S.velocity.y = 0.5*sqrt(2) * move_and_slide_with_snap(S.velocity, 33*Vector2.DOWN, Vector2.UP, true, 4, 0.785398, false).y
		else :
			S.velocity = move_and_slide_with_snap(S.velocity, snap_vector, Vector2.UP, true, 4, 0.785398, false)

################################################################################
# For `characters` group
func get_in(new_holder : Node):
	if not new_holder.is_in_group("characterholders"):
		printerr("error["+name+"], new_holder is not in group `characterholders`.")
	if character_holder != null:
		character_holder.free_character(self)
	self.disable_physics()
	character_holder = new_holder

func get_out(out_global_position : Vector2, velo : Vector2):
	self.enable_physics()
	global_position = out_global_position
	S.velocity = velo
	if character_holder != null:
		character_holder.free_character(self)
	character_holder = null

################################################################################
# For `holders` group
func free_ball(ball):
	# set out  active_ball and has_ball
	BallHandler.free_ball(ball)
