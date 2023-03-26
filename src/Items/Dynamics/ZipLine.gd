# Interactive Zipline node (with currently some implementation problem).
# Two types of zipline are implemented : Rope catch and Handle catch.
@tool
extends Node2D
class_name ZipLine
# @icon("res://assets/art/icons/zipline.png")

enum ZIPLINE_TYPE {ROPE_CATCH, HANDLE_CATCH}
@export var zipline_type : ZIPLINE_TYPE = ZIPLINE_TYPE.ROPE_CATCH
@export var init_point : Vector2  : get = get_init_point, set = set_init_point
@export var final_point : Vector2 : get = get_final_point, set = set_final_point

@export var player_progress : Vector2 = Vector2(0.0,5.0)
@export var rope_progress : Vector2 = Vector2(0.0,10.0)
@export_range(1.0,20.0) var handle_catch_radius : float = 10.0
@export_range(0.0,1.0) var handle_catch_init_unit_progress : float = 0.0 : set = set_handle_catch_init_unit_progress

var linear_velocity = Vector2(0.0,0.0)
var real_rope_progress = Vector2.ZERO
var real_player_progress = Vector2.ZERO
#var relative_position_progress = Vector2.ZERO

var inside_bodies = []

@onready var gravity = ProjectSettings.get_setting("physics/2d/default_gravity") # pix/s²

func set_init_point(v):
	print("set_init")
	init_point = v
	if not is_inside_tree():
		return
	if $Path2D.curve.get_point_count() != 2:
		$Path2D.curve.clear_points()
		$Path2D.curve.add_point(init_point)
		$Path2D.curve.add_point(final_point)
	else :
		$Path2D.curve.set_point_position(0,v)
	$Line2D.set_point_position(0,v)
	set_final_point(final_point)
	#notify_property_list_changed()

func set_final_point(v):
	print("set_final")
	final_point = v
	if not is_inside_tree():
		return
	if $Path2D.curve.get_point_count() != 2:
		$Path2D.curve.clear_points()
		$Path2D.curve.add_point(init_point)
		$Path2D.curve.add_point(final_point)
	else :
		$Path2D.curve.set_point_position(1,v)
	$Line2D.set_point_position(1,v)
	$Line2D.set_point_position(2,v)

func get_init_point():
	return init_point
func get_final_point():
	return final_point

func set_handle_catch_init_unit_progress(v):
	handle_catch_init_unit_progress = v
	$Path2D/PathFollow2D.set_progress_ratio(v)

