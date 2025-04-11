extends "res://code/cellular_automata_algo.gd"

# func flood_fill_elim_inside_terrain(id_grid : Array) -> Array: 
# 	'''
# 		Purpose: 
# 			Gives a district ID to empty space (2) which is surrounded by district ID's (>2)
# 			This addresses a bug where a single district is set as empty space (2)
# 			NOTE: Should be reassessed in versions of the program that do not use empty space, the algorithm has some dependancies on this and the bug may not occur

# 			TODO: 	Fix the bug before it happens instead of after
# 					Only accounts for one new district (okay because only one has been observed)
# 					Assess the algorithm and if it has a place in the program


# 		Arguments: 
# 			id_grid: The 2D grid to perform the algorithm on

# 		Return: 
# 			Array: 'id_grid manipulated by the algorithm'
# 	'''

# 	# Flood fill the edge group from (0,0) and replace values of OUTSIDE_SPACE with VOID_SPACE_0
# 	id_grid = flood_fill_solve_group(id_grid, Vector2(0,0), Enums.Cell.VOID_SPACE_0, Enums.Cell.OUTSIDE_SPACE)

# 	# Replace any remaining values of OUTSIDE_SPACE with a new group
# 	for x in range(len(id_grid)): for y in range(len(id_grid[x])): 
# 		if id_grid[x][y] == 2: id_grid[x][y] = MIN_UNIQUE_ID
# 	MIN_UNIQUE_ID += 1
	
# 	# Flood fill the edge group from VOID_SPACE_0 back to OUTSIDE_SPACE
# 	id_grid = flood_fill_solve_group(id_grid, Vector2(0,0), Enums.Cell.OUTSIDE_SPACE, Enums.Cell.VOID_SPACE_0)
# 	return id_grid
