extends KinematicBody2D

enum MODE{
	move,
	mouse,
	talk,
	locked
}

export(int) var SPEED = 300
onready var raycast = $RayCast2D

var interacting_areas = []
var mode = MODE.move

func _ready():
	yield(get_tree(), "idle_frame")
	get_tree().call_group("zombies", "set_player", self)
	Global.mouse_mode("aim")
	set_process_input(true)
	set_physics_process(true)
	set_process(false)
	add_to_group("Player")
	$Interaction.connect("area_entered",self,"_on_area_entered")
	$Interaction.connect("area_exited",self,"_on_area_exited")
	$Interaction.add_to_group("Player_inter")
	pass

func change_mode(new_mode):
	match mode:
		MODE.talk:
			$CanvasLayer/Text.hide()
		MODE.mouse:
			$CanvasLayer/Inventory.hide()
		MODE.move:
			pass
		MODE.locked:
			pass
	mode = new_mode
	match mode:
		MODE.talk:
			$CanvasLayer/Text.show()
			Global.mouse_mode("arrow")
		MODE.mouse:
			$CanvasLayer/Inventory.show()
			Global.mouse_mode("arrow")
		MODE.move:
			Global.mouse_mode("aim")
		MODE.locked:
			Global.mouse_mode("arrow")
	pass

func _physics_process(delta):
	match mode:
		MODE.talk:
			if (Input.is_action_just_pressed("ui_accept") or
				Input.is_action_just_pressed("ui_interact") or 
				Input.is_action_just_pressed("shoot")):
				change_mode(MODE.move)
		MODE.mouse:
			if Input.is_action_just_pressed("ui_accept"):
				change_mode(MODE.move)
		MODE.move:
			if Input.is_action_just_pressed("ui_interact"):
				if interacting_areas.empty():
					return
				var area = interacting_areas.back()
				while not $Interaction.overlaps_area(area):
					print("area_missing")
					interacting_areas.erase(area)
					if interacting_areas.empty():
						return
					area = interacting_areas.back()
				var res = area.interact(self)
				change_mode(MODE.talk)
			var velocity = Vector2()
			if Input.is_action_pressed("ui_up"):
				velocity.y -= 1
			if Input.is_action_pressed("ui_down"):
				velocity.y +=1
			if Input.is_action_pressed("ui_left"):
				velocity.x -=1
			if Input.is_action_pressed("ui_right"):
				velocity.x +=1
			if Input.is_action_just_pressed("ui_accept"):
				change_mode(MODE.mouse)
			var rel_mouse_pos = $Camera2D.get_mouse_relative_position(global_position)
			rotation = rel_mouse_pos.angle()
			move_and_slide(SPEED*velocity.normalized())
			if Input.is_action_just_pressed("shoot"):
				var coll = raycast.get_collider()
				if raycast.is_colliding() and coll.has_method("kill"):
					coll.kill()
	
	pass

#func _input(event):
	#if (event is InputEventMouseButton 
	#and event.button_index == 1 
	#and event.pressed):
#	pass

func _on_area_entered(area):
	if area.is_in_group("Interactible"):
		interacting_areas.append(area)

func _on_area_exited(area):
	if area in interacting_areas:
		interacting_areas.erase(area)


 
func kill():
	get_tree().reload_current_scene()
