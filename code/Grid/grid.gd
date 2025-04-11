extends "res://code/helpers.gd"

class_name Grid

var width : int
var height : int
var square_size : float
var id_grid : Array[Array]

var district_flag_struct_loader : Resource = preload("res://code/Districts/district_data_flags_struct.gd")
var district_flag_struct : DistrictDataFlagStruct
var district_manager_loader : Resource = preload("res://code/Districts/district_manager.gd")
var district_manager : DistrictManager

var colors_dict : Dictionary = {
		Enums.Cell.DISTRICT_WALL : Color.BLACK, # District walls 
		Enums.Cell.CITY_WALL : Color.BLACK, # City walls
		Enums.Cell.DISTRICT_CENTER : Color.BLUE, #District Center
		Enums.Cell.MAJOR_ROAD : Color.ORANGE, # Major roads
		Enums.Cell.VOID_SPACE_0 : Color.WHITE, # Void space from noise, becomes obsolete
		Enums.Cell.VOID_SPACE_1 : Color.BLACK, # Void space from noise, becomes district and city walls 
		Enums.Cell.OUTSIDE_SPACE : Color.GREEN, # Outside space 
		Enums.Cell.WATER : Color.BLUE, # River
}

func _init(_width : int, _height : int, _square_size : int, init_type : int = Enums.GridInitType.RANDOM, arguments : Dictionary = {}) -> void:
	'''
		Purpose: 
			Initialize the class
		
		Arguments: 
			_width:
				Width of the grid
			_height: 
				Height of the grid
			_square_size: 
				Size of each square for rendering
			init_type: 
				Flag indicating how the grid should be initialized
			arguments: 
				Dictionary to pass arguments onto grid initialization functions as needed
			
		Return: void
	'''

	# Initialize variables
	width = _width
	height = _height
	square_size = _square_size

	# Initialize the grid according to the flag
	if init_type == Enums.GridInitType.RANDOM: 
		init_random()
	elif init_type == Enums.GridInitType.EMPTY: 
		init_empty()
	elif init_type == Enums.GridInitType.VORONOI:
		init_voronoi(arguments)
	else:
		init_random()
		print_debug("Invalid grid initialization type")
		push_error("Invalid grid initialization type")

func init_random():
	''' Generates a 2D grid with dimensions 'width'x'height', each value is randomly assigned to be VOID_SPACE_O (0) or VOID_SPACE_1 (1) '''

	id_grid = []
	for y in height:
		id_grid.append([])
		for x in width:
			id_grid[y].append(randi() % 2)
			pass
	
func init_empty():
	''' Generates a 2D grid with dimensions 'width'x'height', each value is assigned to be VOID_SPACE_O (0) '''

	id_grid = []
	for y in height:
		id_grid.append([])
		for x in width:
			id_grid[y].append(0)

func init_voronoi(arguments : Dictionary) -> void:
	'''
		Purpose: 
			Generate an ID grid where each ID is set to the value of the nearest randomly generated voronoi point

		Args (contained in 'arguments' dict):
			num_cells: 
				Number of randomly generated voronoi cells
			min_dist:
				The minimum distance a voroni cells can be from any edge as a percentage of the size of the grid

		Returns: void
	'''

	# Get the arguments from 'arguments'
	var num_cells : int = arguments["num_cells"] if "num_cells" in arguments else 100
	var min_dist_from_edge_percent : float = arguments["min_dist"] if "min_dist" in arguments else 0.05

	init_empty()

	# Create a vector representing the interger distance a voronoi cell should be from the edge
	var buffer_zone : Vector2i = Vector2i(ceil(height * min_dist_from_edge_percent), ceil(width * min_dist_from_edge_percent))
	
	# TODO: Validate the buffer zone
	var cells : Array[Vector2i] = []

	# Randomly generate the cell locations
	for i in range(num_cells): 
		cells.append(Vector2i(buffer_zone.y + randi()%(height - 2 * buffer_zone.y), buffer_zone.x + randi()% (width - 2 * buffer_zone.x)))
	
	# Determine each point in the grids value based on the vornoi cell locations
	for y in range(height): for x in range(width): 
		set_id(y, x, get_position_id_by_voronoi_cell_locations(cells, Vector2i(y, x)) + 1)

