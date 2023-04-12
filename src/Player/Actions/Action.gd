@icon("res://assets/art/icons/action.png")
extends Node
class_name Action

@onready var P : Player = get_parent().get_parent()
@onready var S = P.get_node("State")
