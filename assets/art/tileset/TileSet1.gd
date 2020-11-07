tool
extends TileSet

var brick_BG = [find_tile_by_name("brick-BG-ext"), find_tile_by_name("brick-BG-in")]
# Script for tileset
func _is_tile_bound(drawn_id, neighbor_id):
	if not drawn_id in brick_BG :
		return (neighbor_id != -1) and \
			(neighbor_id != find_tile_by_name("stairs_floating")) and \
			(not neighbor_id in brick_BG)
	else :
		return (neighbor_id in brick_BG)

