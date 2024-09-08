extends RayCast2D

@export var color_true : Color = Color(1.0,0.3,0.1)
@export var color_false : Color = Color(1.0,0.9,0.5)

@onready var intersection_info : Dictionary = {}
@onready var result : bool = false
@onready var updated : bool = false

# This class is for abstract Raycast only, that will not cast rays by themselves.
# There are called by Special_Action_Handler.gd when required.
func _ready():
	set_enabled(false) 
	pass # Replace with function body.

func _draw(): #
	if Global.DEBUG:
		if result:#r.is_colliding():
			draw_circle(intersection_info.position - self.global_position, 3, color_true)
			draw_line(Vector2.ZERO, self.target_position, color_true, 2.0)
		else :
			draw_line(Vector2.ZERO, self.target_position, color_false, -1.0)

 # Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if Global.DEBUG:
		queue_redraw()
