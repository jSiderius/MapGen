extends "res://code/cellular_automata_algo.gd"

func flood_fill(id_grid : Array, target_id : int = Enums.Cell.VOID_SPACE_0) -> Array: 
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

func flood_fill_solve_group(id_grid : Array, initial_pos : Vector2i, new_id : int, target_id : int = Enums.Cell.VOID_SPACE_0) -> Array:
	'''
		Purpose: 
			Set all cells with an ID of 'target_id' that are spatially connected to 'initial_pos' to 'new_id'
			Solves a single group of connected cells within the larger 'flood_fill' algorithm

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
		# for n in neighbors:
		for n in four_neighbors:
			var n_pos : Vector2i = pos + n 
			
			# Ensure the neighbor is in bounds of the grid and it's value is 'target_id' otherwise continue
			if not bounds_check(n_pos, Vector2i(id_grid.size(), id_grid[0].size())): continue
			if not id_grid[n_pos.x][n_pos.y] == target_id: continue 

			# Add the neighbor to the active array and set its value to 'new_id'
			valid_positions.append(n_pos)
			id_grid[n_pos.x][n_pos.y] = new_id

	
	return id_grid

func flood_fill_elim_inside_terrain(id_grid : Array) -> Array: 
	'''
		Purpose: 
			Gives a district ID to empty space (2) which is surrounded by district ID's (>2)
			This addresses a bug where a single district is set as empty space (2)
			NOTE: Should be reassessed in versions of the program that do not use empty space, the algorithm has some dependancies on this and the bug may not occur
			TODO: Fix the bug before it happens instead of after
			TODO: Only accounts for one new district (okay because only one has been observed)

		Arguments: 
			id_grid: The 2D grid to perform the algorithm on

		Return: 
			Array: 'id_grid manipulated by the algorithm'
	'''

	# Flood fill the edge group from (0,0) and replace values of OUTSIDE_SPACE with VOID_SPACE_0
	id_grid = flood_fill_solve_group(id_grid, Vector2(0,0), Enums.Cell.VOID_SPACE_0, Enums.Cell.OUTSIDE_SPACE)

	# Replace any remaining values of OUTSIDE_SPACE with a new group
	for x in range(len(id_grid)): for y in range(len(id_grid[x])): 
		if id_grid[x][y] == 2: id_grid[x][y] = MIN_UNIQUE_ID
	MIN_UNIQUE_ID += 1
	
	# Flood fill the edge group from VOID_SPACE_0 back to OUTSIDE_SPACE
	id_grid = flood_fill_solve_group(id_grid, Vector2(0,0), Enums.Cell.OUTSIDE_SPACE, Enums.Cell.VOID_SPACE_0)
	return id_grid

func add_city_border(id_grid : Array, border_value : int = Enums.Cell.DISTRICT_WALL) -> Array:
	''' Adds a border of cells with value 'border_value' between null space (2) and district space (>2) '''

	id_grid = add_rough_city_border(id_grid, border_value)

	id_grid = validate_city_border(id_grid, border_value)

	return id_grid

func validate_city_border(id_grid : Array, border_value : int = Enums.Cell.CITY_WALL) -> Array:
	'''   
		Purpose: 
			Validates the border by ensuring every cell with value 'border_value' borders null space (2)
			NOTE: Could be extended to district borders using null space arguments and small changes in logic
			
		Arguments: 
			id_grid: 
				2D grid for the algoritm
			border_value: 
				The ID value of border cells
		
		Return: 
			Array: 'id_grid' manipulated by the algorithm
	'''

	# Iterate the grid
	for x in range(len(id_grid)): for y in range(len(id_grid[x])): 
		
		# Only checking for cells with value 'border_value'
		if id_grid[x][y] != border_value: continue

		
		# Loop to ensure the cell neighbors OUTSIDE_SPACE
		var is_border : bool = false
		for n in neighbors: 
			var n_pos : Vector2i = Vector2i(x, y) + n
			
			if id_grid[n_pos.x][n_pos.y] == Enums.Cell.OUTSIDE_SPACE:
				is_border = true
				break
		
		# If the cell should not be a border set it to an arbitrary value that will be overwritten
		if not is_border: 
			id_grid[x][y] = -1001
			
	# Expand the grid to overwrite arbitrary values
	id_grid = expand_id_grid(id_grid, [Enums.Cell.OUTSIDE_SPACE, border_value])

	return id_grid

func add_rough_city_border(id_grid : Array, border_value : int = Enums.Cell.CITY_WALL) -> Array:
	'''
		Purpose: 
			Adds a rough city border by searching from null space cells (2) and setting as borders if they have a neighboring district cell (>2)
			NOTE: This is a rough border because it can create small interior lumps of border, these can be eliminated with the 'validate_city_border' function

		Arguments: 
			id_grid: 
				The 2D grid to perform the algorithm on
			border_value: 
				The new ID for the border cells
		
		Return: 
			Array: 'id_grid' manupulated by the algorithm
	'''

	# Iterate the grid
	for x in range(len(id_grid)): for y in range(len(id_grid[x])): 

		# Skip if the cell is not null space (2) or is on the edge
		if id_grid[x][y] != Enums.Cell.OUTSIDE_SPACE: continue
		if is_edge(Vector2i(x, y), Vector2i(len(id_grid), len(id_grid[x]))): continue

		# Iterate all neighbors
		for n in neighbors:	

			# If the neighbor is a district, set the cell to a border ('border_value')
			if id_grid[x + n[0]][y + n[1]] > 2: 
				id_grid[x][y] = border_value
				break

	return id_grid
