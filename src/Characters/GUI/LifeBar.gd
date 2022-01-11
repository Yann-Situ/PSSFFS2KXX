extends HBoxContainer

onready var progress_bar = self.get_node("LifeBar")
onready var label = self.get_node("MarginContainer/Background/Label")

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func set_max_life(max_life):
	progress_bar.max_value = max_life

func on_life_changed(life):
	progress_bar.value = life
	label.text = str(floor(progress_bar.value))+ " / "+str(floor(progress_bar.max_value))
