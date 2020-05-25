extends Camera2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
func get_mouse_relative_position(pos):
	var camera_rel_pos = global_position-pos
	return camera_rel_pos + get_viewport().get_mouse_position()-get_viewport_rect().size/2
	pass

# Called when the node enters the scene tree for the first time.
func _ready():
	pass 


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