func init_district_manager():
	''' Initialize the district manager to track information about the districts '''

	district_flag_struct = district_flag_struct_loader.new(true)
	district_manager = district_manager_loader.new(id_grid, district_flag_struct)

func update_district_manager(flags : DistrictDataFlagStruct = null):
	''' Update the district manager with the currently set flags or new ones ''' 

	# Update the flags if necessary
	if flags != null: district_flag_struct = flags

	# Update the manager
	district_manager.update_district_data(id_grid, district_flag_struct)

func _draw() -> void:
	''' Draws to screen based on the values class data ''' 

	for y in range(height): for x in range(width):
		
		# Get the value of the node 
		var val : int = index(y, x)

		# Get the color and position of the node
		# var col = colors_dict[val] if val in colors_dict else get_random_color(id_grid[y][x], Vector3(1.0, -1.0, 0.0)) # RED-YELLOW SPECTRUM
		var col = colors_dict[val] if val in colors_dict else get_random_color(id_grid[y][x], Vector3(-1.0, -1.0, -1.0))
		var rect : Rect2 = Rect2(Vector2(x*square_size,y*square_size), Vector2(square_size, square_size))

		if district_manager and is_district(val):
			var district = district_manager.get_district(val)
			if district and district.render_border: 
				col = Color("a34a4d")

		# Draw the rect
		draw_rect(rect, col)
	
	# TODO: improve effeciency here
	if not district_manager: return
	var borders_to_render : Array[Vector2i] = district_manager.get_borders_to_render()
	var rendered : Dictionary = {}
	for pos in borders_to_render: 
		
		var skip_render : bool = false
		for n in neighbors:
			var n_pos : Vector2i = n + pos 
			if not bounds_check(n_pos, Vector2i(height, width)): continue

			if index_vec(n_pos) != index_vec(pos) and n_pos in rendered: 
				skip_render = true
				break

		if skip_render: continue
		rendered[pos] = true

		# Get the color and position of the node 
		var rect : Rect2 = Rect2(Vector2(pos.y*square_size,pos.x*square_size), Vector2(square_size, square_size))

		# Draw the rect
		draw_rect(rect, Color.YELLOW)

func index(y : int, x : int):
	''' get an id from the grid by a y, x index '''
	return id_grid[y][x]

func index_vec(vec : Vector2i):
	''' get an id from the grid by a y, x vector
		NOTE: Vector should already be formatted in [y][x] '''

	return id_grid[vec.x][vec.y]

func set_id(y : int, x : int, val : int) -> void:
	''' set an id from the grid by a y, x index '''

	id_grid[y][x] = val

func set_id_vec(vec : Vector2i, val : int) -> void: 
	''' get an id from the grid by a y, x vector
		NOTE: Vector should already be formatted in [y][x] '''

	id_grid[vec.x][vec.y] = val

func cellular_automata_trials(trial_threshold_values : Array[int], avoidance_ids : Array[int] = [Enums.Cell.WATER]) -> void:
	'''
		Purpose: 
			Run multiple trials of the cellular automata algorithm on a 2D grid

		Arguments: 
			trial_threshold_values: 
				An ordered array of the threshold value used for trial of the algorithm, the length of this array replaces the need for a num_trials arg
			avoidance_ids: 
				ID's which should be directly avoided by cell clumps

		Return: void
	'''

	for threshold in trial_threshold_values:
		cellular_automata(threshold, avoidance_ids)
		
