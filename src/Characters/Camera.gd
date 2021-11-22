extends Camera2D
export (float) var aim_offset = 100
export (float) var crouch_offset = 100
var target_offset = Vector2(0,0)
var current_shake_power = 0.0
var shake_offset = Vector2(0,0)
var offset_no_shake = offset

func _ready():
	pass

func screen_shake(duration, power):
	if power > current_shake_power:
		current_shake_power = power
		$Tween.interpolate_method(self, "set_random_shake_offset",
			Vector2(power, power), Vector2(0,0), duration, 
			$Tween.TRANS_SINE, $Tween.EASE_OUT, 0)
		$Tween.start()

func _on_Tween_tween_completed(object, key):
	if key == ":set_random_shake_offset":
		shake_offset = Vector2(0,0)
		current_shake_power = 0.0

func set_offset_from_type(type, direction = Vector2(0,0), tween_speed = 0.2):
	if type == "aim":
		target_offset = direction*aim_offset
	elif type == "crouch":
		target_offset = Vector2(0,1)*crouch_offset
	elif type == "normal":
		target_offset = Vector2(0,0)
	elif type == "move":
		target_offset = direction
	set_target(target_offset, tween_speed)

func set_target(target_offset, tween_speed = 0.2):
	$Tween.interpolate_property(self, "offset_no_shake", offset_no_shake, target_offset, tween_speed,
		 $Tween.TRANS_LINEAR, $Tween.EASE_OUT_IN, 0)
	$Tween.start()

func set_shake_offset(vec = Vector2(0,0)):
	shake_offset = vec
func set_random_shake_offset(vec = Vector2(0,0)):
	set_shake_offset(Vector2(rand_range(-vec.x,+vec.x),rand_range(-vec.y,+vec.y)))

func add_offset(vec = Vector2(0,0)):
	offset = offset+vec

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	offset = offset_no_shake + shake_offset
