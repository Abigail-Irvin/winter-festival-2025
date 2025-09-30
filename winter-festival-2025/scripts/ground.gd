extends Node
var fall_grass = load("res://assets/sprites/grass_dead.png")
var winter_grass = load("res://assets/sprites/snow_grass.png")
var winter = false
@export var spriteRef: Sprite2D

func set_winter(cold: bool):
	winter = cold

func update_sprite():
	if winter:
		spriteRef.texture = winter_grass
	else:
		spriteRef.texture = fall_grass
	
func _ready() -> void:
	update_sprite()
