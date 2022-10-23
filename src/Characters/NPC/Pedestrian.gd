extends Node2D

export (Resource) var palette_sampler

# Called when the node enters the scene tree for the first time.
func _ready():
	var palette_scheme = PaletteScheme.new()
	palette_scheme.set_local_to_scene(true)
	palette_scheme = palette_sampler.sample()
	apply_palette_scheme(palette_scheme)

func apply_palette_scheme(palette : PaletteScheme):
	if palette.gradients.size() < 4:
		push_warning("not enough gradients ("+str(palette.gradients.size())+"<4)")
		return
	var m : ShaderMaterial = $Sprite.material

	var gt_skin = GradientTexture.new()
	gt_skin.set_gradient(palette.gradients[0])
	m.set_shader_param("grad_skin", gt_skin)
	var gt_1 = GradientTexture.new()
	gt_1.set_gradient(palette.gradients[1])
	m.set_shader_param("grad_1", gt_1)
	var gt_2 = GradientTexture.new()
	gt_2.set_gradient(palette.gradients[2])
	m.set_shader_param("grad_2", gt_2)
	var gt_3 = GradientTexture.new()
	gt_3.set_gradient(palette.gradients[3])
	m.set_shader_param("grad_3", gt_3)

func _input(event):
	if event is InputEventKey and event.pressed:
		if event.scancode == KEY_T:
			var palette_scheme = PaletteScheme.new()
			palette_scheme.set_local_to_scene(true)
			palette_scheme = palette_sampler.sample()
			apply_palette_scheme(palette_scheme)
