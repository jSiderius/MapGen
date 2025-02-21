extends "res://code/helpers.gd"

class_name Graph 

var edges : Array[Array]
var vertices : Array[Vector2i]
#var pqLoad : Resource = preload("res://code/priority_queue.gd")
var graphLoad : Resource = preload("res://code/graph.gd")
var subGraph : Graph 
var randWeights : Array[Array] = []
var width : int 
var height : int 

func _init(e : Array[Array], v : Array[Vector2i], xLen : int = 0, yLen : int = 0) -> void: 
	edges = e 
	vertices = v
	width = xLen
	height = yLen

	if not check_graph(): 
		print("not a valid graph")

func check_graph(): 
	for edge in edges: 
		if not (edge[0] in vertices and edge[1] in vertices): return false
	return true

func add_edge(edge : Array): 
	edges.append(edge)

# Takes edges [[Vector2, Vector2] ... ] and vertices [Vector2 ... ] defining a graph G(V,E)
# Calculates a true MST of the graph via kruskals algorithm and returns 
func kruskals_mst() -> Array[Array]: 
	var sets : Dictionary = {} 
	for v in vertices: 
		sets[v] = [v, 0]

	var mst_edges : Array[Array] = []
	for e in edges: 
		var p1_head : Vector2i = find_set_head(sets, e[0])
		var p2_head : Vector2i = find_set_head(sets, e[1])
		if p1_head == p2_head:                                                                                                  
			continue
		if sets[p1_head][1] > sets[p2_head][1]: 
			sets[p2_head][0] = p1_head
			sets[p1_head][1] += 1
		else: 
			sets[p1_head][0] = p2_head
			sets[p2_head][1] += 1
		
		mst_edges.append(e)
	return mst_edges

func get_mst(_sorted : bool = false) -> Array[Array]: 
	edges.sort_custom(_sort_by_length)
	return kruskals_mst()

# Takes edges [[Vector2, Vector2] ... ] and vertices [Vector2 ... ] defining a graph G(V,E)
# Gets an MST of the graph then selects aditional edges for the tree 
func add_modified_mst(idArray : Array, ratio = 1.8, mod : bool = true) -> Array[Array]: 
	var a_star_lengths : Dictionary = {} 
	var mst : Array[Array] = get_mst()

	subGraph = graphLoad.new(mst, vertices)
	for edge in mst: 
		var route : Array[Vector2i] = a_star(idArray, edge[0], edge[1])
		idArray = positions_to_roads(idArray, route)
		a_star_lengths[edge] = len(route)
		a_star_lengths[[edge[1], edge[0]]] = len(route)
	
	if not mod: return idArray #TODO: this is temp

	var distPrev : Array[Dictionary] = subGraph.dijkstras_all_to_all(a_star_lengths)
	var dist : Dictionary = distPrev[0]
	var prev : Dictionary = distPrev[1]

	for e in edges: 
		var edge : Array[Vector2i]
		edge.assign(e)
		# var euclidian : float = edge[0].distance_to(edge[1])
		var manhattan : float = abs(edge[0][0] - edge[1][0]) + abs(edge[0][1] - edge[1][1])
		if dist[edge] <= ratio * manhattan: continue

		var route : Array[Vector2i] = a_star(idArray, edge[0], edge[1])
		if dist[edge] <= ratio * float(len(route)): continue 
		idArray = positions_to_roads(idArray, route) 
		a_star_lengths[edge] = len(route)
		a_star_lengths[[edge[1], edge[0]]] = len(route)

		subGraph.add_edge(edge)

		var distPrevE1 : Array[Dictionary] = subGraph.dijkstras_one_to_all(edge[0], a_star_lengths)
		var distPrevE2 : Array[Dictionary] = subGraph.dijkstras_one_to_all(edge[1], a_star_lengths)

		for v in vertices: 
			dist[[edge[0], v]] = distPrevE1[0][v]
			prev[[edge[0], v]] = distPrevE1[1][v]

			dist[[edge[1], v]] = distPrevE2[0][v]
			prev[[edge[1], v]] = distPrevE2[1][v]
		
	return idArray

