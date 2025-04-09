extends Control

''' Array of vector increments to neighboring positions of a cell in discrete 2D space '''
var neighbors : Array[Vector2i] = [
		Vector2i(-1,-1), Vector2i(0,-1), Vector2i(1,-1),
		Vector2i(-1,0),                 Vector2i(1,0),
		Vector2i(-1,1), Vector2i(0,1)  , Vector2i(1,1)
	]

''' Array of non-diagonal vector increments to neighboring positions of a cell in discrete 2D space '''
var four_neighbors : Array[Vector2i] = [
					   Vector2i(0,-1), 
		Vector2i(-1,0),                 Vector2i(1,0),
					   Vector2i(0,1)
	]
	
''' Resource loaded for priority queue class '''
var pqLoad : Resource = preload("res://code/priority_queue.gd")

''' The current minimum unique ID, stored globally to track ID's over the course of the program '''
var MIN_UNIQUE_ID : int = 3 # TODO: RIVER FIX

func is_edge(pos : Vector2i, boundary : Vector2i) -> bool:
	''' Takes a pos (x,y), and a boundary for the maximum of x and y and determines if (x,y) is on the edge of the grid '''

	return pos.x <=0 or pos.y <= 0 or pos.x >= boundary.x-1 or pos.y >= boundary.y-1

func bounds_check(pos : Vector2i, boundary : Vector2i):
	''' Takes a position (x,y), and a boundary for the maximum of x and y and determines if (x,y) is in bounds of the grid '''

	return pos.x >=0 and pos.x < boundary.x and pos.y >= 0 and pos.y < boundary.y

func find_width_and_height(screen_size : Vector2, square_size : float) -> Vector2: 
	''' Takes the screen size and square size and determines the integer size of the screen in terms of squares '''

	var width : int =  ceil(screen_size.x / square_size)
	var height : int = ceil(screen_size.y / square_size)

	return Vector2(width, height)

func update_screen_size(width : int, height : int, square_size : float) -> Vector2: 
	''' Takes the current screensize and the square size and updates the size of the screen to land exactly on a square, returns the resulting size '''

	var screen_size : Vector2 = Vector2(width*square_size, height*square_size)
	DisplayServer.window_set_size(screen_size)

	return screen_size

func get_random_color(_seed : int, hardsets : Vector3 = Vector3(-1, -1, -1), scalars : Vector3 = Vector3(1.0, 1.0, 1.0)) -> Color:
	''' Uses a seed (int) to randomly generate a color which is then unique to the seed, allows for hardsets and scaling of values to target certain gradiants '''

	# Validate Scalar data 
	if scalars.x < 0.0 or scalars.x > 1.0: scalars.x = 1.0
	if scalars.y < 0.0 or scalars.y > 1.0: scalars.y = 1.0
	if scalars.z < 0.0 or scalars.z > 1.0: scalars.z = 1.0
	
	# Select random values for the red, green, and blue spectrums
	var r = (_seed * 1234567) % 256 / 255.0
	var g = (_seed * 2345678) % 256 / 255.0
	var b = (_seed * 3456789) % 256 / 255.0

	# Override with hard sets if requested, otherwise apply scalars
	r = hardsets.x if (hardsets.x >= 0 and hardsets.x <= 1) else r * scalars.x
	g = hardsets.y if (hardsets.y >= 0 and hardsets.y <= 1) else g * scalars.y
	b = hardsets.z if (hardsets.z >= 0 and hardsets.z <= 1) else b * scalars.z
	
	return Color(r, g, b, 1.0)


var last_exit_time : float = 0.0 
# Takes the algorithm number (int) and the amount of time to stall (float)
# Prints the amount of time the algorithm took, and stall for visual analysis 
func redraw_and_pause(alg : int, stall : float = 1.0, screenshot = true) -> void:
	'''
		Purpose: 
			Redraw the screen and generate debugging information such as the time since the last call and creating a screenshot of the new state of the program
			TODO: Improve the modularity of algorithms

		Arguments: 
			alg: 
				The current algorithm number
			stall: 
				The amount of time to pause the entire program
			screenshot: 
				Boolean indicating if a screenshot should be taken

		Return: void
	'''

	print("Algorithm ", alg, " complete in ", (Time.get_ticks_msec() / 1000.0) - last_exit_time, " seconds")
	queue_redraw()
	await get_tree().create_timer(stall).timeout
	if screenshot: take_screenshot()
	print("\t exit redraw_and_pause()")
	last_exit_time = Time.get_ticks_msec() / 1000.0

func _sort_by_attribute(array : Array, attribute : String, ascending : bool) -> Array:
	''' Sort a passed array by a passed attribute in ascending or descending order '''
	''' TODO: Validate that the array is of objects, the attribute is valid, ... ''' 
	array.sort_custom(func(a, b): return (a[attribute] < b[attribute]) if ascending else (a[attribute] > b[attribute]))
	return array

''' Permanent data for take_screenshot() ''' 
var start_time : String = Time.get_datetime_string_from_system()
var path = "/Users/joshsiderius/Desktop/GodotSS/%s" % [start_time]
var first_screenshot = true 

func take_screenshot():
	''' Takes a screenshot of the game window and saves to file ''' 

	if first_screenshot: 
		first_screenshot = false
		DirAccess.make_dir_recursive_absolute(path)
		
	# Get the root viewport
	var root_viewport = get_viewport()
	# Capture the viewport as an image
	var screenshot = root_viewport.get_texture().get_image()
	
	# Save the screenshot to a file
	var file_path = "/Users/joshsiderius/Desktop/GodotSS/%s/%d.png" % [start_time, Time.get_ticks_usec()]
	var _error = screenshot.save_png(file_path)
	
func select_random_items(arr: Array, count: int) -> Array:
	''' Return 'count' number of random elements from 'arr' '''

	# Ensure the count doesn't exceed the size of the array
	if count > arr.size():
		count = arr.size()
	
	# Create a copy of the array to avoid modifying the original
	var temp_arr = arr.duplicate()

	# Shuffle the array
	temp_arr.shuffle()
	
	# Take the first_screenshot `count` items
	return temp_arr.slice(0, count)

func random_edge_position(width: int, height: int) -> Vector2i:
	''' Gives a random position on the edge of the grid '''
	''' TODO: Small chance to not reach the edge, I don't think the bug is in this function '''

	var side := randi() % 4  # 0 = top, 1 = bottom, 2 = left, 3 = right
	
	match side:
		0:  # top
			return Vector2i(randi() % width, 0)
		1:  # bottom
			return Vector2i(randi() % width, height - 1)
		2:  # left
			return Vector2i(0, randi() % height)
		3:  # right
			return Vector2i(width - 1, randi() % height)
	
	return Vector2i(0, 0) # Unreachable (for compiler)
