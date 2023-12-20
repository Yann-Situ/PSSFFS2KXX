#@tool
extends Path2D
class_name PipeCharacter

@export_range(20, 2000) var speed_at_exit : float
@export_range(20, 2000) var speed_inside : float
@export var activated : bool = true : set = set_activated

enum PIPE_TYPE {ONE_WAY, BOTH_WAYS}
@export var pipe_type : PIPE_TYPE = PIPE_TYPE.ONE_WAY

var paths_to_free = {}
var path_follows = {}
var position_offsets = {}

func _update_entrance():
	$Entrance.position = curve.get_point_position(0)
	if self.activated :
		$Entrance/Sprite2D.set_animation("active")
		#$Entrance/Particles.emitting = true
		pass
	else :
		$Entrance/Sprite2D.set_animation("not_active")
		#$Entrance/Particles.emitting = false
		pass

	if curve.get_point_count() >= 2:
		var vec_direction = curve.get_point_position(0) - \
			curve.get_point_position(1)
		$Entrance.set_rotation(Vector2.UP.angle_to(vec_direction))

func _update_exit():
	var n = curve.get_point_count()
	$Exit.position = curve.get_point_position(n-1)
	if self.activated :
		$Exit/Sprite2D.set_animation("active")
		if pipe_type == PIPE_TYPE.BOTH_WAYS :
			#$Exit/Particles.emitting = true
			pass
		else :
			#$Exit/Particles.emitting = false
			pass
	else :
		$Exit/Sprite2D.set_animation("not_active")

	if n >= 2:
		var vec_direction = curve.get_point_position(n-1) - \
			curve.get_point_position(n-2)
		$Exit.set_rotation(Vector2.UP.angle_to(vec_direction))

###############################################################################

func _ready():
	self.z_index = Global.z_indices["foreground_1"]
	add_to_group("characterholders")
	add_to_group("activables")
	if curve.get_point_count() < 2:
		push_error("Not enough points in the curve!")

	_update_entrance()
	_update_exit()

func _on_Entrance_body_entered(body):
	if !self.activated:
		return 1
	if !body.is_in_group("characters") :
		return 1
	if body.is_hold(): # already hold by a character_holder
		return 1
	if path_follows.has(body):
		push_warning(body.name+" already in "+self.name)
		return 1

	var new_path_follow : PathFollow2D = PathFollow2D.new()
	new_path_follow.loop = false
	self.add_child(new_path_follow)

	new_path_follow.progress = 0
	new_path_follow.loop = false
	path_follows[body] = new_path_follow
	position_offsets[body] = body.global_position-new_path_follow.global_position
	pickup_character(body)


################################################################################
# For `characterholders` group
func pickup_character(character : Node2D):
	character.get_in(self)
	print(character.name+" on "+self.name)

func free_character(character : Node2D):
	# called by character when getting out
	print(name+" free_character("+character.name+")")
	path_follows[character].queue_free()
	path_follows.erase(character)
	position_offsets.erase(character)

func move_character(character : Node2D, linear_velocity : Vector2, \
	delta : float) -> Vector2:
	assert(path_follows.has(character))
	var path_follow = path_follows[character]
	var position_offset = position_offsets[character]

	path_follow.progress += speed_inside * delta
	position_offset = lerp(position_offset, Vector2.ZERO, 0.08)
	character.global_position = path_follow.global_position + position_offset
	position_offsets[character] = position_offset

	if path_follow.get_progress_ratio() >= 1.0 or \
		path_follow.get_progress_ratio() <= 0.0 :
		character.get_out(character.global_position, speed_at_exit * path_follow.transform.x)
		return speed_at_exit * path_follow.transform.x
	return speed_inside * path_follow.transform.x

################################################################################
# For `activables` group
func set_activated(b : bool):
	if b :
		enable()
	else :
		disable()

func enable():
	# Annoying problem on export variables in tool with setter that calle a node :
	#[https://github.com/godotengine/godot-proposals/issues/325]
	activated = true
	if is_inside_tree():
		_update_entrance()
		_update_exit()
		for body in $Entrance/Area2D.get_overlapping_bodies():
			_on_Entrance_body_entered(body)

func disable():
	activated = false
	if is_inside_tree():
		_update_entrance()
		_update_exit()
