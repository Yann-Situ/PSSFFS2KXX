extends Resource
class_name Alterable

# signal value_changed # useless for the moment

var base_value : float = 0.0 : set = set_base_value
var alterers : Dictionary = {} # key: RID, value: Alterer
var current_value : float = base_value
var is_up_to_date : bool = true : set = set_is_up_to_date

func _init(_base_value : float = 0.0):
	base_value = _base_value

func set_base_value(_base_value : float):
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
	# self.value_changed.emit()# useless for the moment
	
func add_alterer(alterer : Alterer):
	if alterers.has(alterer.get_rid()):
		push_warning("alterer RID("+str(alterer.get_rid())+") already added.")
	else:
		alterers[alterer.get_rid()] = alterer
		alterer.is_done.connect(_on_alterer_is_done.bind(alterer))
		alterer.has_changed.connect(set_is_up_to_date.bind(false))
		set_is_up_to_date(false)
		emit_changed()

## this method is called by the alterer when it is done
func _on_alterer_is_done(alterer : Alterer):
	if alterers.has(alterer.get_rid()):
		base_value = alterer.alter_done(base_value) # TODO this can induce problems when using also multiplicative
		remove_alterer(alterer)
	else:
		push_warning("alterer RID("+str(alterer.get_rid())+") not found.")

## Note that removing the alterer removes also its effect.
## If you want to remove the alterer but keeping permanent effects, use the alterer.stop() function, 
## which should call the _on_alterer_is_done function
func remove_alterer(alterer : Alterer):
	if alterers.has(alterer.get_rid()):
		alterers.erase(alterer.get_rid())
		set_is_up_to_date(false)
		emit_changed()
	else:
		push_warning("alterer RID("+str(alterer.get_rid())+") not found.")

func clear_alterers():
	alterers.clear()
	set_is_up_to_date(false)
	emit_changed()


func set_max(m : float):
	push_warning("not implemented yet.")

func set_min(m : float):
	push_warning("not implemented yet.")
