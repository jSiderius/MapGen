extends "res://code/helpers.gd"

class_name TileManager

var font : Font = preload("res://font/Money Plans.otf")

var tile_splicer : TileSplicer # TODO: Get rid of loaders across files
var tile_grid : Array[Array]
var height : int
var width : int
var complete : bool = false
var square_size : float

func _init(id_grid : Grid) -> void:
	print(id_grid)
	height = id_grid.height
	width = id_grid.width
	square_size = id_grid.square_size
	tile_splicer = TileSplicer.new(Image.load_from_file("res://tileset.png"), 16, 16, Vector2(id_grid.square_size, id_grid.square_size))
	
	generate_tile_grid(id_grid)

func generate_tile_grid(id_grid : Grid) -> void:
	
	if not id_grid.district_manager:
		print_debug("Grid does not contain district manager")
		push_error("Grid does not contain district manager")
		
	var water_border : Array[Vector2i] = []
	if id_grid.district_manager.has_district(Enums.Cell.WATER):
		water_border = id_grid.district_manager.get_district(Enums.Cell.WATER).border

	for y in range(height): 
		tile_grid.append([])
		for x in range(width):
			var cell_id : int = id_grid.index(y,x)
			if Vector2i(y, x) in water_border: cell_id = Enums.Cell.WATER_BORDER
			tile_grid[y].append(Tile.new(cell_id))
	
	for y in range(height): for x in range(width): 
		var tile : Tile = tile_grid[y][x]
		var tile_possibilities = tile.get_possibilities()
		
		if y > 0:
			tile.add_neighbor(wfcConfig.Dir.NORTH, tile_grid[y-1][x])
			tile_grid[y-1][x].constrain(tile_possibilities, wfcConfig.Dir.NORTH)
			tile.constrain(tile_grid[y-1][x].possibilities, wfcConfig.Dir.SOUTH)
		else: 
			tile.add_border(wfcConfig.Dir.NORTH)

		if y < height-1:
			tile.add_neighbor(wfcConfig.Dir.SOUTH, tile_grid[y+1][x])
			tile_grid[y+1][x].constrain(tile_possibilities, wfcConfig.Dir.SOUTH)
			tile.constrain(tile_grid[y+1][x].possibilities, wfcConfig.Dir.NORTH)
		else: 
			tile.add_border(wfcConfig.Dir.SOUTH)

		if x > 0:
			tile.add_neighbor(wfcConfig.Dir.WEST, tile_grid[y][x-1])
			tile_grid[y][x-1].constrain(tile_possibilities, wfcConfig.Dir.WEST)
			tile.constrain(tile_grid[y][x-1].possibilities, wfcConfig.Dir.EAST)
		else: 
			tile.add_border(wfcConfig.Dir.WEST)

		if x < width - 1:
			tile.add_neighbor(wfcConfig.Dir.EAST, tile_grid[y][x+1])
			tile_grid[y][x+1].constrain(tile_possibilities, wfcConfig.Dir.EAST)
			tile.constrain(tile_grid[y][x+1].possibilities, wfcConfig.Dir.WEST)
		else: 
			tile.add_border(wfcConfig.Dir.EAST)


func get_entropy(x : int, y : int) -> int:
	return tile_grid[y][x].get_entropy()

func get_type(x : int, y : int) -> int: 
	if len(tile_grid[y][x].get_possibilities()) == 0: return wfcConfig.TILE_ERROR
	return tile_grid[y][x].get_possibilities()[0] # TODO: ??? Should we check that the entropy is also 0? 

func get_lowest_entropy_value() -> int: 
	var lowest_entropy : int = len(wfcConfig.tile_edges.keys())
	for y in range(height): for x in range(width):
		if tile_grid[y][x].get_entropy() <= 0: continue
		lowest_entropy = min(lowest_entropy, tile_grid[y][x].get_entropy())
	
	return lowest_entropy

func get_lowest_entropy_tile_list() -> Array[Tile]:
	# TODO: A priority queue could help runtime
	
	var lowest_entropy_tiles : Array[Tile] = []
	var lowest_entropy : int = wfcConfig.TileType.size()
	
	for y in range(height): for x in range(width): 
		var tile_entropy : int = tile_grid[y][x].get_entropy()
		if tile_entropy <= 0: 
			continue
		elif tile_entropy > lowest_entropy: 
			continue
		elif tile_entropy == lowest_entropy: 
			lowest_entropy_tiles.append(tile_grid[y][x])
			continue
		else:
			lowest_entropy = tile_entropy
			lowest_entropy_tiles = [tile_grid[y][x]]
	
	return lowest_entropy_tiles

func wave_function_collapse(dm : DistrictManager) -> void:
	
	var is_complete : bool = false
	while not is_complete: 
		is_complete = await wave_function_collapse_iteration()
		await redraw_and_pause(-1, 0.0, false)

	complete = true
	print("Block 1 time : ", block_1_time / (block_1_time + block_2_time), "%")
	print("Block 2 time : ", block_2_time / (block_1_time + block_2_time), "%")
	
var block_1_time : float = 0 # about 8%
var block_2_time : float = 0 # about 92%
func wave_function_collapse_iteration() -> bool:
	
	var start_1 = Time.get_ticks_usec()

	var lowest_entropy_tiles : Array[Tile] = get_lowest_entropy_tile_list() # This could be a long time thing 
	if len(lowest_entropy_tiles) == 0:
		return true
	
	block_1_time += Time.get_ticks_usec() - start_1

	var tile_to_collapse : Tile = lowest_entropy_tiles[randi() % len(lowest_entropy_tiles)]
	tile_to_collapse.collapse()
	
	var start_2 = Time.get_ticks_usec()

	var stack : Array = [tile_to_collapse]
	while(len(stack) > 0):
		var tile : Tile = stack.pop_back()
		var tile_possibilities = tile.get_possibilities()
		var tile_directions = tile.get_directions()
		
		for direction in tile_directions:
			var neighbor : Tile = tile.get_neighbor(direction)
			if neighbor.get_entropy() == 0: continue
			
			if neighbor.constrain(tile_possibilities, direction): 
				stack.append(neighbor)
				
	block_2_time += Time.get_ticks_usec() - start_2
	
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
