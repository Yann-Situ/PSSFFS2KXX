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
		match tile_set.tile_get_name(tile_id):
			"basket0" :
				var instance = basket.instance()
				instance.position = map_to_world(cell+Vector2(1,0))
				add_child(instance)
				set_cellv(cell, -1) # clear the cell
			"spawner0" :
				var instance = spawner.instance()
				instance.position = map_to_world(cell+Vector2(1,1))
				add_child(instance)
				set_cellv(cell, -1) # clear the cell
			"jumper0" :
				var instance = jumper.instance()
				instance.position = map_to_world(cell+Vector2(1,1))
				add_child(instance)
				set_cellv(cell, -1) # clear the cell
			"breakablebloc0" :
				var instance = breakableBloc.instance()
				instance.position = map_to_world(cell+Vector2(1,1))
				add_child(instance)
				set_cellv(cell, -1) # clear the cell
			"spikes" :
				var instance = spikes.instance()
				instance.position = map_to_world(cell)+Vector2(8,8)
				add_child(instance)
				set_cellv(cell, -1) # clear the cell
			"buttons0" :
				var instance = button.instance()
				instance.position = map_to_world(cell+Vector2(1,1))
				
				assert(tile_set.tile_get_tile_mode(tile_id) == 2)
				var atlas_pos : int = get_cell_autotile_coord(cell.x,cell.y).x
				print("button : "+str(cell)+" --- "+str(atlas_pos))
				instance.activated = (atlas_pos % 2 == 1)
				instance.button_type = (atlas_pos / 2)
				add_child(instance)
				set_cellv(cell, -1) # clear the cell
			"doors0" :
				var instance = door.instance()
				instance.position = map_to_world(cell+Vector2(1,2))
				
				assert(tile_set.tile_get_tile_mode(tile_id) == 2)
				var atlas_pos : int = get_cell_autotile_coord(cell.x,cell.y).x
				print("door : "+str(cell)+" --- "+str(atlas_pos))
				instance.activated = (atlas_pos % 2 == 1)
				instance.visual_type = (atlas_pos / 2)
				instance.flip_h = is_cell_x_flipped(cell.x, cell.y)
				add_child(instance)
				set_cellv(cell, -1) # clear the cell
			_ :
				pass
			
