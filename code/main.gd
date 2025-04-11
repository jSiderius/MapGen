extends "res://code/flood_fill_algo.gd"

# export variables
@export var debug : bool = true
@export var square_size : float = 10.0
@export var threshold : float = 0.01

# Needs to be global for _draw()
var id_grid : Grid
var bbs : Dictionary = {}
var districts : Dictionary = {} 
var roads : Array = []

var grid_loader : Resource = preload("res://code/Grid/grid.gd")
var district_flag_struct_loader : Resource = preload("res://code/Districts/district_data_flags_struct.gd")
var district_manager_loader : Resource = preload("res://code/Districts/district_manager.gd")
var district_flag_struct : DistrictDataFlagStruct
var district_manager : DistrictManager

var graph_loader : Resource = preload("res://code/Graph/graph.gd")

func _ready() -> void:

	# Initialize  variables
	var rng = RandomNumberGenerator.new()
	rng.randomize()

	var screenSize : Vector2 = get_viewport_rect().size
	var w_h : Vector2 = find_width_and_height(screenSize, square_size)
	var width : int = int(w_h[0])
	var height : int = int(w_h[1])
	screenSize = update_screen_size(width, height, square_size) 

	# Begin algorithms 
	if debug: await redraw_and_pause(0, 0.0, false)

	# Fill the initial grid
	id_grid = grid_loader.new(width, height, square_size, Enums.GridInitType.RANDOM)
	add_child(id_grid)
	if debug: await redraw_and_pause(1, 0.1)

	# Run trials of cellular automata on the remaining {0,1} noise values 
	id_grid.cellular_automata_trials([3])
	if debug: await redraw_and_pause(3, 1.0)

	# # TODO: Document grid layout (in class maybe)
	var river_start : Vector2i = random_edge_position(id_grid.height, id_grid.width)
	var river_end : Vector2i = random_edge_position(id_grid.height, id_grid.width)
	id_grid.add_river(river_start, river_end)
	if debug: await redraw_and_pause(3, 1.0)

	id_grid.cellular_automata_trials([6])
	if debug: await redraw_and_pause(3, 1.0)

	# TODO: Working into grid and keep doing A*
	var road_start : Vector2i = random_edge_position(id_grid.height, id_grid.width, [Enums.Border.EAST])
	var road_end : Vector2i = random_edge_position(id_grid.height, id_grid.width, [Enums.Border.WEST])
	# var empty_graph : Graph = graph_loader.new()
	# var path = empty_graph.a_star(id_grid, road_start, road_end)
	# for pos in path: 
	# 	id_grid[pos.x][pos.y] = Enums.Cell.MAJOR_ROAD

	if debug: await redraw_and_pause(3, 1.0)

	# TODO: Districts of size 1 ?
	# Run flood fill to differentiate groups
	id_grid.flood_fill()
	if debug: await redraw_and_pause(4, 0.1)

	# Parse out the smallest groups 
	id_grid.parse_smallest_districts(75)
	if debug: await redraw_and_pause(5, 0.1)

	# # Expand groups into null space (1)
	id_grid.expand_id_grid([Enums.Cell.OUTSIDE_SPACE, Enums.Cell.MAJOR_ROAD, Enums.Cell.WATER], [Enums.Cell.WATER])
	if debug: await redraw_and_pause(6, 0.1)

	# # Create a voronoi cell map, and clear cells from id_grid that correspond to voronoi edge cells, creating a city outline
	# var voronoi_id_array : Array = generate_id_array_with_voronoi_cells(width, height, 100)
	# var edge_cell_ids : Array = find_unique_edge_cell_ids(voronoi_id_array) 
	# voronoi_id_array = overwrite_cells_by_id(voronoi_id_array, edge_cell_ids, Enums.Cell.OUTSIDE_SPACE)

	var voronoi_id_grid : Grid = grid_loader.new(id_grid.width, id_grid.height, square_size, Enums.GridInitType.VORONOI, {})
	var edge_cell_ids = voronoi_id_grid.find_unique_edge_cell_ids()
	voronoi_id_grid.overwrite_cells_by_id(edge_cell_ids, Enums.Cell.OUTSIDE_SPACE)

	id_grid.copy_designated_ids(voronoi_id_grid, [Enums.Cell.OUTSIDE_SPACE], [Enums.Cell.WATER, Enums.Cell.MAJOR_ROAD])
	if debug: await redraw_and_pause(2, 0.1)

	id_grid.update_district_manager()

	# # Increase the array resolution and add a new (thinner) border
	id_grid.increase_array_resolution(1.5)
	# id_grid.add_city_border(Enums.Cell.DISTRICT_WALL) 

	if debug: await redraw_and_pause(8, 0.1)


	id_grid.toggle_border_rendering(true)

	if debug: await redraw_and_pause(11)

