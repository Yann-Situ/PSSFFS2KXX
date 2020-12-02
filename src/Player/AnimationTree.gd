extends AnimationTree

# Declare member variables here :
var state_machine
onready var Sprite = get_parent()
var conds = ["on_wall_cond","not_on_floor_cond","on_floor_cond","idle_cond",\
  	"falling_cond","walking_cond","jumping_cond","walljumping_cond",\
	"dunking_cond","not_dunking_cond","halfturning_cond"\
  #"not_halfturning_cond","crouching_cond","aiming_cond","shooting_cond"\#"landing_cond"\"not_landing_cond",
	]
func add_from_transition(animation_name,
	from_states = [],\
	from_cond = [],\
	from_switch_mode = []):
	"""Add transition from the from_states to the animation_name state, with the
	parameters advance_condition=from_cond, switch_mode=from_switch_mode."""
	for i in range(len(from_states)):
		var tr = AnimationNodeStateMachineTransition.new()
		if (i<len(from_switch_mode)) and \
			(from_switch_mode[i] > tr.SWITCH_MODE_IMMEDIATE) and \
			(from_switch_mode[i] <= tr.SWITCH_MODE_AT_END):
			tr.switch_mode = from_switch_mode[i]

		if (i<len(from_cond)) and (from_cond[i] != ""):
			if !(from_cond[i] in conds):
				conds.append(from_cond[i])
			tr.advance_condition = from_cond[i]
		else :
			if tr.switch_mode == tr.SWITCH_MODE_AT_END:
				tr.auto_advance = true
		self.tree_root.add_transition(from_states[i], animation_name, tr)

func add_to_transition(animation_name,
	to_states = [],\
	to_cond = [],\
	to_switch_mode = []):
	"""Add transition from the animation_name state to the to_states, with the
	parameters advance_condition=to_cond, switch_mode=to_switch_mode."""
	for i in range(len(to_states)):
		var tr = AnimationNodeStateMachineTransition.new()
		if (i<len(to_switch_mode)) and \
			(to_switch_mode[i] > tr.SWITCH_MODE_IMMEDIATE) and \
			(to_switch_mode[i] <= tr.SWITCH_MODE_AT_END):
			tr.switch_mode = to_switch_mode[i]

		if (i<len(to_cond)) and (to_cond[i] != ""):
			if !(to_cond[i] in conds):
				conds.append(to_cond[i])
			tr.advance_condition = to_cond[i]
		else :
			if tr.switch_mode == tr.SWITCH_MODE_AT_END:
				tr.auto_advance = true
		self.tree_root.add_transition(animation_name, to_states[i], tr)

func add_state(animation_name, \
	from_states = [], to_states = [], \
	from_cond = [], to_cond = [], \
	from_switch_mode = [], to_switch_mode = []):
	"""Add and create a new node for the animation tree player, with the
	appropriate transitions (see add_from_transition and add_to_transition)."""
	var node = AnimationNodeAnimation.new();
	node.animation = animation_name
	self.tree_root.add_node(animation_name, node)
	var t = []
	add_to_transition(animation_name, to_states, to_cond, to_switch_mode)
	add_from_transition(animation_name, from_states, from_cond, from_switch_mode)

func _ready():
	state_machine = self.get("parameters/playback")

	#var air_states = [self.tree_root.get_node(x) \
	#    for x in ["jump1", "fall", "fall_loop", "walljump1", "air_wall"]]
	#var floor_states = [self.tree_root.get_node(x) \
	#    for x in ["idle", "walk", "floor_wall"]]

	#DUNK
	add_state("dunk",\
	  ["fall", "fall_loop", "jump1", "walljump1"],["fall", "idle"],\
	  ["dunking_cond","dunking_cond","dunking_cond","dunking_cond"],["not_dunking_cond","on_floor_cond"],\
	  [],[]) # is same as all SWITCH_MODE_IMMEDIATE

	#HALFTURN
	add_state("halfturn",\
	  ["walk", "idle"],["walk","idle", "floor_wall"], \
	  ["halfturning_cond","halfturning_cond"],["","not_on_floor_cond", "on_wall_cond"],\
	  [0,0],[2, 0, 0])

	# var dunk_node = AnimationNodeAnimation.new();
	# dunk_node.animation = "dunk"
	# self.tree_root.add_node("dunk", dunk_node, Vector2(8.0,8.0))
	# var t_dunk_fall = AnimationNodeStateMachineTransition.new()
	# var t_dunk_idle = AnimationNodeStateMachineTransition.new()
	# var t_fall_dunk = AnimationNodeStateMachineTransition.new()
	# var t_fall_loop_dunk = AnimationNodeStateMachineTransition.new()
	# var t_jump1_dunk = AnimationNodeStateMachineTransition.new()
	# var t_walljump1_dunk = AnimationNodeStateMachineTransition.new()
	# for tr in [t_fall_loop_dunk, t_jump1_dunk, t_walljump1_dunk, t_fall_dunk]:
	# 	tr.advance_condition = "dunking_cond"
	# 	tr.switch_mode = tr.SWITCH_MODE_IMMEDIATE
	# t_dunk_idle.advance_condition = "on_floor_cond"
	# t_dunk_fall.advance_condition = "not_dunking_cond"
	#
	# self.tree_root.add_transition("dunk", "fall", t_dunk_fall)
	# self.tree_root.add_transition("dunk", "idle", t_dunk_idle)
	# self.tree_root.add_transition("fall","dunk", t_fall_dunk)
	# self.tree_root.add_transition("fall_loop","dunk", t_fall_loop_dunk)
	# self.tree_root.add_transition("jump1","dunk", t_jump1_dunk)
	# self.tree_root.add_transition("walljump1","dunk", t_walljump1_dunk)

	for c in conds:
		self["parameters/conditions/"+c] = false


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
	#self["parameters/conditions/not_landing_cond"] = !S.is_landing
	self["parameters/conditions/dunking_cond"] = S.is_dunking
	self["parameters/conditions/not_dunking_cond"] = !S.is_dunking
	self["parameters/conditions/halfturning_cond"] = S.is_halfturning
	#self["parameters/conditions/not_halfturning_cond"] = !S.is_halfturning
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
