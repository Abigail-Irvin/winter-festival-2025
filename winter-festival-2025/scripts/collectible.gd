extends Node
var sprites = [load("res://assets/sprites/holly-wip.png"), load("res://assets/sprites/pansy-wip.png"), load("res://assets/sprites/snowdrop-wip.png")]
var chosen_idx = 0
@export var spriteRef: Sprite2D
var main_ref = null

func _ready() -> void:
	main_ref = self.get_tree().get_root().get_child(1)
	chosen_idx = randi() % sprites.size()
	spriteRef.texture = sprites[chosen_idx]

func _on_area_2d_body_entered(body: Node2D) -> void:
	"""Callback function that fires when player enters collectible area, 
	fires off main function call to collect item and delete this collectible
	"""
	if body.name == "Player":
		main_ref.collect_item(self.global_position)
		self.queue_free()
