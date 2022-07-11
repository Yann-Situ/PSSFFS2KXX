extends Ball
# Rolling Heavy ball, with no bouncing and large mass
func _ready():
	pass

func on_destruction(): # call before changing holder, disable_physics and deleting selectors
	$DashArea.set_is_dash_selectable(false)
	
func on_pickup(holder_node : Node):
	$DashArea.set_is_dash_selectable(false)

func on_throw(previous_holder : Node):
	$DashArea.set_is_dash_selectable(true)
