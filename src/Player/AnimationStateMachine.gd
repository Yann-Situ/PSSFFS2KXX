extends AnimationTree

# Declare member variables here :
var state_machine
@onready var Player = get_parent().get_parent()
var conds = ["on_wall_cond","not_on_floor_cond","on_floor_cond","idle_cond",\
  	"falling_cond","walking_cond","jumping_cond","walljumping_cond",\
	"dunkjumping_cond","not_dunkjumping_cond", "dunking_cond", "not_dunking_cond", \
	"halfturning_cond"\
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

func add_state(state_name, \
	from_states = [], to_states = [], \
	from_cond = [], to_cond = [], \
	from_switch_mode = [], to_switch_mode = [], \
	animation_name = ""):
	"""Add and create a new node for the animation tree player, with the
	appropriate transitions (see add_from_transition and add_to_transition)."""
	var node = AnimationNodeAnimation.new();
	if animation_name == "":
		animation_name = state_name
	node.animation = animation_name
	self.tree_root.add_node(state_name, node)
	var t = []
	add_to_transition(state_name, to_states, to_cond, to_switch_mode)
	add_from_transition(state_name, from_states, from_cond, from_switch_mode)

func _ready():
	state_machine = self.get("parameters/playback")

	var air_states = ["jump1", "fall", "fall_loop", "walljump1", "air_wall"]
	var floor_states = ["idle", "walk", "floor_wall"]

	#DUNKJUMP
	add_state("dunkjump",\
	  ["fall", "fall_loop", "jump1", "walljump1"],["fall", "idle"],\
	  ["dunkjumping_cond","dunkjumping_cond","dunkjumping_cond","dunkjumping_cond"],["not_dunkjumping_cond","on_floor_cond"],\
	  [],[]) # is same as all SWITCH_MODE_IMMEDIATE
	air_states.append("dunkjump")
	
	#DUNK
	add_state("dunk",\
	  ["dunkjump","fall", "fall_loop", "jump1", "walljump1"],["fall"],\
	  ["dunking_cond","dunking_cond","dunking_cond","dunking_cond","dunking_cond"],["not_dunking_cond"],\
	  [0,0,0,0,0],[2])
	air_states.append("dunk")

	#HALFTURN
	add_state("halfturn",\
	  ["walk", "idle"],["walk","idle", "floor_wall"], \
	  ["halfturning_cond","halfturning_cond"],["","not_halfturning_cond", "on_wall_cond"],\
	  [0,0],[2, 0, 0])
	floor_states.append("halfturn")
	
	#CROUCH
	add_state("crouch_idle",\
	  ["walk", "idle"],["idle"], \
	  ["crouching_cond", "crouching_cond"],["not_crouching_cond"],\
	  [0,0],[0])
	floor_states.append("crouch_idle")
	
	add_state("crouch_idle_copy",\
	  [],["crouch_idle", "idle"], \
	  [],["", "not_crouching_cond"],\
	  [],[2,0],\
	  "crouch_idle")
	floor_states.append("crouch_idle_copy")
	
	add_state("crouch",\
	  ["crouch_idle","crouch_idle"],["idle", "crouch_idle"], \
	  ["walking_cond","walking_cond"],["not_crouching_cond", "idle_cond"],\
	  [0,0],[0,0])
	floor_states.append("crouch")
	
	#LAND
	add_state("land",\
	  ["idle", "crouch"],["crouch_idle_copy", "crouch_idle", "floor_wall"], \
	  ["landing_idle_cond","landing_idle_cond"],["", "not_landing_cond", "on_wall_cond"],\
	  [0],[2, 0, 0])
	floor_states.append("land")
	add_state("land_roll",\
	  ["idle", "crouch"],["crouch", "crouch_idle", "floor_wall"], \
	  ["landing_roll_cond","landing_roll_cond"],["", "not_landing_cond", "on_wall_cond"],\
	  [0],[2, 0, 0])
	floor_states.append("land_roll")
	
	#AIMING
	# add_state("air_aim",\
	#   ["fall", "fall_loop", "jump1", "walljump1"],["fall"], \
	#   ["aiming_cond","aiming_cond","aiming_cond","aiming_cond"],["not_aiming_cond"],\
	#   [0,0,0,0],[0])
	#
	# add_state("floor_idle_aim",\
	#   ["idle", "land", "air_aim"],["idle", "air_aim"], \
	#   ["aiming_cond","aiming_cond", "on_floor_cond"],["not_aiming_cond", "not_on_floor_cond"],\
	#   [0,0,0],[0, 0])
	#
	# add_state("floor_run_aim",\
	#   ["floor_idle_aim", "walk"],["floor_idle_aim", "walk", "air_aim"], \
	#   ["walking_cond", "aiming_cond"],["idle_cond", "not_aiming_cond", "not_on_floor_cond"],\
	#   [0,0],[0, 0, 0])

	#SHOOT
	var shoot_conds = []
	for i in range(max(len(air_states), len(floor_states))) :
		shoot_conds.append("shooting_cond")
	add_state("air_shoot",\
	  air_states,["fall", "fall_copy"], \
	  shoot_conds,["","not_shooting_cond"],\
	  [],[2,0])
	air_states.append("air_shoot")

	add_state("floor_shoot",\
	  floor_states,["idle", "idle_copy"], \
	  shoot_conds,["", "not_shooting_cond"],\
	  [],[2, 0, 0])
	floor_states.append("floor_shoot")

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
	# 	tr.advance_condition = "dunkjumping_cond"
	# 	tr.switch_mode = tr.SWITCH_MODE_IMMEDIATE
	# t_dunk_idle.advance_condition = "on_floor_cond"
	# t_dunk_fall.advance_condition = "not_dunkjumping_cond"
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
	self["parameters/conditions/not_on_wall_cond"] = !S.can_walljump
	self["parameters/conditions/on_wall_cond"] = S.can_walljump
	self["parameters/conditions/not_on_floor_cond"] = !S.is_onfloor
	self["parameters/conditions/on_floor_cond"] = S.is_onfloor

	self["parameters/conditions/idle_cond"] = S.is_idle
	self["parameters/conditions/falling_cond"] = S.is_falling
	self["parameters/conditions/walking_cond"] =  (S.direction_p != 0) and not S.is_idle

	self["parameters/conditions/jumping_cond"] = S.is_jumping
	self["parameters/conditions/walljumping_cond"] = S.is_walljumping and !S.can_walljump

	self["parameters/conditions/landing_idle_cond"] = S.is_landing and !S.is_landing_roll
	self["parameters/conditions/not_landing_cond"] = !S.is_landing
	self["parameters/conditions/landing_roll_cond"] = S.is_landing_roll
	self["parameters/conditions/dunkjumping_cond"] = S.is_dunkjumping
	self["parameters/conditions/not_dunkjumping_cond"] = !S.is_dunkjumping
	self["parameters/conditions/dunking_cond"] = S.is_dunking
	self["parameters/conditions/not_dunking_cond"] = !S.is_dunking
	self["parameters/conditions/halfturning_cond"] = S.is_halfturning
	self["parameters/conditions/not_halfturning_cond"] = !S.is_halfturning
	self["parameters/conditions/crouching_cond"] = S.is_crouching
	self["parameters/conditions/not_crouching_cond"] = !S.is_crouching
	#self["parameters/conditions/aiming_cond"] = S.is_aiming
	#self["parameters/conditions/not_aiming_cond"] = !S.is_aiming
	self["parameters/conditions/shooting_cond"] = S.is_shooting
	self["parameters/conditions/not_shooting_cond"] = !S.is_shooting

	set_flip(S.move_direction == -1, S.move_direction == 1)

func set_flip(b1,b2):
	#set flip if b1 true or unset flip if b2 true
	if b1 :
		Player.set_flip_h(true)
	elif b2 :
		Player.set_flip_h(false)
