extends Node2D
var height = 50
var width = 20
var maze_grid = []
var maze_wall = load("res://scenes/maze-blocker.tscn")
var ground = load("res://scenes/ground.tscn")
var winter = false

func init_maze() -> void:
	maze_grid.resize(height)
	for i in range(height):
		maze_grid[i] = []
		maze_grid[i].resize(width)
		for j in range(width):
			maze_grid[i][j] = MazeNode.new()
			maze_grid[i][j].tag = str(i) + "-" + str(j)
			maze_grid[i][j].x = j
			maze_grid[i][j].y = i
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
	
func draw_maze() -> void:
	#pre alg: draw all the grass
	for i in range(height * 2):
		for j in range(width * 2):
			var ground_chip = ground.instantiate()
			ground_chip.position = Vector2(j * 100, i * 100)
			if winter:
				ground_chip.set_winter(true)
				ground_chip.update_sprite()
			add_child(ground_chip)
	#algorithm:
	#start at 0,0, and push onto stack
	#pop current cell, draw it at it's grid position.
	#get list of all connections, and draw 1 inbetween spot, and put that connection on the stack
	#repeat
	#how to deal with dual connections?
	#keep stashed in memory i-j connections, and skip j-i connections
	#already printed? another stack
	var current_cell = maze_grid[0][0]
	var stack = []
	var prev_conns = []
	var already_printed = []
	stack.append(current_cell)
	while true:
		if stack.size() == 0:
			break
		current_cell = stack.pop_back()
		if current_cell == null:
			continue
		var print_test = str(current_cell.get_x()) + "," + str(current_cell.get_y())
		if print_test not in already_printed:
			# check if we need to actually print a wall blocker, continue as normal
			var grid_point = maze_wall.instantiate()
			already_printed.append(print_test)
			if winter: # sprite winter swticher
				grid_point.set_winter(true)
			else:
				grid_point.set_winter(false)
			grid_point.position = Vector2((current_cell.get_x() * 200) + 100, (current_cell.get_y() * 200) + 100)
			add_child(grid_point)
		for conn in current_cell.get_connections():
			var conn_tester = str(conn.get_x()) + "," + str(conn.get_y()) + "->" + str(current_cell.get_x()) + "," + str(current_cell.get_y())
			var inv_tester = str(current_cell.get_x()) + "," + str(current_cell.get_y()) + "->" + str(conn.get_x()) + "," + str(conn.get_y()) 
			if conn_tester not in prev_conns and inv_tester not in prev_conns:
				prev_conns.append(conn_tester)
				var curr_x = current_cell.get_x()
				var curr_y = current_cell.get_y()
				var conn_x = conn.get_x()
				var conn_y = conn.get_y()
				var x_offset = 100
				var y_offset = 100
				if conn_x > curr_x:
					x_offset = 200
				elif conn_x < curr_x:
					x_offset = 0
				elif conn_y > curr_y:
					y_offset = 200
				elif conn_y < curr_y:
					y_offset = 0
				var conn_between_print_test = str(conn.get_x() + x_offset) + "," + str(conn.get_y() + y_offset)
				if conn_between_print_test not in already_printed:
					already_printed.append(conn_between_print_test)
					var conn_between = maze_wall.instantiate()
					conn_between.position = Vector2((conn_x * 200) + x_offset, (conn_y * 200) + y_offset)
					if winter:
						conn_between.set_winter(true)
					else:
						conn_between.set_winter(false)
					add_child(conn_between)
				stack.append(conn)
		

func _ready() -> void:
	init_maze()
	#print_maze()
	draw_maze()
