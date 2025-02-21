extends "res://code/subdivide_districts_algo.gd"

# Takes an ID array and the number of districts that should be in the algorithm (int)
# Parses down to the number of districts and returns the array
func parse_smallest_groups(idArray : Array, districts : Dictionary, num_districts : int = 15) -> Array: 
	
	
	# Create a array the groups sorted by their sizes 
	var keys : Array = sorted_district_keys(districts, "size")
	print(keys)
	if len(keys) <= num_districts: return idArray
	
	# Determine which groups to parse 
	var groups_to_parse : Array = keys.slice(0, len(keys) - num_districts)
	
	# Parse the groups
	for x in range(len(idArray)): for y in range(len(idArray[x])): 
		if idArray[x][y] in groups_to_parse: 
			idArray[x][y] = 1
	
	for key in groups_to_parse: 
		districts.erase(key)
	
	return idArray
