extends Resource
## Abstract class for alterers
class_name Alterer

signal is_done # when the alterer won't be modified again, so it can be removed
signal has_changed # when the alterer was modified

enum PRIORITY {ADDITIVE, MULTIPLICATIVE, POST}

@export var priority : PRIORITY = PRIORITY.ADDITIVE

## this function should modify the alterable value
func alter(alterable_value):
	return alterable_value

## this function should modify the alterable base_value afterwards when the alterer is done
func alter_done(base_value):
	return alter(base_value)

func stop():
	self.is_done.emit()
