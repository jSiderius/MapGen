# TODO: ASSESS EVERYTHING IN THIS FILE
# FLOOD FILL ALGOS
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

# MAJOR ROAD ALGOS
var graph : Resource = preload("res://code/Graph/graph.gd")
var edge : Resource = preload("res://code/Graph/edge.gd")

# Takes an ID array
# Determines the set of major roads between district centers, sets them in the array, returns 
func add_roads(id_grid : Array, vertices : Array[Vector2i], colorVert : bool = false) -> Array: 
	# TODO: Document
	# TODO: Reassess if it becomes relevant
	
	# Create the set of roads as a fully connected set of all vertices
	var roads : Array[Edge] = []
	for i in range(len(vertices)): for j in range(i+1, len(vertices)):
		roads.append(edge.new(vertices[i], vertices[j]))
	
	var g : Graph = graph.new(roads, vertices)
	# var mst = g.get_mst()
	var mst = g.maximal_non_intersecting_edge_set()
	g.add_edge_set_to_grid(id_grid, mst)
	''' TODO: Assess modified algorithms next '''
	# id_grid = g.add_modified_mst(id_grid, 8.0, mod)
	# g.add_modified_mst2(id_grid)

	for v in vertices: 
		id_grid[v[0]][v[1]] = Enums.Cell.DISTRICT_CENTER if colorVert else Enums.Cell.MAJOR_ROAD # TODO: ???
	
	return mst

# TODO: what is this function?
# func get_outgoing_path_locations(id_grid : Array, district_manager : DistrictManager): 
# 	var districtBorderNodes : Array[Vector2i] = []
# 	var edgeNodes : Array[Vector2i] = []
# 	for x in range(len(id_grid)): for y in range(len(id_grid[x])):
# 		if is_edge(x, y, len(id_grid), len(id_grid[x])): 
# 			edgeNodes.append(Vector2i(x, y))
# 			continue
# 		if not id_grid[x][y] == district_manager.center_district_id: continue

# 		for n in neighbors:
# 			var newX : int = x + n.x 
# 			var newY : int = y + n.y

# 			if not bounds_check(newX, newY, len(id_grid), len(id_grid[x])): continue
# 			if id_grid[newX][newY] != id_grid[x][y]: districtBorderNodes.append(Vector2i(newX, newY))

# 	var pairs : Array[Array] = []
# 	var selectedEdges : Array[Vector2i] = select_random_items(edgeNodes, 6)
# 	var minDis : float = 1000000
# 	var minNode : Vector2i = districtBorderNodes[0] 
# 	for node1 in selectedEdges: for node2 in districtBorderNodes: 
# 		var currDis = node1.distance_squared_to(node2)
# 		if currDis < minDis: 
# 			minDis = currDis
# 			minNode = node2
# 		pairs.append([node1, minNode])
	
# 	var g : Graph = graph.new(Array([], TYPE_ARRAY, "", null), Array([], TYPE_VECTOR2I, "", null))
# 	for pair in pairs: 
# 		g.positions_to_roads(id_grid, g.a_star(id_grid, pair[0], pair[1]))
	
# SUBDIVIDE DISTRICTS 
# INCOMPLETE: Will have to somehow subdivide the districts such that one node is now 4
# TODO: Assess, Verify, Document
func subdivide_district(idArrayArg : Array, bb : Array, _key : int) -> Array: 
	var sub_array : Array = get_array_between(bb[0], bb[1], idArrayArg)
	return sub_array

# Takes 2 vectors (Vector2) and an ID array 
# Returns a 2D array of all values between the vectors in the ID array
# TODO: Assess, Verify, Document
func get_array_between(v1: Vector2, v2: Vector2, id_grid: Array) -> Array:
	# Ensure v1 has the smaller x and y values
	var start = Vector2(min(v1.x, v2.x), min(v1.y, v2.y))
	var end = Vector2(max(v1.x, v2.x), max(v1.y, v2.y))
	
	# Create a 2D array of all the values between start and end in array
	var result = []
	for x in range(start.x, end.x+1): 
		result.append([])
		for y in range(start.y, end.y+1):
			if not bounds_check(Vector2i(x, y), Vector2i(len(id_grid), len(id_grid[x]))): continue 
			result[x-start.x].append(id_grid[x][y])

	return result

# TODO: Probably depreciated in District
# TODO: Assess, Verify, Document
func add_district_border(id_grid : Array, id : int, bounding_box : Array): 
	for x in range(bounding_box[0][0], bounding_box[1][0]+1, 1):
		for y in range(bounding_box[0][1], bounding_box[1][1]+1, 1): 
			if not id_grid[x][y] == id: continue
			
			for n in neighbors: 
				var newX : int = x + n[0]
				var newY : int = y + n[1]
				
				if id_grid[newX][newY] > 2 and id_grid[newX][newY] not in [id]: 
					id_grid[newX][newY] = -4
	return id_grid

