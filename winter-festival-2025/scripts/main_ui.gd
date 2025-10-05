extends Node
@export var popup_diag: Panel

func _on_intro_pressed() -> void:
	popup_diag.visible = false
	self.get_tree().get_root().get_child(0).start_game()


func _on_exit_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/title-screen.tscn")
