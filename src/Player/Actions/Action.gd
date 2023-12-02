@icon("res://assets/art/icons/action.png")
extends Node
class_name Action

@export var P: Player
@onready var S = P.get_state_node()
