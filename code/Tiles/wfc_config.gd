extends Node

# Directions TODO switch to enum
var NORTH = 0
var EAST  = 1
var SOUTH = 2
var WEST  = 3

## Tile Types
var TILE_ERROR = -1
var TILE_COAST = 0
var TILE_OCEAN = 1
var TILE_LAND = 2

# Tile Edges
var COAST = 0
var OCEAN = 1
var LAND = 2

## Dictionary of all tile types and tile edges, on the directions [North, East, South, West]
var edge_rules : Dictionary = {
	COAST : [COAST, OCEAN, LAND],
	OCEAN : [OCEAN, COAST],
	LAND : [LAND, COAST],
}

var tile_edges : Dictionary = {
	TILE_COAST : [COAST, COAST, COAST, COAST],
	TILE_OCEAN : [OCEAN, OCEAN, OCEAN, OCEAN],
	TILE_LAND : [LAND, LAND, LAND, LAND],
}

var tile_weights : Dictionary = {
	TILE_COAST : 10,
	TILE_OCEAN : 100, 
	TILE_LAND : 100,
}

var tile_vector : Dictionary = {
	# TILE_COAST : Vector2(26, 4),
	# TILE_OCEAN : Vector2(25, 5),
	# TILE_LAND : Vector2(25, 4),
	TILE_COAST : Vector2(22, 4),
	TILE_OCEAN : Vector2(21, 5),
	TILE_LAND : Vector2(21, 4),
}

func get_opposite_direction(direction : int) -> int:
	match direction: 
		NORTH: return SOUTH
		SOUTH: return NORTH
		EAST: return WEST
		WEST: return EAST
		_: 
			print_debug("Bad value")
			return -1
