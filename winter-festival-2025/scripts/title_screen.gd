extends Node
@export var credit_screen: Panel

func _on_start_game_pressed() -> void:
	"""Start button callback function, scene switches to the main scene.
	"""
	get_tree().change_scene_to_file("res://scenes/main.tscn")


func _on_options_pressed() -> void:
	"""Options button callback function, currently WIP.
	"""
	pass # Replace with function body.


func _on_credits_pressed() -> void:
	"""Credits scene callback function, opens ui for credits.
	"""
	credit_screen.visible = true


func _on_quit_pressed() -> void:
	"""Quit callback to exit game.
	"""
	get_tree().quit()


func _on_return_pressed() -> void:
	"""Callback inside the credit popup to return back to main menu.
	"""
	credit_screen.visible = false
