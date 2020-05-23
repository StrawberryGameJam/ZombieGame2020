extends KinematicBody2D
 
const SPEED = 200
 
onready var raycast = $RayCast2D
#onready var map_navigation = get_parent().get_node("Navigation2D")
 
var destination
var player = null
 
func _ready():
	add_to_group("zombies")
 
func _physics_process(delta):
	if player == null:
		return
		
#	destination = map_navigation.get_closest_point(player.get_global_position())
#	var path_to_destination = map_navigation.get_simple_path(get_global_position(), destination)
#	var starting_point = get_global_position()
#	var move_dist = SPEED * delta
#
#	for point in range(path_to_destination.size()):
#		var distance_to_next_point = starting_point.distance_to(path_to_destination[0])
#		if move_dist <= distance_to_next_point:
#			var move_rotation = get_angle_to(starting_point.linear_interpolate(path_to_destination[0], move_dist / distance_to_next_point))
#			var motion = Vector2(SPEED, 0).rotated(move_rotation)
#			move_and_slide(motion)
#			break
#
#		move_dist -= distance_to_next_point
#		starting_point = path_to_destination[0]
#		path_to_destination.remove(0)
		
		
	var vec_to_player = player.global_position - global_position
	vec_to_player = vec_to_player.normalized()
	global_rotation = atan2(vec_to_player.y, vec_to_player.x)
	move_and_slide(vec_to_player * SPEED)
   
	if raycast.is_colliding():
		var coll = raycast.get_collider()
		if coll.name == "Player":
			coll.OneHit(200)
 


func kill():
	queue_free()
 
func set_player(p):
	player = p
