extends "res://code/helpers.gd"

class_name Tile

var possibilities : Array
var entropy : int
var tile_neighbors : Dictionary = {}
var cell_id : int
var overlay : int

# TODO: x, y necessary ? 
func _init(_cell_id : int) -> void:
	cell_id = _cell_id 
	if is_district(cell_id): 
		cell_id = Enums.Cell.DISTRICT_STAND_IN

	# possibilities = wfcConfig.tile_edges.keys()
	if cell_id in wfcConfig.cell_to_tile_options: 
		possibilities = wfcConfig.cell_to_tile_options[cell_id].duplicate()
	else:
		possibilities = wfcConfig.cell_to_tile_options[Enums.Cell.DISTRICT_STAND_IN].duplicate()

	entropy = len(possibilities)

	if entropy == 1: entropy = 0
	
# TODO: Types for enums
func add_neighbor(direction, tile : Tile) -> void:
	tile_neighbors[direction] = tile

func add_overlay() -> void:
	var overlays = wfcConfig.OverlayTiles.values()
	var weights : Array[float] = []
	for o in overlays:
		weights.append(wfcConfig.overlay_weights[o])

	overlay = overlays[weighted_random_index(weights)]

func get_neighbor(direction) -> Tile:
	return tile_neighbors[direction]
	
func get_directions() -> Array: 
	return tile_neighbors.keys()
	
func get_possibilities() -> Array: 
	return possibilities

func get_entropy() -> int:
	return entropy

func has_priority_options() -> bool:
	for possibility in possibilities: 
		if possibility in wfcConfig.priority_options: return true
	return false

func collapse():
	var weights : Array[float] = []
	for possibility in possibilities:
		weights.append(wfcConfig.tile_weights[possibility])
	
	possibilities = [possibilities[weighted_random_index(weights)]]
	# possibilities = [possibilities[randi() % len(possibilities)]]
	entropy = 0

	if possibilities[0] in wfcConfig.valid_for_overlay and randf() <= wfcConfig.overlay_chance:
		add_overlay()

func get_tile_type():
	if len(possibilities) == 0:
		return wfcConfig.TileType.TILE_ERROR
	
	return possibilities[0]

func constrain(neighbor_possibilities, direction): 
	var reduced : bool = false
	
	if entropy <= 0: return reduced

	# Creates an array of all possible edges facing this tile
	var connecting_edges_set : Dictionary = {}
	for possibility in neighbor_possibilities: 
		for connecting_edge in wfcConfig.edge_rules[wfcConfig.tile_edges[possibility][direction]]:
			connecting_edges_set[connecting_edge] = true

	var opposite = wfcConfig.get_opposite_direction(direction)
	
	
	# Remove a possibility if it's edge is not reciprocated by any possible connection in the neighboring tile	
	for i in range(possibilities.size() - 1, -1, -1): 
		if wfcConfig.tile_edges[possibilities[i]][opposite] not in connecting_edges_set: 
			possibilities.remove_at(i)
			reduced = true
	
			
	if len(possibilities) == 0: 
		possibilities = [wfcConfig.TileType.TILE_ERROR]
		print_debug("REMOVAL FAILURE: Neighbor Possibilities: ", neighbor_possibilities)

	entropy = len(possibilities) if len(possibilities) > 1 else 0

	return reduced

func weighted_random_index(weights : Array[float]) -> int:
	
	# Calculate the sum of the weights
	var total : float = 0.0
	for weight in weights:
		total += weight
	
	# Randomly create a float less than or equal to the total weighting 
	var rnd : float = randf() * total
	
	# Select an index according the the float	
	var accum = 0.0
	for i in range(len(weights)):
		accum += weights[i]
		if rnd < accum:
			return i
			
	return len(weights) - 1  # Fallback

# TODO: Add recursive fail safes if necessary
