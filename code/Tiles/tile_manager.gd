extends "res://code/helpers.gd"

class_name TileManager

var font : Font = preload("res://font/Money Plans.otf")

var tile_splicer : TileSplicer # TODO: Get rid of loaders across files
var tile_grid : Array[Array]
var height : int
var width : int
var complete : bool = false
var square_size : float

var pq : PriorityQueue


func _init(id_grid : Grid) -> void:
	
	height = id_grid.height
	width = id_grid.width
	square_size = id_grid.square_size
	tile_splicer = TileSplicer.new(Image.load_from_file("res://tileset.png"), 16, 16, Vector2(id_grid.square_size, id_grid.square_size))
	pq = pqLoad.new()
	
	generate_tile_grid(id_grid)

func generate_tile_grid(id_grid : Grid) -> void:
	'''
		Purpose:
			Setup a tile grid according to the data in the Grid argument

		Arguments:
			id_grid:
				Grid containing data for the tiles

		Return: void
	'''

	if not id_grid.district_manager:
		id_grid.update_district_manager()
		print_debug("Grid does not contain district manager")
		push_error("Grid does not contain district manager")
	
	# Construct an array of all border water cells
	var water_border : Array = []
	
	if id_grid.district_manager.has_district(Enums.Cell.WATER):
		var border_by_neighbor = id_grid.district_manager.get_district(Enums.Cell.WATER).border_by_neighbor
		for key in border_by_neighbor.keys():
			if key == Enums.Cell.BRIDGE: continue

			water_border += border_by_neighbor[key]

	# Iterate the grid and create a tile for each cell
	for y in range(height): 
		tile_grid.append([])
		for x in range(width):
			var cell_id : int = id_grid.index(y,x)
			if Vector2i(y, x) in water_border: cell_id = Enums.Cell.WATER_BORDER # Override cell_id with WATER_BORDER for WFC
			if id_grid.district_manager.has_district(cell_id) and id_grid.district_manager.get_district(cell_id).generic_district: 
				cell_id = id_grid.district_manager.get_district(cell_id).generic_district
			tile_grid[y].append(Tile.new(cell_id))
	
	for y in range(height): for x in range(width): 
		var tile : Tile = tile_grid[y][x]
		var tile_possibilities = tile.get_possibilities()
		
		# Initialize NESW Neighbors
		if y > 0:
			tile.add_neighbor(wfcConfig.Dir.NORTH, tile_grid[y-1][x])
			tile_grid[y-1][x].constrain(tile_possibilities, wfcConfig.Dir.NORTH)
			tile.constrain(tile_grid[y-1][x].possibilities, wfcConfig.Dir.SOUTH)
		if y < height-1:
			tile.add_neighbor(wfcConfig.Dir.SOUTH, tile_grid[y+1][x])
			tile_grid[y+1][x].constrain(tile_possibilities, wfcConfig.Dir.SOUTH)
			tile.constrain(tile_grid[y+1][x].possibilities, wfcConfig.Dir.NORTH)
		if x > 0:
			tile.add_neighbor(wfcConfig.Dir.WEST, tile_grid[y][x-1])
			tile_grid[y][x-1].constrain(tile_possibilities, wfcConfig.Dir.WEST)
			tile.constrain(tile_grid[y][x-1].possibilities, wfcConfig.Dir.EAST)
		if x < width - 1:
			tile.add_neighbor(wfcConfig.Dir.EAST, tile_grid[y][x+1])
			tile_grid[y][x+1].constrain(tile_possibilities, wfcConfig.Dir.EAST)
			tile.constrain(tile_grid[y][x+1].possibilities, wfcConfig.Dir.WEST)
	
	for y in range(height): for x in range(width):
		pq.insert(tile_grid[y][x], float(get_entropy(y, x)))

func get_entropy(y : int, x : int) -> int:
	''' Returns the entropy of the tile at (y, x)'''

	return tile_grid[y][x].get_entropy()

func get_type(y : int, x : int) -> int:
	''' Return the tile type of the tile at position y, x '''

	if len(tile_grid[y][x].get_possibilities()) == 0:
		print_debug("Tile type requested for tile with no possibilities")
		push_warning("Tile type requested for tile with no possibilities")
		return wfcConfig.TILE_ERROR

	return tile_grid[y][x].get_possibilities()[0]

func get_lowest_entropy_tile_pq():
	return pq.pop_min()

func wave_function_collapse_pq(spectate : bool = true) -> void:
	''' Execute the wave function collapse algorithm '''

	# Run iterations of the algorithm until complete
	var is_complete : bool = false
	while not is_complete: 
		is_complete = wave_function_collapse_iteration_pq()
		if spectate: await redraw_and_pause(-1, 0.0, false, false)
	
	for y in range(height): for x in range(width):
		# if get_type(y, x) == wfcConfig.TileType.TILE_ERROR: tile_grid[y][x].removal_failure()
		pass

	await redraw_and_pause(-1, 0.0, false, false)

	complete = true
	
