extends "res://code/helpers.gd"

class_name DistrictManager

var district : Resource = preload("res://code/Districts/district.gd")
var districts_dict : Dictionary = {}
var center_district_id : int
var castle_district_id : int
var square_size : float

func _init(id_grid : Grid, _square_size : float):
	square_size = _square_size

	update_district_data(id_grid)

func update_district_data(id_grid : Grid) -> void:
	'''
		Purpose: 
			Update the data model, choose which data to update according to the DistrictDataFlagStruct class

		Arguments: 
			id_grid: 
				The 2D grid used to update the data
			data_flags: 
				A class containing flags to determine which data to update

		Return: void

		Note: Removed the flag struct, none of the update_or_init functions have terrible runtimes where they should be avoided if possible
	'''

	square_size = id_grid.square_size
	districts_dict = {}

	update_or_init_size_location_data(id_grid)
	update_or_init_percentage_data(id_grid)
	update_or_init_centrality_data(id_grid)
	update_or_init_bounding_data()
		
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

		# Don't evaluate non-districts # TODO: We are going to track ALL values, BUT may need some fixes because of this previous assumption
		# if not is_district(id): continue 

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

	# Defer to the District class to calculate the data for each districts
	for key in districts_dict.keys():
		districts_dict[key].set_center(id_grid)
	
	var keys = get_keys_sorted_by_attribute("distance_to_grid_center", true)
	center_district_id = keys[0]
	
func update_or_init_bounding_data() -> void: 

	for key in districts_dict.keys(): 
		districts_dict[key].set_bounding_box()

func get_district_keys() -> Array:

	return districts_dict.keys()

func get_keys_sorted_by_attribute(attribute : String, ascending : bool, districts_only : bool = false) -> Array[int]:
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

	# Get the district values sorted by attribute
	var districts_arr : Array = _sort_by_attribute(districts_dict.values(), attribute, ascending)
	
	# Compile the ordered array of keys
	var keys_arr : Array[int] = []
	for distr in districts_arr:
		if districts_only and not is_district(distr.id): continue
		keys_arr.append(distr.id)
	
	return keys_arr

func select_castle_district():
	var keys = get_keys_sorted_by_attribute("size_", false, true)
	castle_district_id = keys[randi() % min(len(keys), 4)]
	get_district(castle_district_id).generic_district = Enums.Cell.DISTRICT_STAND_IN_CASTLE

func get_center_district() -> District:
	''' Returns the center district '''

	if not center_district_id: 
		print_debug("Trying to get center district which has not been initialized")
		push_error("Trying to get center district which has not been initialized")
		return null
	
	if center_district_id not in districts_dict:
		print_debug("District correlating to recorded center district ID not found")
		push_error("District correlating to recorded center district ID not found")
		return null

	return districts_dict[center_district_id]

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
		push_error("Non-existent district (" + str(key) + ") requested from district manager")
		return null

	return districts_dict[key]

func has_district(key : int) -> bool:
	''' Returns a bool indicating if the manager has data for a district '''

	return key in districts_dict

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

func get_borders_to_render() -> Array[Vector2i]:
	''' Returns an array of every border cell in any district marked to render '''

	var borders_to_render : Array[Vector2i] = []
	
	for d in districts_dict.values(): 
		if d.render_border: borders_to_render += d.border
	
	return borders_to_render

func get_district_cell_location_array(additional_ids : Array = []) -> Array[Vector2i]: 
	''' Returns an array of the Vector2i location of every district cell (with ID > 2) '''

	var location_array : Array[Vector2i] = []

	for key in districts_dict.keys():
		if not (is_district(key) or key in additional_ids): continue
			
		location_array += districts_dict[key].locations
	
	return location_array

func get_bounding_box() -> Rect2:
	'''
		Purpose:
			Return the bounding box of all observed data
		
		Return: 
			Rect2: (Vector2(bounding box min point), Vector2(bounding box max point))
	'''

	if len(districts_dict.values()) == 0:
		print_debug("No districts tracked to observe bounding box")
		push_error("No districts tracked to observe bounding box")
		return Rect2(-1, -1, -1, -1)

	var bb_min : Vector2i = Vector2i(2147483647, 2147483647) # INT 32 Max
	var bb_max : Vector2i = Vector2i(0, 0)

	for d in districts_dict.values():
		print(d.id, " ", is_district(d.id))
		if not is_district(d.id): continue
		print('through')

		var d_bb : Rect2 = d.bounding_box
		print(d_bb)
		bb_min[0] = min(bb_min[0], d_bb.position[0])
		bb_min[1] = min(bb_min[1], d_bb.position[1])

		bb_max[0] = max(bb_max[0], d_bb.size[0])
		bb_max[1] = max(bb_max[1], d_bb.size[1])
	
	return Rect2(bb_min, bb_max)
	
func erase_district(id : int) -> void: 
	''' Erases the district with ID matching the argument from the data model if it exists '''
	
	if id in districts_dict: 
		districts_dict.erase(id)

func get_nearest(pos : Vector2i, id : int) -> Vector2i:

	if not id in districts_dict:
		print_debug("Requested invalid district")
		push_error("Requested invalid district")
		return Vector2i(-1, -1)
	
	return districts_dict[id].get_nearest(pos)

func get_water_neighbors() -> Array[District]:
	var dist_array : Array[District] = []
	for dist in districts_dict.values():
		if not dist.has_neighbor(Enums.Cell.WATER): continue

		dist_array.append(dist)
	
	return dist_array

func can_path_to(start_id : int, end_id: int, exclusion_ids : Array[int]) -> bool:
	var visited = {}
	var queue = [districts_dict[start_id]]

	while queue.size() > 0:
		var current = queue.pop_front()

		if current.id == end_id:
			return true

		if current.id in visited:
			continue

		visited[current.id] = true

		for neighbor_id in current.border_by_neighbor:
			if neighbor_id in exclusion_ids or not is_district(neighbor_id): continue

			if neighbor_id in districts_dict:
				var neighbor = districts_dict[neighbor_id]
				if neighbor.id not in visited:
					queue.append(neighbor)

	return false


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
