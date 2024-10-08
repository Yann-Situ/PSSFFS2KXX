extends InputController

# var right : Trigger = Trigger.new("right")
# var left : Trigger = Trigger.new("left")
# var up : Trigger = Trigger.new("up")
# var down : Trigger = Trigger.new("down")
# var select : Trigger = Trigger.new("select")
# var accept : Trigger = Trigger.new("accept")
# var power : Trigger = Trigger.new("power")
# var release : Trigger = Trigger.new("release")
# var interact : Trigger = Trigger.new("interact")

func update_triggers():
	up.set_from_input_action('ui_up')
	down.set_from_input_action('ui_down')
	left.set_from_input_action('ui_left')
	right.set_from_input_action('ui_right')
	accept.set_from_input_action('ui_accept')
	power.set_from_input_action('ui_power')
	release.set_from_input_action('ui_release')
	interact.set_from_input_action('ui_interact')

func force_release_triggers():
	Input.action_release('ui_up')
	Input.action_release('ui_down')
	Input.action_release('ui_left')
	Input.action_release('ui_right')
	Input.action_release('ui_accept')
	Input.action_release('ui_power')
	Input.action_release('ui_release')
	Input.action_release('ui_interact')