func wave_function_collapse_iteration_pq() -> bool:
	'''
		Purpose: 
			Completes a single iteration of the wave function collapse algorithm
		Return:
			bool: indicates if the algorithm is complete
	'''

	# Return if all cells are collapsed
	if pq.is_empty(): return true

	# Select the lowest entropy tile
	var  tile_to_collapse : Tile = get_lowest_entropy_tile_pq()
	tile_to_collapse.collapse()

	# Constrain all tiles effected by the collapse
	var stack : Array = [tile_to_collapse]
	while(len(stack) > 0):
		var tile : Tile = stack.pop_back()
		
		# Iterate the tiles neighbors
		for direction in tile.get_directions():

			# Setup the neighbor
			var neighbor : Tile = tile.get_neighbor(direction)
			if neighbor.get_entropy() == 0: continue
			
			# Constrain the neighbor according to the tile, if it reduces add it to the stack and update the pq
			if neighbor.constrain(tile.get_possibilities(), direction): 
				pq.insert_or_update(neighbor, len(neighbor.possibilities))
				stack.append(neighbor)
	
	return false

func _draw() -> void:

	for y in height: for x in width:
		
		var t : Tile = tile_grid[y][x]
		
		if t.entropy == 0 or t.entropy == 1:
			var callback : Dictionary = tile_splicer.get_drawing_data(wfcConfig.tile_vector[t.get_tile_type()], Vector2i(y, x))
			draw_texture_rect_region( tile_splicer.tileset_texture, callback["rect"], callback["src_rect"] )
			
			if t.overlay:
				callback = tile_splicer.get_drawing_data(wfcConfig.overlay_vector[t.overlay], Vector2i(y, x))
				draw_texture_rect_region( tile_splicer.tileset_texture, callback["rect"], callback["src_rect"] )
			continue
		
		var rect : Rect2 = Rect2(Vector2(x*square_size, y*square_size), Vector2(square_size, square_size)) #Takes pos = (y,x) and coverts to godot's coords (x, y)
		draw_rect(rect, Color(0, 0, 0, 1.0))

		# Calculate text size and position for centering
		var text = str(t.entropy)
		var text_pos = (Vector2(x * square_size + square_size / 2.0, y * square_size + square_size / 2.0))
		
		# Draw the text
		draw_string(font, text_pos, text)






# KEEP FOR RUNTIME ANALYSIS
func wave_function_collapse() -> void:
	''' Execute the wave function collapse algorithm '''

	# Run iterations of the algorithm until complete
	var is_complete : bool = false
	while not is_complete: 
		is_complete = wave_function_collapse_iteration()
	
	await redraw_and_pause(-1, 0.0, false)
	complete = true

func wave_function_collapse_iteration() -> bool:
	'''
		Purpose: 
			Completes a single iteration of the wave function collapse algorithm
		Return:
			bool: indicates if the algorithm is complete
	'''

	# Get an array containing all tiles of the lowest entropy
	var lowest_entropy_tiles : Array[Tile] = get_lowest_entropy_tile_list()

	# Exit if all cells have selected a tile type
	if len(lowest_entropy_tiles) == 0:
		return true
	
	# Select a tile randomly from the lowest entropy cells and collapse it
	var tile_to_collapse : Tile = lowest_entropy_tiles[randi() % len(lowest_entropy_tiles)]
	tile_to_collapse.collapse()

	# Constrain all tiles effected by the collapse
	var stack : Array = [tile_to_collapse]
	while(len(stack) > 0):
		var tile : Tile = stack.pop_back()
		
		# Iterate the tiles neighbors
		for direction in tile.get_directions():

			# Setup the neighbor
			var neighbor : Tile = tile.get_neighbor(direction)
			if neighbor.get_entropy() == 0: continue
			
			# Constrain the neighbor according to the tile, if it reduces add it to the stack
			if neighbor.constrain(tile.get_possibilities(), direction): 
				stack.append(neighbor)
	
	return false

func get_lowest_entropy_tile_list() -> Array[Tile]:
	'''
		Purpose: 
			Compiles and returns an array of all the lowest entropy tiles in the grid

		Return: 
			Array[Tile]: All tiles having the lowest entropy value in the grid
	'''
	# TODO: A priority queue could help runtime
	
	# Initialize variables
	var lowest_entropy_tiles : Array[Tile] = []
	var lowest_entropy : int = wfcConfig.TileType.size()
	
	# Iterate the grid
	for y in range(height): for x in range(width): 
		var tile_entropy : int = get_entropy(y, x)
		
		# Skip solved cells and entropy larger than lowest
		if tile_entropy <= 1 or tile_entropy > lowest_entropy:
			continue
		# Add to array if matching entropy
		elif tile_entropy == lowest_entropy: 
			lowest_entropy_tiles.append(tile_grid[y][x])
			continue
		# Reset variables if lower entropy
		else:
			lowest_entropy = tile_entropy
			lowest_entropy_tiles = [tile_grid[y][x]]
	
	return lowest_entropy_tiles
