extends Control

@export var activated : bool = false : set = set_activated
@onready var player = get_parent().get_parent()

func set_activated(v:bool):
	activated = v
	self.set_process(v)

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	var s=Vector2.ZERO
	s = player.S.velocity * 1.0/player.walk_speed_max
	$SpriteVelocity.set_scale(Vector2(0.5,0.2+1.3*s.length()))
	$SpriteVelocity.set_rotation(Vector2.UP.angle_to(s))
