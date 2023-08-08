@tool
extends BackBufferCopy

@export var extents : Vector2 = Vector2(128,128) : set = set_extents

@export var water_albedo : Color = Color(0.3, 0.7, 0.9) : set = set_water_albedo
func set_water_albedo(v: Color):
	water_albedo = v
	$ColorRect.material.set_shader_parameter("water_albedo", v)
@export var water_opacity : float = 0.35 : set = set_water_opacity
func set_water_opacity(v: float):
	water_opacity = v
	$ColorRect.material.set_shader_parameter("water_opacity", v)
@export var water_speed : float = 0.1 : set = set_water_speed
func set_water_speed(v: float):
	water_speed = v
	$ColorRect.material.set_shader_parameter("water_speed", v)
@export var wave_distortion : float = 0.012 : set = set_wave_distortion
func set_wave_distortion(v: float):
	wave_distortion = v
	$ColorRect.material.set_shader_parameter("wave_distortion", v)
@export var wave_harmonics : int = 5 : set = set_wave_harmonics
func set_wave_harmonics(v: int):
	wave_harmonics = v
	$ColorRect.material.set_shader_parameter("wave_harmonics", v)
@export var blur : float = 0.5 : set = set_blur
func set_blur(v: float):
	blur = v
	$ColorRect.material.set_shader_parameter("blur", v)

# Called when the node enters the scene tree for the first time.
func _ready():
	visible = true
	update_rectangle()

func set_extents(r : Vector2):
	extents = r
	update_rectangle()

func update_rectangle():
	set_rect(Rect2(-0.5*extents, extents))
	$ColorRect.size = extents
	$ColorRect.position = -0.5*extents
	$ColorRect.material.set_shader_parameter("texture_height", extents.y)
