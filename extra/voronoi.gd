#TODO: Make sure false and true us consistent for all fuctions
extends Node2D

var drawStrings : bool = false
var debug : bool = true
var width : int = 0
var height : int = 0
var squareSize : float = 6.0
@export var threshold : float = 0.01
var screenSize : Vector2
var rng = RandomNumberGenerator.new()
var noise = FastNoiseLite.new() 
var boolGrid : Array = []
var idArray : Array = []
var neighbors : Array = [
		Vector2(-1,-1), Vector2(0,-1), Vector2(1,-1),
		Vector2(-1,0),                 Vector2(1,0),
		Vector2(-1,1), Vector2(0,1)  , Vector2(1,1)
	]
	
func _ready() -> void: 
	
	# Initialize  variables
	rng.randomize()
	screenSize = get_viewport_rect().size
	find_width_and_height()
	
	# Fill the initial grid 
	#boolGrid = generate_random_grid(true)
	#idArray = bool_array_to_id_array(boolGrid)
	#if debug: await redraw_and_pause("1")
	
	idArray = generate_voronoi_bool_map(idArray)
	queue_redraw()

func generate_voronoi_bool_map(idArrayArg : Array) -> Array: 
	idArrayArg = generate_empty_id_array()
	
	var num_cells : int = 100
	var cells : Array = []
	for i in range(num_cells): cells.append(Vector2(randi()%width, randi()%height))
	
	idArrayArg = color_voronoi(idArrayArg, cells)
	
	var edge_cells : Array = find_voronoi_edge_cells(idArrayArg)
	#idArrayArg = clear_voronoi_edge_cells(idArrayArg, edge_cells)
	return idArrayArg
	
func color_voronoi(idArrayArg : Array, cells : Array, p : int = 3) -> Array: 
	for x in range(len(idArrayArg)): for y in range(len(idArrayArg[x])): 
		var vec : Vector2 = Vector2(x, y)
		var col : Color
		if vec in cells: 
			idArrayArg[x][y] = 1
			continue
		
		var minIndex : int = 0
		var minDistance : float = 100000
		for i in range(len(cells)): 
			var distance : float = pow( pow(abs(x - cells[i].x), p) + pow(abs(y - cells[i].y), p), 1.0/p)
			#var distance : float = sqrt(pow(x - cells[i].x, 2) + pow(y - cells[i].y, 2))
						
			if distance < minDistance:
				minIndex = i 
				minDistance = distance
				
		idArrayArg[x][y] = minIndex
	
	return idArrayArg
	
func find_voronoi_edge_cells(idArrayArg : Array) -> Array:
	 
	var edge_cells : Array = []
	for x in range(len(idArrayArg)): for y in range(len(idArrayArg[x])): 
		var val : int = idArrayArg[x][y]
		if val in edge_cells: continue
		if is_edge(x, y, len(idArrayArg), len(idArrayArg[x])): edge_cells.append(val)
	
	return edge_cells

func clear_voronoi_edge_cells(idArrayArg : Array, edge_cells : Array) -> Array: 
	for x in range(len(idArrayArg)): for y in range(len(idArrayArg[x])): 
		if idArrayArg[x][y] in edge_cells: 
			idArrayArg[x][y] = 1
			
	return idArrayArg
	
func find_width_and_height() -> void: 
	width =  ceil(screenSize.x/squareSize)
	height = ceil(screenSize.y/squareSize)
	screenSize = Vector2(width*squareSize, height*squareSize)
	
	# Slight adjustment to the window size so that the squares fit perfectly 
	DisplayServer.window_set_size(screenSize)

func generate_random_grid(alt_edges : bool = false) -> Array: 
	var newBoolGrid : Array = []
	for x in width:
		newBoolGrid.append([])
		for y in height:
			newBoolGrid[x].append(randi() % 2 == 1)
	
	return newBoolGrid 

func generate_empty_id_array() -> Array: 
	var newIdArray : Array = []
	for x in width: 
		newIdArray.append([])
		for y in range(height): 
			newIdArray[x].append(0)
	return newIdArray

func bool_array_to_id_array(boolArray : Array) -> Array: 
	var idArrayNew : Array = []
	for x in range(len(boolArray)):
		idArrayNew.append([])
		for y in range(len(boolArray[x])): 
			idArrayNew[x].append(1 if boolArray[x][y] else 0)
	
	return idArrayNew
	
func id_array_to_bool_array(idArrayArg : Array) -> Array: 
	var boolArrayNew : Array = [] 
	for x in range(len(idArrayArg)): 
		boolArrayNew.append([])
		for y in range(len(idArrayArg)):
			boolArrayNew.append(false if idArrayArg[x][y] == 0 else true)
	return boolArrayNew
		
func redraw_and_pause(str : String = "", stall : float = 0.5):
	print("Redraw ", str)
	queue_redraw()
	await get_tree().create_timer(stall).timeout
	print("	Wait complete")

func is_edge(x,y,boundX, boundY):
	return x <=0 or y <= 0 or x >=boundX-1 or y >= boundY-1

func _draw() -> void: 
	if len(idArray) == 0: 
		draw_from_bool_grid() 
		return
	draw_from_id_grid()

func draw_from_id_grid(): 
	for x in range(len(idArray)): 
		for y in range(len(idArray[x])): 
			var rect := Rect2(Vector2(x*squareSize,y*squareSize), Vector2(squareSize, squareSize))
			var col : Color = Color.BLACK if idArray[x][y] == 1 else Color.WHITE if idArray[x][y] == 0 else get_random_color(idArray[x][y])
			draw_rect(rect, col)

func get_random_color(seed : int) -> Color: 
	# Use the seed to generate RGB values
	var r = (seed * 1234567) % 256 / 255.0  # Random red value
	var g = (seed * 2345678) % 256 / 255.0  # Random green value
	var b = (seed * 3456789) % 256 / 255.0  # Random blue value
	
	return Color(r, g, b)
	
func draw_from_bool_grid(): 
	for x in range(len(boolGrid)): 
		for y in range(len(boolGrid[x])): 
			var rect := Rect2(Vector2(x*squareSize,y*squareSize), Vector2(squareSize, squareSize))
			var col : Color = Color.BLACK if boolGrid[x][y] else Color.WHITE
			draw_rect(rect, col)