func _ready():
	self.z_index = Global.z_indices["foreground_1"]
	add_to_group("characterholders")
	set_init_point(init_point)
	set_final_point(final_point)

	if zipline_type == ZIPLINE_TYPE.ROPE_CATCH:
		print("zip_rope_catch")
		$PlayerDetector/CollisionShape2D.shape = SegmentShape2D.new()
		$PlayerDetector/CollisionShape2D.shape.set_a(init_point)
		$PlayerDetector/CollisionShape2D.shape.set_b(final_point)
		$PlayerDetector/CollisionShape2D.shape.resource_local_to_scene = true
		$Path2D/PathFollow2D/Sprite2D.visible = false
	elif zipline_type == ZIPLINE_TYPE.HANDLE_CATCH:
		print("zip_handle_catch")
		$PlayerDetector/CollisionShape2D.shape = CircleShape2D.new()
		$PlayerDetector/CollisionShape2D.shape.set_radius(handle_catch_radius)
		$PlayerDetector/CollisionShape2D.shape.resource_local_to_scene = true
		var source = $PlayerDetector
		self.remove_child(source)
		$Path2D/PathFollow2D.add_child(source)
		source.set_owner($Path2D/PathFollow2D)
		$Path2D/PathFollow2D/Sprite2D.visible = true
		$Path2D/PathFollow2D.set_progress_ratio(handle_catch_init_unit_progress)

	#relative_position_progress = $Path2D/PathFollow2D.get_progress_ratio()*(final_point-init_point)+init_point

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if not inside_bodies.is_empty():
		linear_velocity.y += gravity * delta
		var fi =(final_point-init_point).normalized()
		var veldotfi = linear_velocity.dot(fi)
		var body = inside_bodies[0]
		body.S.velocity = veldotfi*fi

		var temp_u_progress = $Path2D/PathFollow2D.get_progress_ratio()
		$Path2D/PathFollow2D.set_progress($Path2D/PathFollow2D.get_progress()+veldotfi*delta)
		#relative_position_progress = temp_u_progress*(final_point-init_point)+init_point
		real_rope_progress = lerp(real_rope_progress, 4*temp_u_progress*(1-temp_u_progress)*rope_progress, 0.1)
		real_player_progress = lerp(real_player_progress, player_progress, 0.1)

		#body.position = real_player_progress+self.global_position+relative_position_progress
		body.global_position = $Path2D/PathFollow2D.global_position+real_rope_progress+real_player_progress
		$Line2D.set_point_position(1,$Path2D/PathFollow2D.global_position-self.global_position+real_rope_progress)
		$Path2D/PathFollow2D/Sprite2D.offset = real_rope_progress

		if $Path2D/PathFollow2D.get_progress_ratio() > 0.999 or\
			$Path2D/PathFollow2D.get_progress_ratio() < 0.001 or\
			!body.S.is_hanging :
			#body.enable_physics()

			body.get_out(body.global_position, veldotfi*fi)

			#inside_bodies.remove(0)
			#$Line2D.set_point_position(1,$Line2D.get_point_position(2))
			#$Path2D/PathFollow2D/Sprite2D.offsetq = Vector2.ZERO
			$Timer.start()
	else :
		#relative_position_progress = $Path2D/PathFollow2D.get_progress_ratio()*(final_point-init_point)+init_point
		real_rope_progress = lerp(real_rope_progress, Vector2.ZERO, 0.1)
		$Line2D.set_point_position(1,$Path2D/PathFollow2D.global_position-self.global_position+real_rope_progress)
		$Path2D/PathFollow2D/Sprite2D.offset = real_rope_progress


func _on_PlayerDetector_body_exited(body):
	if !body.is_in_group("characters"):
		return 1
	if !body.has_node("Actions/Hang"):
		printerr(body.name + " doesn't have a node called Actions/Hang")
		return 1
	if !body.S.can_hang:
		print(body.name+" cannot hang on "+self.name)
		return 1

	if inside_bodies.is_empty() and body.S.velocity.y > 0 and $Timer.is_stopped() :

		var bi =body.position-global_position-init_point
		var fi =final_point-init_point
		linear_velocity = body.S.velocity
		inside_bodies.append(body)
		$Path2D/PathFollow2D.set_progress(bi.dot(fi.normalized()))
		#relative_position_progress = $Path2D/PathFollow2D.get_progress_ratio()*(final_point-init_point)+init_point
		real_player_progress = bi - ($Path2D/PathFollow2D.global_position-self.global_position)
		#body.disable_physics()
		pickup_character(body)

################################################################################
# For `characterholders` group
func pickup_character(character : Node):
	character.get_in(self)
	print(character.name+" on "+self.name)
	character.get_node("Actions/Hang").move(0.01)

func free_character(character : Node):
	# called by character when getting out
	var i = 0
	for body in inside_bodies:
		if body == character:
			print(name+" free_character("+character.name+")")
			if character.has_node("Actions/Hang"):
				character.get_node("Actions/Hang").move_stop()
			else :
				printerr(body.name + " doesn't have a node called Actions/Hang")
			remove_body(i)
		i += 1

func remove_body(i : int):
	assert(i < inside_bodies.size())
	inside_bodies.remove_at(i)
	real_player_progress = Vector2.ZERO