func cellular_automata(threshold : int, avoidance_ids : Array[int] = []) -> void: 
	'''
		Purpose: 
			Follows the cellular automata algorithm to update the values in id_grid based on the number of neighbors a cell has w.r.t. the threshold

		Arguments: 
			threshold: 
				The threshod number of 1 neighbors such that if a cell has more, it becomes a 1, and if it has less it becomes a 0
			avoidance_ids: 
				ID's which should be directly avoided by cell clumps

		Return: void
	'''

	var new_grid : Array[Array] = []
	
	# Iterate the grid
	for y in range(height): 
		new_grid.append([])
		for x in range(width):

			# If an ID is not 0 or 1 it is ignored by the algorithm and maintains it's value
			if index(y, x) not in [Enums.Cell.VOID_SPACE_0, Enums.Cell.VOID_SPACE_1]: 
				new_grid[y].append(index(y, x))
				continue

			var num_neighbors : int = 0

			# Iterate all neighbors of (x,y)
			for n in neighbors: 
				var n_pos = Vector2i(y, x) + n
				
				# Check that n_pos is in bounds
				if not bounds_check(n_pos, Vector2i(height, width)): continue 

				# Check and handle if the ID should be avoided by cells
				if index_vec(n_pos) in avoidance_ids:
					num_neighbors += 10
					continue
				
				# Ensure the neighbor's is valid for the algorithm (This equates to any other ID being treated as VOID_SPACE_0)
				if index_vec(n_pos) not in [Enums.Cell.VOID_SPACE_0, Enums.Cell.VOID_SPACE_1]:
					continue
				
				# Update the num_neighbors counter (+1 if 1, no change if 0)
				num_neighbors += index_vec(n_pos)

			# Set the value in the new grid according to the number of neighbors and the threshold 
			new_grid[y].append(Enums.Cell.VOID_SPACE_1 if num_neighbors >= threshold else Enums.Cell.VOID_SPACE_0)
	
	id_grid = new_grid
	
func add_river(start: Vector2i, end: Vector2i, offset_probability : float) -> void:
	'''
		Purpose: 
			Adds a river to the grid
		
		Arguments: 
			start: the starting point of the river 
			end: the ending point of the river, this point may not be literally reached due to offsets
		
		Return: void
	'''
	# Validate arguments
	if offset_probability > 1.0: offset_probability = 1.0
	if offset_probability < 0.0: offset_probability = 0.0
	if not bounds_check(start, Vector2i(height, width)) or not bounds_check(end, Vector2i(height, width)):
		print_debug("Start (" + str(start) + ") or end (" + str(end) + ") of river out of boundary (" + str(Vector2i(height, width)) +")")
		push_warning("Start (" + str(start) + ") or end (" + str(end) + ") of river out of boundary (" + str(Vector2i(height, width)) +")")
	
	# Determine the number of steps and initialize variables
	var diff = end - start
	var steps = int(max(abs(diff.x), abs(diff.y)))
	var offset = 0
	
	# Iterate the steps
	for i in range(steps + 1):

		# Interpolate the position in the grid at the current step
		var t = float(i) / float(steps)
		var x = int(round(lerp(start.x, end.x, t)))
		var y = int(round(lerp(start.y, end.y, t)))
		
		# 
		if randf() < offset_probability:
			# TODO: add offset magnitude
			offset += (randi() % 3) - 1  # -1, 0, or +1
		var offset_pos : Vector2i = Vector2i(y, x + offset)
		
		# Bounds check the offset position
		if not bounds_check(offset_pos, Vector2i(height, width)): continue
		
		# TODO: Fix this if necessary
		if index_vec(offset_pos) == 0: 
			pass
			# flood_fill_solve_group(_id_grid, offset_pos, 1, 0)

		# Set the selected values to WATER
		for j in range(4):
			for k in range(4):
				# TODO: Argument for size of the cube
				if not bounds_check(offset_pos + Vector2i(j-2, k-2), Vector2i(height, width)): continue
				set_id_vec(Vector2i(j-2, k-2) + offset_pos, Enums.Cell.WATER)

	MIN_UNIQUE_ID += 1

func flood_fill(target_id : int = Enums.Cell.VOID_SPACE_0) -> void: 
	'''
		Purpose: 
			Uses the flood fill algorithm to identify differentiated regions of cells with a designated ID, and sets new ID's which are unique by region

		Arguments: 
			target_id: 
				The ID for which the algorithm will find spatially seperated regions
				Could easily be replaced by an array of ID's if this functionality becomes necessary

		Return: void
	'''
	
	# Iterate the grid
	for y in range(height): for x in range(width):
		
		# Skip if the ID is not the designated ID
		if not index(y, x) == target_id: continue

		# Use the flood_fill_solve_group algorithm to set all cells connected to this one to MIN_UNIQUE_ID
		flood_fill_solve_group(Vector2(y,x), MIN_UNIQUE_ID, target_id)

		# Update MIN_UNIQUE_ID
		MIN_UNIQUE_ID += 1

