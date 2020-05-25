extends Control


func _ready():
	Global.mouse_mode("arrow")
	$VBoxContainer/NewGame.connect("pressed",self,"new_game")
	$VBoxContainer/Credits.connect("pressed",self,"credits")
	$VBoxContainer/Exit.connect("pressed",self,"exit")
	
	$AudioStreamPlayer.play()
	pass

func new_game():
	get_tree().change_scene("res://Scenes/Level.tscn")
	pass

func credits():
	get_tree().change_scene("res://Scenes/Credits.tscn")
	

func exit():
	get_tree().quit()
	pass

