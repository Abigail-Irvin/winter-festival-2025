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
@export var main_ui: Control
@export var fall_shader: DirectionalLight2D
@export var winter_shader: DirectionalLight2D
@export var player_ref: CharacterBody2D
var total_collectibles_needed = 0
var collectible_total_lvl_0 = 0
var collectible_total_lvl_1 = 0
var cur_collected_lvl_0 = 0
var cur_collected_lvl_1 = 0
var timer = 0
var sanity = 100

var collectible_coords = []


func init_maze() -> void:
	"""Main generative function for the maze, using the maze node approach we follow an iterative
	stack algorithm in path generation ensuring a complete maze each time. By the end of this
	function the maze_grid will be populated with all relevant neighbors and which nodes they then
	connect to.
	"""
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
	"""Helper function for the draw maze function. This serves to help prevent overwriting the same
	general grid square with multiple copies of a maze blocker. This is important for performance,
	but also in general graphical quality as blocker sprites are randomized and it will usually not
	line up right if we put multiple in the same spot.
	"""
	for vec in coord_list:
		if abs(vec.x - new_coords.x) < extent and abs(vec.y - new_coords.y) < extent:
			# too close to other vector, is basically the same
			return false
	# all good, not matching
	return true

func draw_maze() -> void:
	"""Main function of the game, this takes the generation algorithm path and converts it to a patterned
	map of maze blockers. To help corral the player before generating the maze proper, a box is made around
	the general maze to help ensure there will only be one side with valid exits. In this function we also
	generate all of the collectibles, which to help simplify the problem of "can we get this collectible" is
	placed in place of a normal maze wall, which should ensure that no matter what it will be accessible.
	"""
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
			if randi() % 42 == 20:
				if not winter and collectible_total_lvl_0 < 10:
					var collect_point = collectible.instantiate()
					collect_point.position = coords
					collectible_coords.append(collect_point.global_position)
					add_child(collect_point)
					collectible_total_lvl_0 += 1
					total_collectibles_needed += 1
					place_wall = false
				elif winter and collectible_total_lvl_1 < 10:
					var collect_point = collectible.instantiate()
					collect_point.position = coords
					collectible_coords.append(collect_point.global_position)
					add_child(collect_point)
					collectible_total_lvl_1 += 1
					total_collectibles_needed += 1
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
				
func collect_item(coords: Vector2) -> void:
	"""Helper function that is called whenever a collectible detects a player entering its area. This
	will first check a coordinate array and remove the corresponding collectible from it, then check
	what level we are at, and add the respective current collected. This is used to determine how many
	collectibles are left in a stage, and later is tallied together for the score. The coordinate array
	is then used with the xray arrow to help locate the next closest collectible.
	"""
	var remove_idx = -1
	for idx in range(collectible_coords.size()):
		var vec = collectible_coords[idx]
		if vec == coords:
			remove_idx = idx
	if remove_idx != -1:
		collectible_coords.remove_at(remove_idx)
	if not winter:
		cur_collected_lvl_0 += 1
	else:
		cur_collected_lvl_1 += 1
	
func start_game():
	"""simple helper function called to ensure game start after clicking on the intro sequence.
	"""
	paused = false
	
func win_game():
	"""Calls the main ui to present the ending scene text and sets the relevant scoring information.
	"""
	if paused:
		return
	paused = true
	var total_score = ((1 / (timer / 2)) + 0.5) * ((cur_collected_lvl_0 + cur_collected_lvl_1 + 0.5) / total_collectibles_needed) * 10000
	var exit_text = "Collectibles obtained: " + str(cur_collected_lvl_0 + cur_collected_lvl_1) + "\nTotal Collectibles: " + str(total_collectibles_needed) + "\nTime: " + str(round(timer)) + "\nTotal Score: " + str(round(total_score))
	main_ui.set_exit_text(exit_text)
	
	
func get_paused():
	"""Getter function for the paused variable, used specifically in the player script to stop movement.
	"""
	return paused
	
func advance_level() -> void:
	"""Callback function called by exit gate when the player reaches its area. It is called by the
	player script and is deferred due to its demand on the queue on clearing the entire maze and
	regenerating.
	"""
	if not winter:
		collectible_coords.clear()
		winter = true
		fall_shader.visible = false
		winter_shader.visible = true
		call_deferred("clear_maze")
		call_deferred("init_maze")
		call_deferred("draw_maze")
	elif winter:
		win_game()
		
func clear_maze() -> void:
	"""Sets up everything in the game area to be cleared out to make room to regenerate the room.
	"""
	var root = self.get_tree().get_root().get_child(0)
	for child in root.get_children():
		if child.name.contains("StaticBody2D") or child.name.contains("MazeBlocker"):
			child.queue_free()

func _ready() -> void:
	"""Startup function that makes the initial map.
	"""
	init_maze()
	draw_maze()
	
func closest_collectible() -> Vector2:
	"""Helper function for the player xray, utilizing the collectible vector array to determine
	where the nearest collectible is and to set the player xray to point towards it when the power
	is active.
	"""
	var closest_mag = INF
	var closest_vec = Vector2(0, 0)
	for vec in collectible_coords:
		var dir_vec = vec - player_ref.global_position
		if dir_vec.length() < closest_mag:
			closest_mag = dir_vec.length()
			closest_vec = vec
	return closest_vec
	
func _process(delta: float) -> void:
	"""Basic processing and ui updating function in main that handles calling main ui to update
	relevant player information such as sanity and collectible data. Also handles player xray and
	lantern powers.
	"""
	if not paused:
		timer += delta
		if player_ref.spawned_light:
			sanity += delta * 1.5
			if sanity > 100:
				sanity = 100.0
		else:
			sanity -= (delta * 0.25)
		player_ref.update_sanity_mult(sanity/100)
		if player_ref.xray:
			var closest_dir = closest_collectible()
			player_ref.xray_look_at(closest_dir)
		else:
			player_ref.disable_xray()
		var current_total = 0
		var current_collected = 0
		if winter:
			current_total = collectible_total_lvl_1 - cur_collected_lvl_1
			current_collected = cur_collected_lvl_1
		else:
			current_total = collectible_total_lvl_0 - cur_collected_lvl_0
			current_collected = cur_collected_lvl_0
		main_ui.update_ui_text(str(round(sanity)), str(current_total), str(current_collected), str(round(timer)))
