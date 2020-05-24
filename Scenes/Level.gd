extends Node2D

var Room = preload("res://Scenes/Room.tscn")
var Player = preload("res://Character.tscn")
var font = preload("res://assets/RobotoBold120.tres")
onready var Map = $TileMap
onready var STimer = $Timer
var tile_size = 32  # size of a tile in the TileMap
var num_rooms = 12 # number of rooms to generate
var min_size = 4 # minimum room size (in tiles)
var max_size = 10  # maximum room size (in tiles)
var hspread = 400  # horizontal spread (in pixels)
var cull = 0  # chance to cull room
var criou = false
var count = 0
var room_positions = []

var min_h = 0
var max_h = 0
var min_w = 0
var max_w = 0

var path #= AStar.new()# AStar pathfinding object
var start_room = null
var end_room = null
var play_mode = false  
var player = null
var zombie = null
 
func _ready():
	randomize()
	make_rooms(0, 0)
	
	
func make_rooms(pos_x, pos_y):
	for i in range(num_rooms):
		var pos = Vector2(pos_x, pos_y)
		var r = Room.instance()
		var w = min_size + randi() % (max_size - min_size)
		var h = min_size + randi() % (max_size - min_size)
		r.make_room(pos, Vector2(w, h) * tile_size)
		$Rooms.add_child(r)
	# wait for movement to stop
	yield(get_tree().create_timer(1.1), 'timeout')
	# cull rooms
	var counter = count
	var coos = 0
	var a = $Rooms.get_children()
	for room in a.slice(count, len(a)-1):
		if randf() < cull:
			$Rooms.remove_child(room)
		else:
			room.mode = RigidBody2D.MODE_STATIC
			room_positions = room_positions  + [Vector3(room.position.x, room.position.y, 0)]
			count += 1
			if(room.position.x > max_h + 100):
				max_h = room.position.x
			elif(room.position.x < min_h - 100):
				min_h = room.position.x
			if(room.position.y < min_w + 100):
				min_w = room.position.y
			elif(room.position.y > max_w - 100):
				max_w = room.position.y
		counter += 1
	criou = false
	print(coos)
	yield(get_tree(), 'idle_frame')
	# generate a minimum spanning tree connecting the rooms
	room_positions.append(Vector3(pos_x, pos_y, 0))
	path = find_mst(room_positions)
	make_map()

func _draw():
	if start_room:
		draw_string(font, start_room.position-Vector2(125,0), "start", Color(1,1,1))
	if end_room:
		draw_string(font, end_room.position-Vector2(125,0), "end", Color(1,1,1))

func _process(delta):
	update()
func _on_Timer_timeout():
	pass
	#var n_zombie = Zombie.instance()
	#add_child(n_zombie)
	#n_zombie.position = end_room.position
	#n_zombie.set_player(player)
	#$Timer.start(3)
func _input(event):
	if event.is_action_pressed('ui_cancel'):
		player = Player.instance()
		add_child(player)
		find_start_room()
		find_end_room()
	
		player.position = start_room.position
		player.set_start(start_room.position)
		play_mode = true
		#zombie = Zombie.instance()
		#add_child(zombie)
		#zombie.position = end_room.position
		#$Timer.connect("timeout", self, "_on_Timer_timeout")
		#zombie.set_player(player)
		#$Timer.start(3)

func find_mst(nodes):
	# Prim's algorithm
	# Given an array of positions (nodes), generates a minimum
	# spanning tree
	# Returns an AStar object
	
	# Initialize the AStar and add the first point
	path = AStar.new()
	var nodes1 = nodes + []
	path.add_point(path.get_available_point_id(), nodes1.pop_front())
	
	# Repeat until no more nodes remain

	while nodes1:
		var min_dist = INF  # Minimum distance so far
		var min_p = null  # Position of that node
		var p = null  # Current position
		# Loop through points in path
		for p1 in path.get_points():
			p1 = path.get_point_position(p1)
			# Loop through the remaining nodes
			for p2 in nodes1:
				# If the node is closer, make it the closest
				if p1.distance_to(p2) < min_dist:
					min_dist = p1.distance_to(p2)
					min_p = p2
					p = p1
		# Insert the resulting node into the path and add
		# its connection
		var n = path.get_available_point_id()
		path.add_point(n, min_p)
		path.connect_points(path.get_closest_point(p), n)
		# Remove the node from the array so it isn't visited again
		nodes1.erase(min_p)
	return path
		
func make_map():
	# Create a TileMap from the generated rooms and path
	Map.clear()
	
	# Fill TileMap with walls, then carve empty rooms
	var full_rect = Rect2()
	for room in $Rooms.get_children():
		var r = Rect2(room.position-room.size,
					room.get_node("CollisionShape2D").shape.extents*2)
		full_rect = full_rect.merge(r)
	var topleft = Map.world_to_map(full_rect.position)
	var bottomright = Map.world_to_map(full_rect.end)
	for x in range(topleft.x-10, bottomright.x+10):
		for y in range(topleft.y-10, bottomright.y+10):
			Map.set_cell(x, y, 1)	
#
#	# Carve rooms
	var corridors = []  # One corridor per connection
	for room in $Rooms.get_children():
		var s = (room.size / tile_size).floor()
		var pos = Map.world_to_map(room.position)
		var ul = (room.position / tile_size).floor() - s
		for x in range(2, s.x * 2 - 1):
			for y in range(2, s.y * 2 - 1):
				Map.set_cell(ul.x + x, ul.y + y, 0)
		# Carve connecting corridor
		var p = path.get_closest_point(Vector3(room.position.x, 
											room.position.y, 0))
		for conn in path.get_point_connections(p):
			if not conn in corridors:
				var start = Map.world_to_map(Vector2(path.get_point_position(p).x,
													path.get_point_position(p).y))
				var end = Map.world_to_map(Vector2(path.get_point_position(conn).x,
												path.get_point_position(conn).y))									
				carve_path(start, end)
		corridors.append(p)
				
func carve_path(pos1, pos2):
	# Carve a path between two points
	var x_diff = sign(pos2.x - pos1.x)
	var y_diff = sign(pos2.y - pos1.y)
	if x_diff == 0: x_diff = pow(-1.0, randi() % 2)
	if y_diff == 0: y_diff = pow(-1.0, randi() % 2)
	# choose either x/y or y/x
	var x_y = pos1
	var y_x = pos2
	if (randi() % 2) > 0:
		x_y = pos2
		y_x = pos1
	for x in range(pos1.x, pos2.x, x_diff):
		Map.set_cell(x, x_y.y, 0)
		Map.set_cell(x, x_y.y + y_diff, 0)  # widen the corridor
	for y in range(pos1.y, pos2.y, y_diff):
		Map.set_cell(y_x.x, y, 0)
		Map.set_cell(y_x.x + x_diff, y, 0)
	
func find_start_room():
	var min_x = INF
	for room in $Rooms.get_children():
		if room.position.x < min_x:
			start_room = room
			min_x = room.position.x

func find_end_room():
	var max_x = -INF
	for room in $Rooms.get_children():
		if room.position.x > max_x:
			end_room = room
			max_x = room.position.x
	var gate = Sprite.new()
	gate.texture = load("res://icon.png")
	end_room.add_child(gate)
	gate.position = end_room.size
	gate.position.x -=32
	gate.position.y = 0
	gate.centered  = true
