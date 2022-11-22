tool
extends Node2D

signal spray_collected(graffspray_node)

export(Color, RGBA) var color setget set_color
var color_dark = Color.black

func set_color(c : Color):
	color = c
	color_dark = c.darkened(0.18)
	if Engine.editor_hint:
		update_color()
	
func update_color():
	var sprite_m : ShaderMaterial = $Sprite.material
	sprite_m.set_shader_param("color_light", color)
	sprite_m.set_shader_param("color_dark", color_dark)
	var g = Gradient.new()
	g.set_color(0, Color.white)
	g.set_color(1, color)
	g.add_point(0.5, Color.white)
	g.add_point(0.8, color)
	$CloudParticles.color_ramp = g

func _ready():
	update_color()

################################################################################
func _on_Area2D_body_entered(body):
	collect()
	
func collect():
	print(name+" collected!")
	emit_signal("spray_collected", self)
	GlobalEffect.make_distortion(self.global_position, 0.75, "fast_subtle")
