extends Node
class_name MazeNode
var neighbors = []
var connected = []
var visited = false
var tag = ""

func _ready() -> void:
	pass

func debug():
	for obj in connected:
		print(self.tag + " connects with: " + obj.tag)
	
func _to_string() -> String:
	return "0"
	if connected.size() > 0:
		return "#"
	return "0"

func set_tag(other_tag: String) -> void:
	tag = other_tag
	
func add_neighbor(other: MazeNode) -> void:
	neighbors.append(other)

func add_connection(other: MazeNode) -> void:
	connected.append(other)
	
func check_if_connected(other: MazeNode) -> bool:
	"""Used in backtracking algorithm to determine what nodes to connect to form a perfect maze.
	"""
	return connected.has(other)

func has_unvisited_neighbor() -> bool:
	"""Specialized function of connection check used in backtracking algorithm to find the next free neighbor to begin maze connections from.
	"""
	var unvisited = get_unvisited_neighbors()
	if unvisited.size():
		return true
	return false
	
func get_unvisited_neighbors() -> Array:
	var unvisited = []
	for obj in neighbors:
		if !obj.visited:
			unvisited.append(obj)
	return unvisited
