extends KinematicBody2D

enum MODE{
	move,
	mouse,
	talk,
	locked
}

export(int) var SPEED = 300

const scent_scene = preload("res://Scenes/Scent.tscn")

var scent_trail = []

var interacting_areas = []
var mode = MODE.move
var bullet_scene = preload("res://Scenes/Player/Bullet.tscn")
var rel_mouse_pos = Vector2()
var velocity = Vector2()

var start_position = Vector2()
func set_start(start):
	start_position = start

func _ready():
	$AnimationPlayer.play("Rifle-Idle")
#	var ScentTimer = Timer.new()
#	add_child(ScentTimer)
#	ScentTimer.autostart = true
#	ScentTimer.wait_time = 0.1
# warning-ignore:return_value_discarded
	$ScentTimer.connect("timeout", self, "add_scent")
	yield(get_tree(), "idle_frame")
	get_tree().call_group("zombies", "set_player", self)
	Global.mouse_mode("aim")
	set_process_input(true)
	set_physics_process(true)
	set_process(false)
	add_to_group("Player")
# warning-ignore:return_value_discarded
	$Interaction.connect("area_entered",self,"_on_area_entered")
# warning-ignore:return_value_discarded
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

# warning-ignore:unused_argument
func _physics_process(delta):
	anim_handler()
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
					interacting_areas.erase(area)
					if interacting_areas.empty():
						return
					area = interacting_areas.back()
# warning-ignore:unused_variable
				var res = area.interact(self)
				change_mode(MODE.talk)
			velocity = Vector2()
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
			rel_mouse_pos = $Camera2D.get_mouse_relative_position(global_position)
			rotation = rel_mouse_pos.angle()
# warning-ignore:return_value_discarded
			move_and_slide(SPEED*velocity.normalized())
			if Input.is_action_just_pressed("shoot"):
				$AnimationPlayer.play("Rifle-Shoot")
				

	
	pass

#func _input(event):
	#if (event is InputEventMouseButton 
	#and event.button_index == 1 
	#and event.pressed):
#	pass
func add_scent():
	var scent      = scent_scene.instance()
	get_parent().add_child(scent)
	scent.player   = self
	scent.position = position
	scent_trail.push_front(scent)


func _on_area_entered(area):
	if area.is_in_group("Interactible"):
		interacting_areas.append(area)

func _on_area_exited(area):
	if area in interacting_areas:
		interacting_areas.erase(area)


 
func kill():
# warning-ignore:return_value_discarded
	pass
	#get_tree().reload_current_scene()

func shoot():
	var bullet = bullet_scene.instance()
	get_parent().add_child(bullet)
	bullet.position = ($Gunpoint.position).rotated(rotation) + position
	bullet.direction = rel_mouse_pos.normalized()

func anim_handler():
	if ($AnimationPlayer.current_animation == "Rifle-Shoot" or
		$AnimationPlayer.current_animation == "Rifle-Melee" or
		$AnimationPlayer.current_animation == "Rifle-Reload"):
			return
	if velocity.length() > 0 and $AnimationPlayer.current_animation == "Rifle-Idle":
		$AnimationPlayer.play("Rifle-Move")
		print("start mover")
	elif velocity.length() == 0 and $AnimationPlayer.current_animation == "Rifle-Move":
		$AnimationPlayer.play("Rifle-Idle")
		print("start idle")
		
