@icon("res://assets/art/icons/explosion.png")
extends Resource
class_name ExplosionData

## Emitted when a body enter the explosion
signal body_explode(body, direction)

@export var use_default_explosion : bool = true : set = set_use_default_explosion ## Whether or not connect the `default_explode_body` function to the `body_explode` signal.
@export var initial_scale_factor : float = 1.0 ## The explosion goes from 'initial_scale_factor * momentum' at the center, to  'momentum' at the radius. Doesn't apply to damages.

@export var explosion_duration : float = 0.5 ##s
@export_range(1,10) var explosion_steps : int = 5
@export var collision_shape : Shape2D : set = set_collision_shape
@export var path_exceptions : Array[NodePath] = []
# TODO : to check : maybe that's not a good idea to put path_exceptions in the resource,
# because multiple bodies that use the same data can interact with each other... (?)
# Maybe put it as a parameter of Explosion.gd

@export_group("Momentums", "momentum_")
@export var momentum_breakable : float = 0.0 ##kg.pix/s
@export var momentum_electric : float = 0.0 ##kg.pix/s
@export var momentum_physicbody : float = 0.0 ##kg.pix/s

@export_group("Damage", "damage_")
@export var damage_value : float = 0.0 ##hp
@export var damage_duration : float = 0.0 ##s

var shape_radius

func set_use_default_explosion(b : bool):
	use_default_explosion = b
	if use_default_explosion and !body_explode.is_connected(default_explode_body):
		body_explode.connect(default_explode_body)
	elif !use_default_explosion and body_explode.is_connected(default_explode_body):
		body_explode.disconnect(default_explode_body)

func default_explode_body(explosive : CollisionObject2D, direction : Vector2):
	if explosive.is_in_group("breakables"):
		explosive.apply_explosion(momentum_breakable*direction)
	if explosive.is_in_group("electrics"):
		explosive.apply_shock(momentum_electric*direction)
	if explosive.has_method("add_impulse"):
		explosive.add_impulse(momentum_physicbody*direction)
	if explosive.is_in_group("damageables"):
		explosive.apply_damage(damage_value, damage_duration)
	# TODO change for the new Eplosive implementation: just call explosive.explode(parameters)

func set_collision_shape(s : Shape2D):
	collision_shape = s
	if s is CircleShape2D:
		shape_radius = s.radius
	elif s is CapsuleShape2D:
		shape_radius = s.height
	elif s is RectangleShape2D:
		shape_radius = max(s.size.x, s.size.y)
	elif s is SeparationRayShape2D:
		shape_radius = s.length
	elif s is SegmentShape2D:
		shape_radius = 0.5*(s.A-s.B).length()
	else:
		shape_radius = 0.0
		push_warning("this Shape2D sub node is not handled in ExplosionData.")
