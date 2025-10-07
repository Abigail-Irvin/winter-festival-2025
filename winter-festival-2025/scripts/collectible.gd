extends Node


func _on_area_2d_body_entered(body: Node2D) -> void:
	"""Callback function that fires when player enters collectible area, 
	fires off main function call to collect item and delete this collectible
	"""
	if body.name == "Player":
		self.get_tree().get_root().get_child(0).collect_item(self.global_position)
		self.queue_free()
