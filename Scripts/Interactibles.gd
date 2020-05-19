extends Area2D

class_name Interactible

export(Texture)var INTER_ICON = preload("res://icon.png")
export(Vector2)var ICON_POS = Vector2()
export(Vector2)var ICON_SCALE = Vector2()
var icon = Sprite.new()

func add_to_group(group, a = false):
	.add_to_group(group, a)

func _ready():
	connect("area_entered",self,"_on_area_entered")
	connect("area_exited",self,"_on_area_exited")
	add_child(icon)
	icon.hide()
	icon.texture = INTER_ICON
	icon.position = ICON_POS
	icon.scale = ICON_SCALE
	
	pass
	
func interact(body):
	print("Ahoy")
	
func _physics_process(delta):
	
	icon.rotation = - get_global_transform().get_rotation()
	icon.position = ICON_POS.rotated(-get_global_transform().get_rotation())

func _on_area_entered(area):
	if area.is_in_group("Player_inter"):
		icon.show()

func _on_area_exited(area):
	if area.is_in_group("Player_inter"):
		icon.hide()
