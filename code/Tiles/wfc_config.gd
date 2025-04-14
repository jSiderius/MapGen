#
#SPRITESHEET_PATH = "../../Assets/SpriteSheets/PunyWorld/punyworld-overworld-tileset.png"
#
## worls size in tiles
#WORLD_X = 60
#WORLD_Y = 34
#
## Spritesheet tile size (original), and upscale factor
#TILESIZE = 16
#SCALETILE = 2
#

extends Node
# Directions
var NORTH = 0
var EAST  = 1
var SOUTH = 2
var WEST  = 3
#
#
## Tile Types
var TILE_ERROR = -1
var TILE_COAST = 0
var TILE_OCEAN = 1
var TILE_LAND = 2
var TILE_TEST = 3

# Tile Edges
var COAST = 0
var OCEAN = 1
var LAND = 2
var TEST = 3

## Dictionary of all tile types and tile edges, on the directions [North, East, South, West]
var edge_rules : Dictionary = {
	COAST : [COAST, OCEAN, LAND],
	OCEAN : [OCEAN, COAST],
	LAND : [LAND, COAST],
}

var cell_edges : Dictionary = {
	TILE_COAST : [COAST, COAST, COAST, COAST],
	TILE_OCEAN : [OCEAN, OCEAN, OCEAN, OCEAN],
	TILE_LAND : [LAND, LAND, LAND, LAND],
}

var cell_weights : Dictionary = {
	TILE_COAST : 10,
	TILE_OCEAN : 100, 
	TILE_LAND : 100,
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
