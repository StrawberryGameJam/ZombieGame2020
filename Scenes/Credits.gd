extends CanvasLayer


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	$AudioStreamPlayer.play()
	$Button.connect("pressed",self,"exit")
	pass # Replace with function body.

func exit():
	get_tree().change_scene("res://Scenes/Title.tscn")
	pass
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
