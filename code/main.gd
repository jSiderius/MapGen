#TODO: Make sure false and true us consistent for all fuctions
# extends "res://code/cellular_automata_algo.gd"
extends "res://code/flood_fill_algo.gd"

# export variables
@export var debug : bool = true
@export var square_size : float = 10.0
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

	district_flag_struct = district_flag_struct_loader.new(true)
	district_manager = district_manager_loader.new(id_grid, district_flag_struct)

	# Initialize  variables
	var rng = RandomNumberGenerator.new()
	rng.randomize()

	var screenSize : Vector2 = get_viewport_rect().size
	var w_h : Vector2 = find_width_and_height(screenSize, square_size)
	var width : int = int(w_h[0])
	var height : int = int(w_h[1])
	screenSize = update_screen_size(width, height, square_size) 

	# var backgrounds : Array = [$BGSpring, $BGFall, $BGWinter]
	# backgrounds[randi()%3].visible = true

	# Begin algorithms 
	if debug: await redraw_and_pause(0, 0.0, false)

	# Fill the initial grid
	id_grid = generate_random_grid(width, height, true)
	if debug: await redraw_and_pause(1, 0.1)
	
	# Create a voronoi cell map, and clear cells from id_grid that correspond to voronoi edge cells, creating a city outline
	# var voronoi_id_array : Array = generate_id_array_with_voronoi_cells(width, height, 100)
	# var edge_cell_ids : Array = find_unique_edge_cell_ids(voronoi_id_array) # var edge_cell_ids : Array = find_unique_rightside_border_cell_ids(id_grid, 2) # TODO: Decide if this is necessary / will be used long term, if so create some kind of argument to abstract which borders will be chosen
	# voronoi_id_array = overwrite_cells_by_id(voronoi_id_array, edge_cell_ids, 2)
	# id_grid = copy_designated_ids(voronoi_id_array, id_grid, [2])
	if debug: await redraw_and_pause(2, 0.1)
	
	# Run trials of cellular automata on the remaining {0,1} noise values 
	# id_grid = cellular_automata_trials(id_grid, [4,5,5,5])
	# if debug: await redraw_and_pause(3, 0.1)

	id_grid = cellular_automata_trials(id_grid, [3])
	if debug: await redraw_and_pause(3, 1.0)

	id_grid = cellular_automata_trials(id_grid, [6])
	if debug: await redraw_and_pause(3, 1.0)

	# id_grid = cellular_automata_trials(id_grid, [6])
	# if debug: await redraw_and_pause(3, 1.0)

	# id_grid = cellular_automata_trials(id_grid, [4])
	# if debug: await redraw_and_pause(3, 1.0)

	# id_grid = cellular_automata_trials(id_grid, [4])
	# if debug: await redraw_and_pause(3, 1.0)
	
	id_grid = add_slanted_line(id_grid, Vector2(0, 0), Vector2(len(id_grid[0]), len(id_grid)))
	if debug: await redraw_and_pause(3, 1.0)

	# Run flood fill to differentiate groups
	id_grid = flood_fill(id_grid)
	if debug: await redraw_and_pause(4, 0.1)

	
	# Parse out the smallest groups 
	id_grid = parse_smallest_districts(id_grid, district_manager, 75) 
	if debug: await redraw_and_pause(5, 0.1)

	# Expand groups into null space (1)
	id_grid = expand_id_grid(id_grid, [2, -1])
	if debug: await redraw_and_pause(6, 0.1)
	
	district_manager.update_district_data(id_grid, district_flag_struct)

	# TODO: PATHS RANDOMLY FROM THE EDGE OF THE CENTER DISTRICT TO THE EDGE OF THE SCREEN
	# get_outgoing_path_locations(id_grid, district_manager)
	
	# Ensure there are no inside districts (common bug) TODO: Could assess the cause but this is fine too
	id_grid = flood_fill_elim_inside_terrain(id_grid)
	if debug: await redraw_and_pause(7, 0.1)

	# Increase the array resolution and add a new (thinner) border
	var multiplier : float = 1.5
	id_grid = increase_array_resolution(id_grid, multiplier)
	square_size = square_size / float(multiplier)
	add_city_border(id_grid, -4)

	if debug: await redraw_and_pause(8, 0.1)

	district_manager.update_district_data(id_grid, district_flag_struct)
	var district_centers : Array[Vector2i] = district_manager.get_district_centers()
	
	# roads = add_roads(id_grid, district_centers, true)
	if debug: await redraw_and_pause(10)
	# return

	id_grid = increase_array_resolution(id_grid, 2.0)
	square_size = square_size / 2.0
	district_manager.update_district_data(id_grid, district_flag_struct)

	# Select districts and add borders to them
	var sorted_keys : Array = district_manager.get_keys_sorted_by_attribute("size_", false)

	for i in range(len(sorted_keys)):
		var district : District = district_manager.get_district(sorted_keys[i])
		district.render_border = true

	if debug: await redraw_and_pause(11)
	
func _draw() -> void: 
	draw_from_id_grid() 
	# draw_roads()
	for key in districts.keys():
		# draw_bounding_box(get_random_color(key), square_size, 5, districts[key]["bounding"][0], districts[key]["bounding"][1])
		pass

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
		var rect : Rect2 = Rect2(Vector2(x*square_size,y*square_size), Vector2(square_size, square_size))

		#print(district_manager)
		#if district_manager and district_manager.get_district(val).render_border: 
		if district_manager: 
			var district = district_manager.get_district(val)
			if district and district.render_border: 
				col = Color.PURPLE

		# Draw the rect
		draw_rect(rect, col)
	
	if not district_manager: return
	var borders_to_render : Array[Vector2i] = district_manager.get_borders_to_render()
	for pos in borders_to_render: 
		
		# Get the color and position of the node 
		var rect : Rect2 = Rect2(Vector2(pos.x*square_size,pos.y*square_size), Vector2(square_size, square_size))

		# Draw the rect
		draw_rect(rect, Color.YELLOW)

func add_center_line(_id_grid : Array) -> Array:
	#for i in range(len(_id_grid[0])): 
		#_id_grid[floor(len(_id_grid) / 2.0)][i] = 1
	var offset : int = 0
	for i in range(len(_id_grid[0])): 
		if randf() < 0.1: offset += (randi() % 2)
		_id_grid[floor(len(_id_grid) / 2.0) + offset][i] = -1
		
	offset = 0
	for i in range(len(_id_grid)):
		if randf() < 0.1: offset += (randi() % 2)
		_id_grid[i][floor(len(_id_grid[0]) / 2.0) + offset] = -1
		
	# MIN_UNIQUE_ID += 1
	return _id_grid

func add_slanted_line(_id_grid: Array, start: Vector2, end: Vector2) -> Array:
	var dx = end.x - start.x
	var dy = end.y - start.y
	var steps = int(max(abs(dx), abs(dy)))
	
	var offset = 0
	
	for i in range(steps + 1):
		var t = float(i) / float(steps)
		var x = int(round(lerp(start.x, end.x, t)))
		var y = int(round(lerp(start.y, end.y, t)))
		
		if randf() < 0.1:
			offset += (randi() % 3) - 1  # -1, 0, or +1
		var ox = x + offset
		var oy = y + offset
		
		if oy >= 0 and oy < _id_grid.size() and ox >= 0 and ox < _id_grid[0].size():
			_id_grid[oy][ox] = -1
	
	return _id_grid