# TODO: Assess, Verify, Document
func add_district_center(id_grid : Array, id : int, bounding_box : Array, center : Vector2i, radius : float) -> Array:
	for x in range(bounding_box[0][0], bounding_box[1][0]+1, 1):
		for y in range(bounding_box[0][1], bounding_box[1][1]+1, 1): 
			if id_grid[x][y] not in [id, -1]: continue 

			var distance : float = sqrt(pow(x - center[0], 2) + pow(y - center[1], 2))
			if distance > radius: continue

			id_grid[x][y] = Enums.Cell.DISTRICT_CENTER

	return id_grid 

# TODO: Assess, Verify, Document
func get_locations_in_district(id_grid : Array, id : int, boundingBox : Array, edgeBarrier : float = 3.0):

	var districtNodes : Array[Vector2i] = []
	var borderNodes : Array[Vector2i] = []
	for x in range(boundingBox[0][0]-1, boundingBox[1][0]+2, 1):
		for y in range(boundingBox[0][1]-1, boundingBox[1][1]+2, 1): 
			if not bounds_check(Vector2i(x, y), Vector2i(len(id_grid), len(id_grid[0]))): continue
			if id_grid[x][y] in [Enums.Cell.DISTRICT_WALL, Enums.Cell.CITY_WALL]: borderNodes.append(Vector2i(x, y))

	for x in range(boundingBox[0][0], boundingBox[1][0]+1, 1):
		for y in range(boundingBox[0][1], boundingBox[1][1]+1, 1): 
			if not id_grid[x][y] == id: continue
			var valid = true
			for b in borderNodes: 
				if Vector2i(x, y).distance_to(b) > edgeBarrier: continue
				valid = false 
				break
				
			if valid: districtNodes.append(Vector2i(x,y))

	var locations = select_random_items(districtNodes, 100) #floor(len(districtNodes) * 0.005)) 
	return add_roads(id_grid, locations, true)


# TODO: Assess, Verify, Document, similar version of this function exists
func replace_ID(id_grid : Array, elimID : int, replacementID : int) -> void: 
	for x in range(len(id_grid)): for y in range(len(id_grid[x])): 
		if id_grid[x][y] != elimID: continue 
		id_grid[x][y] = replacementID
	

	
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

# MAIN
func draw_roads(): 
	for r in roads: 
		draw_line(square_size * Vector2(r.first[0], r.first[1]), square_size * Vector2(r.second[0], r.second[1]), Color.BLUE, 1.0)

# TODO: Backburner, try A* to help accomadate water
func add_road(_id_grid: Array, start: Vector2i, end: Vector2i) -> Array:

	var diff = end - start
	var steps = int(max(abs(diff.x), abs(diff.y)))
	
	var offset = 0
	
	for i in range(steps + 1):
		var t = float(i) / float(steps)
		var x = int(round(lerp(start.x, end.x, t)))
		var y = int(round(lerp(start.y, end.y, t)))
		
		if randf() < 0.2:
			offset += (randi() % 3) - 1  # -1, 0, or +1
		var offset_pos : Vector2i = Vector2i(x + offset, y)
		
		if not bounds_check(offset_pos, Vector2i(len(_id_grid), len(_id_grid[0]))): continue
		
		# TODO: Fix this
		if _id_grid[offset_pos.x][offset_pos.y] == 0:
			pass
			#flood_fill_solve_group(_id_grid, offset_pos, 1, 0)

		_id_grid[offset_pos.x][offset_pos.y] = Enums.Cell.MAJOR_ROAD

		# for j in range(4):
		# 	for k in range(4):
		# 		if not bounds_check(offset_pos + Vector2i(j-2, k-2), Vector2i(len(_id_grid), len(_id_grid[0]))): continue
		# 		_id_grid[offset_pos.x + j - 2][offset_pos.y + k - 2] = Enums.Cell.MAJOR_ROAD

	MIN_UNIQUE_ID += 1
	return _id_grid


func add_center_line(_id_grid : Array) -> Array:
	#for i in range(len(_id_grid[0])): 
		#_id_grid[floor(len(_id_grid) / 2.0)][i] = 1
	var offset : int = 0
	for i in range(len(_id_grid[0])): 
		if randf() < 0.1: offset += (randi() % 2)
		_id_grid[floor(len(_id_grid) / 2.0) + offset][i] = Enums.Cell.MAJOR_ROAD
		
	offset = 0
	for i in range(len(_id_grid)):
		if randf() < 0.1: offset += (randi() % 2)
		_id_grid[i][floor(len(_id_grid[0]) / 2.0) + offset] = Enums.Cell.MAJOR_ROAD
		
	return _id_grid