extends "res://code/helpers.gd"

class_name District

var id : int
var size_ : int = 0
var percentage : float = 0
var center : Vector2i = Vector2i(0, 0)
var locations : Array[Vector2i] = []
var distance_to_grid_center : float

func _init(_id : int): 
	id = _id

func set_center(id_grid : Array): 
	'''
		Purpose: 

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
