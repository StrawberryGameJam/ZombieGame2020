extends KinematicBody2D
 
const MOVE_SPEED = 200
 
 
var player = null
var obj = Vector2()
 
func _ready():
	add_to_group("zombies")
# warning-ignore:return_value_discarded
	$Sprite/Area2D.connect("body_entered", self, "attack") 


# warning-ignore:unused_argument
func _process(delta):
	if player == null:
		return
	
	var has_scent = false
	var space_state = get_world_2d().direct_space_state
	var result = space_state.intersect_ray(global_position, player.global_position,[self],player.collision_mask)
	print(result)
	if !result.empty() and result.collider == player:
		obj = - global_position + player.global_position
		has_scent = true
	else:
		for scent in player.scent_trail:
			result = space_state.intersect_ray(global_position, scent.global_position,[self],player.collision_mask)
			if result.empty():
				obj = - global_position + scent.global_position
				has_scent = true
				break
	if not has_scent:
		return
	rotation = obj.angle()
	var vel = (obj.normalized())*MOVE_SPEED
	var res_par_l = space_state.intersect_ray(global_position, $Sprite/Left.global_position)
	var res_par_r = space_state.intersect_ray(global_position, $Sprite/Right.global_position)
	if not res_par_l.empty():
		if not res_par_l.collider == player:
			var deg = rad2deg(res_par_l.normal.angle_to(Vector2(1,0).rotated(rotation)))
			if deg < -90:
				vel = res_par_l.normal.rotated(deg2rad(-90)).normalized()*MOVE_SPEED
			pass
	elif not res_par_r.empty():
		if not res_par_r.collider == player:
			var deg = rad2deg(res_par_r.normal.angle_to(Vector2(1,0).rotated(rotation)))
			if deg > 90:
				vel = res_par_r.normal.rotated(deg2rad(90)).normalized()*MOVE_SPEED
			pass
	move_and_slide(vel)

func attack(body):
	if(body == player):
		body.kill()

func kill():
	queue_free()
 
func set_player(p):
	player = p
