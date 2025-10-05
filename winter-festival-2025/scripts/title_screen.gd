extends Node
@export var credit_screen: Panel

func _on_start_game_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/main.tscn")


func _on_options_pressed() -> void:
	pass # Replace with function body.


func _on_credits_pressed() -> void:
	credit_screen.visible = true


func _on_quit_pressed() -> void:
	get_tree().quit()


func _on_return_pressed() -> void:
	credit_screen.visible = false
