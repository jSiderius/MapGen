extends "res://code/grid_gen_functions.gd"
# IF GETS TOO COMPLICATED THIS CAN BE A CLASS BUT IT SEEMS FINE 

func get_districts_dict(idArray : Array) -> Dictionary: 
	var districts : Dictionary = get_districts_dict_empty(idArray)
	districts_add_sizes(idArray, districts)
	districts_add_percentages(idArray, districts)
	districts_add_centers(idArray, districts)

	return districts

func get_districts_dict_empty(idArray : Array) -> Dictionary: 
	var districtsDict = {}
	for row in idArray: for val in row:
		if val <= 2: continue 
		if val not in districtsDict: 
			districtsDict[val] = {}
	return districtsDict

func districts_add_sizes(idArray : Array, districts : Dictionary) -> Dictionary: 
	for key in districts.keys(): 
		districts[key]["size"] = 0

	for row in idArray: for val in row:
		if val <= 2 or val not in districts: continue
		districts[val]["size"] += 1

	return districts

func districts_add_percentages(idArray : Array, districts : Dictionary) -> Dictionary: 
	var totalSize : int = 0
	for key in districts.keys(): 
		if "size" not in districts[key]: districts = districts_add_sizes(idArray, districts)
		totalSize += districts[key]["size"]
	
	for key in districts.keys():
		districts[key]["sizePercent"] = float(districts[key]["size"]) / float(totalSize)

	return districts

# Takes an ID array
# Calculates the center of mass for each district and returns the coords as the key's of a dictionary leading to the district ID 
func districts_add_centers(idArray : Array, districts : Dictionary) -> Dictionary: 
	var helperDict : Dictionary = {}
	# Dictionary from group ID (int, key) to [sum all x coords (int), sum all y coords (int), count of nodes in group (int), backup value (Vector2)] (Array, value)
	for x in range(len(idArray)): for y in range(len(idArray[x])): 

		# Get and screen value
		var val : int = idArray[x][y]
		if val <= 2: continue 
		if val not in helperDict: 
			helperDict[val] = [x, y, 1, Vector2(x,y)]
			continue
		
		# Update the dict
		helperDict[val][0] += x
		helperDict[val][1] += y
		helperDict[val][2] += 1
	
	for key in districts.keys():
		if key not in helperDict: 
			districts.erase(key)
			continue

		# Calculate center
		var center_x = floor(helperDict[key][0] / helperDict[key][2])
		var center_y = floor(helperDict[key][1] / helperDict[key][2])
		
		# If the center of mass is not in the group use a backup #TODO: improve backup selection
		if idArray[center_x][center_y] != key: 
			districts[key]["center"] = helperDict[key][3]
			continue
		
		# Set value in dict 
		districts[key]["center"] = Vector2i(center_x, center_y)
		districts[key]["disToCenter"] = Vector2i(center_x, center_y).distance_to(Vector2i(floor(len(idArray) / 2.0), floor(len(idArray[0]) / 2.0)))

	return districts

# Takes an ID array 
# Returns a dictionary from group id (key) to bounding box (value)
func districts_add_bounding_boxes(idArray : Array, districts : Dictionary) -> Dictionary:
	for x in range(len(idArray)): for y in range(len(idArray[x])): 
	
		# Get and screen the value 
		var key : int = idArray[x][y]
		if key <= 2: continue
		if key not in districts: 
			print("Error in construction of districts dict")
		if "bounding" not in districts[key]: 
			districts[key]["bounding"] = [Vector2i(x,y), Vector2i(x,y)]
			continue 
		
		var b0 : Vector2i = districts[key]["bounding"][0]
		var b1 : Vector2i = districts[key]["bounding"][1]

		# If the value is outside the current bounding box expand the box
		districts[key]["bounding"][0][0] = b0.x if b0.x < x else x 
		districts[key]["bounding"][0][1] = b0.y if b0.y < y else y 
		districts[key]["bounding"][1][0] = b1.x if b1.x > x else x 
		districts[key]["bounding"][1][1] = b1.y if b1.y > y else y 

	return districts

func districts_add_window_border(idArray : Array, districts : Dictionary) -> Dictionary: 
	for key in districts.keys():
		districts[key]["windowBorder"] = {}
		districts[key]["windowBorder"]["north"] = false 
		districts[key]["windowBorder"]["east"] = false 
		districts[key]["windowBorder"]["south"] = false
		districts[key]["windowBorder"]["west"] = false
		districts[key]["windowBorder"]["any"] = false

	for x in range(len(idArray)): for y in range(len(idArray[x])): 
		var val : int = idArray[x][y]
		if val not in districts or x not in [0, len(idArray)-1] or y not in [0, len(idArray[x]) -1]: continue
		 
		if x == 0: districts[val]["windowBorder"]["west"] = true
		if y == 0: districts[val]["windowBorder"]["north"] = true
		if x == len(idArray) - 1: districts[val]["windowBorder"]["east"] = true
		if y == len(idArray[x]) - 1: districts[val]["windowBorder"]["south"] = true

		districts[val]["windowBorder"]["any"] = districts[val]["windowBorder"]["north"] or districts[val]["windowBorder"]["east"] or districts[val]["windowBorder"]["south"] or districts[val]["windowBorder"]["west"]

	return districts

func sorted_district_keys(districts : Dictionary, sortVar : String) -> Array:
	var arr : Array = []
	for key in districts.keys():
		arr.append([key, districts[key][sortVar]])
	arr.sort_custom(_sort_by_second_element)

	for i in range(len(arr)): 
		arr [i] = arr[i][0]

	return arr

# ADD DISTANCE TO CENTER 
	 
