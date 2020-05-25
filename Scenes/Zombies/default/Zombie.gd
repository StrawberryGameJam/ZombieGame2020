extends KinematicBody2D
 
var MOVE_SPEED = 50 + (Global.kills)
 
 
var player = null
var obj = Vector2()
var killed = false
func _ready():
	$AnimationPlayer.play("Idle")
	add_to_group("zombies")
# warning-ignore:return_value_discarded
	$Area2D.connect("body_entered", self, "attack") 


# warning-ignore:unused_argument
func _process(delta):
	if player == null or killed:
		return
	anim_handler()
	
	if $Area2D.overlaps_body(player):
		attack(player)
	
	var has_scent = false
	var space_state = get_world_2d().direct_space_state
	var result = space_state.intersect_ray(global_position, player.global_position,[self],player.collision_mask)
	if !result.empty() and result.collider == player:
		obj = - global_position + player.global_position
		has_scent = true
	else:
		for scent in player.scent_trail:
			result = space_state.intersect_ray(global_position, scent.global_position,[self],player.collision_mask)
			if result.empty():
				obj = - global_position + scent.global_position
				has_scent = true
				break
	if not has_scent:
		return
	rotation = obj.angle()
	var vel = (obj.normalized())*MOVE_SPEED
	var res_par_l = space_state.intersect_ray(global_position, $Left.global_position)
	var res_par_r = space_state.intersect_ray(global_position, $Right.global_position)
	if not res_par_l.empty():
		if not (res_par_l.collider == player or res_par_l.collider.is_in_group("zombies")):
			var deg = rad2deg(res_par_l.normal.angle_to(Vector2(1,0).rotated(rotation)))
			if deg < -90:
				vel = res_par_l.normal.rotated(deg2rad(-90)).normalized()*MOVE_SPEED
			pass
	elif not res_par_r.empty():
		if not (res_par_r.collider == player or res_par_r.collider.is_in_group("zombies")):
			var deg = rad2deg(res_par_r.normal.angle_to(Vector2(1,0).rotated(rotation)))
			if deg > 90:
				vel = res_par_r.normal.rotated(deg2rad(90)).normalized()*MOVE_SPEED
			pass
# warning-ignore:return_value_discarded
	move_and_slide(vel)

func attack(body):
	if $AnimationPlayer.current_animation == "Attack":
		return
	if(body == player):
		$AnimationPlayer.play("Attack")
		body.kill()

func attack_frame():
	player.kill()

func kill():
	killed = true
	$CollisionShape2D.queue_free()
#	$Sprite.queue_free()
	$Area2D.queue_free()
	set_process(false)
	$AnimationPlayer.play("Death")
	
	var sound = randi() % 4
	var speech_player = AudioStreamPlayer2D.new()
	add_child(speech_player)
	var audio_file1 = "res://assets/OGG/ZumbiMorrendo1.ogg"
	var audio_file2 = "res://assets/OGG/ZumbiMorrendo2.ogg"

	if sound == 0:
		print("ola amigo cade meu som?1")
		var sfx = load(audio_file1) 
		
		sfx.set_loop(false)
		
		speech_player.stream = sfx
		
		speech_player.play()
	
	elif sound == 1:
		if File.new().file_exists(audio_file2):
			print("ola amigo cade meu som?2")
		var sfx = load(audio_file2) 
		sfx.set_loop(false)
		speech_player.stream = sfx
		speech_player.play()
	Global.kills += 1
	yield(get_tree().create_timer(1), 'timeout')
	
	queue_free()
 
 
func set_player(p):
	player = p

func anim_handler():
	if ($AnimationPlayer.current_animation == "Attack"):
		return
	if obj.length() > 0 and $AnimationPlayer.current_animation == "Idle":
		$AnimationPlayer.play("Move")
	elif obj.length() == 0 and $AnimationPlayer.current_animation == "Move":
		$AnimationPlayer.play("Idle")
