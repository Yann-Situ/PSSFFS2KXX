extends TileMap

func _ready():
	self.z_as_relative = false
	self.z_index = Global.z_indices["foreground_0"]
