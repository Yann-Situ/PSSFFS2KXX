extends Camera2D
@export var aim_offset : float = 100
@export var aim_max_dist : float = 300
@export var crouch_offset : float = 108
@export var boum_distance2_threshold : float = 450*450
@export var initial_position : Vector2 = Vector2(0,-35)# relative position to the player

@export_group("Velocity offset parameters", "velocity_")
@export var velocity_max_offset_DOWN_RIGHT : Vector2 = Vector2(128, 108) ## max camera offset influence of velocity for the down and right direction
@export var velocity_max_offset_UP_LEFT : Vector2 = Vector2(128, 64) ## max camera offset influence of velocity for the up and left direction
@export var velocity_speed_threshold : Vector2 = Vector2(600, 800) ## max velocity values for the smoothstep offset

var target_offset = Vector2(0,0)
var current_shake_power = 0.0
var shake_offset = Vector2(0,0)
var offset_no_shake = offset

var tween_shake : Tween
var tween_no_shake : Tween

func _ready():
	pass

################################################################################

func screen_shake(duration, power, boum_position : Vector2 = self.global_position):
	if (boum_position-global_position).length_squared() > boum_distance2_threshold:
		return
	if power > current_shake_power:
		current_shake_power = power
		if tween_shake:
			tween_shake.kill()
		tween_shake = self.create_tween()
		tween_shake.tween_method(self.set_random_shake_offset,
			Vector2(power, power), Vector2(0,0), duration)\
			.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
		tween_shake.tween_callback(self._on_tween_shake_completed)
		# twee_shake.start() start automatically

func _on_tween_shake_completed():
	shake_offset = Vector2(0,0)
	current_shake_power = 0.0

func set_shake_offset(vec = Vector2(0,0)):
	shake_offset = vec
func set_random_shake_offset(vec = Vector2(0,0)):
	set_shake_offset(Vector2(randf_range(-vec.x,+vec.x),randf_range(-vec.y,+vec.y)))

################################################################################

func set_offset_zero(tween_speed = 0.2):
	target_offset = Vector2.ZERO
	set_target(target_offset, tween_speed)
	
func set_offset_from_aim(mouse : Vector2, tween_speed = 0.2):
	var l = mouse.length()
	if l == 0.0:
		target_offset = Vector2.ZERO
	else:
		target_offset = smoothstep(0.0,aim_max_dist,l) * aim_offset/l*mouse
	set_target(target_offset, tween_speed)

func set_offset_y_from_crouch(tween_speed = 0.2):
	target_offset.y = crouch_offset
	set_target(target_offset, tween_speed)

## set the camera offset x from a velocity
func set_offset_x_from_velocity(velocity_x : float, tween_speed = 0.2):
	if velocity_x > 0.0:
		target_offset.x = velocity_max_offset_DOWN_RIGHT.x * \
			smoothstep(0.0, \
			velocity_speed_threshold.x, abs(velocity_x))
	else:
		target_offset.x = - velocity_max_offset_UP_LEFT.x * \
			smoothstep(0.0, \
			velocity_speed_threshold.x, abs(velocity_x))
	set_target(target_offset, tween_speed)
	
## set the camera offset y from a velocity
func set_offset_y_from_velocity(velocity_y : float, tween_speed = 0.2):
	if velocity_y > 0.0:
		target_offset.y = velocity_max_offset_DOWN_RIGHT.y * \
			smoothstep(0.0, \
			velocity_speed_threshold.y, abs(velocity_y))
	else:
		target_offset.y = - velocity_max_offset_UP_LEFT.y * \
			smoothstep(0.0, \
			velocity_speed_threshold.y, abs(velocity_y))
	set_target(target_offset, tween_speed)

func set_target(target_offset_, tween_duration = 0.2):
	if tween_no_shake:
		tween_no_shake.kill()
	tween_no_shake = self.create_tween()
	tween_no_shake.tween_property(self, "offset_no_shake", target_offset,
		tween_duration).set_trans(Tween.TRANS_LINEAR).set_ease(Tween.EASE_OUT_IN)
	#tween_no_shake.start() start automatically

################################################################################

func add_offset(vec = Vector2(0,0)):
	offset = offset+vec

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	offset = shake_offset
	position = initial_position + offset_no_shake
