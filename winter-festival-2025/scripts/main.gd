extends Node2D
var height = 8
var width = 8
var maze_grid = []


func init_maze() -> void:
	maze_grid.resize(height)
	for i in range(height):
		maze_grid[i] = []
		maze_grid[i].resize(width)
		for j in range(width):
			maze_grid[i][j] = MazeNode.new()
			maze_grid[i][j].tag = str(i) + "-" + str(j)
	# neighbor initializing
	for i in range(0, height):
		for j in range(0, width):
			if i - 1 >= 0:
				maze_grid[i][j].add_neighbor(maze_grid[i-1][j])
			if i + 1 < height:
				maze_grid[i][j].add_neighbor(maze_grid[i+1][j])
			if j - 1 >= 0:
				maze_grid[i][j].add_neighbor(maze_grid[i][j-1])
			if j + 1 < width:
				maze_grid[i][j].add_neighbor(maze_grid[i][j+1])
	# path generation
	var maze_stack = []
	var rand_h = randi() % height - 1
	var rand_w = randi() % width - 1
	maze_grid[rand_h][rand_w].visited = true
	maze_stack.append(maze_grid[rand_h][rand_w])
	while maze_stack.size() > 0:
		# Iterative stack backtracing
		# 1. Pop a cell from the stack and make it current
		# 2. If current cell has any neighbors which have not been visited
		# 	1a. push current cell to stack
		#	2a. choose one of the unvisited neighbours
		#	3a. Remove the wall (connect) the current and chosen cell
		#	4a. Mark the chosen cell as visited and push it to the stack.
		var current_cell = maze_stack.pop_back()
		if current_cell.has_unvisited_neighbor():
			maze_stack.append(current_cell)
			var unvisited_neighbors = current_cell.get_unvisited_neighbors()
			var chosen_cell = unvisited_neighbors[randi() % unvisited_neighbors.size()]
			current_cell.add_connection(chosen_cell)
			chosen_cell.add_connection(current_cell)
			chosen_cell.visited = true
			maze_stack.append(chosen_cell)
	

func print_maze() -> void:
	print("##################################################################")
	for i in range(height):
		var line = ""
		for j in range(width):
			maze_grid[i][j].debug()
			continue
			if j < width - 1:
				line += str(maze_grid[i][j]) + ", "
			else:
				line += str(maze_grid[i][j])
		print(line)
	print("##################################################################")

func _ready() -> void:
	init_maze()
	print_maze()
