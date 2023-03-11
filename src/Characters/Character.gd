extends PhysicBody
class_name Character
@icon("res://assets/art/icons/character.png")

@onready var S = get_node("State")
@onready var ActionHandler = get_node("Actions/Action_Handler")
@onready var Effects = get_node("Effects")
@onready var BallHandler = get_node("Ball_Handler")

# Environment features (should be given by the map)
@export var floor_friction : float = 0.2 # ratio/frame
@export var air_friction : float = 0.0 # ratio/frame
@export var attract_force : float = 800 # m.pix/s²

# Crouch features
@export var crouch_speed_max : float = 300 # pix/s
@export var crouch_instant_speed : float = 60 # pix/s
@export var crouch_return_thresh_instant_speed : float = 100 # pix/s
@export var crouch_accel : float = 200 # pix/s²
@export var landing_velocity_thresh : float = 400 # pix/s

# Aerial features
@export var sideaerial_speed_max : float = 400 # pix/s
@export var air_instant_speed : float = 60 # pix/s
@export var air_return_thresh_instant_speed : float = 50 # pix/s
@export var sideaerial_accel : float = 220 # pix/s²
@export var jump_speed : float = -425 # pix/s
@export var dunk_speed : float = -500 # pix/s
@export var max_speed_fall : float = 800 # pix/s
@export var max_speed_fall_onwall : float = 200 # pix/s
@export var vec_walljump : Vector2 = Vector2(0.65, -1)

# Walk and run features
@export var run_speed_thresh : float = 350 # pix/s
@export var run_speed_max : float = 400 # pix/s
@export var walk_instant_speed : float = 150 # pix/s
@export var walk_return_thresh_instant_speed : float = 300 # pix/s
@export var walk_accel : float = 220 # pix/s²

@export var flip_h : bool = false

@onready var character_holder = null
################################################################################

func _ready():
	self.z_index = Global.z_indices["character_0"]
	add_to_group("holders")
	add_to_group("characters")
	# Character extends PhysicBody so they are in group physicbodies

func set_flip_h(b):
	flip_h  = b
	$Sprite2D.set_flip_h(b)
	ActionHandler.set_flip_h(b)

func behaviour(delta):
	pass

#################### Get input calls actions depending on inputs. It calls S.update_vars

func get_input(delta): #delta in s
	# Change variables of Player_state.gd
	S.update_vars(delta)
	if S.is_onfloor :
		S.get_node("ToleranceJumpFloorTimer").start(S.tolerance_jump_floor)
	else :
		S.last_onair_velocity_y = S.velocity.y
	if S.is_onwall :
		S.get_node("ToleranceWallJumpTimer").start(S.tolerance_wall_jump)
		S.last_wall_normal_direction = -1#sign(get_slide_collision(get_slide_collision_count()-1).normal.x)
		if $Sprite2D.flip_h:
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

	if S.can_go :
		$Actions/Adherence.move(delta)

	if S.release_jp :
		$Actions/Release.move(delta)

	# HITBOX:
	if S.is_crouching or S.is_landing or not S.can_stand:
		$Collision.shape.set_extents(Vector2(8,22))
		$Collision.position.y = 10
	else :
		$Collision.shape.set_extents(Vector2(8,26))
		$Collision.position.y = 6

	# CAMERA:

	# ANIMATION:
	$Sprite2D/AnimationTree.animate_from_state(S)

	S.jump_jp = false
	S.jump_jr = false
	#S.aim_jp = false
	S.shoot_jr = false
	S.dunk_jr = false
	S.dunk_jp = false
#	S.select_jp = false
	S.power_jp = false
	S.power_jr = false
	S.release_jp = false

################################################################################
# For physicbody

func apply_impulse(impulse):
	S.velocity += invmass * impulse
	linear_velocity = S.velocity

func set_linear_velocity(v):
	linear_velocity = v
	S.velocity = v

func physics_process(delta): # called by _physics_process
	behaviour(delta)
	get_input(delta)
	linear_velocity = S.velocity
	update_linear_velocity(delta)

	if ActionHandler.is_on_slope() and linear_velocity.y > - abs(linear_velocity.x) :
		linear_velocity.y = 0.5*sqrt(2) * \
			move_and_slide_with_snap(linear_velocity, 33*Vector2.DOWN, \
				Vector2.UP, true, 4, 0.785398, false).y
	else :
		linear_velocity = move_and_slide(linear_velocity, Vector2.UP, true, 4, \
		0.785398, false)

	S.velocity = linear_velocity

func update_linear_velocity(delta):
	# apply gravity and forces
	if S.is_onwall and linear_velocity.y > 0:
		#fall on a wall
		linear_velocity.y += gravity/2.0 * delta
		linear_velocity.y = min(linear_velocity.y,max_speed_fall_onwall)
	else :
		linear_velocity.y += gravity * delta
		if linear_velocity.y > max_speed_fall:
			linear_velocity.y = max_speed_fall

	for force in applied_forces.values() :
		linear_velocity += invmass * force * delta

func collision_effect(collider : Object, collider_velocity : Vector2,
	collision_point : Vector2, collision_normal : Vector2):
	pass
	# this function does NOT aim to change self.linear_velocity, because it
	# could result in wrong behaviours
	return true

func collision_handle(collision, delta):
	pass

################################################################################
# For `characters` group
func get_in(new_holder : Node):
	if not new_holder.is_in_group("characterholders"):
		print("error["+name+"], new_holder is not in group `characterholders`.")
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
	# set out  held_ball and has_ball
	BallHandler.free_ball(ball)
