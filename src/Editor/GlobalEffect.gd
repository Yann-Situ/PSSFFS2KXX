extends Node

var distortion_scene = preload("res://src/Effects/Distortion.tscn")

func make_distortion(global_position : Vector2, animation_delay : float = 0.75, animation_name : String = "subtle"):
	var distortion = distortion_scene.instance()
	Global.get_current_room().add_child(distortion)
	distortion.global_position = global_position
	distortion.z_index = Global.z_indices["foreground_2"]
	distortion.animation_delay = animation_delay
	distortion.start(animation_name)
