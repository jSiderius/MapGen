extends "res://code/helpers.gd"

class_name Graph 

# TODO: Finish documentation and assessment if it becomes relevant
var edges : Array[Edge]
var vertices : Array[Vector2i]
#var pqLoad : Resource = preload("res://code/priority_queue.gd")
var graph_loader : Resource = preload("res://code/Graph/graph.gd")
var subGraph : Graph 
var randWeights : Array[Array] = []

func _init(e : Array[Edge] = [], v : Array[Vector2i] = []) -> void: 
	edges = e
	vertices = v

	if not validate_graph(): 
		print_debug("not a valid graph")
		push_error("not a valid graph")

func validate_graph():
	''' Validates that every vertex in every edge is contained in 'vertices' '''

	for edge in edges:
		if not (edge.first in vertices and edge.second in vertices): return false
	return true

func add_edge(edge : Edge): 
	''' Adds an edge to the graph '''
	''' TODO: Perpetual nature of the data structure, how do updates impact? '''

	edges.append(edge)

func kruskals_mst() -> Array[Edge]: 
	''' The function uses Kruskals algorithm to determine and return the MST of the current vertices and edges in the graph'''

	# Initialize each vertex as a set with 0 children
	var sets : Dictionary = {}
	for v in vertices: 
		sets[v] = [v, 0]

	# Initialize the array representing vertices in the MST
	var mst_edges : Array[Edge] = []

	# Iterate every edge
	for e in edges: 

		# Find the current set head for each vertex in the edge
		var v1_head : Vector2i = find_set_head(sets, e.first)
		var v2_head : Vector2i = find_set_head(sets, e.second)

		# If the set heads are the same the vertices have a path to each other
		if v1_head == v2_head:                                                                                                  
			continue

		# Use the number of children the vertices have to determine which vertex is a child of the other
		# Update the sets accordingly
		if sets[v1_head][1] > sets[v2_head][1]: 
			sets[v2_head][0] = v1_head
			sets[v1_head][1] += 1
		else: 
			sets[v1_head][0] = v2_head
			sets[v2_head][1] += 1
		
		# Induct the edge to the mst
		mst_edges.append(e)

	return mst_edges
 
func find_set_head(sets, v) -> Vector2i:
	''' Helper function for kruskals MST: Recursively finds the head of a set'''
	''' TODO: Can we accurately reduce v[1] for the set head without addition runtime? Does this have any impact if not? '''
	
	# If a sets parent is itself, it is the head of the set and is returned
	if sets[v][0] == v: return v

	# Otherwise recursively find the set head by passing this nodes parent
	var set_head : Vector2i = find_set_head(sets, sets[v][0])

	# Update this nodes parent to the set head to reduce future runtimes
	sets[v][0] = set_head

	# Return the head
	return set_head

func get_mst(_sorted : bool = false) -> Array[Edge]: 
	''' Getter function for the MST '''
	''' TODO: Perpetuality & other MST algos '''

	if not _sorted:
		edges = _sort_by_attribute(edges, "length", true)

	return kruskals_mst()

# Takes edges [[Vector2, Vector2] ... ] and vertices [Vector2 ... ] defining a graph G(V,E)
# Gets an MST of the graph then selects aditional edges for the tree 
# func add_modified_mst(id_grid : Array, ratio = 1.8, mod : bool = true) -> Array[Array]: 
# 	var a_star_lengths : Dictionary = {} 
# 	var mst : Array[Edge] = get_mst()

# 	subGraph = graph_loader.new(mst, vertices)
# 	for edge in mst: 
# 		var route : Array[Vector2i] = a_star(id_grid, edge[0], edge[1])
# 		id_grid = positions_to_roads(id_grid, route)
# 		a_star_lengths[edge] = len(route)
# 		a_star_lengths[[edge[1], edge[0]]] = len(route)
	
# 	if not mod: return id_grid #TODO: this is temp

# 	var distPrev : Array[Dictionary] = subGraph.dijkstras_all_to_all(a_star_lengths)
# 	var dist : Dictionary = distPrev[0]
# 	var prev : Dictionary = distPrev[1]

# 	for e in edges: 
# 		var edge : Array[Vector2i]
# 		edge.assign(e)
# 		# var euclidian : float = edge[0].distance_to(edge[1])
# 		var manhattan : float = abs(edge[0][0] - edge[1][0]) + abs(edge[0][1] - edge[1][1])
# 		if dist[edge] <= ratio * manhattan: continue

# 		var route : Array[Vector2i] = a_star(id_grid, edge[0], edge[1])
# 		if dist[edge] <= ratio * float(len(route)): continue 
# 		id_grid = positions_to_roads(id_grid, route) 
# 		a_star_lengths[edge] = len(route)
# 		a_star_lengths[[edge[1], edge[0]]] = len(route)

# 		subGraph.add_edge(edge)

