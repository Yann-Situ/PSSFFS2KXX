extends Activable

@export (PackedScene) var ball = null
@export var initial_velocity = Vector2(0.0,20.0)
@export (int, 0, 256) var nb_max_balls = 64
var nb_balls = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	self.z_index = Global.z_indices["foreground_1"]
	if ball == null:
		ball = preload("res://src/Items/Balls/Ball.tscn")
	var texture = ball.instantiate().get_node("Sprite2D").get_texture()
	var newsprite = Sprite2D.new()
	newsprite.texture = texture
	newsprite.position = Vector2(0.0,0.0)
	newsprite.visible = true
	add_child(newsprite)

func spawn():
	if nb_balls >= nb_max_balls:
		printerr(self.name+" spawned too much balls")
		return
	$Sprite2D/AnimationPlayer.play("spawn")
	var newball = ball.instantiate() # Create a new ball
	newball.connect("is_destroyed",Callable(self,"_on_Ball_is_destroyed"))
	newball.z_index = 0 #TODO change to set ball_z_index
	Global.get_current_room().add_child(newball)

	var ball_position = ($SpawnPosition.position+randf_range(-4.0,4.0)*Vector2.RIGHT)
	ball_position = ball_position.rotated(deg_to_rad(self.rotation_degrees))
	ball_position += global_position
	newball.throw(ball_position, initial_velocity.rotated(deg_to_rad(self.rotation_degrees)))
	#newball.position = position+($SpawnPosition.position+randf_range(-2.0,2.0)*Vector2(1.0,0.0)).rotated(deg_to_rad(self.rotation_degrees))
	#newball.set_linear_velocity(initial_velocity.rotated(deg_to_rad(self.rotation_degrees)))
	#newball.enable_physics()

	nb_balls += 1

#########################ACTIVABLE#############################################

func on_enable():
	spawn()

func _on_Ball_is_destroyed():
	nb_balls -= 1
