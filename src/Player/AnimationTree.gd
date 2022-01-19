extends AnimationTree

onready var Character = get_parent().get_parent()
# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

enum Cancelable { NO, YES }
enum ActionType { SHOOT, DUNK, DUNKDASH, DUNKJUMP }
enum Stance { GROUND, AIR, GRIND, HANG }

var CurrentCancelable = "parameters/cancelable/current"
var CurrentActionType = "parameters/action_type/current"
var CurrentStance = "parameters/stance/current"

var IsJumping = "parameters/air/conditions/is_jumping"
var IsOnWall = "parameters/air/conditions/is_onwall"
var IsNotOnWall = "parameters/air/conditions/is_not_onwall"

var IsCrouching = "parameters/ground/conditions/is_crouching"
var IsHalfturning = "parameters/ground/conditions/is_halfturning"
var IsIdle = "parameters/ground/conditions/is_idle"
var IsLanding = "parameters/ground/conditions/is_landing"
var IsLandrolling = "parameters/ground/conditions/is_landrolling"
var IsStanding = "parameters/ground/conditions/is_standing"
var IsWalking = "parameters/ground/conditions/is_walking"

var IsOnFloor = "parameters/shoot/conditions/is_onfloor"

var IsDunkjumpHalfturning = "parameters/dunkjump/conditions/is_dunkjumphalfturning"

func animate_from_state(S):
	
	# in order of priority:
	self[CurrentCancelable] = Cancelable.NO
	if S.is_shooting:
		self[CurrentActionType] = ActionType.SHOOT
		self[IsOnFloor] = S.is_onfloor
	elif S.is_dunking:
		self[CurrentActionType] = ActionType.DUNK
	elif S.is_dunkjumping:
		self[CurrentActionType] = ActionType.DUNKJUMP
		self[IsDunkjumpHalfturning] = S.is_dunkjumphalfturning
	elif S.is_dunkdashing:
		self[CurrentActionType] = ActionType.DUNKDASH
	else :
		self[CurrentCancelable] = Cancelable.YES
	
	# in order of priority:
	if S.is_hanging:
		self[CurrentStance] = Stance.HANG
	elif S.is_grinding:
		self[CurrentStance] = Stance.GRIND
	elif not S.is_onfloor:
		self[CurrentStance] = Stance.AIR
		
		self[IsJumping] = S.is_jumping
		self[IsOnWall] = S.is_onwall
		self[IsNotOnWall] = !S.is_onwall
	else : # S.is_onfloor
		self[CurrentStance] = Stance.GROUND
		
		self[IsCrouching] = S.is_crouching
		self[IsHalfturning] = S.is_halfturning
		self[IsIdle] = S.is_idle
		self[IsLanding] = S.is_landing
		self[IsLandrolling] = S.is_landing_roll
		self[IsStanding] = !S.is_crouching
		self[IsWalking] = !S.is_idle

	set_flip(S.move_direction == -1, S.move_direction == 1)

func set_flip(b1,b2):
	#set flip if b1 true or unset flip if b2 true
	if b1 :
		Character.set_flip_h(true)
	elif b2 :
		Character.set_flip_h(false)
