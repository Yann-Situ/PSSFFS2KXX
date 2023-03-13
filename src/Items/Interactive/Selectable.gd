extends CollisionObject2D
class_name Selectable
# @icon("res://assets/art/icons/targeted.png")
# Selectable.gd

@export var is_shoot_selectable = true : set = set_is_shoot_selectable
@export var is_dash_selectable = true : set = set_is_dash_selectable
@export var is_jump_selectable = true : set = set_is_jump_selectable

var shoot_selected = false # should not be modified by other function than set_selection
var dash_selected = false # should not be modified by other function than set_selection
var jump_selected = false # should not be modified by other function than set_selection
var selected = false # should not be modified by other function than set_selection

func set_is_shoot_selectable(value : bool):
	is_shoot_selectable = value
	if !value:
		set_selection(SelectionType.SHOOT,value)
func set_is_dash_selectable(value : bool):
	is_dash_selectable = value
	if !value:
		set_selection(SelectionType.DASH,value)
func set_is_jump_selectable(value : bool):
	is_jump_selectable = value
	if !value:
		set_selection(SelectionType.JUMP,value)

enum SelectionType { SHOOT, DASH, JUMP }

func _ready():
	add_to_group("selectables")
	#get_parent().add_to_group("selectables")

func set_selection(type : int, value : bool):
	var changed = false
	match type :
		SelectionType.SHOOT :
			if is_shoot_selectable:
				changed = value != shoot_selected
				shoot_selected = value
		SelectionType.DASH :
			if is_dash_selectable:
				changed = value != dash_selected
				dash_selected = value
		SelectionType.JUMP :
			if is_jump_selectable:
				changed = value != jump_selected
				jump_selected = value
		_ :
			printerr("set_select(value, type) with a non existent type.")
	selected = shoot_selected or dash_selected or jump_selected

	if changed :
		if get_parent().has_method("set_selection"):
			get_parent().set_selection(type, value)
