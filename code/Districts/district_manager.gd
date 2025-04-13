extends "res://code/helpers.gd"

class_name DistrictManager

var district : Resource = preload("res://code/Districts/district.gd")
var districts_dict : Dictionary = {}
var size_location_data_recorded = false
var center_district_id : int = 0
var square_size : float

func _init(id_grid : Grid, _square_size : float, data_flags : DistrictDataFlagStruct):
	square_size = _square_size

	update_district_data(id_grid, data_flags)

func update_district_data(id_grid : Grid, data_flags : DistrictDataFlagStruct) -> void:
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

	# TODO: Appropriately handle initializing vs reseting
	districts_dict = {}

	if data_flags.update_size_location_data:
		update_or_init_size_location_data(id_grid)
	if data_flags.update_percentage_data: 
		update_or_init_percentage_data(id_grid)
	if data_flags.update_centrality_data: 
		update_or_init_centrality_data(id_grid)
	if data_flags.update_bounding_data: 
		update_or_init_bounding_data(id_grid)
		
func update_or_init_size_location_data(id_grid : Grid) -> void: 
	'''
		Purpose: 
			Observe and store the size and vector locations of each district in 'districts_dict'

		Arguments: 
			id_grid: 
				The 2D grid used to obtain the data
		
		Return: void
	'''

	# Iterate the grid
	for y in id_grid.height: for x in id_grid.width:
		
		var id = id_grid.index(y, x)

		# Don't evaluate non-districts
		if not is_district(id): continue 

		# Create a new district for the ID if one does not exist
		if id not in districts_dict:
			districts_dict[id] = district.new(id) 
		
		# Update the size counter for the district
		districts_dict[id].locations.append(Vector2i(y,x))
	
	
	for key in districts_dict.keys():
		# Update the size of the district based on the length of the locations array
		districts_dict[key].size_ = len(districts_dict[key].locations) 

		# Determine which locations of the district are borders
		districts_dict[key].set_border(id_grid)
		
	size_location_data_recorded = true

func update_or_init_percentage_data(id_grid : Grid) -> void: 
	'''
		Purpose:
			Observe and store the ratio of each district in 'districts_dict' to the total size

		Arguments: 
			id_grid: 
				The 2D grid used to obtain the data
		
		Return: void
	'''

	var total_size : float = id_grid.height * id_grid.width

	# Ensure size data has been recorded
	if not size_location_data_recorded:
		update_or_init_size_location_data(id_grid)
	
	# Calculate and store the size of each district
	for key in districts_dict.keys():
		districts_dict[key].percentage = float(districts_dict[key].size_) / total_size

func update_or_init_centrality_data(id_grid : Grid) -> void: 
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
	
func update_or_init_bounding_data(id_grid : Grid) -> void: 

	# Ensure location data has been recorded
	if not size_location_data_recorded:
		update_or_init_size_location_data(id_grid)

	for key in districts_dict.keys(): 
		districts_dict[key].set_bounding_box(id_grid)

func get_keys_sorted_by_attribute(attribute : String, ascending : bool) -> Array:
	'''
		Purpose: 
			Construct and return an array of district ID's sorted by a district class attribute
		
		Arguments: 
			attribute: 
				A string representing a class attribute of 'District' the array should be sorted by 
			ascending: 
				Determines if the array is sorted in ascending or descending order

		Return: 
			Array: The sorted array
	'''

	var districts_arr : Array = _sort_by_attribute(districts_dict.values(), attribute, ascending)
	var keys_arr : Array = []

	for distr in districts_arr:
		keys_arr.append(distr.id)
	
	return keys_arr

func get_district_centers() -> Array[Vector2i]: 
	''' Compiles and returns an array of the center of every district tracked by the district manager '''

	var district_centers : Array[Vector2i] = []
	for key in districts_dict.keys(): 
		district_centers.append(districts_dict[key].center)
	
	return district_centers

func get_num_districts() -> int: 
	''' Returns the number of districts which are being tracked by the manager '''
	return len(districts_dict.keys())
	
func get_district(key : int) -> District:
	''' Returns a district from 'districts_dict' if it exists '''

	if key not in districts_dict:
		# print_debug("Non-existent district (" + str(key) + ") requested from district manager")
		# push_error("Non-existent district requested from district manager")
		return null

	return districts_dict[key]

func get_district_attribute(key : int, attribute : String): 
	''' Returns an attribute from a district in 'districts_dict' if it exists '''

	if key not in districts_dict: 
		print_debug("Attribute requested from non-existent district in district manager")
		push_error("Attribute requested from non-existent district in district manager")
		return null
		
	if attribute not in districts_dict[key]:
		print_debug("Non-existent attribute requested from district in district manager")
		push_error("Non-existent attribute requested from district in district manager")
		return null

	return districts_dict[key][attribute]

func get_borders_to_render(): 
	var borders_to_render : Array[Vector2i] = []
	
	for d in districts_dict.values(): 
		
		if d.render_border: borders_to_render += d.border
	
	return borders_to_render

func erase_district(id : int): 
	''' Erases the district with ID matching the argument from the data model if it exists '''
	
	if id in districts_dict: 
		districts_dict.erase(id)

func _draw() -> void:
	
	# Init the tracking set
	var rendered_borders_set : Dictionary = {}
	
	# Iterate the districts
	for d in districts_dict.values(): 
		
		# Ensure the border should be rendered
		if not d.render_border: continue

		# Iterate the districts border divided by its neighbors
		for key in d.border_by_neighbor:

			# Check if the neighbor has been rendered
			if key in rendered_borders_set: continue

			# Iterate all border positions
			for pos in d.border_by_neighbor[key]:

				# Get the color and position of the node 
				var rect : Rect2 = Rect2(Vector2(pos[1]*square_size,pos[0]*square_size), Vector2(square_size / 2.0, square_size / 2.0))

				# Draw the rect
				draw_rect(rect, Color.YELLOW)
		
		# Record that this border has been rendered 
		rendered_borders_set[d.id]= true
		
	# TODO: Make sure square size cascades
	# TODO: Use that verify function to remove blemishes
