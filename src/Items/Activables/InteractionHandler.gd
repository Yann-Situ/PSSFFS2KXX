# Interaction handler, that choose the nearest interaction area in it.
@tool
@icon("res://assets/art/icons/info.png")
extends Area2D
class_name InteractionHandler
# @icon("res://assets/art/icons/interaction.png")
signal nearest_interaction_changed(new_nearest : InteractionArea)
signal interacted(interaction_area : InteractionArea)

@export var enabled : bool = true : set = set_enabled
var has_interaction : bool = false : set = set_has_interaction
var nearest_interaction: InteractionArea = null # this can be null

func _init():
	monitorable = false
	collision_layer = 0
	collision_mask = 2048 # interaction layer
	modulate = Color(0.176, 0.922, 0.51, 0.804)
	area_entered.connect(_on_area_entered)
	area_exited.connect(_on_area_exited)

func set_enabled(b):
	enabled = b
	set_process(enabled && has_interaction)
func set_has_interaction(b):
	has_interaction = b
	set_process(enabled && has_interaction)
	if !has_interaction:
		if nearest_interaction != null:
			nearest_interaction = null
			nearest_interaction_changed.emit(nearest_interaction)

func update_nearest_interaction() -> void:
	var areas: Array[Area2D] = get_overlapping_areas()
	var min_dist2: float = INF
	var new_nearest_interaction = null
	for area in areas:
		var dist2 = area.global_position.distance_squared_to(self.global_position)
		if dist2 < min_dist2 and area is InteractionArea and area.enabled:
			min_dist2 = dist2
			new_nearest_interaction = area
	if new_nearest_interaction != nearest_interaction:
		nearest_interaction = new_nearest_interaction
		nearest_interaction_changed.emit(nearest_interaction)

func _process(delta):
	if has_overlapping_areas():
		update_nearest_interaction()

func _on_area_entered(area : Area2D):
	set_has_interaction(true) # potential interaction
	if area is InteractionArea and area.enabled:
		area.enter.call()

func _on_area_exited(area : Area2D):
	if area is InteractionArea and area.enabled:
		area.exit.call()
	if !has_overlapping_areas():
		set_has_interaction(false)

func interact():
	if enabled and nearest_interaction is InteractionArea :
		print("interact with: "+str(nearest_interaction.get_parent().name))
		set_enabled(false)
		nearest_interaction.interact.call(self)
		interacted.emit(nearest_interaction)
		set_enabled(true)
