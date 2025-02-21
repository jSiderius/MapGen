extends "res://code/district_functions.gd"


var graph : Resource = preload("res://code/graph.gd")

# Takes an ID array
# Determines the set of major roads between district centers, sets them in the array, returns 
func add_roads(idArray : Array, vertices : Array[Vector2i], colorVert : bool = false) -> Array: 
	
	print("Looking for MST on ", len(vertices), " vertices")
	var roads : Array[Array] = []
	for i in range(len(vertices)): for j in range(i+1, len(vertices)): 
		roads.append([vertices[i], vertices[j]])
	
	var g : Graph = graph.new(roads, vertices, len(idArray), len(idArray[0]))
	# idArray = g.add_modified_mst(idArray, 8.0, mod)
	g.add_modified_mst2(idArray)

	# if colorVert: 
	for v in vertices: idArray[v[0]][v[1]] = -2 if colorVert else -1
	
	# roads = []
	return roads

# TODO: Use bounding box
func get_outgoing_path_locations(idArray : Array): 
	var districtBorderNodes : Array[Vector2i] = []
	var edgeNodes : Array[Vector2i] = []
	for x in range(len(idArray)): for y in range(len(idArray[x])): 
		if is_edge(x, y, len(idArray), len(idArray[x])): 
			edgeNodes.append(Vector2i(x, y))
			continue
		if not idArray[x][y] == 2000: continue

		for n in neighbors: 
			var newX : int = x + n.x 
			var newY : int = y + n.y

			if not bounds_check(newX, newY, len(idArray), len(idArray[x])): continue
			if idArray[newX][newY] != idArray[x][y]: districtBorderNodes.append(Vector2i(newX, newY))

	var pairs : Array[Array] = []
	var selectedEdges : Array[Vector2i] = select_random_items(edgeNodes, 6)
	var minDis : float = 1000000
	var minNode : Vector2i = districtBorderNodes[0] 
	for node1 in selectedEdges: for node2 in districtBorderNodes: 
		var currDis = node1.distance_squared_to(node2)
		if currDis < minDis: 
			minDis = currDis
			minNode = node2
		pairs.append([node1, minNode])

		

	
	var g : Graph = graph.new(Array([], TYPE_ARRAY, "", null), Array([], TYPE_VECTOR2I, "", null))
	for pair in pairs: 
		g.positions_to_roads(idArray, g.a_star(idArray, pair[0], pair[1]))
	
