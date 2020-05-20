extends Control


func _ready():
	Global.mouse_mode("arrow")
	$VBoxContainer/NewGame.connect("pressed",self,"new_game")
	$VBoxContainer/Continue.connect("pressed",self,"continue_button")
	$VBoxContainer/Options.connect("pressed",self,"options")
	$VBoxContainer/Credits.connect("pressed",self,"credits")
	pass

func new_game():
	get_tree().change_scene("res://Scenes/Main.tscn")
	pass

func continue_button():
	pass

func options():
	pass

func credits():
	pass
