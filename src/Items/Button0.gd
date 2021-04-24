extends Activable

enum BUTTON0_TYPE {PERMANENT, TIMER, PHYSICAL}
export (BUTTON0_TYPE) var button_type = BUTTON0_TYPE.PERMANENT
export (float) var wait_time = 1#s
var timer = null

signal activated_change_signal(b)
# Called when the node enters the scene tree for the first time.
func _ready():
	if button_type != BUTTON0_TYPE.PERMANENT :
		$Sprite.set_region_rect(Rect2(64,80,64,16)) 
	
	if button_type == BUTTON0_TYPE.TIMER :
		timer = Timer.new()
		timer.one_shot = true
		timer.autostart = false
		timer.wait_time = wait_time
		timer.connect("timeout", self, "_on_Timer_timeout")
		self.add_child(timer)
		
	elif button_type == BUTTON0_TYPE.PHYSICAL :
		$Area2D.connect("body_exited", self, "_on_Area2D_body_exited")
	
func update_Sprite(b):
	if b:
		$Sprite.set_frame(1)
	else:
		$Sprite.set_frame(0)


#########################ACTIVABLE#############################################

func on_enable():
	update_Sprite(activated)
	emit_signal("activated_change_signal",activated)

func on_disable():
	update_Sprite(activated)
	emit_signal("activated_change_signal",activated)

func _on_Area2D_body_exited(body):
	if $Area2D.get_overlapping_bodies().size() <= 1:
		disable()

func _on_Area2D_body_entered(body):
	print("collision : "+body.name)
	if body.is_in_group("physicbodies") or body is Player:
		
		print("collision : "+body.name)
		if not activated :
			self.enable()
			if button_type == BUTTON0_TYPE.TIMER:
				timer.start()

func _on_Timer_timeout():
	self.disable()

