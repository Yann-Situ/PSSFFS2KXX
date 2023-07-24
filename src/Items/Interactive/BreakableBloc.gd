# A physical breakable bloc that can contain objectsin it.
@tool
extends Node2D

@export var mass = 5.0 # kg
@export var momentum_threshold = 0.0 # m*pix/s
@export var content: PackedScene : set = set_content

const DefaultContentImage = preload("res://assets/art/icons/contenticon.png")

@onready var momentum_threshold2 = momentum_threshold*momentum_threshold
@onready var inv_mass = 1.0/mass

var _is_exploding = false # to prevent multiple explosion of the same bloc

func set_content(new_content : PackedScene):
	content = new_content
	if Engine.is_editor_hint():
		if content is PackedScene and content.can_instantiate():
			var instance = content.instantiate()
			if instance.has_node("Sprite2D"):
				var s = instance.get_node("Sprite2D").duplicate()
				s.name = "ContentIcon"
				s.scale = Vector2(0.5,0.5)
				add_child(s)
			else :
				var s = Sprite2D.new()
				s.set_texture(DefaultContentImage)
				s.name = "ContentIcon"
				add_child(s)
			instance.queue_free()
		elif self.has_node("ContentIcon"):
			get_node("ContentIcon").queue_free()

func _ready():
	self.z_index = Global.z_indices["foreground_4"]
	$DebrisParticle.z_index = Global.z_indices["background_4"]

func apply_explosion(momentum : Vector2):
	if momentum.length_squared() >= momentum_threshold2:
		explode(momentum)
		return true
	return false

func explode(momentum : Vector2):
	if !_is_exploding: # to prevent multiple explosion of the same bloc
		_is_exploding = true
		$DebrisParticle.direction = momentum
		$DebrisParticle.initial_velocity_min = 0.5*inv_mass * momentum.length()
		$DebrisParticle.initial_velocity_min = 1.5*inv_mass * momentum.length()
		$DebrisParticle.restart()
		$Occluder.visible = false
		$Breakable.collision_layer = 0
		$Breakable.collision_mask = 0

		#$Sprite2D.visible = false
		$Sprite2D/AnimationPlayer.play("explode")
		if content is PackedScene and content.can_instantiate():
			var instance = content.instantiate()
			if instance is Node2D:
				instance.global_position = self.global_position
			Global.get_current_room().add_child(instance)
			print("SPAWN")
		await get_tree().create_timer($DebrisParticle.lifetime*1.5).timeout
		queue_free()
