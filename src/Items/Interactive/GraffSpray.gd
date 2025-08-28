#@tool # some temporary tool problems
extends Node2D

signal spray_collected(graffspray_node)

@export var color : Color :
	set = set_color # (Color, RGBA)
var color_dark = Color.BLACK
var collected = false

func set_color(c : Color):
	color = c
	color_dark = c.darkened(0.18)
	if Engine.is_editor_hint():
		update_color() # WARNING: Sprite2D not yet created...

func update_color():
	var sprite_m : ShaderMaterial = $Sprite2D.material
	sprite_m.set_shader_parameter("color_light", color)
	sprite_m.set_shader_parameter("color_dark", color_dark)
	var g = Gradient.new()
	g.set_color(0, Color.WHITE)
	g.set_color(1, color)
	g.add_point(0.3, Color.WHITE)
	g.add_point(0.7, color)
	$CloudParticles.color_ramp = g
	$Sprite2D/LightSmall.color = color.lightened(0.9)

func _ready():
	update_color()

################################################################################
func _on_Area2D_body_entered(body):
	if not collected:
		collect()

func collect():
	print(name+" collected!")
	collected = true
	spray_collected.emit(self)
	GlobalEffect.make_distortion(self.global_position, 0.5, "subtle")
	$AnimationPlayer.play("collect")
	$AudioGoal.play()
	#GlobalEffect.bus_fade_out("MusicMaster", 0.5)
	##await $AnimationPlayer.animation_finished
	#GlobalEffect.bus_fade_in("MusicMaster", 5.0)
	await $AudioGoal.finished
	queue_free()