func flood_fill_solve_group(initial_pos : Vector2i, new_id : int, target_id : int = Enums.Cell.VOID_SPACE_0) -> void:
	'''
		Purpose: 
			Set all cells with an ID of 'target_id' that are spatially connected to 'initial_pos' to 'new_id'
			Solves a single group of connected cells within the larger 'flood_fill' algorithm

		Arguments: 
			initial_pos: 
				The starting point of the algorithm
			new_id: 
				The new value that all cell ID's in the group should be set to
			target_id: 
				The ID that cells must have to be added to the group 

		Return: void
	'''

	# Initialize an array to track squares that are in the group but whose neighbors have not yet been checked
	var valid_positions : Array[Vector2i] = [] 
	valid_positions.append(initial_pos)
	
	# Iterate while the array is not empty, the alternate to this is recursion but Godot struggles with recursion
	while len(valid_positions) > 0: 
		
		# Get the position from the back of the array and remove it
		var pos : Vector2i = valid_positions.pop_back()
	
		# Iterate all the positions neighbors
		for n in four_neighbors:
			var n_pos : Vector2i = pos + n 
			
			# Ensure the neighbor is in bounds of the grid and it's value is 'target_id' otherwise continue
			if not bounds_check(n_pos, Vector2i(height, width)): continue
			if not index_vec(n_pos) == target_id: continue

			# Add the neighbor to the active array and set its value to 'new_id'
			valid_positions.append(n_pos)
			set_id_vec(n_pos, new_id)

func parse_smallest_districts(num_districts : int = 15, new_cell_id : int = Enums.Cell.VOID_SPACE_1) -> void: 
	'''
		Purpose: 
			Parses the smallest districts such that only 'num_districts' districts remain
		
		Arguments: 
			id_grid: 
				The 2D grid to perform the algorithm one
			district_manager: 
				The object tracking district related data
			num_districts: 
				The number of districts to remain untouched
			new_cell_id: 
				The new ID for all parsed district cells
		
		Return: 
			Array: 'id_grid' manipulated by the algorithm
	'''

	# Ensure the district manager is initialized
	if not district_manager: init_district_manager()

	# Create a array the groups sorted by their sizes 
	var keys : Array = district_manager.get_keys_sorted_by_attribute("size_", true)

	# If there are already few enough groups return
	if len(keys) <= num_districts: return
	
	# Determine which groups to parse
	var groups_to_parse : Array = keys.slice(0, len(keys) - num_districts)
	
	# Parse the groups
	for y in range(height): for x in range(width):
		if index(y, x) in groups_to_parse:
			set_id(y, x, new_cell_id)
	
	# Remove the districts from the district manager
	for key in groups_to_parse: 
		district_manager.erase_district(key)

func expand_id_grid(autonomous_ids : Array[int] = [], expanding_ids : Array[int] = []) -> void: 
	'''
		Purpose: 
			Expand the district cells into the void space surrounding it

		Arguments: 
			autonomous_ids: 
				A list of ID's which cannot be expanded TO in the algorithm (district ID's (>3) are autonomous by default)

		Return: void
		
		Notes
			- Could add other expansion parameters such as min/max size and block/encourage expansion accordingly
			- pop_at(randi() mod len(checks)) gives a more random distribution, pop_front() is most spatially accurate to the starting point, pop_back() is extremelly biased
	'''

	# Get the array of every district cell in the grid
	var active_expansion_cells : Array[Vector2i] = get_district_cell_location_array(expanding_ids)
	
	# Assess if an active cell has any expandable neighbors (which then become active) until there are no active cells
	while len(active_expansion_cells) > 0:
		var pos : Vector2i = active_expansion_cells.pop_front()
		expand_id_grid_instance(pos, active_expansion_cells, autonomous_ids, expanding_ids)
	
func expand_id_grid_instance(pos : Vector2i, active_expansion_cells : Array, autonomous_ids : Array[int] = [], expanding_ids = []) -> void: 
	'''
		Purpose: 
			Given a position in the grid, determine if the cell can validly expand to any of its neighbors, and do so
		
		Arguments: 
			pos:
				the position of the cell trying to expand
			active_expansion_cells:
				a stack of cells that are currently being active for expanding (if a cell is expanded to it is added)
			autonomous_ids:
				an array of ID's that cannot be expanded to
			expanding_ids: 
				an array of ID's which are allowed to expand (district ID's expand by default)

		Return: void
	'''

	var cell_id : int = index_vec(pos)

	# Ensure the cell is a group node
	if not (is_district(cell_id) or cell_id in expanding_ids): return

	# Determine if any neighbors are valid for expansion
	for n in four_neighbors: 
		var n_pos : Vector2i = pos + n

		# Ensure the neighbor is within the bounds, and has an ID that is valid for expansion
		if not bounds_check(n_pos, Vector2i(height, width)): continue
		if is_district(index_vec(n_pos)) or index_vec(n_pos) in autonomous_ids: continue

		# Set the neighbors value and add it to the active expansion cells
		set_id_vec(n_pos, cell_id)
		active_expansion_cells.append(n_pos)

