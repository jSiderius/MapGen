# extends "res://code/flood_fill_algo.gd"
extends "res://code/voronoi_overlay_algo.gd"

func set_grid_edge(id_grid : Array, val : int = Enums.Cell.VOID_SPACE_0): 
	''' Sets every edge cell in the grid to a designated value'''

	for x in range(len(id_grid)): for y in range(len(id_grid[x])): 
		if is_edge(Vector2i(x, y), Vector2i(len(id_grid), len(id_grid[x]))): 
			id_grid[x][y] = val
