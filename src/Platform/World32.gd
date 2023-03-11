@tool
extends TileMap

var stairs_at_left = [Vector2(1,4), Vector2(0,5), Vector2(7,4), Vector2(8,5), Vector2(10,5)]
var stairs_at_righ = [Vector2(0,4), Vector2(1,5), Vector2(6,4), Vector2(9,5), Vector2(11,5)]
var next_to_stairs = [Vector2(4,5), Vector2(5,5), Vector2(6,5)] # next to right, to left, to both
var next_to_stairs_to_change = [Vector2(9,0), Vector2(5,0), Vector2(6,0)]

# Called when the node enters the scene tree for the first time.
func _ready():
	self.z_as_relative = false
	self.z_index = Global.z_indices["foreground_0"]
	

func set_cell(x, y, tile, flip_x=false, flip_y=false, transpose=false, autotile_coord=Vector2()):
	# Write your custom logic here.
	#print("CELL : "+str(tile))
	# to check stairs	
	if autotile_coord in next_to_stairs_to_change:
		#print("cell "+str(Vector2(x,y))+"  auto_tile_coord : "+str(autotile_coord))
		var indleft = get_cell_autotile_coord(x-1,y)
		var indrigh = get_cell_autotile_coord(x+1,y)
		#print("change! "+str(indrigh)+"   "+str(indleft)+"   "+str(tile))
		if (indrigh in stairs_at_righ):
			#print("change! right ")
			autotile_coord = next_to_stairs[0]
		elif (indleft in stairs_at_left):
			#print("change! left ")
			autotile_coord = next_to_stairs[1]
		print(autotile_coord)
	super.set_cell(x, y, tile, flip_x, flip_y, transpose, autotile_coord)
	
	# to update autotile
	#update_bitmask_area(Vector2(x,y))
