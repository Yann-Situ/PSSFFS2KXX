@icon("res://assets/art/icons/heart-r-16.png")
extends Node2D
class_name LifeHandler

signal took_damage
signal is_dead
#signal life_changed

@export var max_life = 10.0#hp
@export var defense = 0.0#hp
@export var weakness = 1.0#hp/hp
# the damage of an attack is : damage = trg.weakness * damage - trg.defense

# @onready var Character = get_parent()
# @onready var S = Character.get_node("State")

@onready var life_alterable = Alterable.new(max_life)

func get_life():
	var life = life_alterable.get_value()
	if life <= 0.0:
		self.is_dead.emit()
	return clamp(life, 0.0, max_life)

func add_life(lifepoint : float):
	var life = life_alterable.get_value()
	apply_life(clamp(lifepoint, -life, max_life-life), 0.0)

func reset_life():
	life_alterable.clear_alterers()
	life_alterable.set_base_value(max_life)

func _ready():
	self.add_to_group("damageables")

func apply_damage(damage : float, duration : float = 0.0):
	var d = weakness * damage - defense
	apply_life(- max(0.0, d), duration)
	took_damage.emit(damage)

func apply_life(lifepoint : float, duration : float = 1.0):
	var alterer = AltererAdditive.new(0.0)
	life_alterable.add_alterer(alterer)
	if duration > 0.0:
		var alterer_tween = self.create_tween()
		alterer_tween.tween_property(alterer, "value", lifepoint, duration).from(0.0)
		alterer_tween.tween_callback(alterer.stop)
	else:
		alterer.set_value(lifepoint)
		alterer.stop()
