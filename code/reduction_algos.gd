extends "res://code/subdivide_districts_algo.gd"

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
