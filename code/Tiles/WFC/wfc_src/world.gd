extends Node

class_name World

var cell_loader : Resource = preload("res://wfc_src/cell.gd")

var width : int = 0 
var height : int = 0
var cell_rows : Array[Array] = []

func _init(size_x, size_y) -> void: 
	width = size_x
	height = size_y
	
	for y in range(height): 
		cell_rows.append([])
		for x in range(width):
			cell_rows[y].append(cell_loader.new(x, y))
	
	for y in range(height): for x in range(width): 
		var cell : Cell = cell_rows[y][x]
		if y > 0: 
			cell.add_neighbor(wfcConfig.NORTH, cell_rows[y-1][x])
		if y < height-1: 
			cell.add_neighbor(wfcConfig.SOUTH, cell_rows[y+1][x])
		if x > 0: 
			cell.add_neighbor(wfcConfig.WEST, cell_rows[y][x-1])
		if x < width - 1: 
			cell.add_neighbor(wfcConfig.EAST, cell_rows[y][x+1])

func get_entropy(x : int, y : int) -> int:
	return cell_rows[y][x].get_entropy()

func get_type(x : int, y : int) -> int: 
	if len(cell_rows[y][x].get_possibilities()) == 0: return wfcConfig.TILE_ERROR
	return cell_rows[y][x].get_possibilities()[0] # TODO: ??? Should we check that the entropy is also 0? 

# TODO: Why value instead of cell?
func get_lowest_entropy_value() -> int: 
	var lowest_entropy : int = len(wfcConfig.cell_edges.keys())
	for y in range(height): for x in range(width):
		if cell_rows[y][x].get_entropy() <= 0: continue
		lowest_entropy = min(lowest_entropy, cell_rows[y][x].get_entropy())
	
	return lowest_entropy

func get_lowest_entropy_cell_list() -> Array[Cell]:
	
	var lowest_entropy_cells : Array[Cell] = []
	var lowest_entropy : int = len(wfcConfig.edge_rules.keys())
	
	for y in range(height): for x in range(width): 
		var cell_entropy : int = cell_rows[y][x].get_entropy()
		if cell_entropy <= 0: 
			continue
		elif cell_entropy > lowest_entropy: 
			continue
		elif cell_entropy == lowest_entropy: 
			lowest_entropy_cells.append(cell_rows[y][x])
			continue
		else:
			lowest_entropy_cells = [cell_rows[y][x]]
	
	return lowest_entropy_cells

func wave_function_collapse() -> bool:
	
	var lowest_entropy_cells : Array[Cell] = get_lowest_entropy_cell_list()
	if len(lowest_entropy_cells) == 0:
		return true
	
	var cell_to_collapse : Cell = lowest_entropy_cells[randi() % len(lowest_entropy_cells)]
	cell_to_collapse.collapse()
	
	var stack : Array = [cell_to_collapse]
	while(len(stack) > 0):
		var cell : Cell = stack.pop_back()
		var cell_possibilities = cell.get_possibilities()
		var cell_directions = cell.get_directions()
		
		print(cell_directions)
		for direction in cell_directions: 
			var neighbor : Cell = cell.get_neighbor(direction)
			if neighbor.get_entropy() == 0: continue
			
			if neighbor.constrain(cell_possibilities, direction): 
				stack.append(neighbor)
	return false
		
		
	
	
	
