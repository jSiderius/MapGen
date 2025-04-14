extends Node

class_name Cell

var possibilities : Array
var entropy : int
var neighbors : Dictionary = {}

func _init(x, y) -> void: 
	possibilities = wfcConfig.cell_edges.keys()
	entropy = len(possibilities)
	
# TODO: Types for enums
func add_neighbor(direction, cell : Cell) -> void:
	neighbors[direction] = cell
	
func get_neighbor(direction) -> Cell:
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
		weights.append(wfcConfig.cell_weights[possibility])
	
	possibilities = [possibilities[weighted_random_index(weights)]] #TODO: Taking out of the equation for not
	#possibilities = [possibilities[randi() % len(possibilities)]]
	entropy = 0

func constrain(neighbor_possibilities, direction): 
	var reduced : bool = false
	
	if entropy <= 0: return reduced
	
	# Creates an array of all possible edges facing this cell
	var connecting_edges_set : Dictionary = {}
	for possibility in neighbor_possibilities: 
		for connecting_edge in wfcConfig.edge_rules[wfcConfig.cell_edges[possibility][direction]]:
			connecting_edges_set[connecting_edge] = true

	var opposite = wfcConfig.get_opposite_direction(direction)
	
	# Remove a possibility if it's edge is not reciprocated by any possible connection in the neighboring cell	
	for i in range(possibilities.size() - 1, -1, -1): 
		if wfcConfig.cell_edges[possibilities[i]][opposite] not in connecting_edges_set: 
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
