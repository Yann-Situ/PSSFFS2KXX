extends HBoxContainer

@onready var progress_bar = self.get_node("LifeBar")
@export_node_path("RichTextLabel") var label_path
@onready var label = self.get_node(label_path)

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func set_max_life(max_life : float):
	progress_bar.max_value = max_life

func set_life(life : float):
	progress_bar.value = life
	#label.text = str(floor(progress_bar.value))+ " / "+str(floor(progress_bar.max_value))
