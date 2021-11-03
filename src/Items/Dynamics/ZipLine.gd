tool
extends Node2D

enum ZIPLINE_TYPE {ROPE_CATCH, HANDLE_CATCH}
export (ZIPLINE_TYPE) var zipline_type = ZIPLINE_TYPE.ROPE_CATCH
export (Vector2) var init_point  setget set_init_point, get_init_point
export (Vector2) var final_point setget set_final_point, get_final_point
var path_body_list = []
export (Vector2) var player_position_offset = Vector2(0.0,5.0)
export (Vector2) var rope_offset = Vector2(0.0,10.0)
export (float,1.0, 20.0) var handle_catch_radius = 10.0
export (float, 0.0, 1.0) var handle_catch_init_unit_offset = 0.0 setget set_handle_catch_init_unit_offset

var linear_velocity = Vector2(0.0,0.0)
var real_rope_offset = Vector2.ZERO
var real_player_offset = Vector2.ZERO
var relative_position_offset = Vector2.ZERO

onready var gravity = ProjectSettings.get_setting("physics/2d/default_gravity") # pix/s²
onready var player_offset = player_position_offset+rope_offset

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
	#property_list_changed_notify()
	
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

func set_handle_catch_init_unit_offset(v):
	handle_catch_init_unit_offset = v
	$Path2D/PathFollow2D.set_unit_offset(v)

func _ready():
	self.z_index = Global.z_indices["foreground_1"]
	set_init_point(init_point)
	set_final_point(final_point)
	
	if zipline_type == ZIPLINE_TYPE.ROPE_CATCH:
		print("zip_rope_catch")
		$PlayerDetector/CollisionShape2D.shape = SegmentShape2D.new()
		$PlayerDetector/CollisionShape2D.shape.set_a(init_point)
		$PlayerDetector/CollisionShape2D.shape.set_b(final_point)
		$PlayerDetector/CollisionShape2D.shape.resource_local_to_scene = true
		$Path2D/PathFollow2D/Sprite.visible = false
	elif zipline_type == ZIPLINE_TYPE.HANDLE_CATCH:
		print("zip_handle_catch")
		$PlayerDetector/CollisionShape2D.shape = CircleShape2D.new()
		$PlayerDetector/CollisionShape2D.shape.set_radius(handle_catch_radius)
		$PlayerDetector/CollisionShape2D.shape.resource_local_to_scene = true
		var source = $PlayerDetector
		self.remove_child(source)
		$Path2D/PathFollow2D.add_child(source)
		source.set_owner($Path2D/PathFollow2D)
		$Path2D/PathFollow2D/Sprite.visible = true
		$Path2D/PathFollow2D.set_unit_offset(handle_catch_init_unit_offset)
	
	relative_position_offset = $Path2D/PathFollow2D.get_unit_offset()*(final_point-init_point)+init_point
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if not path_body_list.empty():
		linear_velocity.y += gravity * delta
		var fi =(final_point-init_point).normalized()
		var veldotfi = linear_velocity.dot(fi)
		
		path_body_list[0].S.velocity = veldotfi*fi
		
		$Path2D/PathFollow2D.set_offset($Path2D/PathFollow2D.get_offset()+veldotfi*delta)
		relative_position_offset = $Path2D/PathFollow2D.get_unit_offset()*(final_point-init_point)+init_point
		real_rope_offset = lerp(real_rope_offset, rope_offset, 0.1)
		real_player_offset = lerp(real_player_offset, player_offset, 0.1)
		
		path_body_list[0].position = real_player_offset+self.global_position+relative_position_offset
		$Line2D.set_point_position(1,relative_position_offset+real_rope_offset)
		$Path2D/PathFollow2D/Sprite.offset = real_rope_offset
		
		if $Path2D/PathFollow2D.get_unit_offset() > 0.999 or $Path2D/PathFollow2D.get_unit_offset() < 0.001 or path_body_list[0].S.crouch_p :
			path_body_list[0].enable_physics()
			path_body_list[0].S.velocity = (veldotfi*fi)
			#call_deferred("reparent",path_body_list[0], save_parent)
			path_body_list.remove(0)
			real_player_offset = Vector2.ZERO
			#$Line2D.set_point_position(1,$Line2D.get_point_position(2))
			#$Path2D/PathFollow2D/Sprite.offset = Vector2.ZERO
			$Timer.start()
			print("player quit zip")
	else :
		relative_position_offset = $Path2D/PathFollow2D.get_unit_offset()*(final_point-init_point)+init_point
		real_rope_offset = lerp(real_rope_offset, Vector2.ZERO, 0.1)
		$Line2D.set_point_position(1,relative_position_offset+real_rope_offset)
		$Path2D/PathFollow2D/Sprite.offset = real_rope_offset
			

func _on_PlayerDetector_body_exited(body):
	if path_body_list.empty() and body is Player and body.S.velocity.y > 0 and $Timer.is_stopped() :
		print("player on zip")
		var bi =body.position-global_position-init_point
		var fi =final_point-init_point
		linear_velocity = body.S.velocity
		body.disable_physics()
		path_body_list.append(body)
		$Path2D/PathFollow2D.set_offset(bi.dot(fi.normalized()))
		relative_position_offset = $Path2D/PathFollow2D.get_unit_offset()*(final_point-init_point)+init_point
		real_player_offset = bi - relative_position_offset

