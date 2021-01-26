extends Node2D


var can_place = true
onready var level = get_node("/root/Editor/Level")

var current_item

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	global_position = get_global_mouse_position()
	
	# temporary implementation due to https://github.com/godotengine/godot/issues/16854
	#########################
	if(current_item != null and Input.is_action_just_pressed("ui_select")):
		get_node("/root/Editor/Item_Select/TabContainer").update_can_place()
		if can_place:
			var new_item = current_item.instance()
			level.add_child(new_item)
			new_item.global_position = get_global_mouse_position()
			print("item placed !")
	#########################
#	if(current_item != null and can_place and Input.is_action_just_pressed("ui_select")):
#		var new_item = current_item.instance()
#		level.add_child(new_item)
#		new_item.global_position = get_global_mouse_position()
#		print("item placed !")
	