func add_modified_mst2(idArray : Array) -> Array: 
	
	# var mst : Array[Array] = get_mst()
	var empty : Array[Array] = []
	edges.sort_custom(_sort_by_length)
	# edges = edges.slice(0, floor(len(edges) / 5.0))
	subGraph = graphLoad.new(empty, vertices)
	
	var i : int = 0 
	for _e in edges:
		i += 1 
		print(i, " / ", len(edges)) 
		var e : Array[Vector2i]
		e.assign(_e) # Godot needs nested static typing I'm going to lose my mind
		if e in subGraph.edges or subGraph.intersects(e): continue
		subGraph.add_edge(e)
	
	for edge in subGraph.edges: 
		var route : Array[Vector2i] = a_star(idArray, edge[0], edge[1])
		idArray = positions_to_roads(idArray, route)
	
	# return subGraph.edges
	return []
	# TODO: Set self to subgraph? 

const EPSILON = 1e-7
#Precompute edges equations and add to dict to minimize comp
# https://www.cuemath.com/geometry/intersection-of-two-lines/
func intersects(checkEdge : Array[Vector2i]) -> bool: 
	var line1 : Array = standardEquationOfLine(checkEdge[0], checkEdge[1])
	var a1 = line1[0]
	var b1 = line1[1]
	var c1 = line1[2]
	
	for _e in edges: 
		var e : Array[Vector2i]
		e.assign(_e)
		if checkEdge[0] in e or checkEdge[1] in e: continue

		var line2 : Array = standardEquationOfLine(e[0], e[1])
		var a2 = line2[0]
		var b2 = line2[1]
		var c2 = line2[2]
		if abs(a1*b2 - a2*b1) < EPSILON: 
		# if a1*b2 == a2*b1: e
			if abs((c1 / c2) - (a1 / a2)) < EPSILON: return true
		var intersection : Vector2 = Vector2((c1*a2 - c2*a1) / (a1*b2 - a2*b1), (b1*c2 - b2*c1) / (a1*b2-a2*b1))
		if pointInBoundingBox(checkEdge[0], checkEdge[1], intersection) and pointInBoundingBox(e[0], e[1], intersection): 
			return true
	return false

func pointInBoundingBox(b1 : Vector2, b2 : Vector2, p : Vector2) -> bool: 
	var minBounding = Vector2(min(b1.x, b2.x), min(b1.y, b2.y))
	var maxBounding = Vector2(max(b1.x, b2.x), max(b1.y, b2.y))
	
	return p.x >= minBounding.x and p.x <= maxBounding.x and p.y >= minBounding.y and p.y <= maxBounding.y

# Returns [a, b, c] as in ay + bx + c = 0
func standardEquationOfLine(p1 : Vector2i, p2 : Vector2i) -> Array[float]: 
	if p1[0] == p2[0]: return [0, -1, p1[0]]
	var m : float = float(p1[1] - p2[1]) / float(p1[0] - p2[0]) 
	var b : float = p1[1] - m*p1[0]
	return [1, -m, -b]

func is_sparse() -> bool: 
	return len(edges) * log(len(edges)) < len(edges) + len(vertices) * log(len(vertices))

# Recursively find the head of a set
func find_set_head(sets, v) -> Vector2i: 
	if sets[v][0] == v: return v
	var setHead : Vector2i = find_set_head(sets, sets[v][0])
	sets[v][0] = setHead
	return setHead

# Custom sorting function for edge array [[Vector2, Vector2] ... ]
# Sorts [Vector2, Vector2] vs [Vector2, Vector2] based on which distance between vectors is largest 
func _sort_by_length(a,b): 
	# var len_a : float = pow(pow(float(a[0][0]) - float(a[1][0]), 2.0) + pow(float(a[0][1]) - float(a[1][1]), 2.0), 0.5)
	# var len_b : float = pow(pow(float(b[0][0]) - float(b[1][0]), 2.0) + pow(float(b[0][1]) - float(b[1][1]), 2.0), 0.5)
	var len_a : float = abs(a[0][0] - a[1][0]) + abs(a[0][1] - a[1][1])
	var len_b : float = abs(b[0][0] - b[1][0]) + abs(b[0][1] - b[1][1])
	return len_a < len_b

