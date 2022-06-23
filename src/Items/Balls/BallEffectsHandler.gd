extends Node2D

export(Color, RGBA) var col1 setget set_col1
export(Color, RGBA) var col2 setget set_col2
export(Color, RGBA) var col3 setget set_col3
var gradient_destruction := Gradient.new()
var gradient_construction := Gradient.new()
var gradient_dunk := Gradient.new()
var gradient_main := Gradient.new()

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
	0.0: Color(1.0,1.0,1.0,0.0),
	0.25: col1,
	0.5: col2,
	0.75: Color(col3.r,col3.g,col3.b,0.7*col3.a),
	1.0: Color(0.2,0.2,0.2,0.0)
	}
	var gradient_data_dunk := {
	0.0: Color(1.0,1.0,1.0,0.0),
	0.2: col1,
	0.5: Color(col2.r,col2.g,col2.b,0.68*col2.a),
	0.8: Color(col3.r,col3.g,col3.b,0.35*col3.a),
	1.0: Color(0.0,0.0,0.0,0.0)
	}
	var gradient_data_main := {
	0.0: col1,
	0.5: col2,
	1.0: col3
	}
	var destruction_offsets = gradient_data_destruction.keys()
	gradient_destruction.offsets = destruction_offsets
	gradient_destruction.colors = gradient_data_destruction.values()
	
	destruction_offsets.invert()
	gradient_construction.offsets = destruction_offsets
	gradient_construction.colors = gradient_data_destruction.values()
	
	gradient_dunk.offsets = gradient_data_dunk.keys()
	gradient_dunk.colors = gradient_data_dunk.values()
	
	gradient_main.offsets = gradient_data_main.keys()
	gradient_main.colors = gradient_data_main.values()
	
func _ready():
	$Reconstruction.color_ramp = gradient_construction
	$Destruction.color_ramp = gradient_destruction
	$DunkParticles.color_ramp = gradient_dunk