func _draw() -> void: 
	if id_grid: id_grid.queue_redraw()

func draw_roads(): 
	for r in roads: 
		draw_line(square_size * Vector2(r.first[0], r.first[1]), square_size * Vector2(r.second[0], r.second[1]), Color.BLUE, 1.0)

func draw_bounding_box(col : Color, ss : float, line_width : float, tl : Vector2i, br : Vector2i) -> void: 
	# Convert the points to top-left and bottom-right for consistent rectangle rendering
	var top_left = Vector2(ss * min(tl.x, br.x), ss * min(tl.y, br.y))
	var bottom_right = Vector2(ss * (max(tl.x, br.x) + 1), ss * (max(tl.y, br.y) + 1))
	
	# Define the corners
	var top_right = Vector2(bottom_right.x, top_left.y)
	var bottom_left = Vector2(top_left.x, bottom_right.y)

	# Draw the four sides of the rectangle with the specified line width
	draw_line(top_left, top_right, col, line_width)  # Top side
	draw_line(top_right, bottom_right, col, line_width)  # Right side
	draw_line(bottom_right, bottom_left, col, line_width)  # Bottom side
	draw_line(bottom_left, top_left, col, line_width)  # Left side

func add_center_line(_id_grid : Array) -> Array:
	#for i in range(len(_id_grid[0])): 
		#_id_grid[floor(len(_id_grid) / 2.0)][i] = 1
	var offset : int = 0
	for i in range(len(_id_grid[0])): 
		if randf() < 0.1: offset += (randi() % 2)
		_id_grid[floor(len(_id_grid) / 2.0) + offset][i] = Enums.Cell.MAJOR_ROAD
		
	offset = 0
	for i in range(len(_id_grid)):
		if randf() < 0.1: offset += (randi() % 2)
		_id_grid[i][floor(len(_id_grid[0]) / 2.0) + offset] = Enums.Cell.MAJOR_ROAD
		
	return _id_grid

# TODO: Backburner, try A* to help accomadate water
func add_road(_id_grid: Array, start: Vector2i, end: Vector2i) -> Array:

	var diff = end - start
	var steps = int(max(abs(diff.x), abs(diff.y)))
	
	var offset = 0
	
	for i in range(steps + 1):
		var t = float(i) / float(steps)
		var x = int(round(lerp(start.x, end.x, t)))
		var y = int(round(lerp(start.y, end.y, t)))
		
		if randf() < 0.2:
			offset += (randi() % 3) - 1  # -1, 0, or +1
		var offset_pos : Vector2i = Vector2i(x + offset, y)
		
		if not bounds_check(offset_pos, Vector2i(len(_id_grid), len(_id_grid[0]))): continue
		
		# TODO: Fix this
		if _id_grid[offset_pos.x][offset_pos.y] == 0:
			pass
			#flood_fill_solve_group(_id_grid, offset_pos, 1, 0)

		_id_grid[offset_pos.x][offset_pos.y] = Enums.Cell.MAJOR_ROAD

		# for j in range(4):
		# 	for k in range(4):
		# 		if not bounds_check(offset_pos + Vector2i(j-2, k-2), Vector2i(len(_id_grid), len(_id_grid[0]))): continue
		# 		_id_grid[offset_pos.x + j - 2][offset_pos.y + k - 2] = Enums.Cell.MAJOR_ROAD

	MIN_UNIQUE_ID += 1
	return _id_grid
