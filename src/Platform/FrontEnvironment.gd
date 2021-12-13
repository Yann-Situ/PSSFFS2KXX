extends TileMap

# Called when the node enters the scene tree for the first time.
func _ready():
	self.z_as_relative = false
	self.z_index = Global.z_indices["foreground_1"]
