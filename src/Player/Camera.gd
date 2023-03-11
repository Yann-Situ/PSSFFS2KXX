extends Camera2D
@export var aim_offset : float = 100
@export var aim_max_dist : float = 300
@export var crouch_offset : float = 100
@export var boum_distance2_threshold : float = 450*450
@export var move_max_offset : Vector2 = Vector2(128, 64)
@export var move_speed_threshold : Vector2 = Vector2(600, 800)
@export var initial_position : Vector2 = Vector2(0,-35)# relative position to the player
var target_offset = Vector2(0,0)
var current_shake_power = 0.0
var shake_offset = Vector2(0,0)
var offset_no_shake = offset

func _ready():
	pass

func screen_shake(duration, power, boum_position : Vector2 = self.global_position):
	if (boum_position-global_position).length_squared() > boum_distance2_threshold:
		return
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
		var l = direction.length()
		target_offset = smoothstep(0.0,aim_max_dist,l) * aim_offset/l*direction
	elif type == "crouch":
		target_offset = Vector2(0,1)*crouch_offset
	elif type == "normal":
		target_offset = Vector2(0,0)
	elif type == "move":
		target_offset = direction
	set_target(target_offset, tween_speed)

func set_target(target_offset_, tween_speed = 0.2):
	$Tween.interpolate_property(self, "offset_no_shake", offset_no_shake, target_offset_, tween_speed,
		 $Tween.TRANS_LINEAR, $Tween.EASE_OUT_IN, 0)
	$Tween.start()

func set_shake_offset(vec = Vector2(0,0)):
	shake_offset = vec
func set_random_shake_offset(vec = Vector2(0,0)):
	set_shake_offset(Vector2(randf_range(-vec.x,+vec.x),randf_range(-vec.y,+vec.y)))

func add_offset(vec = Vector2(0,0)):
	offset = offset+vec

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	offset = shake_offset
	position = initial_position + offset_no_shake