# 		var distPrevE1 : Array[Dictionary] = subGraph.dijkstras_one_to_all(edge[0], a_star_lengths)
# 		var distPrevE2 : Array[Dictionary] = subGraph.dijkstras_one_to_all(edge[1], a_star_lengths)

# 		for v in vertices: 
# 			dist[[edge[0], v]] = distPrevE1[0][v]
# 			prev[[edge[0], v]] = distPrevE1[1][v]

# 			dist[[edge[1], v]] = distPrevE2[0][v]
# 			prev[[edge[1], v]] = distPrevE2[1][v]
		
# 	return id_grid

func maximal_non_intersecting_edge_set() -> Array[Edge]: 
	'''
		Purpose: 
			Creates and returns a maximal edge set of the graph such that no edge in the set overlaps
			NOTE: If the method is pursued further there is a technique that maximizes the angle between all edges to minimize slivers
		
		Arguments: none, uses data in the Graph class

		Return: 
			Array[Edge]: the maximal non-intersecting edge set
	'''
	
	# Create an empty helper graph
	var empty : Array[Edge] = [] 
	var sub_graph = graph_loader.new(empty, vertices)
	
	# Sort the edges by length
	edges = _sort_by_attribute(edges, "length", true)

	# Add edges one by one while they don't violate the criteria
	for e in edges:	
		if e in sub_graph.edges or sub_graph.intersects(e): continue
		sub_graph.add_edge(e)
	
	return sub_graph.edges

func intersects(edge : Edge, epsilon : float = 1e-7) -> bool: 
	''' 
		Purpose: 
			Determine if the passed edge intersects any in the graph
			To understand how the math works: https://www.cuemath.com/geometry/intersection-of-two-lines/

		Arguments: 
			edge: 
				the edge to check against the graph
			epsilone: 
				tolerance for the intersection

		Return: 
			bool: indicates if the edge intersects the graph	
	'''

	
	for e in edges: 
		if e.contains_vertex(edge.first) or e.contains_vertex(edge.second): continue

		if abs(edge.line.x * e.line.y - e.line.x * edge.line.y) < epsilon: 
			if abs((edge.line.z / e.line.z) - (edge.line.x / e.line.x)) < epsilon: 
				return true

		var intersection_point : Vector2 = Vector2((edge.line.z*e.line.x - e.line.z*edge.line.x) / (edge.line.x*e.line.y - e.line.x*edge.line.y), (edge.line.y*e.line.z - e.line.y*edge.line.z) / (edge.line.x*e.line.y-e.line.x*edge.line.y))
		if point_in_bounding_box(edge.first, edge.second, intersection_point) and point_in_bounding_box(e.first, e.second, intersection_point): 
			return true
	return false

func point_in_bounding_box(b1 : Vector2, b2 : Vector2, p : Vector2) -> bool: 
	''' The function returns a boolean indicating if point 'p' is inside the bounding box created by points 'b1' & 'b2' '''

	var min_bounding = Vector2(min(b1.x, b2.x), min(b1.y, b2.y))
	var max_bounding = Vector2(max(b1.x, b2.x), max(b1.y, b2.y))
	
	return p.x >= min_bounding.x and p.x <= max_bounding.x and p.y >= min_bounding.y and p.y <= max_bounding.y

func add_edge_set_to_grid(id_grid : Array, edge_set : Array[Edge]) -> Array: 
	'''
		Purpose: 
			Add a set (Array) of Edges to an ID grid using the A* algorithm
		
		Arguments: 
			id_grid: 
				The 2D ID grid for the algorithm
			edge_set: 
				The set of edges, for each a path will be added between the 2 points in 'id_grid'

		Return: 
			Array: 'id_grid' manipulated by the algorithm

	'''

	for edge in edge_set: 
		var route : Array[Vector2i] = a_star(id_grid, edge.first, edge.second)
		id_grid = positions_to_roads(id_grid, route)
	
	return id_grid

func is_sparse() -> bool: 
	''' Returns a boolean determining if the graph is sparse by the formula E * log(E) < E + V * log(V) '''
	return len(edges) * log(len(edges)) < len(edges) + len(vertices) * log(len(vertices))

# # Takes edges [[Vector2, Vector2] ... ] and vertices [Vector2 ... ] defining a graph G(V,E) 
# # Runs dijkstras and returns a dict of the distances from all nodes to all nodes and a dictionary indicating the one step path of any node to any node 
# func dijkstras_all_to_all(alt_weights : Variant = null) -> Array[Dictionary]: 
# 	var dist : Dictionary = {}
# 	var prev : Dictionary = {} 

# 	for v1 in vertices: 
# 		var distPrevV1 : Array[Dictionary] = dijkstras_one_to_all(v1, alt_weights)

# 		for v2 in vertices: 
# 			dist[[v1, v2]] = distPrevV1[0][v2]
# 			prev[[v1, v2]] = distPrevV1[1][v2]
	
