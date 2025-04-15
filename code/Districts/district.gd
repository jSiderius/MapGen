extends "res://code/helpers.gd"

class_name District

var id : int
var size_ : int = 0
var percentage : float = 0
var center : Vector2i = Vector2i(0, 0)
var locations : Array[Vector2i] = []

var border : Array[Vector2i] = []
var border_by_neighbor : Dictionary = {} 

var render_border : bool = false
var distance_to_grid_center : float
var bounding_box_min : Vector2i
var bounding_box_max : Vector2i

func _init(_id : int): 
	id = _id

func set_center(id_grid : Grid): 
	'''
		Purpose: 
			Determine the center of the district and store

		Arguments: 
			id_grid: 
				The 2D grid used to update the data

		Return: void
	'''
	
	# Ensure size_ is correct
	size_ = len(locations)

	# Calculate the sum of all location vectors
	var sum_vector = Vector2i(0, 0)
	for loc in locations: 
		sum_vector += loc
	
	# Calculate the center of mass by averaging the vector
	center = Vector2i(ceil(float(sum_vector[0]) / size_), ceil(float(sum_vector[1]) / size_))

	if id_grid.index_vec(center) != id:
		var min_distance : float = locations[0].distance_to(center)
		var min_location : Vector2i = locations[0]
		for loc in locations:
			if loc.distance_to(center) >= min_distance: continue
			min_distance = loc.distance_to(center)
			min_location = loc

		center = min_location
	
	distance_to_grid_center = center.distance_to(Vector2(id_grid.height / 2.0, id_grid.width / 2.0))

func set_bounding_box(id_grid : Grid) -> void:
	'''
		Purpose: 
			Determine the bounding box of the district and store in variables

		Arguments: 
			id_grid: 
				The 2D grid used to update the data

		Return: void
	'''

	bounding_box_max = Vector2i(0, 0)
	bounding_box_min = Vector2i(id_grid.height, id_grid.width)

	for loc in locations: 
		bounding_box_min = Vector2i(min(bounding_box_min[0], loc[0]), min(bounding_box_min[1], loc[1]))
		bounding_box_max = Vector2i(max(bounding_box_max[0], loc[0]), max(bounding_box_max[1], loc[1]))

func set_border(id_grid : Grid, n_type : int = Enums.NeighborsType.EIGHT_NEIGHBORS) -> void:
	'''
		Purpose: 
			Determine the border of the district and store in variables

		Arguments: 
			id_grid: 
				The 2D grid used to update the data

		Return: void
	'''
	
	# reset trackers
	border = []
	border_by_neighbor = {}

	# Iterate every border of every location of the District
	for loc in locations: for n in neighbors[n_type]:
		var n_loc : Vector2i = loc + n

		# Verify the neighbor is in bounds
		if not bounds_check( n_loc, Vector2i(id_grid.height, id_grid.width)): continue
		var n_id : int = id_grid.index_vec(n_loc)

		# If the neighbor is a district (>2) and not this district it is a border
		# if is_district(n_id) and n_id != id: 
		if n_id != id:
			if n_id not in border_by_neighbor: border_by_neighbor[n_id] = []
			border_by_neighbor[n_id].append(loc)
			border.append(loc)

func _draw() -> void:
	pass
