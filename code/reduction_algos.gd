extends "res://code/major_roads_algo.gd"

# Takes an ID array and the number of districts that should be in the algorithm (int)
# Parses down to the number of districts and returns the array
func parse_smallest_groups(idArray : Array, num_districts : int = 15) -> Array: 
	
	# Get a dictionary representing all groups
	var groups_dict : Dictionary = get_groups_dict(idArray)
	
	# Create a array the groups sorted by their sizes 
	var groups_array : Array = []
	for key in groups_dict.keys():
		groups_array.append([key, groups_dict[key]])
	if len(groups_array) <= num_districts: return idArray
	groups_array.sort_custom(_sort_by_second_element)
	
	# Determine which groups to parse 
	var groups_to_parse : Array = []
	for i in range(len(groups_array) - num_districts - 1): 
		groups_to_parse.append(groups_array[i][0])
	
	# Parse the groups
	for x in range(len(idArray)): for y in range(len(idArray[x])): 
		if idArray[x][y] in groups_to_parse: 
			idArray[x][y] = 1
	
	return idArray

# Takes an ID array 
# Compiles and returns a dictionary representing all groups in the array
func get_groups_dict(idArray : Array) -> Dictionary: 
	var groups_dict = {} 
	for row in idArray: for val in row:
		if val <= 2: continue 
		if val not in groups_dict: 
			groups_dict[val] = 1
			continue
		groups_dict[val]+=1
	return groups_dict

# Custom sorting function on the second element of an array 
func _sort_by_second_element(a, b):
	return a[1] < b[1]


# DEPRECIATED: No need to first reduce small groups then later in the algorithm cut to a certain number of groups
# Takes an ID array, the minimum size of a group (int) and the ideal maximum number of groups (int)
# Decides which groups to parse and replaces their values with '1' (void)
func parse_groups_by_size(idArray : Array, min_group : int = 20, max_districts  : int = 15) -> Array: 
	
	# Get a dictionary representing all groups
	var groups_dict : Dictionary = get_groups_dict(idArray)

	# Determine which groups to parse out 
	var num_districts = len(groups_dict.keys())
	var groups_to_parse : Array = []
	for key in groups_dict.keys(): 
		if num_districts <= max_districts: break
		if groups_dict[key] < min_group:
			groups_to_parse.append(key)
			num_districts -= 1
	
	# Parse the groups 
	for x in range(len(idArray)): for y in range(len(idArray[x])): 
		if idArray[x][y] in groups_to_parse: 
			idArray[x][y] = 1
	
	return idArray
