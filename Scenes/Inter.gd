extends Interactible


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var t = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	add_to_group("Interactible")
	pass # Replace with function body.

func interact(body):
	.interact(body)
	print("Hello "+body.name)
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	t+=delta
	rotation += delta*PI/4
	position.x += 30*sin(t)*delta
	pass
