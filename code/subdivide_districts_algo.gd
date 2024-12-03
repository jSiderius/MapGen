extends "res://code/major_roads_algo.gd"

# INCOMPLETE: Will have to somehow subdivide the districts such that one node is now 4
func subdivide_district(idArrayArg : Array, bb : Array, key : int) -> Array: 
	var sub_array : Array = get_array_between(bb[0], bb[1], idArrayArg)
	print(key)
	return sub_array

# Takes an ID array 
# Returns a dictionary from group id (key) to bounding box (value)
func find_district_bounding_boxes(idArray : Array) -> Dictionary:
	var groups_dict : Dictionary = {} 
	for x in range(len(idArray)): for y in range(len(idArray[x])): 
	
		# Get and screen the value 
		var val : int = idArray[x][y]
		if val <= 2: continue
		if val not in groups_dict: 
			groups_dict[val] = [Vector2(x,y), Vector2(x,y)]
			continue 
		
		# If the value is outside the current bounding box expand the box
		groups_dict[val][0][0] = groups_dict[val][0][0] if groups_dict[val][0][0] < x else x 
		groups_dict[val][0][1] = groups_dict[val][0][1] if groups_dict[val][0][1] < y else y 
		groups_dict[val][1][0] = groups_dict[val][1][0] if groups_dict[val][1][0] > x else x 
		groups_dict[val][1][1] = groups_dict[val][1][1] if groups_dict[val][1][1] > y else y 

	return groups_dict

# Takes 2 vectors (Vector2) and an ID array 
# Returns a 2D array of all values between the vectors in the ID array
func get_array_between(v1: Vector2, v2: Vector2, idArray: Array) -> Array:
	# Ensure v1 has the smaller x and y values
	var start = Vector2(min(v1.x, v2.x), min(v1.y, v2.y))
	var end = Vector2(max(v1.x, v2.x), max(v1.y, v2.y))
	
	# Create a 2D array of all the values between start and end in array
	var result = []
	for x in range(start.x, end.x+1): 
		result.append([])
		for y in range(start.y, end.y+1):
			if not bounds_check(x, y, len(idArray), len(idArray[x])): continue 
			result[x-start.x].append(idArray[x][y])

	return result
	
func increase_array_resolution(idArray : Array, multiplier : float = 2): 
	var idArrayNew : Array = []

	for i in range(floor(multiplier * len(idArray))): 
		idArrayNew.append([])
		for j in range(floor(multiplier * len(idArray[0]))): 
			idArrayNew[i].append(idArray[floor(i / float(multiplier))][floor(j / float(multiplier))])

	return idArrayNew

func add_district_border(idArray : Array, id : int, bounding_box : Array): 
	for x in range(bounding_box[0][0], bounding_box[1][0]+1, 1):
		for y in range(bounding_box[0][1], bounding_box[1][1]+1, 1): 
			if not idArray[x][y] == id: continue
			
			for n in neighbors: 
				var newX : int = x + n[0]
				var newY : int = y + n[1]
				
				if idArray[newX][newY] > 2 and idArray[newX][newY] not in [id]: 
					idArray[newX][newY] = -4
	return idArray

func get_locations_in_district(idArray : Array, id : int, boundingBox : Array): 

	var districtNodes : Array[Vector2i] = []
	for x in range(boundingBox[0][0], boundingBox[1][0]+1, 1):
		for y in range(boundingBox[0][1], boundingBox[1][1]+1, 1): 
			if idArray[x][y] == id: districtNodes.append(Vector2i(x,y))

	var locations = select_random_items(districtNodes, floor(len(districtNodes) * 0.05))
	for loc in locations: 
		idArray[loc[0]][loc[1]] = -2
	add_roads(idArray, locations)
	return idArray

func select_random_items(arr: Array, count: int) -> Array:
	# Ensure the count doesn't exceed the size of the array
	if count > arr.size():
		count = arr.size()
	
	# Create a copy of the array to avoid modifying the original
	var temp_arr = arr.duplicate()

	# Shuffle the array
	temp_arr.shuffle()
	
	# Take the first `count` items
	return temp_arr.slice(0, count)