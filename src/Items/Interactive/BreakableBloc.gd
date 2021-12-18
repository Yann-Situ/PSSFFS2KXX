tool
extends Node2D

export var mass = 5.0 # kg
export var momentum_threshold = 0.0 # m*pix/s
export(PackedScene) var content setget set_content

const DefaultContentImage = preload("res://assets/art/icons/contenticon.png")

onready var momentum_threshold2 = momentum_threshold*momentum_threshold
onready var inv_mass = 1.0/mass

func set_content(temp):
	content = temp
	if Engine.editor_hint:
		if content != null and content.can_instance():
			var inst = content.instance()
			if inst.has_node("Sprite"):
				var s = inst.get_node("Sprite").duplicate()
				s.name = "ContentIcon"
				s.scale = Vector2(0.5,0.5)
				add_child(s)
			else :
				print("test")
				var s = Sprite.new()
				s.set_texture(DefaultContentImage)
				s.name = "ContentIcon"
				add_child(s)
			inst.queue_free()
		elif self.has_node("ContentIcon"):
			get_node("ContentIcon").queue_free()

func _ready():
	self.z_index = Global.z_indices["foreground_4"]
	$DebrisParticle.z_index = Global.z_indices["background_4"]

func apply_explosion(momentum : Vector2):
	if momentum.length_squared() >= momentum_threshold2:
		explode(momentum)

func explode(momentum : Vector2):
	$DebrisParticle.direction = momentum
	$DebrisParticle.initial_velocity = inv_mass * momentum.length()
	$DebrisParticle.restart()
	$Occluder.visible = false
	$Breakable.collision_layer = 0
	$Breakable.collision_mask = 0

	#$Sprite.visible = false
	$Sprite/AnimationPlayer.play("explode")

	if content != null and content.can_instance():
		var inst = content.instance()
		if inst is Node2D:
			inst.global_position = self.global_position
		get_parent().add_child(inst) # TODO put level in global and add it to level
	yield(get_tree().create_timer($DebrisParticle.lifetime*1.5), "timeout")
	queue_free()
