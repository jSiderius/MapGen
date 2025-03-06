#TODO: Make sure false and true us consistent for all fuctions
extends "res://code/cellular_automata_algo.gd"

# export variables
@export var debug : bool = true
@export var squareSize : float = 10.0
@export var threshold : float = 0.01

# Needs to be global for _draw()
var id_grid : Array = [] 
var bbs : Dictionary = {}
var districts : Dictionary = {} 
var roads : Array = []

var district_flag_struct_loader : Resource = preload("res://code/Districts/district_data_flags_struct.gd")
var district_manager_loader : Resource = preload("res://code/Districts/district_manager.gd")
var district_flag_struct : DistrictDataFlagStruct
var district_manager : DistrictManager


func _ready() -> void: 

	# Initialize  variables
	var rng = RandomNumberGenerator.new()
	rng.randomize()

	var screenSize : Vector2 = get_viewport_rect().size
	var w_h : Vector2 = find_width_and_height(screenSize, squareSize)
	var width : int = int(w_h[0])
	var height : int = int(w_h[1])
	screenSize = update_screen_size(width, height, squareSize) 

	# var backgrounds : Array = [$BGSpring, $BGFall, $BGWinter]
	# backgrounds[randi()%3].visible = true

	# Begin algorithms 
	if debug: await redraw_and_pause(0, 0.0, false)

	# Fill the initial grid
	id_grid = generate_random_grid(width, height, true)
	if debug: await redraw_and_pause(1, 0.1)
	
	# Create a voronoi cell map, and clear cells from id_grid that correspond to voronoi edge cells, creating a city outline
	var voronoi_id_array : Array = generate_id_array_with_voronoi_cells(width, height, 100)
	var edge_cell_ids : Array = find_unique_edge_cell_ids(voronoi_id_array) # var edge_cell_ids : Array = find_unique_rightside_border_cell_ids(id_grid, 2) # TODO: Decide if this is necessary / will be used long term, if so create some kind of argument to abstract which borders will be chosen
	voronoi_id_array = overwrite_cells_by_id(voronoi_id_array, edge_cell_ids, 2)
	id_grid = copy_designated_ids(voronoi_id_array, id_grid, [2])
	if debug: await redraw_and_pause(2, 0.1)
	
	# Run trials of cellular automata on the remaining {0,1} noise values 
	id_grid = cellular_automata_trials(id_grid, [4,5,5,5])
	if debug: await redraw_and_pause(3, 0.1)
	
	# Run flood fill to differentiate groups
	id_grid = flood_fill(id_grid)
	if debug: await redraw_and_pause(4, 0.1)

	district_flag_struct = district_flag_struct_loader.new(true)
	district_manager = district_manager_loader.new(id_grid, district_flag_struct)
	
	# Parse out the smallest groups 
	id_grid = parse_smallest_districts(id_grid, district_manager, 25) 
	if debug: await redraw_and_pause(5, 2.1)

	# Expand groups into null space (1)
	id_grid = expand_id_grid(id_grid, [2])
	if debug: await redraw_and_pause(6, 2.1)
	
	district_manager.update_district_data(id_grid, district_flag_struct)

	# TODO: PATHS RANDOMLY FROM THE EDGE OF THE CENTER DISTRICT TO THE EDGE OF THE SCREEN
	# get_outgoing_path_locations(id_grid, district_manager)
	
	# TODO: DETERMINES PATHING BETWEEN MAJOR ROADS
	# roads = add_roads(id_grid, locs, true)

	# TODO: ORIGINAL PURPOSE WAS TO SUBDIVIDE A DISTRICT INTO SMALLER VORONOI DISTRICTS, MAY NOT BE NECESSARY
	# voronoi_district(id_grid, centerDistrict, districts[centerDistrict]["bounding"])
	# if debug: await redraw_and_pause(7, 0.1)

	# Ensure there are no inside districts (common bug) TODO: Could assess the cause but this is fine too
	id_grid = flood_fill_elim_inside_terrain(id_grid)
	if debug: await redraw_and_pause(7, 0.1)

	# Make sure border is correct 
	id_grid = enforce_border(id_grid)
	if debug: await redraw_and_pause(8, 0.1)
	return	


	# Indentify which void nodes (1) are city walls (-3) 
	# This just helps cleanup any lingering void (1) values
	if debug: await redraw_and_pause(9, 0.1, true)

	districts = get_districts_dict(id_grid)
	
	var multiplier : float = 1.5
	id_grid = increase_array_resolution(id_grid, multiplier)
	squareSize = squareSize / float(multiplier)
	id_grid = indentify_walls(id_grid)
	id_grid = expand_id_grid(id_grid, [2, -3])

	var dcs : Array[Vector2i] = []
	for key in districts: 
		var c : Vector2i = districts[key]["center"]
		dcs.append(c)
	
	roads = add_roads(id_grid, dcs, true) # DEBUGGING
	if debug: await redraw_and_pause(10)

	id_grid = increase_array_resolution(id_grid, 2.0)
	squareSize = squareSize / float(2)

	for key in districts.keys():
		var center : Vector2i = districts[key]["center"]
		districts[key]["center"] = Vector2i(floor(center[0] * 2.0), floor(center[1] * 2.0))
		districts[key]["size"] *= 2

	districts_add_bounding_boxes(id_grid, districts) 
	var sumPercent : float = 0.0

	var sortedKeys : Array = []
	for key in districts.keys():
		sortedKeys.append([key, districts[key]["size"]]) 
	sortedKeys.sort_custom(_sort_by_second_element_reverse)
	
	for key in sortedKeys:
		key = key[0] 
		if sumPercent >= 0.7: break
		voronoi_district(id_grid, key, districts[key]["bounding"])
		sumPercent += districts[key]["sizePercent"]
		print(sumPercent)
		# id_grid = add_district_border(id_grid, key, bbs[key])

	id_grid = indentify_walls(id_grid)
	id_grid = expand_id_grid(id_grid, [2, -3])
		
	if debug: await redraw_and_pause(11)
	
	for key in districts.keys(): 
		break
		roads = get_locations_in_district(id_grid, key, districts[key]["bounding"], pow(districts[key]["size"] * 0.05 / PI, 1.0/3.0))
		
		#TODO: Max width is probably a better metric
	if debug: await redraw_and_pause(12)

	for key in districts.keys():
		#break
		id_grid = add_district_center(id_grid, key, districts[key]["bounding"], districts[key]["center"],sqrt(districts[key]["size"] * 0.05 / PI))
		

	if debug: await redraw_and_pause(13)
	
