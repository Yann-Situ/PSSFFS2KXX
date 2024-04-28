extends Control

@export var activated : bool = false : set = set_activated
@export var player : NewPlayer

func set_activated(v:bool):
	activated = v
	self.set_process(v)
	self.set_visible(v)

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass # TODO if useful
