extends Node2D
var height = 20
var width = 20
var maze_grid = []
var maze_wall = load("res://scenes/maze-blocker.tscn")
var exit = load("res://scenes/exit.tscn")
var collectible = load("res://scenes/collectible.tscn")

var winter = false
var paused = true
@export var fall_ground: Node2D
@export var winter_ground: Node2D
var total_collectibles = 0
var max_collectibles_lvl_0 = 5
var max_collectibles_lvl_1 = 5
var cur_collectibles = 0
var timer = 0
var wait = false

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

func check_closest_vector(new_coords, coord_list, extent) -> bool:
	for vec in coord_list:
		if abs(vec.x - new_coords.x) < extent and abs(vec.y - new_coords.y) < extent:
			# too close to other vector, is basically the same
			return false
	# all good, not matching
	return true

func draw_maze() -> void:
	#pre alg:
	# draw blockers on three sides and leave bottom open with gate
	if winter:
		fall_ground.visible = false
		winter_ground.visible = true
	else:
		fall_ground.visible = true
		winter_ground.visible = false
	var extended_height = int(height * 2.15)
	var extended_width = int(width * 2.1)
	for y in range(extended_height):
		for x in range(extended_width):
			var coords = Vector2((x * 100) - 100, (y * 100) - 100)
			# corral for making it slightly  tougher
			if (x == (extended_width / 2) - 20 and y >= extended_height - 4) or (x == (extended_width / 2) + 20 and y >= extended_height - 4):
				var grid_point = maze_wall.instantiate()
				grid_point.set_winter(winter)
				grid_point.position = coords
				add_child(grid_point)
			if x == extended_width / 2 and y >= extended_height - 1:
					var gate_point = exit.instantiate()
					gate_point.position = coords
					add_child(gate_point)
			elif y == 0 or y >= (extended_height) - 1:
				# top/bottom row we want it fully covered.
				var grid_point = maze_wall.instantiate()
				grid_point.set_winter(winter)
				grid_point.position = coords
				add_child(grid_point)
			elif x == 0 or x >= (extended_width) - 1:
				# sides we only want two rows either end covered.
				var grid_point = maze_wall.instantiate()
				grid_point.set_winter(winter)
				grid_point.position = coords
				add_child(grid_point)
			
				
					
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
	var printed_coords = []
	stack.append(current_cell)
	while true:
		if stack.size() == 0:
			break
		current_cell = stack.pop_back()
		if current_cell == null:
			continue
		var coords = Vector2((current_cell.get_x() * 200) + 100, (current_cell.get_y() * 200) + 100)
		if check_closest_vector(coords, printed_coords, 50):
			# check if we can place a blocker, and if so either place collectible or wall blocker
			printed_coords.append(coords)
			var place_wall = true
			if randi() % 50 == 42:
				if not winter and max_collectibles_lvl_0 > 0:
					var collect_point = collectible.instantiate()
					collect_point.position = coords
					add_child(collect_point)
					max_collectibles_lvl_0 -= 1
					total_collectibles += 1
					place_wall = false
				elif winter and max_collectibles_lvl_1 > 0:
					var collect_point = collectible.instantiate()
					collect_point.position = coords
					add_child(collect_point)
					max_collectibles_lvl_0 -= 1
					total_collectibles += 1
					place_wall = false
					
			if place_wall:
				var grid_point = maze_wall.instantiate()
				grid_point.set_winter(winter)
				grid_point.position = coords
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
				var x_offset: int = 100
				var y_offset: int = 100
				if conn_x > curr_x:
					x_offset = 200
				elif conn_x < curr_x:
					x_offset = 0
				elif conn_y > curr_y:
					y_offset = 200
				elif conn_y < curr_y:
					y_offset = 0
				var conn_coords = Vector2((conn_x * 200) + x_offset, (conn_y * 200) + y_offset)
				if check_closest_vector(conn_coords, printed_coords, 50):
					printed_coords.append(conn_coords)
					var conn_between = maze_wall.instantiate()
					conn_between.position = conn_coords
					if winter:
						conn_between.set_winter(true)
					else:
						conn_between.set_winter(false)
					add_child(conn_between)
				stack.append(conn)
				
func collect_item():
	cur_collectibles += 1
	print("Nompf")
	
func start_game():
	paused = false
	wait = false
	
func win_game():
	paused = true
	print("Collectibles obtained: ", cur_collectibles, " Total: ", total_collectibles, " Time: ", round(timer))
	
func get_paused():
	return paused
	
func advance_level() -> void:
	if not winter:
		winter = true
		clear_maze()
		init_maze()
		call_deferred("draw_maze")
		wait = true
	elif winter and not wait:
		win_game()
		
func clear_maze() -> void:
	var root = self.get_tree().get_root().get_child(0)
	for child in root.get_children():
		if child.name.contains("StaticBody2D") or child.name.contains("MazeBlocker"):
			child.queue_free()

func _ready() -> void:
	init_maze()
	draw_maze()
	
func _process(delta: float) -> void:
	if not paused:
		timer += delta
