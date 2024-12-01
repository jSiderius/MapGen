extends "res://code/subdivide_districts_algo.gd"

var pq : Resource = preload("res://code/priority_queue.gd")

# Takes an ID array
# Determines the set of major roads between district centers, sets them in the array, returns 
func add_major_roads(idArray : Array) -> Array: 

	var dcs : Array[Vector2]
	dcs.assign(find_district_centers(idArray).keys())
	var roads : Array[Array] = []
	for i in range(len(dcs)): for j in range(i+1, len(dcs)): 
		roads.append([dcs[i], dcs[j]])
	
	idArray = add_modified_mst(idArray, roads, dcs)

	for dc in dcs: 
		idArray[dc[0]][dc[1]] = -2

	return idArray
	
func positions_to_roads(idArray : Array, route : Array[Vector2]) -> Array: 
	for node in route: 
		idArray[node[0]][node[1]] = -1 
	return idArray


# Takes an ID array
# Calculates the center of mass for each district and returns the coords as the key's of a dictionary leading to the district ID 
func find_district_centers(idArray : Array) -> Dictionary: 
	# Dictionary from group ID (int, key) to [sum all x coords (int), sum all y coords (int), count of nodes in group (int), backup value (Vector2)] (Array, value)
	var groups_dict : Dictionary = {}
	for x in range(len(idArray)): for y in range(len(idArray[x])): 

		# Get and screen value
		var val : int = idArray[x][y]
		if val <= 2: continue 
		if val not in groups_dict: 
			groups_dict[val] = [x, y, 1, Vector2(x,y)]
			continue
		
		# Update the dict
		groups_dict[val][0] += x
		groups_dict[val][1] += y
		groups_dict[val][2] += 1
	
	# Dictionary from district center (Vector2, key) to group ID (int, value)
	var centers : Dictionary = {}
	for key in groups_dict.keys(): 
		# Calculate center
		var center_x = floor(groups_dict[key][0] / groups_dict[key][2])
		var center_y = floor(groups_dict[key][1] / groups_dict[key][2])
		
		# If the center of mass is not in the group use a backup
		if idArray[center_x][center_y] != key: 
			# TODO: Improve backup selection
			centers[groups_dict[key][3]] = key
			continue
		
		# Set value in dict 
		centers[Vector2(center_x, center_y)] = key
	
	return centers

# Takes edges [[Vector2, Vector2] ... ] and vertices [Vector2 ... ] defining a graph G(V,E)
# Gets an MST of the graph then selects aditional edges for the tree 
func add_modified_mst(idArray : Array, edges : Array[Array], vertices : Array[Vector2], ratio = 1.5) -> Array: 
	
	edges.sort_custom(_sort_by_length)

	var a_star_lengths : Dictionary = {} 
	var mst : Array[Array] = kruskals_mst(edges, vertices)
	for edge in mst: 
		var route : Array[Vector2] = a_star(idArray, edge[0], edge[1])
		idArray = positions_to_roads(idArray, route) 
		a_star_lengths[edge] = len(route)
		a_star_lengths[[edge[1], edge[0]]] = len(route)


	var distPrev : Array[Dictionary] = dijkstras_all_to_all(mst, vertices, a_star_lengths)
	var dist : Dictionary = distPrev[0]
	var prev : Dictionary = distPrev[1]

	for edge in edges: 
		# var euclidian : float = edge[0].distance_to(edge[1])
		var manhattan : float = abs(edge[0][0] - edge[1][0]) + abs(edge[0][1] - edge[1][1])
		if dist[edge] <= ratio * manhattan: continue

		var route : Array[Vector2] = a_star(idArray, edge[0], edge[1])
		if dist[edge] <= ratio * float(len(route)): continue 
		idArray = positions_to_roads(idArray, route) 
		a_star_lengths[edge] = len(route)
		a_star_lengths[[edge[1], edge[0]]] = len(route)

		mst.append(edge)

		var distPrevE1 : Array[Dictionary] = dijkstras_one_to_all(mst, vertices, edge[0], a_star_lengths)
		var distPrevE2 : Array[Dictionary] = dijkstras_one_to_all(mst, vertices, edge[1], a_star_lengths)

		for v in vertices: 
			dist[[edge[0], v]] = distPrevE1[0][v]
			prev[[edge[0], v]] = distPrevE1[1][v]

			dist[[edge[1], v]] = distPrevE2[0][v]
			prev[[edge[1], v]] = distPrevE2[1][v]
		
	return idArray

# Takes edges [[Vector2, Vector2] ... ] and vertices [Vector2 ... ] defining a graph G(V,E)
# Calculates a true MST of the graph via kruskals algorithm and returns 
func kruskals_mst(edges : Array[Array], vertices : Array[Vector2]) -> Array[Array]: 

	edges.sort_custom(_sort_by_length)
	var sets : Dictionary = {} 
	for v in vertices: 
		sets[v] = [v, 0]

	var mst_edges : Array[Array] = []
	for e in edges: 
		var p1_head : Vector2 = find_set_head(sets, e[0])
		var p2_head : Vector2 = find_set_head(sets, e[1])
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

