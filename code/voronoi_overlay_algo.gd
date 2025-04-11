extends "res://code/reduction_algos.gd"

''' TODO: ORIGINAL PURPOSE WAS TO SUBDIVIDE A DISTRICT INTO SMALLER VORONOI DISTRICTS, MAY NOT BE NECESSARY '''
func voronoi_district(id_grid : Array, id : int, boundingBox : Array): 
	'''
		Purpose: 

		Args: 
		
		Returns: 
	'''

	var districtNodes : Array[Vector2i] = []
	var voronoiRepresentation : Array = id_grid.duplicate(true)

	for x in range(boundingBox[0][0], boundingBox[1][0]+1, 1):
		for y in range(boundingBox[0][1], boundingBox[1][1]+1, 1): 
			if id_grid[x][y] == id: districtNodes.append(Vector2i(x,y))

	var locations = select_random_items(districtNodes, floor(len(districtNodes) * 0.005))

	for x in range(boundingBox[0][0], boundingBox[1][0]+1, 1):
		for y in range(boundingBox[0][1], boundingBox[1][1]+1, 1): 
			if id_grid[x][y] != id: continue
			# get_position_id_by_voronoi_cell_locations(voronoiRepresentation, locations, Vector2i(x, y), 5.0, )
			# TODO: ??? 
	
	for x in range(boundingBox[0][0], boundingBox[1][0]+1, 1):
		for y in range(boundingBox[0][1], boundingBox[1][1]+1, 1): 
			if id_grid[x][y] != id: continue

			for n in neighbors:
				var n_pos : Vector2i = Vector2i(x, y) + n

				if not bounds_check(n_pos , Vector2i(len(voronoiRepresentation), len(voronoiRepresentation[0]))): continue
				var district_border : bool = id_grid[n_pos.x][n_pos.y] > 2 and id_grid[n_pos.x][n_pos.y] != id
				var voronoi_border : bool = voronoiRepresentation[n_pos.x][n_pos.y] != voronoiRepresentation[x][y] and x <= n_pos.x and y <= n_pos.y
				if district_border or voronoi_border: 
					id_grid[x][y] = -4
	
	# MIN_UNIQUE_ID += len(locations)
