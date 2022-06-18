extends TileMap

# preloads :
var basket = preload("res://src/Items/Baskets/Basket.tscn")
var spawner = preload("res://src/Items/Activables/Spawner.tscn")
var button = preload("res://src/Items/Activables/Button0.tscn")
var jumper = preload("res://src/Items/Dynamics/Jumper.tscn")
var door = preload("res://src/Items/Interactive/Door.tscn")
var breakableBloc = preload("res://src/Items/Interactive/BreakableBloc.tscn")
var spikes = preload("res://src/Items/Interactive/Spikes.tscn")

var o = Vector2(1,1)

# Called when the node enters the scene tree for the first time.
func _ready():
	self.z_as_relative = false
	self.z_index = Global.z_indices["foreground_1"]

	############# Interactive tiles :
	var usedCells = get_used_cells()
	for cell in usedCells:
		var tile_id = get_cellv(cell)
		var instance = null
		match tile_set.tile_get_name(tile_id):
			"basket0" :
				instance = basket.instance()
				instance.position = map_to_world(cell+Vector2(1,0))
			"spawner0" :
				instance = spawner.instance()
				instance.position = map_to_world(cell+Vector2(1,1))
			"jumper0" :
				instance = jumper.instance()
				instance.position = map_to_world(cell+Vector2(1,1))
			"breakablebloc0" :
				instance = breakableBloc.instance()
				instance.position = map_to_world(cell+Vector2(1,1))
			"spikes" :
				instance = spikes.instance()
				instance.position = map_to_world(cell)+Vector2(8,8)
			"buttons0" :
				instance = button.instance()
				instance.position = map_to_world(cell+Vector2(1,1))

				assert(tile_set.tile_get_tile_mode(tile_id) == 2)
				const atlas_index : int = get_cell_autotile_coord(cell.x,cell.y).x
				#print("button : "+str(cell)+" --- "+str(atlas_index))
				instance.activated = (atlas_index % 2 == 1)
				instance.button_type = (atlas_index / 2)
			"doors0" :
				instance = door.instance()
				instance.position = map_to_world(cell+Vector2(1,2))

				assert(tile_set.tile_get_tile_mode(tile_id) == 2)
				const atlas_index : int = get_cell_autotile_coord(cell.x,cell.y).x
				#print("door : "+str(cell)+" --- "+str(atlas_index))
				instance.activated = (atlas_index % 2 == 1)
				instance.visual_type = (atlas_index / 2)
			_ :
				pass
		if instance != null:
			const pose = get_angle(cell.x, cell.y)
			if "flip_h" in instance:
				instance.flip_h = pose[1]
			if "global_rotation" in instance:
				instance.global_rotation = pose[0]
			add_child(instance)
			set_cellv(cell, -1) # clear the cell

func get_angle(x, y):
	var xflip = is_cell_x_flipped(x, y)
	var yflip = is_cell_y_flipped(x, y)
	var transpose = is_cell_transposed(x, y)
	if !yflip and !transpose:
		return [0.0, xflip]
	elif yflip  and !transpose  :
		return [PI, !xflip]
	elif !yflip and transpose :
		return [PI/2, !xflip]
	elif yflip and transpose :
		return [-PI/2, xflip]
