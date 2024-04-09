@icon("res://assets/art/icons/alterable.png")
extends Resource
class_name Alterable

signal value_changed # useless for the moment

var base_value : Variant : set = set_base_value
var alterers : Dictionary = {} # key: RID, value: Alterer
var current_value : Variant = base_value
var is_up_to_date : bool = true : set = set_is_up_to_date

func _init(_base_value = 0.0):
	base_value = _base_value

func set_base_value(_base_value : Variant):
	if base_value == _base_value:
		return
	base_value = _base_value
	set_is_up_to_date(false)
	emit_changed()

func get_value():
	if is_up_to_date:
		return current_value
	current_value = base_value
	var alterers_array = alterers.values()
	for priority in Alterer.PRIORITY.values():
		for alterer in alterers_array:
			if alterer.priority == priority:
				current_value = alterer.alter(current_value)
	set_is_up_to_date(true) # there should be some decision to make for incorporating the min and max...
	return current_value

func set_is_up_to_date(b : bool):
	is_up_to_date = b
	if !is_up_to_date:
		self.value_changed.emit()

####################################################################################################

func has_alterer(alterer : Alterer):
	return alterers.has(alterer.get_instance_id())

func add_alterer(alterer : Alterer):
	if has_alterer(alterer):
		push_warning("alterer "+str(alterer.get_instance_id())+" already added.")
	else:
		alterers[alterer.get_instance_id()] = alterer
		alterer.is_done.connect(_on_alterer_is_done.bind(alterer))
		alterer.has_changed.connect(set_is_up_to_date.bind(false))
		set_is_up_to_date(false)
		emit_changed()

## Note that removing the alterer removes also its effect.
## If you want to remove the alterer but keeping permanent effects, use the alterer.stop() function,
## which should call the _on_alterer_is_done function
func remove_alterer(alterer : Alterer):
	if has_alterer(alterer):
		alterer.is_done.disconnect(_on_alterer_is_done.bind(alterer))
		alterer.has_changed.disconnect(set_is_up_to_date.bind(false))
		alterers.erase(alterer.get_instance_id())
		set_is_up_to_date(false)
		emit_changed()
	else:
		push_warning("alterer "+str(alterer.get_instance_id())+" not found.")

## this method is called by the alterer when it is done.
## Note that this modify the base_value. If you don't want to modify the base_value
## after an alterer, use remove_alterer.
func _on_alterer_is_done(alterer : Alterer):
	if has_alterer(alterer):
		base_value = alterer.alter_done(base_value) # TODO this can induce problems when using also multiplicative
		remove_alterer(alterer)
	else:
		push_warning("alterer "+str(alterer.get_instance_id())+" not found.")

func clear_alterers():
	for alterer in alterers.values():
		alterer.is_done.disconnect(_on_alterer_is_done.bind(alterer))
		alterer.has_changed.disconnect(set_is_up_to_date.bind(false))
	alterers.clear()
	set_is_up_to_date(false)
	emit_changed()