# Takes edges [[Vector2, Vector2] ... ] and vertices [Vector2 ... ] defining a graph G(V,E) 
# Runs dijkstras and returns a dict of the distances from all nodes to all nodes and a dictionary indicating the one step path of any node to any node 
func dijkstras_all_to_all(alt_weights : Variant = null) -> Array[Dictionary]: 
	var dist : Dictionary = {}
	var prev : Dictionary = {} 

	for v1 in vertices: 
		var distPrevV1 : Array[Dictionary] = dijkstras_one_to_all(v1, alt_weights)

		for v2 in vertices: 
			dist[[v1, v2]] = distPrevV1[0][v2]
			prev[[v1, v2]] = distPrevV1[1][v2]
	
	return [dist, prev]

# Takes edges [[Vector2, Vector2] ... ] and vertices [Vector2 ... ] defining a graph G(V,E) and a starting vertex (Vector2 \in vertices) 
# Runs dijkstras and returns a dict of the distances from all nodes to start and a dictionary indicating the path backwards from a node
func dijkstras_one_to_all(start : Vector2i, alt_weights : Variant = null) -> Array[Dictionary]: 
	var dist : Dictionary = {} 
	var prev : Dictionary = {} 

	for v in vertices: 
		dist[v] = 0 if v == start else 999999999
		prev[v] = null 
		
	var q : PriorityQueue = pqLoad.new()
	q.insert(start, 0)

	while not q.is_empty(): 
		var v : Vector2i = q.pop_min()

		for u in find_outgoing_graph_neighbors(v): 
			var edge_weight : float = v.distance_to(u) if alt_weights == null else alt_weights[[v, u]] #Todo: cover u -> v case 
			var alt : float = dist[v] + edge_weight 
			
			if alt < dist[u]: 
				dist[u] = alt 
				prev[u] = v 
				q.insert_or_update(u, alt)

	return [dist, prev]

# Assumes unidirectional
func find_outgoing_graph_neighbors(start : Vector2i) -> Array[Vector2i]: 
	var outgoing : Array[Vector2i] = []
	for e in edges:
		if e[0] == start and e[1] not in outgoing: outgoing.append(e[1]) 
		if e[1] == start and e[0] not in outgoing: outgoing.append(e[0])

	return outgoing

# Takes an ID array, start and end vectors (Vector2) and an array of previously visited nodes
# Custom implemenation of the A* algorithm using random weight additions, sets visited values to road (-1)
func a_star(idArray : Array, start : Vector2i, end : Vector2i) -> Array[Vector2i]: 
	
	if randWeights == []: 
		init_rand_weights(idArray)
	
	var prev : Dictionary = {}
	var dist : Dictionary = {}
	var pq : PriorityQueue = pqLoad.new()
	pq.insert(start, 0)
	prev[start] = null 
	dist[start] = 0
	while not pq.is_empty() and end not in prev: 
		var curr : Vector2i = pq.pop_min()

		for n in four_neighbors:
	# 		# Get and screen neighbor  
			n = Vector2i(n.x+curr[0], n.y+curr[1])
			if not bounds_check(int(n.x), int(n.y), len(idArray), len(idArray[0])): continue
			if n == end:
				prev[end] = curr
				dist[end] = dist[curr] + 1
				break

			var g_n : float = 1 + randWeights[n.x][n.y]
			var h_n = abs(n.x - end.x) + abs(n.y - end.y) 
			var f_n = g_n + h_n

			if n in dist and dist[n] <= dist[curr]+g_n: continue  

			pq.insert_or_reduce(n, f_n)
			prev[n] = curr 
			dist[n] = dist[curr] + randWeights[n.x][n.y] + 1

	var _path : Array[Vector2i] = []
	if end not in prev: return path
	var reconstruct : Vector2i = prev[end]
	while reconstruct != start:
		_path.append(reconstruct)
		reconstruct = prev[reconstruct]

	return _path

func init_rand_weights(idArray : Array):
	# Initialize random weighing for each node for more natural appearance 
	for x in range(len(idArray)): 
		randWeights.append([])
		for y in range(len(idArray[x])): 
			# Random weighting 
			randWeights[x].append(randf_range(0, 3))
			# randWeights[x].append(0)

			# Large weighting for city border 
			# if idArray[x][y] == -3: 
				# randWeights[x][y] += 10000

func positions_to_roads(idArray : Array, route : Array[Vector2i]) -> Array: 
	for node in route: 
		idArray[node[0]][node[1]] = -1 
	return idArray
