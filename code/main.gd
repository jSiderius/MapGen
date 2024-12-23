#TODO: Make sure false and true us consistent for all fuctions
extends "res://code/cellular_automata_algo.gd"

# export variables
@export var debug : bool = true
@export var squareSize : float = 10.0
@export var threshold : float = 0.01

# Needs to be global for _draw()
var idArray : Array = [] 
var bbs : Dictionary = {}
var districts : Dictionary = {} 
var roads : Array = []
	
func _ready() -> void: 
	# Initialize  variables
	var rng = RandomNumberGenerator.new()
	rng.randomize()

	var screenSize : Vector2 = get_viewport_rect().size
	var w_h : Vector2 = find_width_and_height(screenSize, squareSize)
	var width : int = int(w_h[0])
	var height : int = int(w_h[1])
	screenSize = update_screen_size(width, height, squareSize) 

	var backgrounds : Array = [$BGSpring, $BGFall, $BGWinter]
	backgrounds[randi()%3].visible = true

	# Begin algorithms 
	if debug: await redraw_and_pause(0, 0.0, false)

	# Fill the initial grid 
	idArray = generate_random_grid(width, height, true)
	if debug: await redraw_and_pause(1, 0.1)
	
	# Create a voronoi cell map, and clear cells from idArray that correspond to voronoi edge cells, creating a city outline
	var binaryIDArray : Array = generate_voronoi_binary_id_array(width, height, 100)	
	idArray = clear_id_array_by_binary_id_array(idArray, binaryIDArray)
	if debug: await redraw_and_pause(2, 0.1)
	
	# Run trials of cellular automata on the remaining {0,1} noise values 
	idArray = cellular_automata_trials(idArray, [4,5,6])
	if debug: await redraw_and_pause(3, 0.1)
	
	# Run flood fill to differentiate groups
	idArray = flood_fill(idArray)
	if debug: await redraw_and_pause(4, 0.1)
	
	# Parse out the smallest groups 
	idArray = parse_smallest_groups(idArray, 6) 
	if debug: await redraw_and_pause(5, 0.1)
	
	# Expand groups into null space (1)
	idArray = expand_id_array(idArray, [2], true)
	if debug: await redraw_and_pause(6, 0.1, true)
	 
	#TODO: enforce_border and identify_walls??
	# Make sure border is correct 
	idArray = enforce_border(idArray)
	if debug: await redraw_and_pause(7, 0.1)
	
	# Make sure there is no empty space (2) district inside the city walls 
	idArray = flood_fill_elim_inside_terrain(idArray)
	if debug: await redraw_and_pause(8, 0.1)

	# Indentify which void nodes (1) are city walls (-3) 
	# This just helps cleanup any lingering void (1) values
	if debug: await redraw_and_pause(9, 0.1, true)

	districts = get_districts_dict_empty(idArray)
	districts = districts_add_sizes(idArray, districts)
	
	var multiplier : float = 1.5
	idArray = increase_array_resolution(idArray, multiplier)
	squareSize = squareSize / float(multiplier)
	idArray = indentify_walls(idArray)
	idArray = expand_id_array(idArray, [2, -3], true)

	districts = districts_add_centers(idArray , districts)
	districts = districts_add_sizes(idArray, districts)
	districts = districts_add_percentages(idArray, districts)

	var dcs : Array[Vector2i] = []
	for key in districts: 
		var c : Vector2i = districts[key]["center"]
		print(c)
		dcs.append(c)
	
	roads = add_roads(idArray, dcs, true, true) # DEBUGGING
	if debug: await redraw_and_pause(10)

	idArray = increase_array_resolution(idArray, 2.0)
	squareSize = squareSize / float(2)

	for key in districts.keys():
		var center : Vector2i = districts[key]["center"]
		districts[key]["center"] = Vector2i(floor(center[0] * 2.0), floor(center[1] * 2.0))
		districts[key]["size"] *= 2

	bbs  = find_district_bounding_boxes(idArray) # TODO: Add bbs to districts dict 
	var sumPercent : float = 0.0

	var sortedKeys : Array = []
	for key in bbs.keys():
		sortedKeys.append([key, districts[key]["size"]]) 
	sortedKeys.sort_custom(_sort_by_second_element_reverse)
	
	for key in sortedKeys:
		key = key[0] 
		if sumPercent >= 0.7: break
		voronoi_district(idArray, key, bbs[key])
		sumPercent += districts[key]["sizePercent"]
		print(sumPercent)
		# idArray = add_district_border(idArray, key, bbs[key])

	idArray = indentify_walls(idArray)
	idArray = expand_id_array(idArray, [2, -3], true)
		
	if debug: await redraw_and_pause(11)
	
	for key in bbs.keys(): 
		break
		roads = get_locations_in_district(idArray, key, bbs[key], districts[key]["center"], pow(districts[key]["size"] * 0.05 / PI, 1.0/3.0))
		
		#TODO: Max width is probably a better metric
	if debug: await redraw_and_pause(12)

	for key in bbs.keys():
		#break
		idArray = add_district_center(idArray, key, bbs[key], districts[key]["center"],sqrt(districts[key]["size"] * 0.05 / PI))
		

	if debug: await redraw_and_pause(13)
	
