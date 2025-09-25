# ComboDisplayer.gd
extends Control
class_name ComboDisplayer

@export var combo_handler: ComboHandler : set = set_combo_handler

@export_category("Associated UI Nodes")
@export var timer_label: Label
@export var combo_information_label: JuicyControl1
@export var combo_list: VBoxContainer

func _ready() -> void:
	assert(combo_handler)
	assert(timer_label)
	assert(combo_list)

func set_combo_handler(c: ComboHandler) -> void:
	if combo_handler:
		combo_handler.disconnect("combo_element_added", self.add_combo_element)
		combo_handler.disconnect("end_combo", self.end_combo)

	combo_handler = c
	combo_handler.connect("combo_element_added", self.add_combo_element)
	combo_handler.connect("end_combo", self.end_combo)

func add_combo_element(combo_element: ComboElement, count : int = 1) -> void:
	if count > 1:
		var label : JuicyControl1 = combo_list.get_node(combo_element.name)
		if !label:
			printerr("Label node "+combo_element.name+" not found")
			return
		label.text = "%s (+%d) x%d" % [
			combo_element.name,
			combo_element.additional_score,
			count
		]
		combo_list.move_child(label, 0)
		label.juicy_update()
	else:
		var label = JuicyControl1.new()
		label.name = combo_element.name
		label.text = "%s (+%d)" % [
			combo_element.name,
			combo_element.additional_score
		]
		print(" - combo: "+label.text)
		combo_list.add_child(label)
		combo_list.move_child(label, 0)
		label.juicy_show()
		combo_information_label.shake_strength = 5.0 - 5.0/max(1.0, combo_handler.get_current_multiplier())
		combo_information_label.shake_times = 3*int(combo_handler.get_current_multiplier())
		combo_information_label.juicy_update()
		if combo_list.get_child_count() > 4:
			var old_label : JuicyControl1 = combo_list.get_child(4)
			old_label.juicy_hide()

func end_combo(final_score: int = 0) -> void:
	timer_label.text = "Final Score: %d" % final_score
	print(" - combo ended: "+str(final_score))
	for child in combo_list.get_children():
		combo_list.remove_child(child)
		child.queue_free() ## TODO change for some animation

func _process(delta: float) -> void:
	if combo_handler and combo_handler.get_remaining_time() > 0.0:
		timer_label.text = "Time: %.2f" % combo_handler.get_remaining_time()
		combo_information_label.text = "%d x%.2f" % [
		combo_handler.get_current_score(),
		combo_handler.get_current_multiplier()
	]