func get_district_cell_location_array(additional_ids : Array = []) -> Array[Vector2i]: 
	''' Returns an array of the Vector2i location of every district cell (with ID > 2) '''
	''' TODO: Seems like a district manager thing '''

	var location_array : Array[Vector2i] = []

	for y in height: for x in width:
		var pos = Vector2i(y, x)
		if is_district(index_vec(pos)) or index_vec(pos) in additional_ids: 
			location_array.append(pos)
	
	return location_array

func copy_designated_ids(from_grid : Grid, ids_to_copy : Array, autonomous_ids : Array = []) -> void:
	'''
		Purpose:
			Copy any cell with a designated ID from 'from_grid' to 'to_grid'

		Args: 
			from_grid: 
				The array to be copied from
			ids_to_copy: 
				The array of ID's which should be copied (ID's not in set will be retain their value in 'to_grid')

		Returns: void
	'''

	# Exit the function if the arrays have different shapes
	if not dimensions_match(from_grid): return

	# Iterate all cells in the 2D grid(s)
	for y in range(height): for x in range(width):
		# If the ID in 'from_grid' is in 'ids_to_copy' set the ID to that value
		if from_grid.index(y, x) in ids_to_copy and not index(y, x) in autonomous_ids: 
			set_id(y, x, from_grid.index(y, x))

func dimensions_match(other_grid : Grid) -> bool: 
	''' Returns a bool indicating if this grid and the argument 'other_grid' have matching dimensions '''

	return width == other_grid.width and height == other_grid.height

func find_unique_edge_cell_ids() -> Array:
	'''
		Purpose: 
			Determine the set of all IDs in the grid which border the edge
		
		Args: none

		Returns: 
			Array: Set of all IDs in 'id_grid' which border the edge
	'''

	var edge_cell_ids : Array = []

	# Check every value in the 2D array
	for y in range(height): for x in range(width): #TODO: iterate only edge cells, put this in a function maybe
		var cell_id : int = index(y, x)

		# Check if the cell is an edge cell and the cell's ID is not already in the set 
		if is_edge(Vector2i(y, x), Vector2i(height, width)) and not cell_id in edge_cell_ids: #TODO: probably some more intuitvie way to clear this as a set like a dict
			edge_cell_ids.append(cell_id)
	
	return edge_cell_ids

func overwrite_cells_by_id(ids_to_overwrite : Array, new_cell_id : int = Enums.Cell.VOID_SPACE_0) -> void: 
	'''
		Purpose: 
			Overwrites all cells in a 2D grid which are designated to be overwritten with a passed value

		Args: 
			id_to_overwrite: 
				The ids in 'id_grid' which will be set to the new override value
			new_cell_id: 
				The new override value

		Returns: void
	'''

	# Iterate all cells in the 2d array
	for y in range(height): for x in range(width):

		# If a cells ID is in ids_to_overwrite, set its new id as new_cell_id
		if index(y, x) in ids_to_overwrite: 
			set_id(y, x, new_cell_id)
			
func increase_array_resolution(multiplier : float = 2) -> void:
	'''	
		Purpose:
			Increases the resolution of 'id_grid' by a factor of 'multiplier' 

		Arguments:
			multiplier: the resolution multiplier

		Return: void		
	'''


	# Setup the new grid
	var id_grid_new : Array[Array] = []

	# Adjust class variables
	height = floor(multiplier * height)
	width = floor(multiplier * width) 
	square_size = square_size / multiplier

	# Iterate the size of the new grid
	for y in range(height):
		id_grid_new.append([])
		for x in range(width):
			# Add the interpolated value to the new grid
			id_grid_new[y].append(index(floor(float(y) / multiplier), floor(float(x) / multiplier)))

	# Update the grid and district manager
	id_grid = id_grid_new	
	update_district_manager()

