@tool
extends Node2D

signal spray_collected(graffspray_node)

@export var color : Color setget set_color # (Color, RGBA)
var color_dark = Color.BLACK

func set_color(c : Color):
	color = c
	color_dark = c.darkened(0.18)
	if Engine.editor_hint:
		update_color()

func update_color():
	var sprite_m : ShaderMaterial = $Sprite2D.material
	sprite_m.set_shader_parameter("color_light", color)
	sprite_m.set_shader_parameter("color_dark", color_dark)
	var g = Gradient.new()
	g.set_color(0, Color.WHITE)
	g.set_color(1, color)
	g.add_point(0.5, Color.WHITE)
	g.add_point(0.8, color)
	$CloudParticles.color_ramp = g
	$Sprite2D/LightSmall.color = color.lightened(0.9)

func _ready():
	update_color()

################################################################################
func _on_Area2D_body_entered(body):
	collect()

func collect():
	print(name+" collected!")
	emit_signal("spray_collected", self)
	GlobalEffect.make_distortion(self.global_position, 0.5, "subtle")
	$AnimationPlayer.play("collect")
	await $AnimationPlayer.animation_finished
	queue_free()
