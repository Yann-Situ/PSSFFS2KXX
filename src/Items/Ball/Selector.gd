extends Area2D
#Selector
onready var ball = get_parent()
export (bool) var selected = false
export (Color) var selection_color = Color(1.0,1.0,0.7) #setget set_selection_color
var selection_color_mid = Color(selection_color.r*0.5, selection_color.g*0.5, selection_color.b*0.5)

# Called when the node enters the scene tree for the first time.
func _ready():
	#connect("mouse_entered", self, "_on_Selector_mouse_entered")
	#connect("mouse_exited", self, "_on_Selector_mouse_exited")
	#input_pickable = true
	pass

func set_selection_color(col):
	$Sprite_Selection.modulate = col

func toggle_selection(b):
	selected = b
	if selected :
		set_selection_color(selection_color)
		$Sprite_Selection.visible = true
	else :
		$Sprite_Selection.visible = false

func _on_Selector_mouse_entered():
	print("WTF 1")
	if !selected:
		set_selection_color(selection_color_mid)
		$Sprite_Selection.visible = true
	Global.mouse_ball = ball

func _on_Selector_mouse_exited():
	print("WTF 2")
	if !selected:
		$Sprite_Selection.visible = false
	if Global.mouse_ball == ball:
		Global.mouse_ball = null
