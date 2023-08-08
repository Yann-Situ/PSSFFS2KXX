extends Alterer
class_name AltererAdditive

var value : Variant : set = set_value

func _init(_value = 0.0):
	value = _value
	priority = PRIORITY.ADDITIVE

func alter(alterable_value):
	return alterable_value + value

func alter_done(base_value):
	return alter(base_value)

func set_value(new_value):
	value = new_value
	self.has_changed.emit()
