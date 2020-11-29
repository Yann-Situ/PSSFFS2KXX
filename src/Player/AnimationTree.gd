extends AnimationTree

# Declare member variables here :
var state_machine
onready var Sprite = get_parent()

# Called when the node enters the scene tree for the first time.
func _ready():
	state_machine = self.get("parameters/playback")

func animate_from_state(S):
	self["parameters/conditions/idle_cond"] = S.is_idle 
	self["parameters/conditions/jumping_cond"] = S.is_jumping
	self["parameters/conditions/walljumping_cond"] = S.is_walljumping and !S.can_walljump
	self["parameters/conditions/not_on_wall_cond"] = !S.can_walljump#HACKED : !S.is_onwall
	self["parameters/conditions/on_wall_cond"] = S.can_walljump# HACKED mustbe S.is_onwall, but I have to implement a wall hit box
	self["parameters/conditions/not_on_floor_cond"] = !S.is_onfloor
	self["parameters/conditions/on_floor_cond"] = S.is_onfloor
	self["parameters/conditions/falling_cond"] = S.is_falling
	self["parameters/conditions/walking_cond"] =  (S.direction_p != 0) and not S.is_idle 
	set_flip(S.move_direction == -1, S.move_direction == 1)

func set_flip(b1,b2):
	#set flip if b1 true or unset flip if b2 true
	if b1 :
		Sprite.set_flip_h(true)
	elif b2 :
		Sprite.set_flip_h(false)
