extends Camera2D
@export var aim_offset : float = 100
@export var crouch_offset : float = 100
var target_offset = Vector2(0,0)
var current_shake_power = 0.0
var shake_offset = Vector2(0,0)
var offset_no_shake = offset

@onready var tween_shake = self.create_tween()
@onready var tween_no_shake = self.create_tween()

func _ready():
	pass

func screen_shake(duration, power):
	if power > current_shake_power:
		current_shake_power = power
		tween_shake.kill()
		tween_shake = self.create_tween()
		tween_shake.tween_method(self.set_random_shake_offset,
			Vector2(power, power), Vector2(0,0), duration)\
			.set_trans(Tween.TRANS_SINE).set_easse(Tween.EASE_OUT)
		tween_shake.tween_callback(self._on_tween_shake_completed)
		# twee_shake.start() start automatically

func _on_tween_shake_completed():
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

func set_target(target_offset, tween_duration = 0.2):
	tween_no_shake.kill()
	tween_no_shake = self.create_tween()
	tween_no_shake.tween_property(self, "offset_no_shake", target_offset,
		tween_duration).set_trans(Tween.TRANS_LINEAR).set_ease(Tween.EASE_OUT_IN)
	#tween_no_shake.start() start automatically

func set_shake_offset(vec = Vector2(0,0)):
	shake_offset = vec
func set_random_shake_offset(vec = Vector2(0,0)):
	set_shake_offset(Vector2(randf_range(-vec.x,+vec.x),randf_range(-vec.y,+vec.y)))

func add_offset(vec = Vector2(0,0)):
	offset = offset+vec

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	offset = offset_no_shake + shake_offset
