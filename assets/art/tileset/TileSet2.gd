tool
extends TileSet

# Script for tileset
func _is_tile_bound(drawn_id, neighbor_id):
	return (neighbor_id != -1)
