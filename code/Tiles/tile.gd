extends Node

class_name Tile

var possibilities : Array
var entropy : int
var neighbors : Dictionary = {}

# TODO: x, y necessary ? 
func _init(x : int, y : int, cell_id : int) -> void: 
	possibilities = wfcConfig.tile_edges.keys()
	entropy = len(possibilities)
	
# TODO: Types for enums
func add_neighbor(direction, tile : Tile) -> void:
	neighbors[direction] = tile
	
func get_neighbor(direction) -> Tile:
	return neighbors[direction]
	
func get_directions() -> Array: 
	return neighbors.keys()
	
func get_possibilities() -> Array: 
	return possibilities

func get_entropy() -> int:
	return entropy

func collapse():
	var weights : Array[float] = []
	for possibility in possibilities:
		weights.append(wfcConfig.tile_weights[possibility])
	
	possibilities = [possibilities[weighted_random_index(weights)]]
	entropy = 0

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
	
			
	if len(possibilities) == 0: print_debug("REMOVAL FAILURE")

	self.entropy = len(possibilities)

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
