extends Control

# Array of neighboring positions that is iterated over in several algorithms 
var neighbors : Array = [
		Vector2(-1,-1), Vector2(0,-1), Vector2(1,-1),
		Vector2(-1,0),                 Vector2(1,0),
		Vector2(-1,1), Vector2(0,1)  , Vector2(1,1)
	]

# Array of non-diagonal neighboring positions that is iterated over in several algorithms 
var four_neighbors : Array = [
					   Vector2(0,-1), 
		Vector2(-1,0),                 Vector2(1,0),
					   Vector2(0,1)
	]
	
var pqLoad : Resource = preload("res://code/priority_queue.gd")

# Takes position (x (int), y (int)) and x max (int), y max (int)
# Returns if (x, y) is on the edge of the constraints
func is_edge(x : int, y : int, boundX : int, boundY : int) -> bool:
	return x <=0 or y <= 0 or x >=boundX-1 or y >= boundY-1

# Takes position (x (int), y (int)) and x max (int), y max (int)
# Returns if (x, y) is within the constraints
func bounds_check(x : int, y : int, boundX : int, boundY : int):
	return x >=0 and x < boundX and y >= 0 and y < boundY

# Takes the size of the screen (Vector2) and the size of a square / node (float)
func find_width_and_height(screenSize : Vector2, squareSize : float) -> Vector2: 
	var width : int =  ceil(screenSize.x / squareSize)
	var height : int = ceil(screenSize.y / squareSize)

	return Vector2(width, height)

# Takes the width (int), height (int), and size of a square (float)
# Updates screen size based on the values, reflects this in the display server and returns screenSize
func update_screen_size(width : int, height : int, squareSize : float) -> Vector2: 
	var screenSize : Vector2 = Vector2(width*squareSize, height*squareSize)
	DisplayServer.window_set_size(screenSize)

	return screenSize

# Takes in a randomness seed (int)
# Returns a random color (based on the factors of _seed so probably could be better but it's sufficient)
func get_random_color(_seed : int) -> Color: 
	# Use the _seed to generate RGB values
	var r = (_seed * 1234567) % 256 / 255.0  # Random red value
	var g = (_seed * 2345678) % 256 / 255.0  # Random green value
	var b = (_seed * 3456789) % 256 / 255.0  # Random blue value
	
	return Color(r, g, b, 0.6)


var lastExitTime : float = 0.0 
# Takes the algorithm number (int) and the amount of time to stall (float)
# Prints the amount of time the algorithm took, and stall for visual analysis 
func redraw_and_pause(alg : int, stall : float = 1.0, screenshot = true) -> void:
	print("Algorithm ", alg, " complete in ", (Time.get_ticks_msec() / 1000.0) - lastExitTime, " seconds")
	queue_redraw()
	await get_tree().create_timer(stall).timeout
	if screenshot: take_screenshot()
	print("\t exit redraw_and_pause()")
	lastExitTime = Time.get_ticks_msec() / 1000.0

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

# Takes an ID array
# Calculates the center of mass for each district and returns the coords as the key's of a dictionary leading to the district ID 
func districts_add_centers(idArray : Array, districts) -> Dictionary: 
	

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
		if key not in helperDict: continue

		# Calculate center
		var center_x = floor(helperDict[key][0] / helperDict[key][2])
		var center_y = floor(helperDict[key][1] / helperDict[key][2])
		
		# If the center of mass is not in the group use a backup #TODO: improve backup selection
		if idArray[center_x][center_y] != key: 
			districts[key]["center"] = helperDict[key][3]
			continue
		
		# Set value in dict 
		districts[key]["center"] = Vector2(center_x, center_y)

	return districts

# Takes an ID array 
# Compiles and returns a dictionary representing all groups in the array
func get_groups_dict(idArray : Array) -> Dictionary: 
	var groups_dict = {} 
	for row in idArray: for val in row:
		if val <= 2: continue 
		if val not in groups_dict: 
			groups_dict[val] = 1
			continue
		groups_dict[val]+=1
	return groups_dict

func scan_at_depth(idArray : Array, pos : Vector2, depth : int, ttl = 1) -> Array[int]: 
	if ttl == 0: return []
	var values : Array[int] = []
	for i in range(-depth, depth): 
		for j in range(-depth, depth):
			var x : int = int(pos[0]) + i 
			var y : int = int(pos[1]) + j
			if not bounds_check(x, y, len(idArray), len(idArray[0])): continue 
			if idArray[x][y] == 2 and depth != 1: continue
			if idArray[x][y] > 1: values.append(idArray[x][y])

	values.append_array(scan_at_depth(idArray, pos, depth + 1, ttl - 1))
	return values 


# Custom sorting function on the second element of an array 
func _sort_by_second_element(a, b):
	return a[1] < b[1]

var startTime : String = Time.get_datetime_string_from_system()
var path = "/Users/joshsiderius/Desktop/GodotSS/%s" % [startTime]
var first = true 

func take_screenshot():
	if first: 
		first = false
		DirAccess.make_dir_recursive_absolute(path)
		
	# Get the root viewport
	var root_viewport = get_viewport()
	# Capture the viewport as an image
	var screenshot = root_viewport.get_texture().get_image()
	
	# Save the screenshot to a file
	var file_path = "/Users/joshsiderius/Desktop/GodotSS/%s/%d.png" % [startTime, Time.get_ticks_usec()]
	var _error = screenshot.save_png(file_path)
	
