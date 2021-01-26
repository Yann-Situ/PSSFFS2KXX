extends TabContainer

onready var object_cursor = get_node("/root/Editor/Editor_Object")

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.
	
# temporary implementation due to https://github.com/godotengine/godot/issues/16854
#########################
func update_can_place():
	object_cursor.can_place = not self.get_global_rect().has_point(self.get_global_mouse_position())
#########################	

	
func _on_TabContainer_mouse_entered():
	object_cursor.can_place = false
	# problem for the moment see https://github.com/godotengine/godot/issues/16854


func _on_TabContainer_mouse_exited():
	object_cursor.can_place = true
	# problem for the moment see https://github.com/godotengine/godot/issues/16854
