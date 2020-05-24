extends KinematicBody2D
 
const MOVE_SPEED = 200
 
onready var raycast = $RayCast2D
 
var player = null
var obj = Vector2()
 
func _ready():
	add_to_group("zombies")
	$Sprite/Area2D.connect("body_entered", self, "attack") 


func _process(delta):
	if player == null:
		return
	
	var l_time = 0
	var look = get_node("RayCast2D")
	look.cast_to = (player.position-position)
	look.force_raycast_update()
	if look.is_colliding() and look.get_collider() == player:
		obj = look.cast_to
	
	$Sprite.rotation = obj.angle()
	$icon.position = obj
	print(obj)
	move_and_slide(obj.normalized()*MOVE_SPEED)

func attack(body):
	if(body == player):
		body.kill()

func kill():
	queue_free()
 
func set_player(p):
	player = p
