extends Node2D
class_name Selectors

@export var P: Player
@onready var S = P.get_state_node()

var names = ["Shoot", "Dash", "Jump"]
var selector_targets = []

func _ready():
	await P.get_parent().ready # WHAAAAAT ???! TODO : change the raparenting (I'm not sure that necessary).
	# I'm not even sure I need Player for this node, maybe just state.
	for _name in names:
		var selector_target = self.get_node(_name+"Target")
		#var new_selector_target = selector_target.duplicate(15) # 7 because see Node.duplicate flags
		#new_selector_target.name += "STYLE"
		self.remove_child(selector_target) # WARNING: Be careful with the reparenting..
		P.get_parent().add_child(selector_target) # TODO: change for Global.get_current_level()
		selector_targets.push_back(selector_target)

## this function seems to be called by the special action handler. I need to rework all this to make
# it understandable and easy. Maybe decorelate rays and selectors. TODO
func update_selection(type : int, target : Selectable):
	var pre_target = selector_targets[type].target_selectable
	if pre_target != target:
		if pre_target != null:
			pre_target.set_selection(type, false)
		if target != null:
			target.set_selection(type, true)

		var new_target = null
		if target != null :
			new_target = target.parent_node
		match type :
			Selectable.SelectionType.SHOOT :
				S.shoot_basket = new_target
			Selectable.SelectionType.DASH :
				S.dunkdash_basket = new_target
			Selectable.SelectionType.JUMP :
				S.dunkjump_basket = new_target

	selector_targets[type].update_selection(target)
