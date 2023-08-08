#tool
extends PathFollow2D
class_name ZipHandle
# @icon("res://assets/art/icons/ziplineline.png")

@export_group("Character parameters", "character_")
@export var character_offset : Vector2 = Vector2(0.0, 0.0)
@export var character_cant_get_in_again_delay : float = 0.2#s

var position_offset = Vector2.ZERO
var released_body = null
var is_available = true
var current_body = null

@onready var path : Path2D = get_parent()

###############################################################################

func _ready():
	self.z_index = Global.z_indices["foreground_1"]
	add_to_group("characterholders")

func _on_Area_body_exited(body : Node2D):
	if !is_available:
		return 1
	if !body.is_in_group("characters") :
		return 1
	if body.is_hold(): # already hold by a character_holder
		return 1
	if body.has_node("Actions/Hang") and !body.S.can_hang:
		print_debug(body.name + "have a node Actions/Hang but cannot hang")
		return 1
	if current_body == body:
		push_warning(body.name+" already in "+self.name)
		return 1
	if released_body == body:
		print_debug(body.name+" just got out from "+self.name)
		return 1

	var zipline_dir = transform.x
	if zipline_dir.cross(body.S.velocity) >= 0.0 :
		# add it to the zipline
		position_offset = body.global_position-global_position
		pickup_character(body)

################################################################################
# For `characterholders` group
func pickup_character(character : Node2D):
	character.get_in(self)
	current_body = character
	is_available = false
	print(character.name+" on "+self.name)
	if character.has_node("Actions/Hang"):
		character.get_node("Actions/Hang").move(0.01)

func free_character(character : Node2D):
	# called by character when getting out
	print(name+" free_character("+character.name+")")
	if character.has_node("Actions/Hang"):
		character.get_node("Actions/Hang").move_stop()
	position_offset = Vector2.ZERO
	released_body = character
	current_body = null
	is_available = true
	await get_tree().create_timer(character_cant_get_in_again_delay).timeout
	# WARNING can induced weird behaviour if the released body change during the timer
	released_body = null

func move_character(character : Node2D, linear_velocity : Vector2, \
	delta : float) -> Vector2:
	var zipline_dir = transform.x
	var new_velocity_length = linear_velocity.dot(zipline_dir)

	set_progress(get_progress() + new_velocity_length * delta)
	position_offset = lerp(position_offset, character_offset, 0.1)
	character.global_position = global_position + position_offset

	if get_progress_ratio() >= 1.0 or \
		get_progress_ratio() <= 0.0 or \
		(character.has_node("Actions/Hang") and !character.S.is_hanging) :
		character.get_out(character.global_position, new_velocity_length * zipline_dir)
	return new_velocity_length * zipline_dir
