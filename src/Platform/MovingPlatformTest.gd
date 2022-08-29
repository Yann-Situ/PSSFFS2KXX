extends Node2D

export (NodePath) var platform setget set_platform
var platform_node = null

func set_platform(p : NodePath):
	platform = p
	platform_node = get_node(p)
	$Path2D/PathFollow2D/RemoteTransform2D.remote_path = $Path2D/PathFollow2D/RemoteTransform2D.get_path_to(platform_node)
	
# Called when the node enters the scene tree for the first time.
func _ready():
	set_platform(platform)
	$AnimationPlayer.play("moving")

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	$Path2D/PathFollow2D/RemoteTransform2D.force_update_cache()
