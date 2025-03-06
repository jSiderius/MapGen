extends "res://code/helpers.gd"

class_name DistrictManager

var district : Resource = preload("res://code/Districts/district.gd")
var districts_dict : Dictionary = {}
var last_observed_id_grid = []
var size_location_data_recorded = false
var center_district_id : int = 0

func _init(id_grid : Array, data_flags : DistrictDataFlagStruct):
	
	update_district_data(id_grid, data_flags)

	# for row in id_grid: for id in row: 
		# if id <= 2 or id in districts_dict: continue # ID's below 3 are non-district values

		# districts_dict[id] = district.new(id)

func update_district_data(id_grid : Array, data_flags : DistrictDataFlagStruct) -> void:
	'''
		Purpose: 
			Update the data model, choose which data to update according to the DistrictDataFlagStruct class

		Arguments: 
			id_grid: 
				The 2D grid used to update the data
			data_flags: 
				A class containing flags to determine which data to update

		Return: void
	'''

	if last_observed_id_grid == id_grid: return

	if data_flags.update_size_location_data:
		update_or_init_size_location_data(id_grid)
	if data_flags.update_percentage_data: 
		update_or_init_percentage_data(id_grid)
	if data_flags.update_centrality_data: 
		update_or_init_centrality_data(id_grid)
	if data_flags.update_bounding_data: 
		update_or_init_bounding_data(id_grid)

	last_observed_id_grid = id_grid

func update_or_init_size_location_data(id_grid : Array) -> void: 
	'''
		Purpose: 
			Observe and store the size of each district in 'districts_dict' and the vector location 

		Arguments: 
			id_grid: 
				The 2D grid used to obtain the data
		
		Return: void
	'''

	# Iterate the grid
	for x in len(id_grid): for y in len(id_grid[x]):
		
		var id = id_grid[x][y]

		# ID's below 3 are non-district values 
		if id <= 2: continue 

		# Create a new district for the ID if one does not exist
		if id not in districts_dict:
			districts_dict[id] = district.new(id) 
		
		# Update the size counter for the district
		districts_dict[id].locations.append(Vector2i(x,y))
	
	# Update the total size of each district based on the length of the locations array
	for key in districts_dict.keys():
		districts_dict[key].size_ = len(districts_dict[key].locations) 
		
	size_location_data_recorded = true

func update_or_init_percentage_data(id_grid : Array) -> void: 
	'''
		Purpose:
			Observe and store the ratio of each district in 'districts_dict' to the total size

		Arguments: 
			id_grid: 
				The 2D grid used to obtain the data
		
		Return: void
	'''

	var totalSize : float = len(id_grid) * len(id_grid[0])

	# Ensure size data has been recorded
	if not size_location_data_recorded:
		update_or_init_size_location_data(id_grid)
	
	# Calculate and store the size of each district
	for key in districts_dict.keys():
		districts_dict[key].percentage = float(districts_dict[key].size_) / totalSize

func update_or_init_centrality_data(id_grid : Array) -> void: 
	'''
		Purpose:
			Observe and store information about the centrality of each district in 'districts_dict' 

		Arguments: 
			id_grid: 
				The 2D grid used to obtain the data
		
		Return: void
	'''

	# Ensure location data has been recorded
	if not size_location_data_recorded:
		update_or_init_size_location_data(id_grid)

	# Defer to the District class to calculate the data for each districts
	for key in districts_dict.keys(): 
		districts_dict[key].set_center(id_grid)
	
	var keys = get_keys_sorted_by_attribute("distance_to_grid_center", true)
	center_district_id = keys[0]
	
	# TODO
	# for key in keys: 
		# if not districts[key]["windowBorder"]["any"]: return key
	# 	return keys.pick_random()

func update_or_init_bounding_data(id_grid : Array) -> void: 

	# Ensure location data has been recorded
	if not size_location_data_recorded:
		update_or_init_size_location_data(id_grid)

	for key in districts_dict.keys(): 
		districts_dict[key].set_bounding_box()

func get_keys_sorted_by_attribute(attribute : String, ascending : bool) -> Array:
	'''
		Purpose: 
			Construct and return an array of district ID's sorted by a district class attribute
		
		Arguments: 
			attribute: 
				A string representing a class attribute of 'District' the array should be sorted by 
				TODO: Ensure good values
			ascending: 
				Determines if the array is sorted in ascending or descending order

		Return: 
			Array: The sorted array
	'''

	var districts_arr : Array = _sort_by_attribute(districts_dict.values(), attribute, ascending)
	var keys_arr : Array = []

	for district in districts_arr: 
		keys_arr.append(district.id)
	
	return keys_arr

func erase_district(id : int): 
	''' Erases the district with ID matching the argument from the data model if it exists '''
	
	if id in districts_dict: 
		districts_dict.erase(id)
