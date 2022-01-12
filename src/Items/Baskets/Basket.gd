extends Node2D
class_name Basket, "res://assets/art/icons/basket.png"

export var speed_ball_threshold = 380 #velocity value
export var dunk_position_offset = 16 * Vector2.DOWN
export var dunk_position_radius = 24
export var can_receive_dunk = true

onready var start_position = global_position
# Should be in any items that can be picked/placed :
func set_start_position(posi):
	start_position = posi
	global_position = posi

func _ready():
	self.z_index = Global.z_indices["foreground_1"]

func _draw():
	pass
	#draw_line(position+$basket_area/CollisionShape2D.shape.a, position+$basket_area/CollisionShape2D.shape.b, color2)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	update()

func _on_basket_area_body_entered(body):
	#print("basket :"+body.name)
	if body.is_in_group("balls"):
		var dunk_dir = Vector2.DOWN.rotated(global_rotation)
		var score = body.linear_velocity.dot(dunk_dir)
		if score > 0.0:
			goal(body,score)

func dunk(dunker : Node2D):
	print("DUUUNK!")
	$CPUParticles2D.amount = 60
	$CPUParticles2D.restart()
	if (dunker.global_position.x - global_position.x) > 0:
		$AnimationPlayer.play("dunk_right")
	else :
		$AnimationPlayer.play("dunk_left")
	Global.camera.screen_shake(0.3,5)

func goal(body,score):
	print("GOOOAL!")
	if score > speed_ball_threshold:
		$CPUParticles2D.amount = 40
		Global.camera.screen_shake(0.3,5)
	else :
		$CPUParticles2D.amount = 20
	$CPUParticles2D.restart()

func enable_contour():
	var light = $LightSmall
	var tween = $LightSmall/Tween
	if tween.is_active():
		tween.remove_all()
	tween.interpolate_property(light, "energy", light.energy, 0.8, 0.15, 0, Tween.EASE_OUT)
	tween.start()
	
func disable_contour():
	var light = $LightSmall
	var tween = $LightSmall/Tween
	if tween.is_active():
		tween.remove_all()
	tween.interpolate_property(light, "energy", light.energy, 0.0, 0.15, 0, Tween.EASE_OUT)
	tween.start()

func get_closest_point(global_pos : Vector2):
	var p = global_pos - self.global_position
	var basket_dir = Vector2.RIGHT.rotated(global_rotation)
	var d = p.dot(basket_dir)
	if abs(d) >= dunk_position_radius:
		return self.global_position + sign(d) * dunk_position_radius * basket_dir
	return self.global_position + d * basket_dir

func get_dunk_position(player_global_position : Vector2):
	return get_closest_point(player_global_position) + dunk_position_offset
