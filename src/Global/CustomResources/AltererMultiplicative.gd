extends Alterer
class_name AltererMultiplicative

var value : float = 1.0 : set = set_value

func _init(_value : float = 1.0):
	value = _value
	priority = PRIORITY.MULTIPLICATIVE

func alter(alterable_value):
	return value*alterable_value

func alter_done(base_value):
	return alter(base_value)

func set_value(new_value : float):
	value = new_value
	self.has_changed.emit()
