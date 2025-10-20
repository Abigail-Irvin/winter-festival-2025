extends Node
@export var credit_screen: Panel
@export var options_screen: Panel
@export var sound_mixer: AudioStreamPlayer2D
@export var ui_mixer: AudioStreamPlayer2D

func _on_start_game_pressed() -> void:
	"""Start button callback function, scene switches to the main scene.
	"""
	ui_mixer.play()
	get_tree().change_scene_to_file("res://scenes/main.tscn")


func _on_options_pressed() -> void:
	"""Options button callback function.
	"""
	options_screen.visible = true
	ui_mixer.play()


func _on_credits_pressed() -> void:
	"""Credits scene callback function, opens ui for credits.
	"""
	credit_screen.visible = true
	ui_mixer.play()


func _on_quit_pressed() -> void:
	"""Quit callback to exit game.
	"""
	ui_mixer.play()
	get_tree().quit()


func _on_return_pressed() -> void:
	"""Callback inside the credit popup to return back to main menu.
	"""
	credit_screen.visible = false
	ui_mixer.play()


func _on_sfx_slider_value_changed(value: float) -> void:
	GlobalData.sfx_volume_control = value
	AudioServer.set_bus_volume_linear(2, GlobalData.sfx_volume_control / 100)


func _on_music_slider_value_changed(value: float) -> void:
	GlobalData.music_volume_control = value
	AudioServer.set_bus_volume_linear(1, GlobalData.music_volume_control / 100)


func _on_main_slider_value_changed(value: float) -> void:
	GlobalData.master_volume_control = value
	AudioServer.set_bus_volume_linear(0, GlobalData.master_volume_control / 100)


func _on_return_from_options_pressed() -> void:
	options_screen.visible = false
	ui_mixer.play()


func _on_mouse_entered() -> void:
	ui_mixer.play()
