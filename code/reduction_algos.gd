extends "res://code/subdivide_districts_algo.gd"

func parse_smallest_districts(id_grid : Array, district_manager : DistrictManager, num_districts : int = 15, new_cell_id : int = 1) -> Array: 
	'''
		Purpose: 
			Parses the smallest districts such that only 'num_districts' districts remain
		
		Arguments: 
			id_grid: 
				The 2D grid to perform the algorithm one
			district_manager: 
				The object tracking district related data
			num_districts: 
				The number of districts to remain untouched
			new_cell_id: 
				The new ID for all parsed district cells
		
		Return: 
			Array: 'id_grid' manipulated by the algorithm
	'''

	# Create a array the groups sorted by their sizes 
	var keys : Array = district_manager.get_keys_sorted_by_attribute("size_", true)

	print(keys)
	
	# If there are already few enough groups return
	if len(keys) <= num_districts: return id_grid
	
	# Determine which groups to parse 
	var groups_to_parse : Array = keys.slice(0, len(keys) - num_districts)
	
	# Parse the groups
	for x in range(len(id_grid)): for y in range(len(id_grid[x])): 
		if id_grid[x][y] in groups_to_parse: 
			id_grid[x][y] = new_cell_id
	
	# Remove the districts from the district manager
	for key in groups_to_parse: 
		district_manager.erase_district(key)
	
	return id_grid
