extends "res://code/reduction_algos.gd"

func generate_id_array_with_voronoi_cells(width : int, height : int, num_cells : int = 100, min_dist_from_edge_percent : float = 0.05) -> Array:
	'''
		Purpose: 
			Generate an ID grid where each ID is set to the value of the nearest randomly generated voronoi point

		Args: 
			width: 
				Width of the new ID grid
			height: 
				Height of the new ID grid
			num_cells: 
				Number of randomly generated voronoi cells
			min_dist_from_edge_percent: 
				The minimum distance a voroni cells can be from any edge as a percentage of the size of the grid

		Returns:
			Array: The generated array 
	'''

	var id_grid : Array = generate_empty_id_array(width, height)

	# Create a vector representing the interger distance a voronoi cell should be from the edge
	var buffer_zone : Vector2i = Vector2i(ceil(width * min_dist_from_edge_percent), ceil(height * min_dist_from_edge_percent))
	# TODO: Validate the buffer zone
	
	var cells : Array[Vector2i] = []

	# Randomly generate the cell locations
	for i in range(num_cells): 
		cells.append(Vector2i(buffer_zone.x + randi()%(width - 2 * buffer_zone.x), buffer_zone.y + randi()% (height - 2 * buffer_zone.y)))
	
	# Determine each point in the grids value based on the vornoi cell locations
	for x in range(len(id_grid)): for y in range(len(id_grid[x])): 
		id_grid[x][y] = get_position_id_by_voronoi_cell_locations(cells, Vector2i(x, y)) + 1

	return id_grid


func get_position_id_by_voronoi_cell_locations(cells : Array[Vector2i], pos : Vector2i, p : float=1) -> int: 
	'''
		Purpose:
			Determine the closest of an array of positions (representing Voronoi cells) to a single passed position 

		Args:
			cells: 
				An array of vectors representing voronoi cell locations
			pos: 
				A single position vector, for which we want to determine the nearest position in 'cells'
			p: 
				The root for the distance functions. p=1 -> manhattan distance, p=2 -> euclidean distance, ... 
				
		Returns: 
			int: The index of the nearest vector to 'pos' in 'cells' 
	'''
	
	var min_index : int = 0
	var min_distance : float = 1000000.0
	for i in range(len(cells)):

		# Calculate the distance from 'pos' to the ith cell
		var distance : float = pow( pow(abs(pos.x - cells[i].x), p) + pow(abs(pos.y - cells[i].y), p), 1.0/p)
		if distance > min_distance: continue
		
		# Update the ith cell as the new minimum cell if it's distance is less than all previous cells
		min_index = i 
		min_distance = distance
	
	return min_index
	
func find_unique_edge_cell_ids(id_grid : Array) -> Array:
	'''
		Purpose: 
			Determine the set of all IDs in the grid which border the edge
		
		Args: 
			id_grid: The grid to determine the output set from 

		Returns: 
			Array: Set of all IDs in 'id_grid' which border the edge
	'''

	var edge_cell_ids : Array = []

	# Check every value in the 2D array
	for x in range(len(id_grid)): for y in range(len(id_grid[x])): #TODO: iterate only edge cells, put this in a function maybe
		var cell_id : int = id_grid[x][y]

		# Check if the cell is an edge cell and the cell's ID is not already in the set 
		if is_edge(x, y, len(id_grid), len(id_grid[x])) and not cell_id in edge_cell_ids: #TODO: probably some more intuitvie way to clear this as a set like a dict
			edge_cell_ids.append(cell_id)
	
	return edge_cell_ids

