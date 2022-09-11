extends Node2D

export (NodePath) var platform setget set_platform
export (Curve2D) var curve setget set_curve
var platform_node = null

func set_platform(p : NodePath):
	platform = p
	platform_node = get_node(p)
	$Path2D/PathFollow2D/RemoteTransform2D.remote_path = $Path2D/PathFollow2D/RemoteTransform2D.get_path_to(platform_node)
	
func set_curve(c : Curve2D):
	curve = c
	$Path2D.curve = c
	
# Called when the node enters the scene tree for the first time.
func _ready():
	set_platform(platform)
	# set_curve(curve) # TODO : wait for godot4 with the curve2D in the inspector
	$AnimationPlayer.play("moving")

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	$Path2D/PathFollow2D/RemoteTransform2D.force_update_cache()
