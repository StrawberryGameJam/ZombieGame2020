extends Area2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var direction = Vector2(1,0)
var speed = 800

# Called when the node enters the scene tree for the first time.
func _ready():
	set_physics_process(true)
	connect("body_entered",self,"_on_body_entered")
	$Timer.connect("timeout",self,"queue_free")
	pass # Replace with function body.
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	position += speed*direction*delta
#	pass
func _on_body_entered(body):
	if body.is_in_group("Player"):
		return
	elif body.is_in_group("zombies"):
		body.kill()
		queue_free()
	else:
		queue_free()
