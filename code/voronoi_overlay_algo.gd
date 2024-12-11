extends "res://code/reduction_algos.gd"

# Takes ints representing width and height of the resulting array and num_cells representing the number of random voronoi cells
# Generates num_cells voronoi cells randomly and returns a array with the cell ID if it is not an edge cell and 0 otherwise
func generate_voronoi_binary_id_array(width : int, height : int, num_cells=100, dis_from_edge_p : float = 0.05) -> Array: 
	var idArray : Array = generate_empty_id_array(width, height)
	
	var cells : Array = []
	for i in range(num_cells): 
		var w_dis : int = ceil(width * dis_from_edge_p)
		var h_dis : int = ceil(height * dis_from_edge_p)
		cells.append(Vector2(w_dis + randi()%(width - 2 * w_dis), h_dis + randi()% (height - 2 * h_dis)))
	color_voronoi(idArray, cells)
	
	var edge_cells : Array = find_voronoi_edge_cells(idArray)
	idArray = clear_voronoi_edge_cells(idArray, edge_cells)
	
	return idArray

# Take an ID array, an array of cells (2D vectors in the bounds of ID array), and p representing the root for the distance function
# p=1 -> manhattan distance, p=2 -> euclidean distance, ... 
# Set the value of each (x,y) in idArray to the index value of the closest cell, return idArray
func color_voronoi(idArray : Array, cells : Array, p=1): 
	for x in range(len(idArray)): for y in range(len(idArray[x])): 
		color_voronoi_single(idArray, cells, Vector2i(x, y), p)

func color_voronoi_single(idArray : Array, cells : Array, pos : Vector2i, p : float=1, idBoost : int = 0, border : bool = false, borderThreshold : float = 1.0, borderOnly : bool = false): 
	var minIndex : int = idBoost
	var minDistance : float = 1000000.0
	# var minDistanceSecond : float = 1000000.0
	for i in range(len(cells)):
		var distance : float = pow( pow(abs(pos.x - cells[i].x), p) + pow(abs(pos.y - cells[i].y), p), 1.0/p)
		if distance < minDistance:
			minIndex = i 
			# minDistanceSecond = minDistance
			minDistance = distance
	
	# if border and abs(minDistance - minDistanceSecond) <= borderThreshold: idArray[pos.x][pos.y] = -4
	idArray[pos.x][pos.y] = minIndex + 1
	
# Takes an ID array
# Returns an array of every unique edge cell value
func find_voronoi_edge_cells(idArray : Array) -> Array:
	 
	var edge_cells : Array = []
	for x in range(len(idArray)): for y in range(len(idArray[x])): 
		var val : int = idArray[x][y]
		if is_edge(x, y, len(idArray), len(idArray[x])) and not val in edge_cells: edge_cells.append(val)
	
	return edge_cells

# Takes an ID array and an array of id's
# Set's every (x, y) cell with a value in edge_cells to 0
func clear_voronoi_edge_cells(idArray : Array, edge_cells : Array) -> Array: 
	for x in range(len(idArray)): for y in range(len(idArray[x])): 
		if idArray[x][y] in edge_cells: 
			idArray[x][y] = 0
			
	return idArray

# Takes an ID array 
# Check if any exterior nodes (2) should be border nodes (1 ... changes to -3 at later point)
func enforce_border(idArray : Array) -> Array:
	for x in range(len(idArray)): for y in range(len(idArray[x])): 
		if idArray[x][y] != 2 or is_edge(x, y, len(idArray), len(idArray[x])): continue
		for n in neighbors:	
			if idArray[x + n[0]][y + n[1]] > 2: idArray[x][y] = 1
	return idArray

# Takes an ID array and a binary ID array (1's and 0's) of equal dimensions 
# Erases the value in idArray if the value in binaryIDArray is 0 (sets val to 2 which represents null space)
func clear_id_array_by_binary_id_array(idArray : Array, binaryIDArray : Array) -> Array: 
	for x in range(len(idArray)): for y in range(len(idArray[x])): 
		idArray[x][y] = 2 if binaryIDArray[x][y]==0 else idArray[x][y]
	return idArray 

# COMPARTMENTALIZE
func voronoi_district(idArray : Array, id : int, boundingBox : Array): 
	var districtNodes : Array[Vector2i] = []
	var voronoiRepresentation : Array = idArray.duplicate(true)

	for x in range(boundingBox[0][0], boundingBox[1][0]+1, 1):
		for y in range(boundingBox[0][1], boundingBox[1][1]+1, 1): 
			if idArray[x][y] == id: districtNodes.append(Vector2i(x,y))

	var locations = select_random_items(districtNodes, floor(len(districtNodes) * 0.005))

	for x in range(boundingBox[0][0], boundingBox[1][0]+1, 1):
		for y in range(boundingBox[0][1], boundingBox[1][1]+1, 1): 
			if idArray[x][y] != id: continue
			color_voronoi_single(voronoiRepresentation, locations, Vector2i(x, y), 5.0)
	
	for x in range(boundingBox[0][0], boundingBox[1][0]+1, 1):
		for y in range(boundingBox[0][1], boundingBox[1][1]+1, 1): 
			if idArray[x][y] != id: continue

			var count : int = 0
			var border : bool = false
			for n in neighbors:
				var newX : int = x + n[0]
				var newY : int = y + n[1]

				if not bounds_check(newX, newY, len(voronoiRepresentation), len(voronoiRepresentation[0])): continue
				if idArray[newX][newY] == -4: count += 1
				var district_border : bool = idArray[newX][newY] > 2 and idArray[newX][newY] != id
				var voronoi_border : bool = voronoiRepresentation[newX][newY] != voronoiRepresentation[x][y] and x <= newX and y <= newY
				if district_border or voronoi_border: 
					idArray[x][y] = -4
					border = true 

			#if border and count <= 4: idArray[x][y] = -4


	
	MIN_UNIQUE_ID += len(locations)
