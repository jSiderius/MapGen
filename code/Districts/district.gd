extends "res://code/helpers.gd"

class_name District

var id : int
var size_ : int = 0
var percentage : float = 0
var center : Vector2i = Vector2i(0, 0)
var locations : Array[Vector2i] = []
var border : Array[Vector2i] = []
var render_border : bool = false
var distance_to_grid_center : float
var bounding_box_min : Vector2i = Vector2i(0, 0)
var bounding_box_max : Vector2i = Vector2i(0, 0)
func _init(_id : int): 
	id = _id

func set_center(id_grid : Array): 
	'''
		Purpose: 
			TODO: Assess

		Arguments: 

		Return: void
	'''
	
	# Ensure size_ is correct
	size_ = len(locations)

	# Calculate the sum of all location vectors
	var sum_vector = Vector2i(0, 0)
	for loc in locations: 
		sum_vector += loc
	
	# Calculate the center of mass by averaging the vector
	var center_of_mass : Vector2i = Vector2i(ceil(float(sum_vector.x) / size_), ceil(float(sum_vector.y) / size_))
		# sum_vector / size_) # TODO: This probably doesn't work syntactically 

	if id_grid[center_of_mass.x][center_of_mass.y] != id: 
		center = locations[randi() % size_] # TODO: Improve on this by seeking the nearest location to the center of mass
	else: 
		center = center_of_mass
	
	distance_to_grid_center = center.distance_to(Vector2(len(id_grid) / 2.0, len(id_grid[0]) / 2.0))

func set_bounding_box() -> void:
	''' Generates the bounding box of the district according the the 'locations' vector array'''

	for loc in locations: 
		bounding_box_min = Vector2i(min(bounding_box_min.x, loc.x), min(bounding_box_min.x, loc.x))
		bounding_box_max = Vector2i(max(bounding_box_max.x, loc.x), max(bounding_box_max.x, loc.x))

func set_border(id_grid : Array) -> void:
	''' TODO: Modify and document'''
	# reset the border to empty
	border = []

	# Iterate every border of every location of the District
	for loc in locations: for n in neighbors:
		var n_loc : Vector2i = loc + n

		# Verify the neighbor is in bounds
		if not bounds_check( n_loc, Vector2i(len(id_grid), len(id_grid[0]))): continue

		# If the neighbor is a district (>2) and not this district it is a border
		if id_grid[n_loc.x][n_loc.y] > 2 and id_grid[n_loc.x][n_loc.y] != id:
			border.append(loc)
	
# TODO: What is this? 
# func add_border_to_grid(id_grid : Array) -> Array: 
# 	#var bdr : 
# 	for loc in locations: for n in neighbors:
# 		var n_loc : Vector2i = loc + n

# 		# Verify the neighbor is in bounds
# 		if not bounds_check(n_loc.x, n_loc.y, len(id_grid), len(id_grid[0])): continue

# 		if id_grid[n_loc.x][n_loc.y] > 2 and id_grid[n_loc.x][n_loc.y] != id:
# 			id_grid[loc.x][loc.y] = -4
# 			# locations.erase(loc)
# 			size_ -= 1
# 			break #break the neighbors loop

# 	return id_grid






# for x in range(bounding_box[0][0], bounding_box[1][0]+1, 1):
	# 	for y in range(bounding_box[0][1], bounding_box[1][1]+1, 1): 
	# 		if not id_grid[x][y] == id: continue
			
	# 		for n in neighbors: 
	# 			var newX : int = x + n[0]
	# 			var newY : int = y + n[1]
				
	# 			if id_grid[newX][newY] > 2 and id_grid[newX][newY] not in [id]:
	# 				id_grid[newX][newY] = -4
	# return id_grid
