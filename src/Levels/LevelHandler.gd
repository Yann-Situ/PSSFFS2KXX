extends Node2D

onready var Level = get_parent()
onready var Transition = $CanvasLayer/Transition

# Called when the node enters the scene tree for the first time.
func _ready():
	$AnimationPlayer.play("transition_in")

func _unhandled_input(event):
	if event is InputEventKey:
		if event.pressed and event.scancode == KEY_R:
			transition_out()
			yield(get_node("AnimationPlayer"), "animation_finished")
			transition_in()

func reload_level():
	#get_tree().change_scene(Level.get_path())
	get_tree().reload_current_scene()

func transition_in():
	$AnimationPlayer.play("transition_in")

func transition_out():
	#var img = get_viewport().get_texture().get_data()
	#img.flip_y()
	#var screenshot = ImageTexture.new()
	#screenshot.create_from_image(img)
	#Transition.texture = screenshot
	$AnimationPlayer.play("transition_out")
