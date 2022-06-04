extends PhysicBody
class_name Ball, "res://assets/art/ball/ball_test.png"

var impact_particles = [preload("res://src/Effects/ImpactParticle1.tscn"),
	preload("res://src/Effects/ImpactParticle0.tscn")]

signal is_destroyed

var selected = false # if selected by mouse
var holder = null # if hold by player
onready var Highlighter = $Highlighter

enum IMPACT_EFFECT {SPIKY, METALLIC}
export (IMPACT_EFFECT) var impact_effect = IMPACT_EFFECT.SPIKY
export (float) var dust_threshold = 300
export (float) var impact_threshold = 500

func _ready():
	self.z_as_relative = false
	self.z_index = Global.z_indices["ball_0"]
	add_to_group("balls")
	add_to_group("damageables")

#func _draw():
#	# draw collision normal
#	draw_line(Vector2(0.0,0.0), Vector2(0.0,0.0)+50.0*normal_colision, color_colision)

###########################################################
func reset_position():
	if holder != null:
		throw(Vector2.ZERO,Vector2.ZERO)
	global_position = start_position
	
func collision_effect(collider, collider_velocity, collision_point, collision_normal):
	var speed = (linear_velocity-collider_velocity).length()
	if speed >= dust_threshold:
		$Effects/DustParticle.restart()
		if speed >= impact_threshold:
			var impact = impact_particles[impact_effect].instance()
			get_parent().add_child(impact)
			impact.global_position = collision_point
			impact.start()
	return true

###########################################################

func change_holder(new_holder : Node):
	if holder != null:
		holder.free_ball(self)
	holder = new_holder
	# WARNING : the game seems to crash when calling change_holder(null) with holder = null on the following line
	get_parent().remove_child(self)
	if new_holder == null:
		Global.get_current_room().add_child(self)
	else :
		new_holder.add_child(self) 

func pickup(holder_node):
	if not holder_node.is_in_group("holders"):
		print("error["+name+"], holder_node is not in group `holders`.")
	change_holder(holder_node)
	self.disable_physics()
	self.z_index = holder_node.z_index+1
	on_pickup(holder_node)

func throw(posi, velo):
	#$TrailHandler.set_node_to_trail(self)
	#$TrailHandler.start(2.0,0.1)
	self.enable_physics()
	var previous_holder = holder
	change_holder(null)
	global_position = posi
	linear_velocity = velo
	self.z_index = Global.z_indices["ball_0"]
	on_throw(previous_holder)

func destruction(delay : float = 0.0):
	if delay > 0.0:
		yield(get_tree().create_timer(delay), "timeout")
	if holder != null:
		change_holder(null)
	$Animation.play("destruction") # will call _queue_free
	#TODO need to handle the selector of the player
	self.disable_physics()
	$Highlighter.toggle_selection(false)
	
func _queue_free():
	print("DESTROYED")
	emit_signal("is_destroyed")
	print("DEAD")
	queue_free()
	
################################################################################

func on_pickup(holder_node : Node):
	pass

func on_throw(previous_holder : Node):
	pass

func on_dunk(basket : Node = null):
	$Animation.stop()
	$Animation.play("dunk")

func on_goal():
	pass
	
func on_destruction():
	pass

func apply_damage(damage : float, duration : float = 0.0):
	destruction(0.0)

################################################################################

func power_p(player,delta):
	if holder == null :
		add_force("attract", player.attract_force*(player.position - position).normalized())

func power_jp(player,delta):
	pass

func power_jr(player,delta):
	if holder == null :
		remove_force("attract")

