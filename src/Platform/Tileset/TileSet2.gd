@tool
extends TileSet

# Script for tileset
func _is_tile_bound(drawn_id, neighbor_id):
	if drawn_id in [find_tile_by_name("wood-window")]:
		return (neighbor_id != -1) and \
			(neighbor_id == find_tile_by_name("wood-window"))
			
	return (neighbor_id != -1)

