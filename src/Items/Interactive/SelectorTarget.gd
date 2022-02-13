extends Sprite
class_name SelectorTarget, "res://assets/art/icons/target.png"

export (float) var tween_speed = 0.3#s
var selection_node = null

func _ready():
	self.self_modulate = Color.transparent
	
func update_selection(selection : Selectable):
	if selection != selection_node:
		if selection == null :
			selection_node = null
			deselect()
		else :
			selection_node = selection
			select()
		
func select():
	$TweenPosition.stop_all()
	$TweenPosition.follow_property(self, "global_position",global_position,\
		selection_node, "global_position", tween_speed, \
		Tween.TRANS_CUBIC, Tween.EASE_OUT)
	$TweenPosition.start()
	
	$TweenSelfModulate.stop_all()
	$TweenSelfModulate.interpolate_property(self, "self_modulate", \
		self.self_modulate, Color.white, tween_speed, \
		Tween.TRANS_LINEAR, Tween.EASE_IN)
	$TweenSelfModulate.start()
	
func deselect():
	$TweenSelfModulate.stop_all()
	$TweenSelfModulate.interpolate_property(self, "self_modulate", \
		self.self_modulate, Color.transparent, tween_speed, \
		Tween.TRANS_LINEAR, Tween.EASE_OUT_IN)
	$TweenSelfModulate.start()
	
#func _draw():
#	if selection_node != null :
#		draw_circle(Vector2.ZERO, 16, Color(1.0,0.8,0.6,1.0))
#
#func _process(delta):
#	update()
