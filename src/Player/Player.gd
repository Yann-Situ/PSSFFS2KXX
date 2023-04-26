@icon("res://assets/art/icons/popol.png")
extends CharacterBody2D
class_name Player

var _zero_velocity_workaround = false

@export var physics_enabled : bool = true

@export var mass : float = 4.0 # kg
## Environment features (should be given by the map)
@export var floor_unfriction : float = 0.18 # s
@export var air_unfriction : float = 0.32 # s
@export var attract_force : float = 800.0 # m.pix/s² # don't know for what know (?)

@export_group("Ground features")
@export_subgroup("Crouch properties", "crouch_")
@export var crouch_speed_max : float = 300.0 # pix/s
@export var crouch_instant_speed : float = 60.0 # pix/s
@export var crouch_return_instant_speed_thresh : float = 100.0 # pix/s
@export var crouch_accel : float = 200.0 # pix/s²

@export_subgroup("Walk properties", "walk_")
@export var walk_speed_max : float = 400.0 # pix/s
@export var walk_speed_moving_fast_thresh : float = 350.0 # pix/s
@export var walk_instant_speed : float = 150.0 # pix/s
@export var walk_return_instant_speed_thresh : float = 300.0 # pix/s
@export var walk_accel : float = 220.0 # pix/s²

@export_group("Aerial features")
@export_subgroup("Air horizontal motion", "air_")
@export var air_side_speed_max : float = 400.0 # pix/s
@export var air_instant_speed : float = 45.0 # pix/s
@export var air_return_instant_speed_thresh : float = 50.0 # pix/s
@export var air_side_accel : float = 220.0 # pix/s²

@export_subgroup("Air vertical motion")
@export var jump_speed : float = -425.0 # pix/s
@export var fall_speed_max : float = 800.0 # pix/s
@export var fall_speed_max_onwall : float = 200.0 # pix/s
@export var walljump_direction : Vector2 = Vector2(0.65, -1)
@export var landing_velocity_thresh : float = 400.0 # pix/s

@export_group("Special features")
@export var dunkjump_speed : float = -500.0 # pix/s
@export var dunkdash_speed : float = 600.0 # pix/s
@export var dunkdash_dist2_max : float = 180*180.0 # pix^2
@export var throw_impulse : float = 600.0 # kg.pix/s


################################################################################

@onready var S = get_node("State")
@onready var SpecialActionHandler = get_node("Actions/SpecialActionHandler")
@onready var ShootPredictor = get_node("Shooter/ShootPredictor")
@onready var Shooter = get_node("Shooter")
@onready var PlayerEffects = get_node("PlayerEffects")
@onready var BallHandler = get_node("BallHandler")
@onready var Camera = get_node("Camera")
@onready var LifeHandler = get_node("LifeHandler")
@onready var LifeBar = get_node("UI/MarginContainer/HBoxContainer/VBoxContainer/Bar")
@onready var animation_tree = get_node("Sprite2D/AnimationTree")

@onready var start_position = global_position
@onready var foot_vector = Vector2(0,32)
@onready var invmass = 1.0/mass
@onready var collision_layer_save = 1
@onready var collision_mask_save = 514
@onready var floor_friction = GlobalMaths.unfriction_to_friction(floor_unfriction) # ratio/s
@onready var air_friction = GlobalMaths.unfriction_to_friction(air_unfriction) # ratio/s

@onready var force_alterable = Alterable.new(Vector2.ZERO)
@onready var speed_alterable = Alterable.new(Vector2.ZERO)
@onready var accel_alterable = Alterable.new(Vector2.ZERO)

var character_holder = null
var flip_h : bool = false
var shoot = Vector2.ZERO
var snap_vector = Vector2.ZERO

################################################################################

func reset_holder():
	get_out(global_position, S.velocity)

func reset_move():
	reset_holder()
	S.reset_state()
	LifeHandler.reset_life()
	force_alterable.clear_alterers()
	speed_alterable.clear_alterers()
	accel_alterable.clear_alterers()
	accel_alterable.add_alterer(Global.gravity_alterer)
	set_flip_h(false)
	reset_position()

################################################################################

func _ready():
	Global.list_of_physical_nodes.append(self)
	self.z_as_relative = false
	self.z_index = Global.z_indices["player_0"]
	$Sprite2D.z_as_relative = false
	$Sprite2D.z_index = Global.z_indices["player_0"]
	add_to_group("holders")
	add_to_group("characters")
	if !Global.playing:
		Global.toggle_playing()
	accel_alterable.add_alterer(Global.gravity_alterer)
	Global.camera = Camera

func set_flip_h(b):
	flip_h  = b
	$Sprite2D.set_flip_h(b)
	ShootPredictor.set_flip_h(b)
	SpecialActionHandler.set_flip_h(b)

