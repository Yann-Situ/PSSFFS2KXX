extends Ball

@export var enabled = false : set = set_enabled

func _ready():
	super()
	set_enabled(enabled)

func set_enabled(b):
	#print(self.has_node("LightSmall")) # TODO: weird bug, because it returns false. This was not the case before I worked on Wind...
	enabled = b
	if self.has_node("LightSmall"):
		if b :
			$LightSmall.enabled = false
			$LightBack.enabled = true
			$LightFront.enabled = true
		else :
			$LightSmall.enabled = true
			$LightBack.enabled = false
			$LightFront.enabled = false

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
