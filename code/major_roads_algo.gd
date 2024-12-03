extends "res://code/grid_gen_functions.gd"

var graph : Resource = preload("res://code/graph.gd")

# Takes an ID array
# Determines the set of major roads between district centers, sets them in the array, returns 
func add_roads(idArray : Array, vertices : Array[Vector2i], colorVert : bool = false) -> Array: 
	
	print("Looking for MST on ", len(vertices), " vertices")
	var roads : Array[Array] = []
	for i in range(len(vertices)): for j in range(i+1, len(vertices)): 
		roads.append([vertices[i], vertices[j]])
	
	var g : Graph = graph.new(roads, vertices, len(idArray), len(idArray[0]))
	idArray = g.add_modified_mst(idArray)
	print("Out of func")

	# if colorVert: 
	for v in vertices: idArray[v[0]][v[1]] = -2 if colorVert else -1

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