func _draw() -> void: 
	draw_from_id_grid() 
	draw_roads()
	for key in districts.keys():
		# draw_bounding_box(get_random_color(key), squareSize, 5, districts[key]["bounding"][0], districts[key]["bounding"][1])
		pass

func draw_roads(): 
	for r in roads: 
		draw_line(squareSize * Vector2(r[0][0], r[0][1]), squareSize * Vector2(r[1][0], r[1][1]), Color.BLUE, 1.0)

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

# Takes nothing because it is an extension of _draw (uses global variables)
# Draws to screen based on the values in id_grid
func draw_from_id_grid() -> void: 
	# Dictionary defining a mapping from values (int) in id_grid to colors in the draw 
	var colors_dict : Dictionary = {
		2000 : Color.RED, # Main District (Alot of algorithms expect districts to be positive )
		-4 : Color.BLACK, # District walls 
		-3 : Color.BLACK, # City walls
		-2 : Color.BLUE, #District Center
		-1 : Color8(139,69,19), # Major roads
		 0 : Color.WHITE, # Void space from noise, becomes obsolete
		 1 : Color.BLACK, # Void space from noise, becomes district and city walls 
		 2 : Color(0,0,0,0) # Outside space 
	}

	for x in range(len(id_grid)): for y in range(len(id_grid[x])): 
		
		# Get the value of the node 
		var val : int = id_grid[x][y]
		if val == 2: continue 

		# Get the color and position of the node 
		var col = colors_dict[val] if val in colors_dict else get_random_color(id_grid[x][y])
		var rect : Rect2 = Rect2(Vector2(x*squareSize,y*squareSize), Vector2(squareSize, squareSize))

		# Draw the rect
		draw_rect(rect, col)
