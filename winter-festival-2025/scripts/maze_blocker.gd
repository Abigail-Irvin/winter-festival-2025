extends Node
var tree_1 = load("res://assets/sprites/deadsnowtree.png")
var tree_2 = load("res://assets/sprites/dead_tree.png")
var tree_3 = load("res://assets/sprites/fall_three_3.png")
var tree_4 = load("res://assets/sprites/fall_tree_1.png")
var tree_5 = load("res://assets/sprites/fall_tree_2.png")
var tree_6 = load("res://assets/sprites/tree1.png")
var tree_7 = load("res://assets/sprites/tree1winter.png")
var tree_8 = load("res://assets/sprites/tree2.png")
var tree_9 = load("res://assets/sprites/tree2winter.png")
var winter_tree = [tree_1, tree_7, tree_9]
var fall_tree = [tree_3, tree_4, tree_5, tree_6, tree_8, tree_2]
@export var spriteRef: Sprite2D
@export var shadowRef: Sprite2D
var winter: bool = false

func _ready() -> void:
	"""Startup function for maze blocker that will set initial sprite.
	"""
	update_sprite()

func set_winter(cold: bool):
	"""Setter function that changes sprite list from fall or winter varieties.
	"""
	winter = cold
	
func update_sprite():
	"""Main function for maze blockers, ensuring that the sprite and shadow refs
	will always refer to the same selection so shading will work properly.
	"""
	if winter:
		var rand_index = randi() % winter_tree.size()
		spriteRef.texture = winter_tree[rand_index]
		shadowRef.texture = winter_tree[rand_index]
	else:
		var rand_index = randi() % fall_tree.size()
		spriteRef.texture = fall_tree[rand_index]
		shadowRef.texture = fall_tree[rand_index]
