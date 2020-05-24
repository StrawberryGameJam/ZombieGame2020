extends Node

var mouse_override = false
var normal_mouse = "arrow"
var pause_menu = preload("res://Scenes/PauseMenu.tscn").instance()

var mouse_icons = {
	"aim": {"icon": preload("res://icons/mouse_icons/sprite_1.png"),
			"hotspot": Vector2(16,16),
			"locked": true},
	"arrow": {"icon": preload("res://icons/mouse_icons/sprite_0.png"),
			"hotspot": Vector2(),
			"locked": false}
}

var map = {}

func set_up_action_map():
	for action in InputMap.get_actions():
		for input in InputMap.get_action_list(action):
			if input is InputEventKey:
				map[input.scancode] = action
	#print(map)
func _ready():
	pause_menu.pause_mode = Node.PAUSE_MODE_PROCESS
	pause_mode = Node.PAUSE_MODE_PROCESS
	set_process_input(true)
	set_up_action_map()
	pass
	
func _input(event):
	if event is InputEventKey and event.scancode in map.keys():
		if map[event.scancode] == "ui_escape" and event.pressed:
			var current_scene = get_tree().get_current_scene()
			if not get_tree().paused:
				get_tree().paused = true
				override_mouse()
				current_scene.add_child(pause_menu)
			else:
				get_tree().paused = false
				resume_mouse()
				current_scene.remove_child(pause_menu)
	
func mouse_mode(icon = "arrow"):
	if mouse_override:
		return
	normal_mouse = icon
	Input.set_custom_mouse_cursor(mouse_icons[icon]["icon"],0,mouse_icons[icon]["hotspot"])
	if mouse_icons[icon]["locked"]:
		Input.set_mouse_mode(Input.MOUSE_MODE_CONFINED)
	else:
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	pass

func override_mouse():
	mouse_override = true
	Input.set_custom_mouse_cursor(mouse_icons["arrow"]["icon"],0,mouse_icons["arrow"]["hotspot"])
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
func resume_mouse():
	mouse_override = false
	mouse_mode(normal_mouse)
