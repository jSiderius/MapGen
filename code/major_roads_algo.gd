extends "res://code/grid_gen_functions.gd"

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
	
