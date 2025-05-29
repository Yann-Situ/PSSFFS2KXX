@icon("res://assets/art/icons/target.png")
extends Sprite2D
class_name SelectorTarget

@export var tween_duration : float = 0.3#s
var target_selectable : Selectable = null
var tween_self_modulate : Tween
var tween_position : Tween

func _ready():
	set_process(false)
	self.self_modulate = Color.TRANSPARENT

## function that is called by Selector or TargetHandler
func update_selection(selection : Selectable):
	if selection != target_selectable:
		if selection == null :
			target_selectable = null
			deselect()
		else :
			target_selectable = selection
			select()

func select():
	set_process(false)
	if tween_position:
		tween_position.kill()
	tween_position = self.create_tween()
	tween_position.tween_method(self.tween_position_follow_property.bind(global_position, target_selectable),\
	0.0, 1.0, tween_duration)\
	.set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	tween_position.tween_callback(self._on_tween_position_completed)
	# tween_position.start()

	if tween_self_modulate:

		tween_self_modulate.kill()
	tween_self_modulate = self.create_tween()
	tween_self_modulate.tween_property(self, "self_modulate", \
		Color.WHITE, tween_duration)\
		.set_trans(Tween.TRANS_LINEAR).set_ease(Tween.EASE_OUT_IN)
	# tween_self_modulate.start()

func deselect():
	if tween_self_modulate:
		tween_self_modulate.kill()
	tween_self_modulate = self.create_tween()
	tween_self_modulate.tween_property(self, "self_modulate", \
		Color.TRANSPARENT, tween_duration)\
		.set_trans(Tween.TRANS_LINEAR).set_ease(Tween.EASE_OUT_IN)
	# tween_self_modulate.start()
	set_process(false)

func tween_position_follow_property(t : float, src_pos : Vector2, trg : Node2D) -> void:
	self.global_position = src_pos.lerp(trg.global_position,t)

#func _draw():
#	if target_selectable != null :
#		draw_circle(Vector2.ZERO, 16, Color(1.0,0.8,0.6,1.0))
#
func _process(delta):
	if target_selectable != null:
		global_position = target_selectable.global_position
	else:
		push_warning("target_slectable == null, but process is true (likely due to exiting a room next to a target). Setting process to false.")
		set_process(false)

func _on_tween_position_completed():
	if target_selectable != null:
		set_process(true)
