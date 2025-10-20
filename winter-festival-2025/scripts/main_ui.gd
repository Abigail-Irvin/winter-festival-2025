extends Node
@export var popup_diag: Panel
@export var exit_diag: Panel
@export var sanity_ref: RichTextLabel
@export var collectibles_ref: RichTextLabel
@export var total_collectibles_ref: RichTextLabel	
@export var timer_ref: RichTextLabel
@export var ui_mixer: AudioStreamPlayer
var main_ref = null

func _ready() -> void:
	main_ref = self.get_tree().get_root().get_child(1)

func _on_intro_pressed() -> void:
	"""Callback function when the intro popup is closed, starting the game.
	"""
	popup_diag.visible = false
	main_ref.start_game()
	ui_mixer.play()


func _on_exit_pressed() -> void:
	"""Callback function when the outro popup is closed, ending the game.
	"""
	get_tree().change_scene_to_file("res://scenes/title-screen.tscn")

func set_exit_text(exit_text: String) -> void:
	"""Helper function that sets the score information on the outro popup.
	"""
	exit_diag.visible = true
	exit_diag.get_child(0).get_child(0).text = exit_text

func update_ui_text(sanity_amt: String, collectible_amt: String, total_collected: String, timer: String) -> void:
	"""General game ui update function, called by main and updated each process call to have updated
	player data.
	"""
	sanity_ref.text = "Sanity: " + sanity_amt
	collectibles_ref.text = "Collectibles left in level: " + collectible_amt
	total_collectibles_ref.text = "Total collectibles: " + total_collected
	timer_ref.text = "Timer: " + timer


func _on_mouse_entered() -> void:
	ui_mixer.play()
