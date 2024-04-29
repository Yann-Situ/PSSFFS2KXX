@icon("res://assets/art/icons/ambient-r-16.png")
extends Node2D
class_name AmbientHandler
## handle the different AmbientData around.
## It must have an area2D that detects the AmbientArea and manage the resulting
## ambient_data
@export var ambient_data_floor : AmbientData
@export var ambient_data_air : AmbientData
@export var ambient_data_wall : AmbientData
var ambient_data : AmbientData = null

func has_ambient() -> bool:
	return ambient_data != null # TEMPORARY
