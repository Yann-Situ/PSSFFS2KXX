@tool
extends Activable

signal activated_change_signal(b)

enum BUTTON0_TYPE {PERMANENT, TIMER, PHYSICAL}

@export (BUTTON0_TYPE) var button_type : set = set_button_type
@export (float) var wait_time = 1#s
var timer = null

func set_button_type(t):
	button_type = t
	if Engine.editor_hint:
		if button_type == BUTTON0_TYPE.PERMANENT :
			$Sprite2D.set_region_rect(Rect2(0,80,64,16))
			
		elif button_type == BUTTON0_TYPE.TIMER :
			$Sprite2D.set_region_rect(Rect2(64,80,64,16))
			
		elif button_type == BUTTON0_TYPE.PHYSICAL :
			$Sprite2D.set_region_rect(Rect2(128,80,64,16))
		
# Called when the node enters the scene tree for the first time.
func _ready():
	self.z_index = Global.z_indices["background_4"]
	
	if button_type == BUTTON0_TYPE.PERMANENT :
		$Sprite2D.set_region_rect(Rect2(0,80,64,16))
		pass
		
	elif button_type == BUTTON0_TYPE.TIMER :
		$Sprite2D.set_region_rect(Rect2(64,80,64,16))
		timer = Timer.new()
		timer.one_shot = true
		timer.autostart = false
		timer.wait_time = wait_time
		timer.connect("timeout",Callable(self,"_on_Timer_timeout"))
		self.add_child(timer)
		
	elif button_type == BUTTON0_TYPE.PHYSICAL :
		$Sprite2D.set_region_rect(Rect2(128,80,64,16))
		$Area2D.connect("body_exited",Callable(self,"_on_Area2D_body_exited"))
		_on_Area2D_body_exited(null)
	update_Sprite(activated)
		
func update_Sprite(b):
	if is_inside_tree():
		if b:
			$Sprite2D.set_frame(1)
		else:
			$Sprite2D.set_frame(0)


#########################ACTIVABLE#############################################

func on_enable():
	update_Sprite(activated)
	if not Engine.editor_hint:
		emit_signal("activated_change_signal",activated)

func on_disable():
	update_Sprite(activated)
	if not Engine.editor_hint:
		emit_signal("activated_change_signal",activated)

# only if PHYSICAL button :
func _on_Area2D_body_exited(_body):
	if $Area2D.get_overlapping_bodies().size() < 1:
		disable()

func _on_Area2D_body_entered(body):
	print("collision : "+body.name)
	if body.is_in_group("physicbodies") or body.is_in_group("characters"):
		
		print("collision : "+body.name)
		if not activated :
			enable()
			if button_type == BUTTON0_TYPE.TIMER:
				timer.start()

# only if TIMER button :
func _on_Timer_timeout():
	disable()

