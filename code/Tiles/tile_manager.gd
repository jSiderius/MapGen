extends "res://code/helpers.gd"

class_name TileManager

var tile_splicer : TileSplicer # TODO: Get rid of loaders across files
var tile_grid : Array[Array]
var height : int
var width : int

func _init(id_grid : Grid) -> void:
	height = id_grid.height
	width = id_grid.width
	generate_tile_grid(id_grid)
	tile_splicer = TileSplicer.new(Image.load_from_file("res://tileset.png"), 16, 16, Vector2(id_grid.square_size, id_grid.square_size))
	
var grasses : Array[int] = [Enums.Tiles.GRASS_0, Enums.Tiles.GRASS_1, Enums.Tiles.GRASS_2, Enums.Tiles.GRASS_3, Enums.Tiles.GRASS_4, Enums.Tiles.GRASS_5, Enums.Tiles.GRASS_6, Enums.Tiles.GRASS_7, Enums.Tiles.GRASS_8]

func generate_tile_grid(id_grid : Grid) -> void:
	for y in range(height): 
		tile_grid.append([])
		for x in range(width):
			tile_grid[y].append(Tile.new(x, y, id_grid.index(y, x)))
	
	for y in range(height): for x in range(width): 
		var tile : Tile = tile_grid[y][x]
		if y > 0: 
			tile.add_neighbor(wfcConfig.NORTH, tile_grid[y-1][x])
		if y < height-1: 
			tile.add_neighbor(wfcConfig.SOUTH, tile_grid[y+1][x])
		if x > 0: 
			tile.add_neighbor(wfcConfig.WEST, tile_grid[y][x-1])
		if x < width - 1: 
			tile.add_neighbor(wfcConfig.EAST, tile_grid[y][x+1])
	
	wave_function_collapse()

	# for y in height:
	# 	tile_grid.append([])
	# 	for x in width:
	# 		if id_grid.index(y, x) == Enums.Cell.OUTSIDE_SPACE:
	# 			tile_grid[y].append(grasses[randi() % len(grasses)])
	# 		else: 
	# 			tile_grid[y].append(Enums.Tiles.NONE)
				
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
	
	var lowest_entropy_tiles : Array[Tile] = []
	var lowest_entropy : int = len(wfcConfig.edge_rules.keys())
	
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
			lowest_entropy_tiles = [tile_grid[y][x]]
	
	return lowest_entropy_tiles

func wave_function_collapse() -> void:
	var is_complete : bool = false
	while not is_complete: 
		is_complete = wave_function_collapse_iteration()
	
func wave_function_collapse_iteration() -> bool:
	
	var lowest_entropy_tiles : Array[Tile] = get_lowest_entropy_tile_list()
	if len(lowest_entropy_tiles) == 0:
		return true
	
	var tile_to_collapse : Tile = lowest_entropy_tiles[randi() % len(lowest_entropy_tiles)]
	tile_to_collapse.collapse()
	
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
	return false

var tiles_dict = {
	Enums.Tiles.GRASS_0 : Vector2i(0,0),
	Enums.Tiles.GRASS_1 : Vector2i(0,1),
	Enums.Tiles.GRASS_2 : Vector2i(0,2),
	Enums.Tiles.GRASS_3 : Vector2i(1,0),
	Enums.Tiles.GRASS_4 : Vector2i(1,1),
	Enums.Tiles.GRASS_5 : Vector2i(1,2),
	Enums.Tiles.GRASS_6 : Vector2i(2,0),
	Enums.Tiles.GRASS_7 : Vector2i(2,1),
	Enums.Tiles.GRASS_8 : Vector2i(2,2),
}


func _draw() -> void:
	for y in height: for x in width:
		# if tile_grid[y][x] == Enums.Tiles.NONE: continue
		var t : Tile = tile_grid[y][x]
		
		var callback : Dictionary = tile_splicer.get_drawing_data(wfcConfig.tile_vector[t.possibilities[0]], Vector2i(y, x))
		# print(callback)
		# var callback : Dictionary = tile_splicer.get_drawing_data(Vector2i(0,0), Vector2i(y, x))
		draw_texture_rect_region( tile_splicer.tileset_texture, callback["rect"], callback["src_rect"] )
