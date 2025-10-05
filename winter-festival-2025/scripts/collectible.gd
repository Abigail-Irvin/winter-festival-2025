extends Node


func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.name == "Player":
		self.get_tree().get_root().get_child(0).collect_item()
		self.queue_free()
