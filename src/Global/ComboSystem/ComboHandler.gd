@icon("res ://assets/art/icons/cool-r-16.png")
extends Node
class_name ComboHandler

signal end_combo(final_score : int)
signal combo_element_added(combo_element : ComboElement)

var combo_elements : Array[ComboElement] = []
var current_score : int = 0 : get = get_current_score
var current_multiplier : float = 0.0 : get = get_current_multiplier
var remaining_time : float = 0.0

func _process(delta : float) -> void :
	if remaining_time > 0.0 :
		remaining_time -= delta
		if remaining_time <= 0.0 :
			_end_combo()

func start_combo(combo_element : ComboElement) -> void :
	_reset_combo()
	add_combo_element(combo_element)

func has_combo_element(combo_element : ComboElement) -> bool :
	return combo_element in combo_elements

func add_combo_element(combo_element : ComboElement) -> void :
	combo_elements.append(combo_element)
	update_timer(max(combo_element.remaining_time, remaining_time+combo_element.remaining_time*0.25))
	emit_signal("combo_element_added", combo_element)

func update_timer(time : float) -> void :
	remaining_time = max(remaining_time, time)

func get_current_score() -> int :
	var r : int = 0
	for combo_element in combo_elements:
		r += combo_element.additional_score
	current_score = r
	return r
	
func get_current_multiplier() -> float :
	var r : float = 0.0
	for combo_element in combo_elements:
		r = max(1.0, r+combo_element.additional_multiplier)
	current_multiplier = r
	return r
	
func get_remaining_time() -> float :
	return remaining_time

func _end_combo() -> void :
	emit_signal("end_combo", current_score * current_multiplier)
	_reset_combo()

func _reset_combo() -> void :
	combo_elements.clear()
	current_score = 0
	current_multiplier = 0.0
	remaining_time = 0.0
