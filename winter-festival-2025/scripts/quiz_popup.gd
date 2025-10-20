extends Node
@export var snowdrop_ref: Button
@export var holly_ref: Button
@export var pansy_ref: Button
var snowdrop_counter = 0
var holly_counter = 0
var snowdrop_tease_list = ["Oops so sorry, I meant to put Pansy here!", "Wait I forget how you spell it, starts with a P",
 "Sorry bestie! I know you meant Pansy ^w^", "It's oki to be a bit confused", "Nono it's up a couple", "Like up here see? (Pansy)",
 "tsk comeon you know what it is", "Stanley Picked the TOP option", "Pansy"] 
var holly_tease_list = ["Oops! Meant to put Pansy here sorries </3", "Happy Pranktober! ^^w^^",
 "Hol- HA nope sorry, all Pansy", "Snowdrop- er wait no Pansy!", "Hollies are trees not even flowers lol",
 "Nono easy mistake, it's the one above you", "Comeonn you almost got it, I'll help", "Uh so determined",
 "Nope", "Still nope", "Nope its all Pansy", "Not falling for a rookie mistake like that",
 "Ooh you almost got it that time", "Pansy"]

func _on_snowdrop_mouse_entered() -> void:
	if snowdrop_counter < snowdrop_tease_list.size():
		snowdrop_ref.text = snowdrop_tease_list[snowdrop_counter]
	else:
		snowdrop_ref.text = "Pansy"
	snowdrop_counter += 1


func _on_snowdrop_mouse_exited() -> void:
	snowdrop_ref.text = "Snowdrop"


func _on_holly_mouse_entered() -> void:
	if holly_counter < holly_tease_list.size():
		holly_ref.text = holly_tease_list[holly_counter]
	else:
		holly_ref.text = "Pansy"
	holly_counter += 1


func _on_holly_mouse_exited() -> void:
	holly_ref.text = "Holly"


func _on_pressed() -> void:
	self.get_tree().get_root().get_child(1).open_easter_egg()
	self.visible = false