func _draw() -> void: 
	draw_from_id_grid() 
	draw_roads()
	for key in bbs.keys():
		# draw_bounding_box(get_random_color(key), squareSize, 5, bbs[key][0], bbs[key][1])
		pass

func draw_roads(): 
	for r in roads: 
		draw_line(squareSize * Vector2(r[0][0], r[0][1]), squareSize * Vector2(r[1][0], r[1][1]), Color.BLUE, 1.0)

func draw_bounding_box(col : Color, ss : float, line_width : float, first : Vector2i, second : Vector2i) -> void: 
	# Convert the points to top-left and bottom-right for consistent rectangle rendering
	var top_left = Vector2(ss * min(first.x, second.x), ss * min(first.y, second.y))
	var bottom_right = Vector2(ss * (max(first.x, second.x) + 1), ss * (max(first.y, second.y) + 1))
	
	# Define the corners
	var top_right = Vector2(bottom_right.x, top_left.y)
	var bottom_left = Vector2(top_left.x, bottom_right.y)

	# Draw the four sides of the rectangle with the specified line width
	draw_line(top_left, top_right, col, line_width)  # Top side
	draw_line(top_right, bottom_right, col, line_width)  # Right side
	draw_line(bottom_right, bottom_left, col, line_width)  # Bottom side
	draw_line(bottom_left, top_left, col, line_width)  # Left side

# Takes nothing because it is an extension of _draw (uses global variables)
# Draws to screen based on the values in idArray
func draw_from_id_grid() -> void: 
	# Dictionary defining a mapping from values (int) in idArray to colors in the draw 
	var colors_dict : Dictionary = {
		-4 : Color.BLACK, # District walls 
		-3 : Color.BLACK, # City walls
		-2 : Color.BLUE, #District Center
		-1 : Color8(139,69,19), # Major roads
		 0 : Color.WHITE, # Void space from noise, becomes obsolete
		 1 : Color.BLACK, # Void space from noise, becomes district and city walls 
		 2 : Color(0,0,0,0) # Outside space 
	}

	for x in range(len(idArray)): for y in range(len(idArray[x])): 
		
		# Get the value of the node 
		var val : int = idArray[x][y]
		if val == 2: continue 

		# Get the color and position of the node 
		var col = colors_dict[val] if val in colors_dict else get_random_color(idArray[x][y])
		var rect : Rect2 = Rect2(Vector2(x*squareSize,y*squareSize), Vector2(squareSize, squareSize))

		# Draw the rect
		draw_rect(rect, col)
