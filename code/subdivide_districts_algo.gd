extends "res://code/major_roads_algo.gd"

# INCOMPLETE: Will have to somehow subdivide the districts such that one node is now 4
func subdivide_district(idArrayArg : Array, bb : Array, _key : int) -> Array: 
	var sub_array : Array = get_array_between(bb[0], bb[1], idArrayArg)
	return sub_array

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

func add_district_center(idArray : Array, id : int, bounding_box : Array, center : Vector2i, radius : float) -> Array:
	for x in range(bounding_box[0][0], bounding_box[1][0]+1, 1):
		for y in range(bounding_box[0][1], bounding_box[1][1]+1, 1): 
			if idArray[x][y] not in [id, -1]: continue 

			var distance : float = sqrt(pow(x - center[0], 2) + pow(y - center[1], 2))
			if distance > radius: continue

			idArray[x][y] = -2

	return idArray 

func get_locations_in_district(idArray : Array, id : int, boundingBox : Array, edgeBarrier : float = 3.0):

	var districtNodes : Array[Vector2i] = []
	var borderNodes : Array[Vector2i] = []
	for x in range(boundingBox[0][0]-1, boundingBox[1][0]+2, 1):
		for y in range(boundingBox[0][1]-1, boundingBox[1][1]+2, 1): 
			if not bounds_check(x, y, len(idArray), len(idArray[0])): continue
			if idArray[x][y] in [-3, -4]: borderNodes.append(Vector2i(x, y))

	for x in range(boundingBox[0][0], boundingBox[1][0]+1, 1):
		for y in range(boundingBox[0][1], boundingBox[1][1]+1, 1): 
			if not idArray[x][y] == id: continue
			var valid = true
			for b in borderNodes: 
				if Vector2i(x, y).distance_to(b) > edgeBarrier: continue
				valid = false 
				break
				
			if valid: districtNodes.append(Vector2i(x,y))

	var locations = select_random_items(districtNodes, 100) #floor(len(districtNodes) * 0.005)) 
	return add_roads(idArray, locations, true)

	# return idArray



func replace_ID(idArray : Array, elimID : int, replacementID : int) -> void: 
	for x in range(len(idArray)): for y in range(len(idArray[x])): 
		if idArray[x][y] != elimID: continue 
		idArray[x][y] = replacementID
	

	
