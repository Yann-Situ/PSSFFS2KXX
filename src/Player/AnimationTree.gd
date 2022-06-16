extends AnimationTree

onready var Character = get_parent().get_parent()
# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

enum Stance { GROUND, AIR, GRIND, HANG }

const S_Cancelable = "parameters/cancelable/conditions/"
var IsCancelable = S_Cancelable + "is_cancelable"
var IsNotCancelable = S_Cancelable + "is_not_cancelable"
var CurrentStance = "parameters/cancelable/stance/stancetransition/current"

const S_Air = "parameters/cancelable/stance/air/conditions/"
var IsJumping = S_Air + "is_jumping"
var IsOnWall = S_Air + "is_onwall"
var IsNotOnWall = S_Air + "is_not_onwall"

const S_Ground = "parameters/cancelable/stance/ground/conditions/"
var IsCrouching = S_Ground +"is_crouching"
var IsHalfturning = S_Ground + "is_halfturning"
var IsIdle = S_Ground + "is_idle"
var IsLanding = S_Ground + "is_landing"
var IsLandrolling = S_Ground + "is_landrolling"
var IsStanding = S_Ground + "is_standing"
var IsWalking = S_Ground + "is_walking"

const S_Action = "parameters/cancelable/action/conditions/"
var IsDunkjumping = S_Action + "is_dunkjumping"
var IsDunkdashing = S_Action + "is_dunkdashing"
var IsDunking = S_Action + "is_dunking"
var IsShooting = S_Action + "is_shooting"

var IsNotDunkjumping = S_Action + "is_not_dunkjumping"
var IsNotDunkdashing = S_Action + "is_not_dunkdashing"

var IsOnFloor = "parameters/cancelable/action/shoot/conditions/is_onfloor"
var IsDunkjumpHalfturning = "parameters/cancelable/action/dunkjump/conditions/is_dunkjumphalfturning"

var GrindBlend = "parameters/cancelable/stance/grind/blend_position"

func animate_from_state(S):

	# in order of priority:
	self[IsCancelable] = !S.is_non_cancelable
	self[IsNotCancelable] = S.is_non_cancelable

	self[IsDunkjumping] = S.is_dunkjumping
	self[IsDunkdashing] = S.is_dunkdashing
	self[IsDunking] = S.is_dunking
	self[IsShooting] = S.is_shooting
	self[IsNotDunkjumping] = !S.is_dunkjumping
	self[IsNotDunkdashing] = !S.is_dunkdashing
	self[IsOnFloor] = S.is_onfloor
	self[IsDunkjumpHalfturning] = S.is_dunkjumphalfturning

	# in order of priority:
	if S.is_hanging:
		self[CurrentStance] = Stance.HANG
	elif S.is_grinding:
		self[CurrentStance] = Stance.GRIND
		var dir = S.velocity
		if dir.x < 0:
			dir.x = -dir.x
		self[GrindBlend] = 0.2*round(-dir.angle() * (12.0/PI))
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
