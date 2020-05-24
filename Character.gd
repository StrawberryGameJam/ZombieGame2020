extends KinematicBody2D

export var id = 0
export var speed = 250

var velocity = Vector2()

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

#func _physics_process(delta):
#	get_input()
#	velocity = move_and_slide(velocity)
func _physics_process(delta):
	
	get_input()
	velocity = move_and_slide(velocity)
	var rel_mouse_pos = $Camera2D.get_mouse_relative_position(global_position)
	rotation = rel_mouse_pos.angle()
	
	pass
