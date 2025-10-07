extends Node
class_name MazeNode
var neighbors = []
var connected = []
var visited = false
var tag = ""
var x = 0
var y = 0

func set_tag(other_tag: String) -> void:
	"""Helper function that will set tag of this maze node, makes debugging
	easier.
	"""
	tag = other_tag
	
func add_neighbor(other: MazeNode) -> void:
	"""Primary function to attach nodes to each other, this will set valid
	neighbor nodes which is used in the iterative algorithm.
	"""
	neighbors.append(other)

func add_connection(other: MazeNode) -> void:
	"""Primary function for path generation, following iterative algorithm a single
	path of connected nodes will be formed.
	"""
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
	"""Helper function that returns an array of only unvisited neighbors.
	"""
	var unvisited = []
	for obj in neighbors:
		if !obj.visited:
			unvisited.append(obj)
	return unvisited
	
func get_connections() -> Array:
	"""Helper function to grab this node's connected array.
	"""
	return self.connected

func get_x() -> int:
	"""Gets the x value (in a grid setting) of this node.
	"""
	return x

func get_y() -> int:
	"""Gets the y value (in a grid setting) of this node.
	"""
	return y