# Takes edges [[Vector2, Vector2] ... ] and vertices [Vector2 ... ] defining a graph G(V,E) 
# Runs dijkstras and returns a dict of the distances from all nodes to all nodes and a dictionary indicating the one step path of any node to any node 
func dijkstras_all_to_all(edges : Array[Array], vertices : Array[Vector2], alt_weights : Variant = null) -> Array[Dictionary]: 
	var dist : Dictionary = {}
	var prev : Dictionary = {} 

	for v1 in vertices: 
		var distPrevV1 : Array[Dictionary] = dijkstras_one_to_all(edges, vertices, v1, alt_weights)

		for v2 in vertices: 
			dist[[v1, v2]] = distPrevV1[0][v2]
			prev[[v1, v2]] = distPrevV1[1][v2]
	
	return [dist, prev]

# Takes edges [[Vector2, Vector2] ... ] and vertices [Vector2 ... ] defining a graph G(V,E) and a starting vertex (Vector2 \in vertices) 
# Runs dijkstras and returns a dict of the distances from all nodes to start and a dictionary indicating the path backwards from a node
func dijkstras_one_to_all(edges : Array[Array], vertices : Array[Vector2], start : Vector2, alt_weights : Variant = null) -> Array[Dictionary]: 
	var dist : Dictionary = {} 
	var prev : Dictionary = {} 

	for v in vertices: 
		dist[v] = 0 if v == start else 999999999
		prev[v] = null 
		
	var q : PriorityQueue = pq.new()
	q.insert(start, 0)

	while not q.is_empty(): 
		var v : Vector2 = q.pop_min()

		for u in find_outgoing_graph_neighbors(edges, v): 
			var edge_weight : float = v.distance_to(u) if alt_weights == null else alt_weights[[v, u]] #Todo: cover u -> v case 
			var alt : float = dist[v] + edge_weight 
			
			if alt < dist[u]: 
				dist[u] = alt 
				prev[u] = v 
				q.insert_or_update(u, alt)

	return [dist, prev]

# Assumes unidirectional
func find_outgoing_graph_neighbors(edges : Array, start : Vector2) -> Array: 
	neighbors = []
	for e in edges:
		if e[0] == start and e[1] not in neighbors: neighbors.append(e[1]) 
		if e[1] == start and e[0] not in neighbors: neighbors.append(e[0])

	return neighbors

# Recursively find the head of a set
func find_set_head(sets, v): 
	if sets[v][0] == v: return v
	return find_set_head(sets, sets[v][0]) #Can do the log* thing but not a primary concern
	
# Custom sorting function for edge array [[Vector2, Vector2] ... ]
# Sorts [Vector2, Vector2] vs [Vector2, Vector2] based on which distance between vectors is largest 
func _sort_by_length(a,b): 
	var len_a : float = pow(pow(float(a[0][0]) - float(a[1][0]), 2.0) + pow(float(a[0][1]) - float(a[1][1]), 2.0), 0.5)
	var len_b : float = pow(pow(float(b[0][0]) - float(b[1][0]), 2.0) + pow(float(b[0][1]) - float(b[1][1]), 2.0), 0.5)
	return len_a < len_b
	
# TODO: See if infinite recursion is modifiable
# TODO: Search pathing not deterministic
# Takes an ID array, start and end vectors (Vector2) and an array of previously visited nodes
# Custom implemenation of the A* algorithm using random weight additions, sets visited values to road (-1)
func a_star(idArray : Array, start : Vector2, end : Vector2, prev : Array[Vector2] = []) -> Array[Vector2]: 

	# Initialize random weighing for each node for more natural appearance 
	var rand_weights = []
	for x in range(len(idArray)): 
		rand_weights.append([])
		for y in range(len(idArray[x])): 
			# Random weighting 
			rand_weights[x].append(randf_range(0, 3))
			# rand_weights[x].append(0)

			# Large weighting for city border 
			if idArray[x][y] == -3: 
				rand_weights[x][y] += 150

	
	#idArray[start[0]][start[1]] = -1
	var min_n : Vector2 = Vector2(0,0)
	var min_value = INF
	for i in range(len(four_neighbors)):
		# Get and screen neighbor  
		var n : Vector2 = Vector2(start[0]+four_neighbors[i][0], start[1]+four_neighbors[i][1])
		if n in prev or not bounds_check(int(n[0]), int(n[1]), len(idArray), len(idArray[0])): continue
		if n == end: return prev

		# Calculate the hueristic value of the neighbor
		var hueristic_value = rand_weights[n[0]][n[1]] + pow(pow(float(n[0]) - float(end[0]), 2.0) + pow(float(n[1]) - float(end[1]), 2.0), 0.5) #all cost's are g(n)=1
		
		# Update min_value accordingly
		if hueristic_value < min_value: 
			min_value = hueristic_value
			min_n = n
	
	prev.append(min_n)
	#TODO: How can this work with needing path distances? 
	# if idArray[min_n[0]][min_n[1]] == -1: return idArray 
	return a_star(idArray, min_n, end, prev)
