extends KinematicBody2D
 
const MOVE_SPEED = 200
 
onready var raycast = $RayCast2D
 
var player = null
var dir = Vector2()
 
func _ready():
	add_to_group("zombies")
	$Area2D.connect("body_entered", self, "attack") 


func _physics_process(delta):
	if player == null:
		return
	
	chase_target()
	rotation = dir.angle()
	move_and_slide(dir*MOVE_SPEED)
 
func chase_target():
	if(player != null):
		var look = get_node("RayCast2D")
		look.cast_to = (player.position - position).rotated(-rotation)
		look.force_raycast_update()
		$Sprite2.position = look.cast_to
	
		# if we can see the target, chase it
		if not look.is_colliding():
			print("ta vendo o target")
			dir = (player.position - position).normalized()
	
	  # or chase first scent we can see
		else:
			print("nao ta vendo o player")
			for scent in player.scent_trail:
				look.cast_to = (scent.position - position).rotated(-rotation)
				look.force_raycast_update()
			
				if not look.is_colliding():
					dir = (scent.position - position).normalized()
					break
			
func attack(body):
	if(body == player):
		body.kill()

func kill():
	queue_free()
 
func set_player(p):
	player = p
