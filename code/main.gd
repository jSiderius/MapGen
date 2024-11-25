#TODO: Make sure false and true us consistent for all fuctions
extends "res://code/cellular_automata_algo.gd"

var drawStrings : bool = false
var debug : bool = true
var width : int = 0
var height : int = 0
var squareSize : float = 10.0
@export var threshold : float = 0.01
var screenSize : Vector2
var rng = RandomNumberGenerator.new()
var noise = FastNoiseLite.new() 
var boolGrid : Array = []
var idArray : Array = []
var district_centers : Dictionary = {}
var roads : Array = []

	
func _ready() -> void: 
	# Initialize  variables
	rng.randomize()
	screenSize = get_viewport_rect().size
	find_width_and_height()
	
	
	var backgrounds = [$BGSpring, $BGFall, $BGWinter]
	backgrounds[randi()%3].visible = true

	# Fill the initial grid 
	idArray = generate_random_grid(width, height, true)
	if debug: await redraw_and_pause("1")
	
	boolGrid = generate_voronoi_bool_map(width, height)	
	idArray = clear_id_array_by_bool_array(idArray, boolGrid)
	if debug: await redraw_and_pause("5")
	
	# Run trials of cellular automata 
	idArray = await cellular_automata_trials([4,5,6], idArray)
	#idArray = bool_array_to_id_array(boolGrid)
	if debug: await redraw_and_pause("2")
	
	idArray = id_array_create_edge_group(idArray)
	
	idArray = flood_fill(idArray)
	drawStrings = true
	if debug: await redraw_and_pause("3")
	
	idArray = parse_groups_by_size(idArray)
	if debug: await redraw_and_pause("4")
	
	
	
	idArray = expand_id_array(idArray)
	if debug: await redraw_and_pause("6")
	
	idArray = parse_smallest_groups(idArray)
	if debug: await redraw_and_pause("7")
	
	idArray = expand_id_array(idArray)
	idArray = create_voronoi_border(idArray)
	if debug: await redraw_and_pause("8")
	
	idArray = flood_fill_elim_inside_terrain(idArray)
	
	# ROAD FINDING 
	roads = find_major_roads(idArray)
	for road in roads:
		idArray = a_star(idArray, road[0], road[1])
	for road in roads: 
		idArray[road[0][0]][road[0][1]] = -2
		idArray[road[1][0]][road[1][1]] = -2
	roads = []
	if debug: await redraw_and_pause("9")
	
	indentify_walls(idArray)
	sprite_overlay(idArray, squareSize)
	
	# ROTATING THE DRAW 
	#scale = Vector2(0.5, 0.5)
	#rotation = PI * float(randi()%2)	
	#rotation_degrees = randi()%360
	#set_rotation(PI * float(randi()%2))
	
	# SUBDIVIDING THE DISTRICTS 
	#var bbs : Dictionary = find_district_bounding_boxes(idArray)
	#var temp = idArray
	#for key in bbs.keys():
		#idArray = subdivide_district(temp, bbs[key], key)
		#idArray = flood_fill(idArray, key)
		#if debug: await redraw_and_pause("9", 2.0)
	
	queue_redraw()

func subdivide_district(idArrayArg : Array, bb : Array, key : int) -> Array: 
	var sub_array : Array = get_array_between(bb[0], bb[1], idArrayArg)
	
	return sub_array
	
func find_district_bounding_boxes(idArrayArg):
	var groups_dict : Dictionary = {} 
	for x in range(len(idArrayArg)): for y in range(len(idArrayArg[x])): 
		var val : int = idArrayArg[x][y]
		if val <= 2: continue
		elif val not in groups_dict: 
			groups_dict[val] = [Vector2(x,y), Vector2(x,y)]
			continue 
		groups_dict[val][0][0] = groups_dict[val][0][0] if groups_dict[val][0][0] < x else x 
		groups_dict[val][0][1] = groups_dict[val][0][1] if groups_dict[val][0][1] < y else y 
		groups_dict[val][1][0] = groups_dict[val][1][0] if groups_dict[val][1][0] > x else x 
		groups_dict[val][1][1] = groups_dict[val][1][1] if groups_dict[val][1][1] > y else y 

	return groups_dict

func get_array_between(v1: Vector2, v2: Vector2, array: Array) -> Array:
	# Ensure v1 has the smaller x and y values
	var start = Vector2(min(v1.x, v2.x), min(v1.y, v2.y))
	var end = Vector2(max(v1.x, v2.x), max(v1.y, v2.y))
	
	var result = []
	for x in range(start.x, end.x+1): 
		result.append([])
		for y in range(start.y, end.y+1):
			if not bounds_check(x, y, len(array), len(array[x])): continue 
			result[x-start.x].append(array[x][y])
	
	return result
	
func find_width_and_height() -> void: 
	width =  ceil(screenSize.x/squareSize)
	height = ceil(screenSize.y/squareSize)
	screenSize = Vector2(width*squareSize, height*squareSize)
	
	# Slight adjustment to the window size so that the squares fit perfectly 
	DisplayServer.window_set_size(screenSize)

func indentify_walls(idArray) -> void:
	for x in range(len(idArray)): for y in range(len(idArray[x])): 
		if idArray[x][y] != 1: continue
		for n in neighbors: 
			if idArray[x+n[0]][y+n[1]] == 2: 
				idArray[x][y] = -3
				break
	

# DRAW
func redraw_and_pause(str : String = "", stall : float = 20.0):
	print("Redraw ", str)
	queue_redraw()
	await get_tree().create_timer(stall).timeout
	print("	Wait complete")
	
func _draw() -> void: 
	if len(idArray) == 0: 
		draw_from_bool_grid() 
	else: 
		draw_from_id_grid()
	
	draw_roads()

func draw_from_id_grid(): 
	for x in range(len(idArray)): for y in range(len(idArray[x])): 
		var rect := Rect2(Vector2(x*squareSize,y*squareSize), Vector2(squareSize, squareSize))
		var val = idArray[x][y]
		if val == 2: continue 
		var colors_dict : Dictionary = {
			-3 : Color(0,0,0,0),
			-2 : Color.BLUE, #District Center
			-1 : Color(128,128,128), # Major roads
			0 : Color.WHITE, # Empty space, becomes obsolete
			1 : Color.BLACK # Eventually city walls
		}
		var col = colors_dict[val] if val in colors_dict else get_random_color(idArray[x][y])
		draw_rect(rect, col)
	
		#if draw_strings: draw_string(ThemeDB.fallback_font, Vector2(x*squareSize + squareSize/2 - 4,y*squareSize + squareSize/2), str(idArray[x][y]), 0, -1, 8, Color.RED)

func get_random_color(seed : int) -> Color: 
	# Use the seed to generate RGB values
	var r = (seed * 1234567) % 256 / 255.0  # Random red value
	var g = (seed * 2345678) % 256 / 255.0  # Random green value
	var b = (seed * 3456789) % 256 / 255.0  # Random blue value
	
	return Color(r, g, b)
	
func draw_from_bool_grid(): 
	for x in range(len(boolGrid)): for y in range(len(boolGrid[x])): 
		var rect := Rect2(Vector2(x*squareSize,y*squareSize), Vector2(squareSize, squareSize))
		var col : Color = Color.BLACK if boolGrid[x][y] else Color.WHITE
		draw_rect(rect, col, true)

func draw_roads(): 
	var color : Color = Color(1, 0, 0)
	var thickness : float = 1.0
	
	for road in roads: 
		draw_line(road[0]*squareSize, road[1]*squareSize, color, thickness)
