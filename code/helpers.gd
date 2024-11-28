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
func redraw_and_pause(alg : int, stall : float = 1.0) -> void:
	# print()
	print("Algorithm ", alg, " complete in ", (Time.get_ticks_msec() / 1000.0) - lastExitTime, " seconds")
	queue_redraw()
	await get_tree().create_timer(stall).timeout
	print("\t exit redraw_and_pause()")
	lastExitTime = Time.get_ticks_msec() / 1000.0