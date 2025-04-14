extends Node2D

var id_grid : Array[Array] = []
var square_size : float = 30.0

var world_loader : Resource = preload("res://wfc_src/world.gd")
var world : World

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var screenSize : Vector2 = get_viewport_rect().size
	var w_h : Vector2 = find_width_and_height(screenSize, square_size)
	var width : int = int(w_h.x)
	var height : int = int(w_h.y)
	screenSize = update_screen_size(width, height, square_size) 
	
	world = world_loader.new(width, height)
	# draw world function
	
	var i : int = 0
	var is_complete : bool = false
	while not is_complete: 
		is_complete = world.wave_function_collapse()
	queue_redraw()
	
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

func _draw() -> void: 
	var colors_dict : Dictionary = {
		wfcConfig.TILE_ERROR : Color.RED,
		wfcConfig.TILE_COAST : Color.BEIGE,
		wfcConfig.TILE_OCEAN : Color.BLUE, 
		wfcConfig.TILE_LAND : Color.GREEN,
	}
	
	for y in range(world.height): for x in range(world.width): 
		var type = world.get_type(x, y)
		
		var col = colors_dict[type] if type in colors_dict else Color.YELLOW
		var rect : Rect2 = Rect2(Vector2(x*square_size,y*square_size), Vector2(square_size, square_size))
#
		# Draw the rect
		draw_rect(rect, col)
