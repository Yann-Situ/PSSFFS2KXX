extends Resource
class_name DistortionResource

@export var animation_delay : float = 0.75
@export var animation_name : String = "subtle"
@export var size : Vector2 = Vector2(128,128)
@export var z_index : int = Global.z_indices["foreground_2"]

var distortion_scene = preload("res://src/Effects/Distortion.tscn")

func make_instance(global_position: Vector2):
	var distortion = distortion_scene.instantiate()
	Global.get_current_room().add_child(distortion)
	distortion.global_position = global_position
	distortion.z_index = z_index
	distortion.animation_delay = animation_delay
	distortion.size = size
	distortion.start(animation_name)
