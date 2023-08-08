extends RayCast2D

@onready var intersection_info : Dictionary = {}
@onready var result : bool = false
@onready var updated : bool = false

# This class is for abstract Raycast only, that will not cast rays by themselves.
# There are called by Special_Action_Handler.gd when required.
func _ready():
	set_enabled(false) 
	pass # Replace with function body.
