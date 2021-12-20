extends Node2D

signal tookdamage

export var max_life = 10.0#hp
export var defense = 0.0#hp
export var weakness = 1.0#hp/hp
export var strength = 0.0#hp
# the damage of an attack is : damage = trg.weakness * src.strength - trg.defense

onready var life = max_life setget set_life
onready var trg_life = life setget set_trg_life

onready var Character = get_parent()
onready var S = Character.get_node("State")
var life_tween

func set_life(v):
	if v <= 0.0:
		#emit death
		pass
	life = clamp(v, 0.0, max_life)
	#print("life : "+str(life))
	$Sprite.modulate = Color((life/max_life),(life/max_life)*0.5,(life/max_life)*0.8)

func set_trg_life(v):
	trg_life = clamp(v, 0.0, max_life)

func update_life_tween(lifepoint : float, duration : float):
	var t = 0.0#s
	set_trg_life(trg_life + lifepoint)
	if life_tween.is_active():
		t = life_tween.get_runtime()
		life_tween.remove_all()
	life_tween.follow_property(self, "life", life, self, "trg_life", \
		max(duration,t), Tween.TRANS_LINEAR)
	
#	print("- life : "+str(life))
#	print("- durat : "+str(max(duration,t)))
#	print("- trgt : "+str(trg_life))
	life_tween.start()
	# TODO : not a correct method as the lifepoints are dealed with the speed 
	# of the longest dealer called. We need to find a quicker method.
	
func _ready():
	self.add_to_group("damageables")
	life_tween = Tween.new()
	life_tween.name = "LifeTween"
	add_child(life_tween)

func apply_damage(damage : float, duration : float = 0.05):
	var d = weakness * damage - defense
	update_life_tween(- max(0.0, d), duration)
	
	# emit(tookdamage)
	if life == 0.0:
		life = 0.0
		#emit death

func apply_life(lifepoint : float):
	set_life(life + lifepoint)

func apply_regen(amount : float, rate : float = 0.0, duration : float = -1):
	var real_amount = min(amount, max_life-life)
	var real_duration
	if duration <= 0.0:
		real_duration = real_amount/rate
	else :
		real_duration = real_amount/amount * duration
	
	update_life_tween(real_amount, real_duration)
