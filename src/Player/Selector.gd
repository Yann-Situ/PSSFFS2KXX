extends Node2D

onready var Player = get_parent().get_parent()
onready var S = Player.get_node("State")

var names = ["Shoot", "Dash", "Jump"]
var selector_targets = []

func _ready():
	yield(Player.get_parent(), "ready")
	for name in names:
		var selector_target = self.get_node(name+"Target")
		#var new_selector_target = selector_target.duplicate(15) # 7 because see Node.duplicate flags
		#new_selector_target.name += "STYLE"
		self.remove_child(selector_target)
		#selector_target.queue_free()
		Player.get_parent().add_child(selector_target)
		selector_targets.push_back(selector_target)

func update_selection(type : int, selection_node : Selectable):
	var pre_selection_node = selector_targets[type].selection_node
	if pre_selection_node != selection_node:
		if pre_selection_node != null:
			pre_selection_node.set_selection(type, false)
		if selection_node != null:
			selection_node.set_selection(type, true)
		
		var new_basket = null
		if selection_node != null :
			new_basket = selection_node.get_parent()
		match type :
			Selectable.SelectionType.SHOOT :
				S.shoot_basket = new_basket
			Selectable.SelectionType.DASH :
				S.dunkdash_basket = new_basket
			Selectable.SelectionType.JUMP :
					S.dunkjump_basket = new_basket
				
	selector_targets[type].update_selection(selection_node)