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
	  var look     = get_node("RayCast2D")
	  look.cast_to = (player.position - position)
	  look.force_raycast_update()
	
	  # if we can see the target, chase it
	  if !look.is_colliding():
	    dir = look.cast_to.normalized()
	
	  # or chase first scent we can see
	  else:
	    for scent in player.scent_trail:
	      look.cast_to = (scent.position - position)
	      look.force_raycast_update()
	
	      if !look.is_colliding():
	        dir = look.cast_to.normalized()
	        break
			
func attack(body):
	if(body == player):
		body.kill()

func kill():
	queue_free()
 
func set_player(p):
	player = p
