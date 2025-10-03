extends Node


func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.name == "Player":
		body.position = Vector2(35, 35)
		self.get_tree().get_root().get_child(0).advance_level()