''' TODO: Fix river issues with city border algorithm '''
func add_city_border(border_value : int = Enums.Cell.DISTRICT_WALL) -> void:
	''' Adds a border of cells with value 'border_value' between null space (2) and district space (>2) '''

	add_rough_city_border(border_value)

	validate_city_border(border_value)

func validate_city_border(border_value : int = Enums.Cell.CITY_WALL) -> void:
	'''   
		Purpose: 
			Validates the border by ensuring every cell with value 'border_value' borders null space (2)
			NOTE: Could be extended to district borders using null space arguments and small changes in logic
			
		Arguments: 
			border_value: 
				The ID value of border cells
		
		Return: void
	'''

	# Iterate the grid
	for y in range(height): for x in range(width):
		
		# Only checking for cells with value 'border_value'
		if index(y, x) != border_value: continue

		
		# Loop to ensure the cell neighbors OUTSIDE_SPACE
		var is_border : bool = false
		for n in neighbors:
			var n_pos : Vector2i = Vector2i(y, x) + n
			
			if index_vec(n_pos) == Enums.Cell.OUTSIDE_SPACE:
				is_border = true
				break
		
		# If the cell should not be a border set it to an arbitrary value that will be overwritten
		if not is_border:
			id_grid[x][y] = -1001
			
	# Expand the grid to overwrite arbitrary values
	expand_id_grid([Enums.Cell.OUTSIDE_SPACE, border_value])

func add_rough_city_border(border_value : int = Enums.Cell.CITY_WALL) -> void:
	'''
		Purpose: 
			Adds a rough city border by searching from null space cells (2) and setting as borders if they have a neighboring district cell (>2)
			NOTE: This is a rough border because it can create small interior lumps of border, these can be eliminated with the 'validate_city_border' function

		Arguments: 
			border_value: 
				The new ID for the border cells
		
		Return: void
	'''

	# Iterate the grid
	for y in range(height): for x in range(width):

		# Skip if the cell is not null space (2) or is on the edge
		if index(y, x) != Enums.Cell.OUTSIDE_SPACE: continue
		if is_edge(Vector2i(y, x), Vector2i(height, width)): continue

		# Iterate all neighbors
		for n in neighbors:	

			# If the neighbor is a district, set the cell to a border ('border_value')
			if index_vec(n + Vector2i(y, x)) > 2: 
				set_id(y, x, border_value)
				break

func toggle_border_rendering(render : bool, n_largest : int = -1) -> void:
	'''
		Purpose: 
			Toggle the 'render_border' fields of the 'n_largest' districts so that the borders will be drawn to screen
		
		Arguments: 
			render: 
				Bool for if rendering should be toggled on or off
			n_largest: 
				The number of districts that should be toggled

		Return: void
	'''

	# Select districts sorted by size (gives the ability to render the n largest if wanted)
	var sorted_keys : Array = district_manager.get_keys_sorted_by_attribute("size_", false)

	# Validate n_largest
	if n_largest == -1 or n_largest < 0 or n_largest > len(sorted_keys): n_largest = len(sorted_keys)

	for i in range(n_largest):
		var district : District = district_manager.get_district(sorted_keys[i])
		if sorted_keys[i] == Enums.Cell.WATER: continue
		district.render_border = render

func draw_bounding_box(col : Color, ss : float, line_width : float, tl : Vector2i, br : Vector2i) -> void: 
	# Convert the points to top-left and bottom-right for consistent rectangle rendering
	var top_left = Vector2(ss * min(tl.x, br.x), ss * min(tl.y, br.y))
	var bottom_right = Vector2(ss * (max(tl.x, br.x) + 1), ss * (max(tl.y, br.y) + 1))
	
	# Define the corners
	var top_right = Vector2(bottom_right.x, top_left.y)
	var bottom_left = Vector2(top_left.x, bottom_right.y)

	# Draw the four sides of the rectangle with the specified line width
	draw_line(top_left, top_right, col, line_width)  # Top side
	draw_line(top_right, bottom_right, col, line_width)  # Right side
	draw_line(bottom_right, bottom_left, col, line_width)  # Bottom side
	draw_line(bottom_left, top_left, col, line_width)  # Left side
