extends Alterer
class_name AltererAdditive

var value : float = 0.0 : set = set_value

func _init(_value : float = 0.0):
	value = _value

func alter(alterable_value : float) -> float:
	return alterable_value + value

func alter_done(base_value : float) -> float:
	print("alter done additive")
	return alter(base_value)
	
func set_value(new_value : float):
	value = new_value
	self.has_changed.emit()

