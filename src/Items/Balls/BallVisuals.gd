@tool
extends Sprite2D

@export var col1 : Color :
	set = set_col1 # (Color, RGBA)
@export var col2 : Color :
	set = set_col2 # (Color, RGBA)
@export var col3 : Color :
	set = set_col3 # (Color, RGBA)
var gradient_destruction := Gradient.new()
var gradient_construction := Gradient.new()
var gradient_dunk := Gradient.new()
var gradient_main := Gradient.new()
var gradient_dash := Gradient.new()
var gradient_shader := Gradient.new()

#func _process(delta):
	#update_colors()
	
func set_col1(c : Color):
	col1 = c
	update_colors()
func set_col2(c : Color):
	col2 = c
	update_colors()
func set_col3(c : Color):
	col3 = c
	update_colors()

func update_colors():
	var gradient_data_destruction := {
	0.0: Color(col3.r,col3.g,col3.b,0.0),
	0.25: col3,
	0.5: col2,
	0.75: Color(col1.r,col1.g,col1.b,0.8*col1.a),
	1.0: Color(col1.r,col1.g,col1.b,0.0)
	}
	var gradient_data_dunk := {
	0.0: Color(col1.r,col1.g,col1.b,0.0),
	0.2: col1,
	0.5: Color(col2.r,col2.g,col2.b,0.68*col2.a),
	0.8: Color(col3.r,col3.g,col3.b,0.35*col3.a),
	1.0: Color(col3.r,col3.g,col3.b,0.0)
	}
	var gradient_data_main := {
	0.0: col1,
	0.5: col2,
	1.0: col3
	}
	var gradient_data_shader := {
	0.0: Color(0.2*col3.r,0.2*col3.g,0.2*col3.b,col3.a),
	0.33: col3,
	0.6: col2,
	0.87: col1,
	1.0: Color(0.7+0.3*col1.r,0.7+0.3*col1.g,0.7+0.3*col1.b,col1.a)
	}

	var destruction_offsets = gradient_data_destruction.keys()
	gradient_destruction.offsets = destruction_offsets
	gradient_destruction.colors = gradient_data_destruction.values()

	#destruction_offsets.invert()
	gradient_construction.offsets = destruction_offsets
	gradient_construction.colors = gradient_data_destruction.values()

	gradient_dunk.offsets = gradient_data_dunk.keys()
	gradient_dunk.colors = gradient_data_dunk.values()

	gradient_main.offsets = gradient_data_main.keys()
	gradient_main.colors = gradient_data_main.values()
	
	gradient_shader.offsets = gradient_data_shader.keys()
	gradient_shader.colors = gradient_data_shader.values()

	gradient_dash = gradient_main.duplicate()
	for i in range(gradient_dash.get_point_count()):
		gradient_dash.set_offset(i, 0.5*gradient_dash.get_offset(i))
		var col = gradient_dash.get_color(i)
		col.a *= 0.7
		gradient_dash.set_color(i, col)
	
	if material is ShaderMaterial:
		var g : GradientTexture1D = GradientTexture1D.new()
		g.gradient = gradient_shader
		g.width = 64
		self.material.set_shader_parameter('gradient', g)

func activate_contour(c : Color = Color.TRANSPARENT):
	if c != Color.TRANSPARENT:
		self.material.set_shader_parameter('contour_color', c)
	self.material.set_shader_parameter('contour_activated', true)
		
func desactivate_contour():
	self.material.set_shader_parameter('contour_activated', false)
	
#func _init() -> void:
	#update_colors()

func _ready():
	$Reconstruction.color_ramp = gradient_construction
	$Destruction.color_ramp = gradient_destruction
	$DunkParticles.color_ramp = gradient_dunk
