extends Ball

export var enabled = false setget set_enabled

func _ready():
	self.mass = 0.9
	self.set_friction(0.04)
	self.set_bounce(0.6)
	self.set_penetration(0.8)
	set_enabled(enabled)
	
func set_enabled(b):
	print(self.has_node("LightSmall")) # weird bug, because it returns false. This was not the case before I worked on Wind...
	enabled = b
#	if b :
#		$LightSmall.enabled = false
#		$LightBack.enabled = true
#		$LightFront.enabled = true
#	else :
#		$LightSmall.enabled = true
#		$LightBack.enabled = false
#		$LightFront.enabled = false

func on_dunk(basket : Node = null):
	$Animation.stop()
	$Animation.play("dunk")
	$AnimationPlayer.play("flash_light")
	
func power_p(player,delta):
	pass
	
func power_jp(player,delta):
	set_enabled(!enabled)
	
func power_jr(player,delta):
	pass