func get_input(delta): #delta in s
	############### Change variables of Player_state.gd
	S.update_vars(delta)
	if S.is_onfloor:
		S.get_node("ToleranceJumpFloorTimer").start(S.tolerance_jump_floor)
	else:# !S.is_onfloor:
		S.last_onair_velocity_y = S.velocity.y
	if S.is_onwall :
		S.get_node("ToleranceWallJumpTimer").start(S.tolerance_wall_jump)
		S.last_wall_normal_direction = -1#sign(get_slide_collision(get_slide_collision_count()-1).normal.x)
		if $Sprite2D.flip_h:
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
		if not S.is_crouching:
			if not S.is_sliding and S.is_moving_fast:
				$Actions/Slide.move(delta)
			else :
				$Actions/Crouch.move(delta)
	elif S.can_stand:
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

	# HITBOX:
	if S.is_crouching or S.is_landing or not S.can_stand:
		$Collision.shape.set_radius(8.5)
		$Collision.shape.set_height(31)
		$Collision.position.y = 16.5
	else :
		$Collision.shape.set_radius(8.5)
		$Collision.shape.set_height(57)
		$Collision.position.y = 3.5

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

		ShootPredictor.draw_prediction(Vector2.ZERO, shoot,
			(Shooter.global_gravity_scale_TODO*Global.default_gravity.y)*Vector2.DOWN)
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
	#$Sprite2D/AnimationTree.animate_from_state(S)
	if S.direction_sprite == -1:
		self.set_flip_h(true)
	elif S.direction_sprite == 1:
		self.set_flip_h(false)

	LifeBar.set_life(LifeHandler.get_life())

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
func add_impulse(impulse : Vector2):
	S.set_velocity_safe(S.velocity + invmass * impulse)

func apply_forces_accel(delta):
	var force = force_alterable.get_value()
	S.velocity += invmass * delta * force
	var accel = accel_alterable.get_value()
	S.velocity += delta * accel
	if S.is_onwall and S.velocity.y > 0.0: #fall on a wall
		S.velocity.y = min(S.velocity.y,fall_speed_max_onwall)
	else :
		S.velocity.y = min(S.velocity.y,fall_speed_max)

func has_force(force_alterer : Alterer):
	return force_alterable.has_alterer(force_alterer)
func add_force(force_alterer : Alterer):
	force_alterable.add_alterer(force_alterer)
func remove_force(force_alterer : Alterer):
	force_alterable.remove_alterer(force_alterer)

func has_accel(accel_alterer : Alterer):
	return accel_alterable.has_alterer(accel_alterer)
func add_accel(accel_alterer : Alterer):
	accel_alterable.add_alterer(accel_alterer)
func remove_accel(accel_alterer : Alterer):
	accel_alterable.remove_alterer(accel_alterer)

func has_speed(speed_alterer : Alterer):
	return speed_alterable.has_alterer(speed_alterer)
func add_speed(speed_alterer : Alterer):
	speed_alterable.add_alterer(speed_alterer)
func remove_speed(speed_alterer : Alterer):
	speed_alterable.remove_alterer(speed_alterer)

func _physics_process(delta):
	#print("0: "+str(S.velocity)) # always (0.0,0.0) for some reason...
	_zero_velocity_workaround = true

	get_input(delta)
	if physics_enabled:
		apply_forces_accel(delta)
		set_velocity(S.velocity+speed_alterable.get_value())
		# TODOConverter40 looks that snap in Godot 4.0 is float, not vector like in Godot 3 - previous value `snap_vector`
		set_up_direction(Vector2.UP)
		set_floor_stop_on_slope_enabled(true)
		set_max_slides(4)
		set_floor_max_angle(0.785398)
		# TODOConverter40 infinite_inertia were removed in Godot 4.0 - previous value `false`
		move_and_slide()
		S.velocity = get_real_velocity()-speed_alterable.get_value()

	_zero_velocity_workaround = false

func disable_physics():
	physics_enabled = false
	collision_layer_save = collision_layer
	collision_layer = 0
	collision_mask_save = collision_mask
	collision_mask = 0
	S.velocity *= 0.0

func enable_physics():
	physics_enabled = true
	collision_layer = collision_layer_save
	collision_mask = collision_mask_save

func set_start_position(_position):
	start_position = _position

func reset_position():
	global_position = start_position

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
func free_ball(ball : Ball):
	# set out  active_ball and has_ball
	BallHandler.free_ball(ball)

################################################################################
# For ball selection
func select_ball(ball : Ball):
	BallHandler.select_ball(ball)
func deselect_ball(ball : Ball):
	BallHandler.deselect_ball(ball)
