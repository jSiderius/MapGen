extends "res://code/subdivide_districts_algo.gd"

# Takes an ID array
# Determines the set of major roads between district centers, sets them in the array, returns 
func find_major_roads(idArray : Array) -> Array: 

	var dcs : Array = find_district_centers(idArray).keys()
	var roads : Array = []
	for i in range(len(dcs)): for j in range(i+1, len(dcs)): 
		roads.append([dcs[i], dcs[j]])
	
	roads = modified_mst(roads, dcs)

	return set_roads_in_id_array(idArray, roads)

# Takes an ID array and array of roads [Vector2,Vector2]
# Runs A* between the start and end points of each road, sets the values in the array and returns
func set_roads_in_id_array(idArray : Array, roads : Array) -> Array: 
	for road in roads:
		idArray = a_star(idArray, road[0], road[1])
		idArray[road[0][0]][road[0][1]] = -2
		idArray[road[1][0]][road[1][1]] = -2
	
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
# Calculates an MST of the graph then selects aditional edges for the tree 
func modified_mst(edges : Array, vertices : Array): 
	edges.sort_custom(_sort_by_length)
	var sets : Dictionary = {} 
	for v in vertices: 
		sets[v] = [v, 0]
	
	var mst_edges : Array = []
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

	# TODO: Add travelled distance / true distance ratio as a selection metric
	return mst_edges

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
	
# Takes an ID array, start and end vectors (Vector2) and an array of previously visited nodes
# Custom implemenation of the A* algorithm using random weight additions, sets visited values to road (-1)
func a_star(idArray : Array, start : Vector2, end : Vector2, prev : Array = []): 

	# Initialize random weighing for each node for more natural appearance 
	var rand_weights = []
	for x in range(len(idArray)): 
		rand_weights.append([])
		for y in range(len(idArray[x])): 
			# Random weighting 
			rand_weights[x].append(randf_range(0, 1))

			# Large weighting for city border 
			if idArray[x][y] == -3: 
				rand_weights[x][y] += 150

	
	idArray[start[0]][start[1]] = -1
	var min_n : Vector2 = Vector2(0,0)
	var min_value = INF
	for i in range(len(four_neighbors)):
		# Get and screen neighbor  
		var n : Vector2 = Vector2(start[0]+four_neighbors[i][0], start[1]+four_neighbors[i][1])
		if n in prev or not bounds_check(int(n[0]), int(n[1]), len(idArray), len(idArray[0])): continue
		if n == end: return idArray

		# Calculate the hueristic value of the neighbor
		var hueristic_value = rand_weights[n[0]][n[1]] + pow(pow(float(n[0]) - float(end[0]), 2.0) + pow(float(n[1]) - float(end[1]), 2.0), 0.5) #all cost's are g(n)=1
		
		# Update min_value accordingly
		if hueristic_value < min_value: 
			min_value = hueristic_value
			min_n = n
	
	prev.append(min_n)
	if idArray[min_n[0]][min_n[1]] == -1: return idArray #TODO: Break if found a road square working?? 
	return a_star(idArray, min_n, end, prev)
