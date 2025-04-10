# extends "res://code/flood_fill_algo.gd"
extends "res://code/voronoi_overlay_algo.gd"

func cellular_automata_trials(id_grid : Array, trial_threshold_values : Array[int]) -> Array:
	'''
		Purpose: 
			Run multiple trials of the cellular automata algorithm on a 2D grid

		Arguments: 
			id_grid:
				The 2D grid
			trial_threshold_values: 
				An ordered array of the threshold value used for trial of the algorithm, the length of this array replaces the need for a num_trials arg

		Return: 
			Array: 'id_grid' manipulated according to the function
	'''

	for threshold in trial_threshold_values:
		id_grid = cellular_automata(id_grid, threshold)
		
	return id_grid
	
func cellular_automata(id_grid : Array, threshold : int) -> Array: 
	'''
		Purpose: 
			Follows the cellular automata algorithm to update the values in id_grid based on the number of neighbors a cell has w.r.t. the threshold
			Exclusively considers 1 & 0 values, any other value is untouched and not considered a neighbor 

		Arguments: 
			id_grid: 
				The 2D grid to conduct the algorithm on
			threshold: 
				The threshod number of 1 neighbors such that if a cell has more, it becomes a 1, and if it has less it becomes a 0

		Return: 
			Array: A new 2D grid resulting from the algorithm being run on 'id_grid'
	'''

	var new_id_grid : Array = []
	
	# Iterate the grid
	for x in range(len(id_grid)): 
		new_id_grid.append([])
		for y in range(len(id_grid[x])): 

			# If an ID is not 0 or 1 it is ignored by the algorithm and maintains it's value
			if id_grid[x][y] not in [Enums.Cell.VOID_SPACE_0, Enums.Cell.VOID_SPACE_1]: 
				new_id_grid[x].append(id_grid[x][y])
				continue

			var num_neighbors : int = 0

			# Iterate all neighbors of (x,y)
			for n in neighbors: 
				var n_pos = Vector2i(x, y) + n
				
				# Check that n_pos is in bounds
				if not bounds_check(n_pos, Vector2i(len(id_grid), len(id_grid[x]))): continue 
				
				if id_grid[n_pos.x][n_pos.y] == Enums.Cell.WATER: 
					num_neighbors += 10
					continue
				
				# Update the num_neighbors counter (+1 if 1, no change if 0)
				num_neighbors += id_grid[n_pos.x][n_pos.y]
				# TODO: Proof all values, even though there shouldn't be any others

			# Set the value in the new grid according to the number of neighbors and the threshold 
			new_id_grid[x].append(Enums.Cell.VOID_SPACE_1 if num_neighbors >= threshold else Enums.Cell.VOID_SPACE_0)
	
	return new_id_grid

func set_grid_edge(id_grid : Array, val : int = Enums.Cell.VOID_SPACE_0): 
	''' Sets every edge cell in the grid to a designated value'''

	for x in range(len(id_grid)): for y in range(len(id_grid[x])): 
		if is_edge(Vector2i(x, y), Vector2i(len(id_grid), len(id_grid[x]))): 
			id_grid[x][y] = val


func expand_id_grid(id_grid : Array, autonomous_ids : Array[int] = [], expanding_ids : Array[int] = []) -> Array: 
	'''
		Purpose: 
			Expand the district cells into the void space surrounding it

		Arguments: 
			id_grid: 
				The 2D grid that the function modifies
			autonomous_ids: 
				A list of ID's which cannot be expanded TO in the algorithm (district ID's (>3) are autonomous by default)

		Return: 
			Array: 'id_grid' manipulated by the algorithm
		
		Notes
			- Could add other expansion parameters such as min/max size and block/encourage expansion accordingly
			- pop_at(randi() mod len(checks)) gives a more random distribution, pop_front() is most spatially accurate to the starting point, pop_back() is extremelly biased
	'''

	# Get the array of every district cell in the grid
	var active_expansion_cells : Array[Vector2i] = get_district_cell_location_array(id_grid, expanding_ids)
	
	# Assess if an active cell has any expandable neighbors (which then become active) until there are no active cells
	while len(active_expansion_cells) > 0:
		var pos : Vector2i = active_expansion_cells.pop_front()
		expand_id_grid_instance(id_grid, pos, active_expansion_cells, autonomous_ids, expanding_ids)
	
	return id_grid

func expand_id_grid_instance(id_grid : Array, pos : Vector2i, active_expansion_cells : Array, autonomous_ids : Array[int] = [], expanding_ids = []) -> void: 
	'''
		Purpose: 
			Given a position in the grid, determine if the cell can validly expand to any of its neighbors, and do so
		
		Arguments: 
			id_grid: the ID grid

		Return: void
	'''

	var cell_id : int = id_grid[pos.x][pos.y]

	
	if cell_id == Enums.Cell.WATER: print("Before")

	# Ensure the cell is a group node
	if not (is_district(cell_id) or cell_id in expanding_ids): return
	
	if cell_id == Enums.Cell.WATER: print("Through")
	# Determine if any neighbors are valid for expansion
	for n in four_neighbors: 
		var n_pos : Vector2i = pos + n

		# Ensure the neighbor is within the bounds, and has an ID that is valid for expansion
		if not bounds_check(n_pos, Vector2i(len(id_grid), len(id_grid[pos.x]))): continue
		if is_district(id_grid[n_pos.x][n_pos.y]) or id_grid[n_pos.x][n_pos.y] in autonomous_ids: continue

		# Set the neighbors value and add it to the active expansion cells
		id_grid[n_pos.x][n_pos.y] = cell_id
		active_expansion_cells.append(n_pos)

func get_district_cell_location_array(id_grid : Array, additional_ids : Array = []) -> Array[Vector2i]: 
	''' Returns an array of the Vector2i location of every district cell (with ID > 2) '''

	var location_array : Array[Vector2i] = []

	for x in range(len(id_grid)): for y in range(len(id_grid[x])): 
		if is_district(id_grid[x][y]) or id_grid[x][y] in additional_ids: 
			location_array.append(Vector2i(x,y))
	
	return location_array
