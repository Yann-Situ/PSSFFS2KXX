extends Node2D

# Called when the node enters the scene tree for the first time.
func _ready():
	pass

func apply_palette_scheme(palette : PaletteScheme):
	if palette.gradients.size() < 4:
		push_warning("not enough gradients ("+str(palette.gradients.size())+"<4)")
		return
	var m : ShaderMaterial = $Sprite.material

	var gt_skin = GradientTexture.new()
	gt_skin.set_gradient(palette.get_gradient(0))
	m.set_shader_param("grad_skin", gt_skin)
	var gt_1 = GradientTexture.new()
	gt_1.set_gradient(palette.get_gradient(1))
	m.set_shader_param("grad_1", gt_1)
	var gt_2 = GradientTexture.new()
	gt_2.set_gradient(palette.get_gradient(2))
	m.set_shader_param("grad_2", gt_2)
	var gt_3 = GradientTexture.new()
	gt_3.set_gradient(palette.get_gradient(3))
	m.set_shader_param("grad_3", gt_3)