# TODO: Holding off on docs for this because if I use it again I'll probably override with some modular way to select right, left, up, down, and corners
func find_unique_rightside_border_cell_ids(id_grid : Array, trials : int = 1) -> Array:
	'''
		Purpose: 

		Args: 
		
		Returns: 
	'''

	var edgeCells : Array = []
	for x in range(len(id_grid)): for y in range(len(id_grid[x])): #TODO: See 'TODO' in find_unique_edge_cell_ids
		var cell_id : int = id_grid[x][y]

		# Check if the cell is adjacent to the right edge and the cell's ID is not already in the set
		if x + 1 == len(id_grid) and cell_id not in edgeCells: 
			edgeCells.append(cell_id)

	# Extend the depth ie. trials = 2 is border or bordering a border, ...
	# TODO: refactor and/or document for
	for i in range(trials - 1): 
		var edgeCellsNext : Array = []
		for x in range(len(id_grid)): for y in range(len(id_grid[x])): 
			for n in four_neighbors: 
				var newX : int = x + n[0]
				var newY : int = y + n[1]

				if not bounds_check(newX, newY, len(id_grid), len(id_grid[x])): continue
				if id_grid[newX][newY] in edgeCells and id_grid[newX][newY] not in edgeCellsNext: 
					edgeCellsNext.append(id_grid[newX][newY])
		edgeCells.append_array(edgeCellsNext)
		
	return edgeCells

func overwrite_cells_by_id(id_grid : Array, ids_to_overwrite : Array, new_cell_id : int = 0) -> Array: 
	'''
		Purpose: 
			Overwrites all cells in a 2D grid which are designated to be overwritten with a passed value

		Args: 
			id_grid: 
				The 2D grid
			id_to_overwrite: 
				The ids in 'id_grid' which will be set to the new override value
			new_cell_id: 
				The new override value

		Returns:
			Array: 'id_grid' manipulated according to the function
	'''

	# Iterate all cells in the 2d array
	for x in range(len(id_grid)): for y in range(len(id_grid[x])): 

		# If a cells ID is in ids_to_overwrite, set its new id as new_cell_id
		if id_grid[x][y] in ids_to_overwrite: 
			id_grid[x][y] = new_cell_id
			
	return id_grid

func copy_designated_ids(from_grid : Array, to_grid : Array, ids_to_copy : Array) -> Array:
	'''
		Purpose:
			Copy any cell with a designated ID from 'from_grid' to 'to_grid'

		Args: 
			from_grid: 
				The array to be copied from
			to_grid:
				The array to copy to
			ids_to_copy: 
				The array of ID's which should be copied (ID's not in set will be retain their value in 'to_grid')

		Returns:
			Array: 'to_grid' manipulated according to the function 
	'''

	# Exit the function if the arrays have different shapes
	if not len(from_grid) == len(to_grid) or not len(from_grid[0]) == len(to_grid[0]): return to_grid

	# Iterate all cells in the 2D grid(s)
	for x in range(len(to_grid)): for y in range(len(to_grid[x])):

		# If the ID in 'from_grid' is in 'ids_to_copy' set the ID in 'to_grid' to that value
		if from_grid[x][y] in ids_to_copy: 
			to_grid[x][y] = from_grid[x][y]
	
	return to_grid

func enforce_border(id_grid : Array) -> Array:
	''' Enforces the border between district cells (>2) and null space (2) setting the in-between cells to the border ID (1)'''

	# Iterate the grid
	for x in range(len(id_grid)): for y in range(len(id_grid[x])): 

		# Skip if the cell is not null space (2) or is on the edge
		if id_grid[x][y] != 2 or is_edge(x, y, len(id_grid), len(id_grid[x])): continue

		# Iterate all neighbors
		for n in neighbors:	

			# If the neighbor is a district, set the cell to a border (1)
			if id_grid[x + n[0]][y + n[1]] > 2: 
				id_grid[x][y] = 1
				break

	return id_grid

# ORIGINAL PURPOSE WAS TO SUBDIVIDE A DISTRICT INTO SMALLER VORONOI DISTRICTS, MAY NOT BE NECESSARY
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
				var newX : int = x + n[0]
				var newY : int = y + n[1]

				if not bounds_check(newX, newY, len(voronoiRepresentation), len(voronoiRepresentation[0])): continue
				var district_border : bool = id_grid[newX][newY] > 2 and id_grid[newX][newY] != id
				var voronoi_border : bool = voronoiRepresentation[newX][newY] != voronoiRepresentation[x][y] and x <= newX and y <= newY
				if district_border or voronoi_border: 
					id_grid[x][y] = -4
	
	# MIN_UNIQUE_ID += len(locations)
