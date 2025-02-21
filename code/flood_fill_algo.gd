extends "res://code/voronoi_overlay_algo.gd"

func flood_fill(id_grid : Array, target_id : int = 0) -> Array: 
	'''
		Purpose: 
			Uses the flood fill algorithm to identify differentiated regions of cells with a designated ID, and sets new ID's which are unique by region

		Arguments: 
			id_grid: 
				The 2D grid for the algorithms
			target_id: 
				The ID for which the algorithm will find spatially seperated regions
				Could easily be replaced by an array of ID's if this functionality becomes necessary

		Return: 
			'id_grid' manipulated by the function
	'''
	
	# Iterate the grid
	for x in range(len(id_grid)): for y in range(len(id_grid[x])): 
		
		# Skip if the ID is not the designated ID
		if not id_grid[x][y] == target_id: continue

		# Use the flood_fill_solve_group algorithm to set all cells connected to this one to MIN_UNIQUE_ID
		id_grid = flood_fill_solve_group(id_grid, Vector2(x,y), MIN_UNIQUE_ID, target_id)

		# Update MIN_UNIQUE_ID
		MIN_UNIQUE_ID += 1
	
	return id_grid

func flood_fill_solve_group(id_grid : Array, initial_pos : Vector2i, new_id : int, target_id : int = 0) -> Array:
	'''
		Purpose: 
			Set all cells with an ID of 'target_id' that are spatially connected to 'initial_pos' to 'new_id'

		Arguments: 
			id_grid: 
				The 2D grid to perform the algorithm on
			initial_pos: 
				The starting point of the algorithm
			new_id: 
				The new value that all cell ID's in the group should be set to
			target_id: 
				The ID that cells must have to be added to the group 

		Return: 
			Array: 'id_grid' manipulated by the function
	'''

	# Initialize an array to track squares that are in the group but whose neighbors have not yet been checked
	var valid_positions : Array[Vector2i] = [] 
	valid_positions.append(initial_pos)
	
	# Iterate while the array is not empty, the alternate to this is recursion but Godot struggles with recursion
	while len(valid_positions) > 0: 
		
		# Get the position from the back of the array and remove it
		var pos : Vector2i = valid_positions.pop_back()
	
		# Iterate all the positions neighbors
		for n in neighbors:
			var n_pos : Vector2i = pos + n 
			
			# Ensure the neighbor is in bounds of the grid and it's value is 'target_id' otherwise continue
			if not bounds_check(n_pos.x, n_pos.y, id_grid.size(), id_grid[0].size()): continue
			if not id_grid[n_pos.x][n_pos.y] == target_id: continue 

			# Add the neighbor to the active array and set its value to 'new_id'
			valid_positions.append(n_pos)
			id_grid[n_pos.x][n_pos.y] = new_id

	
	return id_grid

# Takes an ID array
# Fill's in any group of '2' (empty space) that is not connected to an edge with an ID
# This function is a fix to a consistent bug of a region generating on the inside of the city 
func flood_fill_elim_inside_terrain(id_grid : Array) -> Array: 

	# Flood fill the edge group from (0,0) and replace values of '2' with '0'
	id_grid = flood_fill_solve_group(id_grid, Vector2(0,0), 0, 2)

	# Replace any remaining values of '2' with a new group
	# TODO: technically could be more than one group but haven't observed this 
	for x in range(len(id_grid)): for y in range(len(id_grid[x])): 
		if id_grid[x][y] == 2: id_grid[x][y] = MIN_UNIQUE_ID
	MIN_UNIQUE_ID += 1
	
	# Flood fill the edge group from '0' back to '2'
	id_grid = flood_fill_solve_group(id_grid, Vector2(0,0), 2, 0)
	return id_grid

# Takes an ID array 
# Determine which nodes should be walls and update them in the array, return 
func indentify_walls(id_grid) -> Array:
	for x in range(len(id_grid)): for y in range(len(id_grid[x])): 
		# Only checking for void (1) nodes 
		if id_grid[x][y] != 1: continue

		# If any neighbor is open space (2) set at city wall (-3)
		for n in neighbors: 
			if id_grid[x+n[0]][y+n[1]] == 2: 
				id_grid[x][y] = -3
				break

		# Has not been set as city wall (-3) therefore must be district wall (-4)
		# if id_grid[x][y] == 1: id_grid[x][y] = -4

	return id_grid
