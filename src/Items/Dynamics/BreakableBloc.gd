extends StaticBody2D

export var momentum_threshold = 0.0 # m*pix/s
onready var momentum_threshold2 = momentum_threshold*momentum_threshold

func _ready():
	self.z_index = Global.z_indices["foreground_4"]
	$DebrisParticle.z_index = Global.z_indices["background_4"]
	add_to_group("breakables")

func apply_impulse(momentum : Vector2):
	if momentum.length_squared() >= momentum_threshold2:
		explode(momentum)

func explode(momentum : Vector2):
	$DebrisParticle.restart()
	$Sprite.visible = false
	collision_layer = 0
	collision_mask = 0
	yield(get_tree().create_timer($DebrisParticle.lifetime*1.5), "timeout")
	queue_free()
	
