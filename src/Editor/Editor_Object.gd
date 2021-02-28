extends Node2D


var can_place = true
var is_panning = true
onready var level = get_node("/root/Editor/Level")
onready var cam_container = get_node("/root/Editor/Cam_Container")
onready var editor_cam = cam_container.get_node("Camera2D")

export var cam_spd = 10
var current_item

# Called when the node enters the scene tree for the first time.
func _ready():
	editor_cam.current = true
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
			new_item.set_start_position(get_global_mouse_position())
			print("item placed !")
	#########################
#	if(current_item != null and can_place and Input.is_action_just_pressed("ui_select")):
#		var new_item = current_item.instance()
#		level.add_child(new_item)
#		new_item.global_position = get_global_mouse_position()
#		print("item placed !")
	
	move_editor_cam()
	is_panning = Input.is_action_pressed("mb_middle")
	
func move_editor_cam():
	if Input.is_action_pressed("ui_up"):
		cam_container.global_position.y -= cam_spd
	if Input.is_action_pressed("ui_left"):
		cam_container.global_position.x -= cam_spd
	if Input.is_action_pressed("ui_down"):
		cam_container.global_position.y += cam_spd
	if Input.is_action_pressed("ui_right"):
		cam_container.global_position.x += cam_spd

func _unhandled_input(event):
	if(event is InputEventMouseButton):
		if(event.is_pressed()):
			if(event.button_index == BUTTON_WHEEL_UP):
				editor_cam.zoom -= Vector2(0.1,0.1)
			if(event.button_index == BUTTON_WHEEL_DOWN):
				editor_cam.zoom += Vector2(0.1,0.1)
	if(event is InputEventMouseMotion):
		if(is_panning):
			cam_container.global_position -= event.relative * editor_cam.zoom
