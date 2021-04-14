extends Activable

export (PackedScene) var ball = null
export var initial_velocity = Vector2(0.0,20.0)

# Called when the node enters the scene tree for the first time.
func _ready():
	if ball == null:
		ball = preload("res://src/Items/Ball/Ball.tscn")
	var texture = ball.instance().get_node("Sprite").get_texture()
	var newsprite = Sprite.new()
	newsprite.texture = texture
	newsprite.position = Vector2(0.0,0.0)
	newsprite.visible = true
	add_child(newsprite)

func spawn():
	$Sprite/AnimationPlayer.play("spawn")
	var newball = ball.instance() # Create a new ball
	#newball.set_start_position(spawn_position)
	newball.position = position+($SpawnPosition.position+rand_range(-2.0,2.0)*Vector2(1.0,0.0)).rotated(self.rotation_degrees)
	newball.set_linear_velocity(initial_velocity.rotated(self.rotation_degrees))
	newball.enable_physics()
	get_parent().add_child(newball) # Add it as a child of this node.

#func _process(delta):	
#	if Input.is_action_just_pressed('ui_select_alter'):
#		spawn()

#########################ACTIVABLE#############################################

func on_enable():
	spawn()
