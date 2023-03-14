extends Area2D
#Highlighter
@onready var ball = get_parent()
@export var selection_color : Color = Color(1.0,1.0,0.7) #: set = set_selection_color
var selection_color_mid = Color(selection_color.r*0.5, selection_color.g*0.5, selection_color.b*0.5)
var sprite_selection
var sprite_material
# Called when the node enters the scene tree for the first time.
func _ready():
	sprite_selection = ball.get_node("Sprite2D/Sprite_Selection")
	sprite_material = ball.get_node("Sprite2D").material
	#mouse_entered.connect(self._on_Selector_mouse_entered)
	#mouse_exited.connect(self._on_Selector_mouse_exited)
	#input_pickable = true
	pass

func set_selection_color(col):
	#sprite_selection.modulate = col
	sprite_material.set_shader_parameter("contour_color", col)

func toggle_selection(b):
	if b :
		set_selection_color(selection_color)
		#sprite_selection.visible = true
		sprite_material.set_shader_parameter("activated", true)
	else :
		sprite_material.set_shader_parameter("activated", false)
		#sprite_selection.visible = false

func _on_Selector_mouse_entered():
	if !ball.is_selected():
		set_selection_color(selection_color_mid)
		#sprite_selection.visible = true
		sprite_material.set_shader_parameter("activated", true)
	Global.mouse_ball = ball

func _on_Selector_mouse_exited():
	if !ball.is_selected():
		#sprite_selection.visible = false
		sprite_material.set_shader_parameter("activated", false)
	if Global.mouse_ball == ball:
		Global.mouse_ball = null
