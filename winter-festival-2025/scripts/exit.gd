extends Node
@export var collider: CollisionShape2D
var timer = 0

func _on_area_2d_body_entered(body: Node2D) -> void:
	"""Callback function that fires when player enters a gate, resets the player position and then
	defer calls a level advancement / win game state.
	"""
	if body.name == "Player":
		body.reset_pos()

func activate_collider() -> void:
	"""This function serves as a way to help address bug with deferred function, it disables any
	callback functions while the game is loaded with queues so that the player doesn't accidentally
	double-trigger an advance level event.
	"""
	collider.disabled = false
	
func _ready() -> void:
	"""Ready up function that sets timer to 0
	"""
	timer = 0

func _process(delta: float) -> void:
	"""Basic process function that advances timer, and after 5 seconds makes the gate active
	"""
	timer += delta
	if timer > 5:
		activate_collider()
