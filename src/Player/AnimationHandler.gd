extends AnimationTree

onready var Character = get_parent().get_parent()
# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

enum Terrain { FLOOR, AIR }
enum OneFloorAction { SHOOT, LAND, LANDROLL, HALFTURN }
enum OneAirAction { SHOOT, DUNK, JUMP, WALLJUMP }
enum FloorPose { STAND, CROUCH }
enum AirPose { FALL, GRIND, HANG, WALLSLIDE, DUNKJUMP }

var idle_blend_save

func animate_from_state(S):
	
	if S.is_onfloor:
		
		var idle_blend = 0.0
		if (S.direction_p != 0) and not S.is_idle:
			idle_blend = 1.0
		
		if idle_blend != idle_blend_save:
			self["parameters/seek_floor/seek_position"] = 0.0
		idle_blend_save = idle_blend
		
		self["parameters/terrain_type/current"] = Terrain.FLOOR
		var save_one_shot = self["parameters/one_floor_action/active"]
		self["parameters/one_floor_action/active"] = true
		
		if S.is_shooting:
			self["parameters/one_floor_action_type/current"] = OneFloorAction.SHOOT
		elif S.is_landing_roll:
			self["parameters/one_floor_action_type/current"] = OneFloorAction.LANDROLL
		elif S.is_landing:
			self["parameters/one_floor_action_type/current"] = OneFloorAction.LAND
		elif S.is_halfturning:
			self["parameters/one_floor_action_type/current"] = OneFloorAction.HALFTURN
		else:
			if save_one_shot:
				pass
				#self["parameters/seek_floor/seek_position"] = 0.0
			self["parameters/one_floor_action/active"] = false
			
		if S.is_crouching:
			self["parameters/floor_pose/current"] = FloorPose.CROUCH
			self["parameters/crouch/blend_position"] = idle_blend
		else:
			self["parameters/floor_pose/current"] = FloorPose.STAND
			self["parameters/stand/blend_position"] = idle_blend
		
	else :
		self["parameters/terrain_type/current"] = Terrain.AIR
		self["parameters/one_air_action/active"] = true
			
		if S.is_dunking:
			self["parameters/one_air_action_type/current"] = OneAirAction.DUNK
		elif S.is_shooting:
			self["parameters/one_air_action_type/current"] = OneAirAction.SHOOT
		elif S.is_walljumping:
			self["parameters/one_air_action_type/current"] = OneAirAction.WALLJUMP
		elif S.is_jumping:
			self["parameters/one_air_action_type/current"] = OneAirAction.JUMP
		else:
			self["parameters/one_air_action/active"] = false
		
		
		if S.is_dunkjumping:
			self["parameters/air_pose/current"] = AirPose.DUNKJUMP
		elif S.is_hanging:
			self["parameters/air_pose/current"] = AirPose.HANG
		elif S.is_grinding:
			self["parameters/air_pose/current"] = AirPose.GRIND
		elif S.can_walljump:
			self["parameters/air_pose/current"] = AirPose.WALLSLIDE
		else:
			self["parameters/air_pose/current"] = AirPose.FALL

	set_flip(S.move_direction == -1, S.move_direction == 1)

func set_flip(b1,b2):
	#set flip if b1 true or unset flip if b2 true
	if b1 :
		Character.set_flip_h(true)
	elif b2 :
		Character.set_flip_h(false)
