#TODO: Make sure false and true us consistent for all fuctions
extends "res://code/cellular_automata_algo.gd"

# export variables
@export var debug : bool = true
@export var squareSize : float = 10.0
@export var threshold : float = 0.01

# Needs to be global for _draw()
var idArray : Array = [] 
	
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
	if debug: await redraw_and_pause(0, 0.0)

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
	# idArray = expand_id_array(idArray, [2])
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
	idArray = indentify_walls(idArray)
	idArray = expand_id_array(idArray, [2, -3], true) # This just helps cleanup any lingering void (1) values
	if debug: await redraw_and_pause(9, 0.1, true)

	# Determine major roads spanning the districts and add them to the array 
	idArray = add_major_roads(idArray)
	if debug: await redraw_and_pause(10)
		
	queue_redraw()
	
func _draw() -> void: 
	draw_from_id_grid() 

# Takes nothing because it is an extension of _draw (uses global variables)
# Draws to screen based on the values in idArray
func draw_from_id_grid() -> void: 
	# Dictionary defining a mapping from values (int) in idArray to colors in the draw 
	var colors_dict : Dictionary = {
			-4 : Color.BLACK, # District walls 
			-3 : Color.BLACK, # City walls
			-2 : Color.BLUE, #District Center
			-1 : Color(205,133,63), # Major roads
			0 : Color.WHITE, # Void space from noise, becomes obsolete
			1 : Color.BLACK, # Void space from noise, becomes district and city walls 
			2 : Color(0,0,0,0) # Outside space 
			# 2 : Color.BLACK
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
