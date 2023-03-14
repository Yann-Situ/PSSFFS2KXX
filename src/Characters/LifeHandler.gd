extends Node2D

signal took_damage
signal died
signal life_changed

@export var max_life = 10.0#hp
@export var defense = 0.0#hp
@export var weakness = 1.0#hp/hp
@export var strength = 0.0#hp
# the damage of an attack is : damage = trg.weakness * src.strength - trg.defense

@export var timer_tick = 0.05#s
@onready var life = max_life : set = set_life

@onready var Character = get_parent()
@onready var S = Character.get_node("State")

@onready var life_modifiers = [] # contains Vector2(nb_remaining_ticks, amount_per_tick)
var timer

func set_life(v):
	if v <= 0.0:
		died.emit()
	life = clamp(v, 0.0, max_life)
	#print("life : "+str(life))
	#$Sprite2D.modulate = Color((life/max_life),(life/max_life)*0.5,(life/max_life)*0.8)
	life_changed.emit(life)
	
func add_life(lp):
	set_life(life+lp)

func reset_life():
	set_life(max_life)

func _ready():
	self.add_to_group("damageables")
	timer = Timer.new()
	timer.name = "LifeTimer"
	timer.one_shot = false
	timer.autostart = false
	timer.wait_time = timer_tick
	timer.timeout.connect(self.update_life_tick)
	self.add_child(timer)

func apply_damage(damage : float, duration : float = 0.0):
	var d = weakness * damage - defense
	apply_life(- max(0.0, d), duration)
	took_damage.emit(damage)
	
func apply_life(lifepoint : float, duration : float = 1.0):
	var nb_ticks : int = max(ceil(duration/timer_tick), 1)
	var life_per_tick = lifepoint/nb_ticks
	life_modifiers.push_back(Vector2(nb_ticks, life_per_tick))
	if timer.is_stopped():
		timer.start()

func update_life_tick():
	var temp = []
	var life_point = 0.0
	var v = life_modifiers.pop_back()
	while v != null:
		life_point += v.y
		v.x -= 1
		if v.x > 0:
			temp.push_back(v)
		v = life_modifiers.pop_back()
	life_modifiers = temp
	add_life(life_point)
	if life_modifiers.is_empty():
		timer.stop()
