extends "res://code/flood_fill_algo.gd"

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
			if id_grid[x][y] not in [0,1]: 
				new_id_grid[x].append(id_grid[x][y])
				continue

			var num_neighbors : int = 0

			# Iterate all neighbors of (x,y)
			for n in neighbors: 
				var n_pos = Vector2i(x + n[0], y + n[1])
				
				# Check that n_pos is in bounds
				if not bounds_check(n_pos.x, n_pos.y, len(id_grid), len(id_grid[x])): continue 

				# Update the num_neighbors counter (+1 if 1, no change if 0)
				num_neighbors += id_grid[n_pos.x][n_pos.y]
			
			# Set the value in the new grid according to the number of neighbors and the threshold 
			new_id_grid[x].append(1 if num_neighbors >= threshold else 0)
	
	return new_id_grid

func maintain_edge(id_grid, val : int = 0): 
	for x in range(len(id_grid)): for y in range(len(id_grid[x])): 
		if is_edge(x, y, len(id_grid), len(id_grid[x])): 
			id_grid[x][y] = val

# Takes an ID array, an array of ids that are autonomous (can't be expanded into), and a bool indicating if empty space (2) should expand
# Single iteration of each group node (>2) into null space (1) if possible 
func expand_id_array(id_grid : Array,  districts : Dictionary, autonomousIDs : Array[int] = [], expansionBlocked : Array = [], checks : Array[Vector2i] = []) -> Array: 
	var idArrayNew : Array = id_grid.duplicate(true)
	var newChecks : Array[Vector2i] = []
	
	# var totalSize : int = len(id_grid) * len(id_grid[0])
	# for key in districts.keys(): 
	# 	if districts[key]["size"] > totalSize * 0.3: expansionBlocked.append(key)

	if checks == []:
		for x in range(len(id_grid)): for y in range(len(id_grid[x])): 
			if id_grid[x][y] < 2 or id_grid[x][y] in expansionBlocked: continue
			expand_id_array_instance(id_grid, idArrayNew, districts, Vector2i(x, y), newChecks, autonomousIDs)
	else: 
		for check in checks: 
			if id_grid[check.x][check.y] < 2 or id_grid[check.x][check.y] in expansionBlocked: continue
			expand_id_array_instance(id_grid, idArrayNew, districts, Vector2i(check.x, check.y), newChecks, autonomousIDs)
	
	if idArrayNew != id_grid and len(newChecks) > 0: return expand_id_array(idArrayNew, districts, autonomousIDs, expansionBlocked, newChecks)
	return idArrayNew 

func expand_id_array_instance(id_grid : Array, idArrayNew : Array, districts : Dictionary, pos : Vector2i, checks : Array, autonomousIDs : Array[int] = []): 
	# Make sure the square is a group node, and has not been previously updated in this iteration
	if id_grid[pos.x][pos.y] != idArrayNew[pos.x][pos.y]: return
	
	# Determine if any candidates are valid for expansion
	for n in neighbors: 
		var newX : int = pos.x + n[0]
		var newY : int = pos.y + n[1]
		if not bounds_check(newX, newY, len(id_grid), len(id_grid[pos.x])): continue
		if id_grid[newX][newY] > 2 or id_grid[newX][newY] in autonomousIDs: continue #TIME OUT, THESE CAN EXPAND INTO EACH OTHER ? 

		if idArrayNew[newX][newY] == 1: 
			idArrayNew[newX][newY] = id_grid[pos.x][pos.y]
			checks.append(Vector2i(newX, newY))
			districts[id_grid[pos.x][pos.y]]["size"] += 1