# 	return [dist, prev]

# # Takes edges [[Vector2, Vector2] ... ] and vertices [Vector2 ... ] defining a graph G(V,E) and a starting vertex (Vector2 \in vertices) 
# # Runs dijkstras and returns a dict of the distances from all nodes to start and a dictionary indicating the path backwards from a node
# func dijkstras_one_to_all(start : Vector2i, alt_weights : Variant = null) -> Array[Dictionary]: 
# 	var dist : Dictionary = {} 
# 	var prev : Dictionary = {} 

# 	for v in vertices: 
# 		dist[v] = 0 if v == start else 999999999
# 		prev[v] = null 
		
# 	var q : PriorityQueue = pqLoad.new()
# 	q.insert(start, 0)

# 	while not q.is_empty(): 
# 		var v : Vector2i = q.pop_min()

# 		for u in find_outgoing_graph_neighbors(v): 
# 			var edge_weight : float = v.distance_to(u) if alt_weights == null else alt_weights[[v, u]] #Todo: cover u -> v case 
# 			var alt : float = dist[v] + edge_weight 
			
# 			if alt < dist[u]: 
# 				dist[u] = alt 
# 				prev[u] = v 
# 				q.insert_or_update(u, alt)

# 	return [dist, prev]

# # Assumes unidirectional
# func find_outgoing_graph_neighbors(start : Vector2i) -> Array[Vector2i]: 
# 	var outgoing : Array[Vector2i] = []
# 	for e in edges:
# 		if e[0] == start and e[1] not in outgoing: outgoing.append(e[1]) 
# 		if e[1] == start and e[0] not in outgoing: outgoing.append(e[0])

# 	return outgoing

func a_star(id_grid : Array, start : Vector2i, end : Vector2i) -> Array[Vector2i]: 
	'''
		Purpose:
			Use the A* Algorithm to determine the path between 2 points in an ID grid

		Arguments: 
			id_grid: 
				the 2D grid for the algorithm
			start: 
				the start point (arbitrary)
			end: 
				the end point (arbitrary)

		Return: 
			Array[Vector2i]: An array of every point in the discovered path
	'''
	
	# TODO: Verify the best system for random weighting
	if randWeights == []: 
		init_rand_weights(id_grid, 5.0)

	
	# Initialize data structures
	var prev : Dictionary = {} # Dict for the previous node a node comes from
	var dist : Dictionary = {} # Dict for distance of a node from the start
	var pq : PriorityQueue = pqLoad.new() # priority queue 

	# Set up the initial node in the priority queue
	pq.insert(start, 0)
	prev[start] = null 
	dist[start] = 0

	# Iterate while we have not found the end (TODO: error handling for the pq.is_empty case)
	while not pq.is_empty() and end not in prev:
		
		# Get the min node
		var curr : Vector2i = pq.pop_min()

		# Iterate the nodes horizontal neighbors
		for n in neighbors:
			
			# Get the global position of the neighbor
			n = n + curr

			# Bounds check the neighbor position
			if not bounds_check(n, Vector2i(len(id_grid), len(id_grid[0]))): continue

			# Check if the neighbor is the goal and handle accordingly
			if n == end:
				prev[end] = curr
				dist[end] = dist[curr] + 1
				break

			# Calculate the heuristic cost of the neighbor (see https://brilliant.org/wiki/a-star-search/)
			var g_n : float = 1 + randWeights[n.x][n.y]
			var h_n = abs(n.x - end.x) + abs(n.y - end.y) 
			var f_n = g_n + h_n

			# Skip if the neighbor has been observed a cost less than the distance to the current node plus the travel cost to the neighbor
			if n in dist and dist[n] <= dist[curr]+g_n: continue  

			# Track the neighbor in the data structures
			pq.insert_or_reduce(n, f_n)
			prev[n] = curr 
			dist[n] = dist[curr] + g_n

	var _path : Array[Vector2i] = []
	if end not in prev: return _path

	# Reconstruct the path from the 'prev' dictionary
	var reconstruct : Vector2i = prev[end]
	while reconstruct != start:
		_path.append(reconstruct)
		reconstruct = prev[reconstruct]

	return _path

func init_rand_weights(id_grid : Array, max_weight : float = 3.0):
	# Initialize random weighing for each node for more natural appearance 
	for x in range(len(id_grid)):
		randWeights.append([])
		for y in range(len(id_grid[x])):

			# Random weighting 
			randWeights[x].append(randf_range(0, max_weight))

			# Large weighting for city border 
			if id_grid[x][y] == Enums.Cell.DISTRICT_WALL or id_grid[x][y] == Enums.Cell.WATER: 
				randWeights[x][y] += 10000

func positions_to_roads(id_grid : Array, route : Array[Vector2i]) -> Array: 
	for node in route: 
		id_grid[node[0]][node[1]] = 2
	return id_grid
