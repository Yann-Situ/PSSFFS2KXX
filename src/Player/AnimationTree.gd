extends AnimationTree

# Declare member variables here :
var state_machine
onready var Sprite = get_parent()

# Called when the node enters the scene tree for the first time.
func _ready():
	state_machine = self.get("parameters/playback")

	var dunk_node = AnimationNodeAnimation.new();
	dunk_node.animation = "dunk"

	self.tree_root.add_node("dunk", dunk_node, Vector2(8.0,8.0))

	var t_dunk_fall = AnimationNodeStateMachineTransition.new()
	var t_dunk_idle = AnimationNodeStateMachineTransition.new()
	var t_fall_dunk = AnimationNodeStateMachineTransition.new()
	var t_fall_loop_dunk = AnimationNodeStateMachineTransition.new()
	var t_jump1_dunk = AnimationNodeStateMachineTransition.new()
	var t_walljump1_dunk = AnimationNodeStateMachineTransition.new()
	for tr in [t_fall_loop_dunk, t_jump1_dunk, t_walljump1_dunk, t_fall_dunk]:
		tr.advance_condition = "dunking_cond"
		tr.switch_mode = tr.SWITCH_MODE_IMMEDIATE
	t_dunk_idle.advance_condition = "on_floor_cond"
	t_dunk_fall.advance_condition = "not_dunking_cond"

	self.tree_root.add_transition("dunk", "fall", t_dunk_fall)
	self.tree_root.add_transition("dunk", "idle", t_dunk_idle)
	self.tree_root.add_transition("fall","dunk", t_fall_dunk)
	self.tree_root.add_transition("fall_loop","dunk", t_fall_loop_dunk)
	self.tree_root.add_transition("jump1","dunk", t_jump1_dunk)
	self.tree_root.add_transition("walljump1","dunk", t_walljump1_dunk)


func animate_from_state(S):
	self["parameters/conditions/not_on_wall_cond"] = !S.can_walljump#HACKED : !S.is_onwall
	self["parameters/conditions/on_wall_cond"] = S.can_walljump# HACKED mustbe S.is_onwall, but I have to implement a wall hit box
	self["parameters/conditions/not_on_floor_cond"] = !S.is_onfloor
	self["parameters/conditions/on_floor_cond"] = S.is_onfloor

	self["parameters/conditions/idle_cond"] = S.is_idle
	self["parameters/conditions/falling_cond"] = S.is_falling
	self["parameters/conditions/walking_cond"] =  (S.direction_p != 0) and not S.is_idle

	self["parameters/conditions/jumping_cond"] = S.is_jumping
	self["parameters/conditions/walljumping_cond"] = S.is_walljumping and !S.can_walljump
	#self["parameters/conditions/landing_cond"] = S.is_landing
	self["parameters/conditions/dunking_cond"] = S.is_dunking
	self["parameters/conditions/not_dunking_cond"] = !S.is_dunking
	#self["parameters/conditions/halfturning_cond"] = S.is_halfturning
	#self["parameters/conditions/crouching_cond"] = S.is_crouching
	#self["parameters/conditions/aiming_cond"] = S.is_aiming
	#self["parameters/conditions/shooting_cond"] = S.is_shooting

	set_flip(S.move_direction == -1, S.move_direction == 1)

func set_flip(b1,b2):
	#set flip if b1 true or unset flip if b2 true
	if b1 :
		Sprite.set_flip_h(true)
	elif b2 :
		Sprite.set_flip_h(false)
