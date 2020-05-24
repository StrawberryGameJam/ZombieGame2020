extends KinematicBody2D

export var id = 0
export var speed = 250
onready var raycast = $RayCast2D
var velocity = Vector2()
var start_position = Vector2()
func set_start(start):
	start_position = start
func _ready():
	yield(get_tree(), "idle_frame")
	get_tree().call_group("zombies", "set_player", self)
#	Global.mouse_mode("aim")
	set_process_input(true)
	set_physics_process(true)
	set_process(false)
	add_to_group("Player")
func _input(event):
	if event is InputEventKey and event.pressed:
		if event.scancode == KEY_B:
			$Camera2D.zoom = $Camera2D.zoom - Vector2(0.1, 0.1)
		if event.scancode == KEY_V:
			$Camera2D.zoom = $Camera2D.zoom + Vector2(0.1, 0.1)

func get_input():
	velocity = Vector2()
	if Input.is_action_pressed('ui_right'):
		velocity.x += 1
	if Input.is_action_pressed('ui_left'):
		velocity.x -= 1
	if Input.is_action_pressed('ui_up'):
		velocity.y -= 1
	if Input.is_action_pressed('ui_down'):
		velocity.y += 1
	velocity = velocity.normalized() * speed
	
	if Input.is_action_pressed("shoot"):
		var coll = raycast.get_collider()
		if raycast.is_colliding() and coll.has_method("kill"):
			coll.kill()

#func _physics_process(delta):
#	get_input()
#	velocity = move_and_slide(velocity)
func _physics_process(delta):
	
	get_input()
	velocity = move_and_slide(velocity)
	var rel_mouse_pos = $Camera2D.get_mouse_relative_position(global_position)
	rotation = rel_mouse_pos.angle()
	
	pass
func kill():
	print("infelizmente morri")
	position = start_position
	
 
	
