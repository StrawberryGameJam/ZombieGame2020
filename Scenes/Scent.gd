extends Node2D

var player
onready var timer = $Timer

func _ready():
  timer.connect("timeout", self, "remove_scent")

func remove_scent():
  player.scent_trail.erase(self)
  queue_free()
