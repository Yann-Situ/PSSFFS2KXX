extends AnimationPlayer


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
onready var Sprite = get_parent()

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func animate_from_state(S):
	if not S.is_onfloor :
		if S.is_aiming : # check aim direction
			set_flip(S.aim_direction == -1, S.aim_direction == 1)
			if assigned_animation != "air_aim":
				self.play("air_aim")
		elif S.is_shooting : # check shoot direction
			set_flip(S.aim_direction == -1, S.aim_direction == 1)
			if assigned_animation != "floor_shoot" and assigned_animation != "air_shoot" :
				self.play("air_shoot")
		else :		
			set_flip(S.move_direction == -1, S.move_direction == 1)
			if S.can_walljump: #HACK MUST BE ON_WALL
				set_flip(S.last_wall_normal_direction == 1, S.last_wall_normal_direction == -1)
				self.play("air_wall")
			elif S.is_falling :
				if assigned_animation != "fall":
					self.play("fall")
			elif S.is_jumping :
				self.play("jump1")
	else : #on floor
		if S.is_aiming : # check aim direction
			set_flip(S.aim_direction == -1, S.aim_direction == 1)
			if S.is_idle :
				if assigned_animation != "floor_idle_aim":
					self.play("floor_idle_aim")
			else :
				if assigned_animation != "floor_run_aim" :
					self.play("floor_run_aim")
		elif S.is_shooting : # check shoot direction
			set_flip(S.aim_direction == -1, S.aim_direction == 1)
			if assigned_animation != "floor_shoot" and assigned_animation != "air_shoot" :
				self.play("floor_shoot")
		else :		
			set_flip(S.move_direction == -1, S.move_direction == 1)
			if S.is_onwall:
				set_flip(S.last_wall_normal_direction == 1, S.last_wall_normal_direction == -1)
				self.play("floor_wall")
			elif S.is_moving_fast and S.direction_p != 0 :
				#self.play("run")
				self.play("walk")
			elif S.is_idle :
				self.play("idle")
			elif S.direction_p != 0 :
				self.play("walk")

func set_flip(b1,b2):
	if b1 :
		Sprite.set_flip_h(true)
	elif b2 :
		Sprite.set_flip_h(false)
		
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
