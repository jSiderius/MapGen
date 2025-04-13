extends "res://code/helpers.gd"


# export variables
@export var debug : bool = true
@export var square_size : float = 10.0

# global variables
var grid_loader : Resource = preload("res://code/Grid/grid.gd")
var id_grid : Grid
var secondary_grid_debug : Grid

var river_start : Vector2i
var river_end : Vector2i

func _ready() -> void:

	# Seed randomness
	var rng = RandomNumberGenerator.new()
	rng.randomize()

	# Adjust screen size
	var screen_size : Vector2 = get_viewport_rect().size
	var w_h : Vector2i = find_width_and_height(screen_size, square_size)
	screen_size = update_screen_size(w_h.x, w_h.y, square_size) 

	# Begin algorithms 
	if debug: await redraw_and_pause(0, 0.0, false)

	# Fill the initial grid
	id_grid = grid_loader.new(w_h.x, w_h.y, square_size, Enums.GridInitType.RANDOM)
	add_child(id_grid)
	if debug: await redraw_and_pause(1, 0.1)

	# Run trials of cellular automata on the remaining {0,1} noise values 
	id_grid.cellular_automata_trials([3])
	if debug: await redraw_and_pause(2, 0.2)

	river_start = random_edge_position(id_grid.height, id_grid.width)
	river_end = random_edge_position(id_grid.height, id_grid.width, river_start)
	id_grid.add_river(river_start, river_end, 0.8, 2, 4)
	if debug: await redraw_and_pause(3, 0.2)

	id_grid.cellular_automata_trials([6])
	if debug: await redraw_and_pause(4, 0.2)

	# id_grid.add_major_roads()
	if debug: await redraw_and_pause(5, 0.2)

	# Run flood fill to differentiate groups
	id_grid.flood_fill()
	if debug: await redraw_and_pause(6, 0.2)

	# Parse out the smallest groups 
	id_grid.parse_smallest_districts(75)
	if debug: await redraw_and_pause(7, 0.2)

	# Expand groups into null space (1)
	id_grid.expand_id_grid([Enums.Cell.OUTSIDE_SPACE, Enums.Cell.MAJOR_ROAD, Enums.Cell.WATER], [Enums.Cell.WATER])
	if debug: await redraw_and_pause(8, 0.2)

	# Clear the grid with the exception of water
	id_grid.clear_grid([Enums.Cell.WATER], Enums.Cell.VOID_SPACE_1)
	if debug: await redraw_and_pause(9, 0.2)

	# Create a voronoi cell map, and clear cells from id_grid that correspond to voronoi edge cells, creating a city outline
	var voronoi_id_grid : Grid = grid_loader.new(id_grid.width, id_grid.height, square_size, Enums.GridInitType.VORONOI, {})
	# secondary_grid_debug = voronoi_id_grid
	# if debug: await redraw_and_pause(10, 2.0)

	var edge_cell_ids = voronoi_id_grid.find_unique_edge_cell_ids()
	voronoi_id_grid.overwrite_cells_by_id(edge_cell_ids, Enums.Cell.OUTSIDE_SPACE)
	id_grid.copy_designated_ids(voronoi_id_grid, [Enums.Cell.OUTSIDE_SPACE], [Enums.Cell.WATER, Enums.Cell.MAJOR_ROAD])
	if debug: await redraw_and_pause(10, 0.2)
	
	# Eliminate groups of city space less than some threshold percentage of total city space
	id_grid.flood_fill_elim_annexed_space(0.25, Enums.Cell.VOID_SPACE_1, Enums.Cell.OUTSIDE_SPACE)
	if debug: await redraw_and_pause(11, 0.2)

	# Reintigrate noise
	id_grid.clear_grid_to_noise([Enums.Cell.WATER, Enums.Cell.OUTSIDE_SPACE], [Enums.Cell.VOID_SPACE_0, Enums.Cell.VOID_SPACE_1])
	if debug: await redraw_and_pause(12, 0.2)

	# Add roads
	id_grid.add_major_roads()
	if debug: await redraw_and_pause(13, 0.2)

	id_grid.cellular_automata_trials([3, 6])
	if debug: await redraw_and_pause(14, 0.2)
	
	id_grid.flood_fill()
	if debug: await redraw_and_pause(15, 0.2)

	# Parse out the smallest groups 
	id_grid.parse_smallest_districts(75)
	if debug: await redraw_and_pause(16, 0.2)

	# Expand groups into null space (1)
	id_grid.expand_id_grid([Enums.Cell.OUTSIDE_SPACE, Enums.Cell.MAJOR_ROAD, Enums.Cell.WATER], [Enums.Cell.WATER])
	if debug: await redraw_and_pause(17, 0.2)

	id_grid.flood_fill_elim_inside_terrain()
	if debug: await redraw_and_pause(18, 0.2)
	
	# # Increase the array resolution and add a new (thinner) border
	# id_grid.increase_array_resolution(4.0) # TODO: Just draw the walls smaller
	id_grid.add_city_border(Enums.Cell.DISTRICT_WALL) 
	if debug: await redraw_and_pause(19, 0.2)

	id_grid.update_district_manager()
	id_grid.toggle_border_rendering(true)

	if debug: await redraw_and_pause(20, 0.2)

func _draw() -> void: 
	if secondary_grid_debug: 
		secondary_grid_debug.queue_redraw()
		return
	if id_grid: id_grid.queue_redraw()


# TODO: Make Model View Controller more explicit
