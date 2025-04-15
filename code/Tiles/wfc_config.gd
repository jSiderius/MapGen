extends Node

# TODO: This should all be a json file

enum Dir {
	NORTH = 0,
	EAST  = 1,
	SOUTH = 2,
	WEST  = 3,
}

## Tile Types
enum TileType{
	TILE_ERROR = -1,
	TILE_DISTRICT,
	TILE_LAND,
	
	LAND_01,
	LAND_02,
	LAND_03,
	LAND_04,
	LAND_05,
	LAND_06,
	LAND_07,
	LAND_08,
	LAND_09,

	LAND_10,
	LAND_11,
	LAND_12,
	LAND_13,
	LAND_14,
	LAND_15,
	LAND_16,
	LAND_17,
	LAND_18,




	WATER,
	WATER_NW,
	WATER_W,
	WATER_SW,
	WATER_S,
	WATER_SE,
	WATER_E,
	WATER_NE,
	WATER_N,
	WATER_01,
	WATER_02,
	WATER_03,
	WATER_04,
	WATER_05,
	# WATER_06,
	WATER_07,
	WATER_08,
	# WATER_09,
	WATER_10,

	WATER_11,
	WATER_12,
	WATER_13,
	WATER_14,
	WATER_15,
	# WATER_16,
	# WATER_17,
	# WATER_18,
	# WATER_19,
	# WATER_20,
	# WATER_21,
	# WATER_22,
	# WATER_23,
	# WATER_24,
	# WATER_NO_SPRITE_1,
	# WATER_NO_SPRITE_2,
	# WATER_NO_SPRITE_3,
	# WATER_NO_SPRITE_4,

}

enum EdgeType {
	DISTRICT,
	WATER,
	LAND,
	ERROR,

	LAND_WATER_N,
	LAND_WATER_E,
	LAND_WATER_S,
	LAND_WATER_W,
	LAND_WATER_2,

	ROCK_N,
	ROCK_E,
	ROCK_S,
	ROCK_W,
	ROCK_INNER,
}


## Dictionary of all tile types and tile edges, on the directions [North, East, South, West]
const edge_rules : Dictionary = {
	EdgeType.DISTRICT : [EdgeType.DISTRICT, EdgeType.LAND, EdgeType.ERROR],
	EdgeType.WATER : [EdgeType.WATER, EdgeType.ERROR],
	EdgeType.LAND : [EdgeType.LAND, EdgeType.DISTRICT, EdgeType.ERROR],

	EdgeType.LAND_WATER_N : [EdgeType.LAND_WATER_N, EdgeType.ERROR],
	EdgeType.LAND_WATER_E : [EdgeType.LAND_WATER_E, EdgeType.ERROR],
	EdgeType.LAND_WATER_S : [EdgeType.LAND_WATER_S, EdgeType.ERROR],
	EdgeType.LAND_WATER_W : [EdgeType.LAND_WATER_W, EdgeType.ERROR],
	EdgeType.LAND_WATER_2 : [EdgeType.LAND_WATER_2, EdgeType.ERROR],

	EdgeType.ROCK_N : [EdgeType.ROCK_N, EdgeType.ERROR],
	EdgeType.ROCK_E : [EdgeType.ROCK_E, EdgeType.ERROR],
	EdgeType.ROCK_S : [EdgeType.ROCK_S, EdgeType.ERROR],
	EdgeType.ROCK_W : [EdgeType.ROCK_W, EdgeType.ERROR],
	EdgeType.ROCK_INNER : [EdgeType.ROCK_INNER, EdgeType.ERROR],

	EdgeType.ERROR : [EdgeType.DISTRICT, EdgeType.WATER, EdgeType.LAND, EdgeType.ERROR, EdgeType.LAND_WATER_N, EdgeType.LAND_WATER_E, EdgeType.LAND_WATER_S, EdgeType.LAND_WATER_W]
}

# [N, E, S, W]
const tile_edges : Dictionary = {
	TileType.TILE_ERROR : [EdgeType.ERROR, EdgeType.ERROR, EdgeType.ERROR, EdgeType.ERROR],
	TileType.TILE_DISTRICT : [EdgeType.DISTRICT, EdgeType.DISTRICT, EdgeType.DISTRICT, EdgeType.DISTRICT],
	TileType.TILE_LAND : [EdgeType.LAND, EdgeType.LAND, EdgeType.LAND, EdgeType.LAND],

	TileType.LAND_01 : [EdgeType.LAND, EdgeType.LAND, EdgeType.LAND, EdgeType.LAND],
	TileType.LAND_02 : [EdgeType.LAND, EdgeType.LAND, EdgeType.LAND, EdgeType.LAND],
	TileType.LAND_03 : [EdgeType.LAND, EdgeType.LAND, EdgeType.LAND, EdgeType.LAND],
	TileType.LAND_04 : [EdgeType.LAND, EdgeType.LAND, EdgeType.LAND, EdgeType.LAND],
	TileType.LAND_05 : [EdgeType.LAND, EdgeType.LAND, EdgeType.LAND, EdgeType.LAND],
	TileType.LAND_06 : [EdgeType.LAND, EdgeType.LAND, EdgeType.LAND, EdgeType.LAND],
	TileType.LAND_07 : [EdgeType.LAND, EdgeType.LAND, EdgeType.LAND, EdgeType.LAND],
	TileType.LAND_08 : [EdgeType.LAND, EdgeType.LAND, EdgeType.LAND, EdgeType.LAND],
	TileType.LAND_09 : [EdgeType.LAND, EdgeType.LAND, EdgeType.LAND, EdgeType.LAND],

	TileType.LAND_10 : [EdgeType.LAND, EdgeType.ROCK_N, EdgeType.ROCK_W, EdgeType.LAND],
	TileType.LAND_11 : [EdgeType.LAND, EdgeType.ROCK_N, EdgeType.LAND, EdgeType.ROCK_N],
	TileType.LAND_16 : [EdgeType.LAND, EdgeType.LAND, EdgeType.ROCK_E, EdgeType.ROCK_N],
	TileType.LAND_13 : [EdgeType.ROCK_W, EdgeType.LAND, EdgeType.ROCK_W, EdgeType.LAND],
	TileType.LAND_14 : [EdgeType.LAND, EdgeType.LAND, EdgeType.LAND, EdgeType.LAND],
	TileType.LAND_15 : [EdgeType.ROCK_E, EdgeType.LAND, EdgeType.ROCK_E, EdgeType.LAND],
	TileType.LAND_12 : [EdgeType.ROCK_W, EdgeType.ROCK_S, EdgeType.LAND, EdgeType.LAND],
	TileType.LAND_17 : [EdgeType.LAND, EdgeType.ROCK_S, EdgeType.LAND, EdgeType.ROCK_S],
	TileType.LAND_18 : [EdgeType.ROCK_E, EdgeType.LAND, EdgeType.LAND, EdgeType.ROCK_S],

	TileType.WATER : [EdgeType.WATER, EdgeType.WATER, EdgeType.WATER, EdgeType.WATER],
	TileType.WATER_NW : [EdgeType.LAND, EdgeType.LAND_WATER_N, EdgeType.LAND_WATER_W, EdgeType.LAND],
	TileType.WATER_W : [EdgeType.LAND_WATER_W, EdgeType.WATER, EdgeType.LAND_WATER_W, EdgeType.LAND],
	TileType.WATER_SW : [EdgeType.LAND_WATER_W, EdgeType.LAND_WATER_S, EdgeType.LAND, EdgeType.LAND],
	TileType.WATER_S : [EdgeType.WATER, EdgeType.LAND_WATER_S, EdgeType.LAND, EdgeType.LAND_WATER_S],
	TileType.WATER_SE : [EdgeType.LAND_WATER_E, EdgeType.LAND, EdgeType.LAND, EdgeType.LAND_WATER_S],
	TileType.WATER_E : [EdgeType.LAND_WATER_E, EdgeType.LAND, EdgeType.LAND_WATER_E, EdgeType.WATER],
	TileType.WATER_NE : [EdgeType.LAND, EdgeType.LAND, EdgeType.LAND_WATER_E, EdgeType.LAND_WATER_N],
	TileType.WATER_N : [EdgeType.LAND, EdgeType.LAND_WATER_N, EdgeType.WATER, EdgeType.LAND_WATER_N],

	TileType.WATER_01 : [EdgeType.WATER, EdgeType.WATER, EdgeType.LAND_WATER_W, EdgeType.LAND_WATER_S],
	TileType.WATER_02 : [EdgeType.WATER, EdgeType.LAND_WATER_S, EdgeType.LAND_WATER_E, EdgeType.WATER],
	TileType.WATER_03 : [EdgeType.LAND_WATER_E, EdgeType.LAND_WATER_N, EdgeType.WATER, EdgeType.WATER],
	TileType.WATER_04 : [EdgeType.LAND_WATER_W, EdgeType.WATER, EdgeType.WATER, EdgeType.LAND_WATER_N],
	TileType.WATER_05 : [EdgeType.LAND, EdgeType.LAND, EdgeType.LAND_WATER_2, EdgeType.LAND],
	# TileType.WATER_06 : [EdgeType.LAND_WATER_2, EdgeType.LAND, EdgeType.LAND_WATER_2, EdgeType.LAND],
	TileType.WATER_07 : [EdgeType.LAND_WATER_2, EdgeType.LAND, EdgeType.LAND, EdgeType.LAND],
	TileType.WATER_08 : [EdgeType.LAND, EdgeType.LAND_WATER_2, EdgeType.LAND, EdgeType.LAND],
	# TileType.WATER_09 : [EdgeType.LAND, EdgeType.LAND_WATER_2, EdgeType.LAND, EdgeType.LAND_WATER_2],
	TileType.WATER_10 : [EdgeType.LAND, EdgeType.LAND, EdgeType.LAND, EdgeType.LAND_WATER_2],

	TileType.WATER_11 : [EdgeType.LAND_WATER_2, EdgeType.LAND_WATER_N, EdgeType.WATER, EdgeType.LAND_WATER_N],
	TileType.WATER_12 : [EdgeType.WATER, EdgeType.LAND_WATER_S, EdgeType.LAND_WATER_2, EdgeType.LAND_WATER_S],
	TileType.WATER_13 : [EdgeType.LAND_WATER_E, EdgeType.LAND_WATER_2, EdgeType.LAND_WATER_E, EdgeType.WATER],
	TileType.WATER_14 : [EdgeType.LAND_WATER_W, EdgeType.WATER, EdgeType.LAND_WATER_W, EdgeType.LAND_WATER_2],
	TileType.WATER_15 : [EdgeType.WATER, EdgeType.WATER, EdgeType.WATER, EdgeType.WATER],
	# TileType.WATER_16 : [EdgeType.LAND_WATER_2, EdgeType.LAND_WATER_2, EdgeType.LAND_WATER_2, EdgeType.LAND_WATER_2],
	# TileType.WATER_17 : [EdgeType.LAND, EdgeType.LAND_WATER_2, EdgeType.LAND_WATER_2, EdgeType.LAND_WATER_2],
	# TileType.WATER_18 : [EdgeType.LAND, EdgeType.LAND, EdgeType.LAND_WATER_2, EdgeType.LAND_WATER_2],
	# TileType.WATER_19 : [EdgeType.LAND_WATER_2, EdgeType.LAND_WATER_2, EdgeType.LAND_WATER_2, EdgeType.LAND],
	# TileType.WATER_20 : [EdgeType.LAND_WATER_2, EdgeType.LAND_WATER_2, EdgeType.LAND, EdgeType.LAND],
	# TileType.WATER_21 : [EdgeType.LAND_WATER_2, EdgeType.LAND_WATER_2, EdgeType.LAND, EdgeType.LAND_WATER_2],
	# TileType.WATER_22 : [EdgeType.LAND_WATER_2, EdgeType.LAND, EdgeType.LAND, EdgeType.LAND_WATER_2],
	# TileType.WATER_23 : [EdgeType.LAND_WATER_2, EdgeType.LAND, EdgeType.LAND_WATER_2, EdgeType.LAND_WATER_2],
	# TileType.WATER_24 : [EdgeType.LAND, EdgeType.LAND, EdgeType.LAND_WATER_2, EdgeType.LAND_WATER_2],
	# TileType.WATER_NO_SPRITE_1 : [EdgeType.LAND_WATER_2, EdgeType.LAND_WATER_2, EdgeType.LAND_WATER_2, EdgeType.LAND_WATER_2],
	# TileType.WATER_NO_SPRITE_2 : [EdgeType.LAND_WATER_2, EdgeType.LAND_WATER_2, EdgeType.LAND_WATER_2, EdgeType.LAND_WATER_2],
	# TileType.WATER_NO_SPRITE_3 : [EdgeType.LAND_WATER_2, EdgeType.LAND_WATER_2, EdgeType.LAND_WATER_2, EdgeType.LAND_WATER_2],
	# TileType.WATER_NO_SPRITE_4 : [EdgeType.LAND_WATER_2, EdgeType.LAND_WATER_2, EdgeType.LAND_WATER_2, EdgeType.LAND_WATER_2],
}

const tile_weights : Dictionary = {
	TileType.TILE_ERROR : 0,
	TileType.TILE_DISTRICT : 10,
	TileType.TILE_LAND : 100,
	
	TileType.LAND_01 : 60,
	TileType.LAND_02 : 10,
	TileType.LAND_03 : 10,
	TileType.LAND_04 : 10,
	TileType.LAND_05 : 10,
	TileType.LAND_06 : 10,
	TileType.LAND_07 : 10,
	TileType.LAND_08 : 10,
	TileType.LAND_09 : 10,

	TileType.LAND_10 : 5,
	TileType.LAND_11 : 5,
	TileType.LAND_12 : 5,
	TileType.LAND_13 : 5,
	TileType.LAND_14 : 5,
	TileType.LAND_15 : 5,
	TileType.LAND_16 : 5,
	TileType.LAND_17 : 5,
	TileType.LAND_18 : 5,

	TileType.WATER : 100,
	TileType.WATER_NW : 1,
	TileType.WATER_W : 1,
	TileType.WATER_SW : 1,
	TileType.WATER_S : 1,
	TileType.WATER_SE : 1,
	TileType.WATER_E : 1,
	TileType.WATER_NE : 1,
	TileType.WATER_N : 1,

	TileType.WATER_01 : 1,
	TileType.WATER_02 : 1,
	TileType.WATER_03 : 1,
	TileType.WATER_04 : 1,

	TileType.WATER_05 : 0,
	# TileType.WATER_06 : 0,
	TileType.WATER_07 : 0,
	TileType.WATER_08 : 0,
	# TileType.WATER_09 : 0,
	TileType.WATER_10 : 0,

	TileType.WATER_11 : 0,
	TileType.WATER_12 : 0,
	TileType.WATER_13 : 0,
	TileType.WATER_14 : 0,
	TileType.WATER_15 : 10,
# 	TileType.WATER_16 : 0,
# 	TileType.WATER_17 : 0,
# 	TileType.WATER_18 : 0,
# 	TileType.WATER_19 : 0,
# 	TileType.WATER_20 : 0,
# 	TileType.WATER_21 : 0,
# 	TileType.WATER_22 : 0,
# 	TileType.WATER_23 : 0,
# 	TileType.WATER_24 : 0,
	# TileType.WATER_NO_SPRITE_1 : 1,
	# TileType.WATER_NO_SPRITE_2 : 1,
	# TileType.WATER_NO_SPRITE_3 : 1,
	# TileType.WATER_NO_SPRITE_4 : 1,
}

const  tile_vector : Dictionary = {
	TileType.TILE_ERROR : Vector2(22, 5),

	TileType.TILE_DISTRICT : Vector2(22, 4),
	# TileType.TILE_WATER : Vector2(21, 5),
	TileType.TILE_LAND : Vector2(21, 4),

	TileType.LAND_01 : Vector2(0, 0),
	TileType.LAND_02 : Vector2(0, 1),
	TileType.LAND_03 : Vector2(0, 2),
	TileType.LAND_04 : Vector2(1, 0),
	TileType.LAND_05 : Vector2(1, 1),
	TileType.LAND_06 : Vector2(1, 2),
	TileType.LAND_07 : Vector2(2, 0),
	TileType.LAND_08 : Vector2(2, 1),
	TileType.LAND_09 : Vector2(2, 2),

	TileType.LAND_10 : Vector2i(0, 4),
	TileType.LAND_11 : Vector2i(1, 4),
	TileType.LAND_16 : Vector2i(2, 4),
	TileType.LAND_13 : Vector2i(0, 5),
	TileType.LAND_14 : Vector2i(1, 5),
	TileType.LAND_15 : Vector2i(2, 5),
	TileType.LAND_12 : Vector2i(0, 6),
	TileType.LAND_17 : Vector2i(1, 6),
	TileType.LAND_18 : Vector2i(2, 6),

	TileType.WATER : Vector2(8, 11),
	TileType.WATER_NW : Vector2(7, 10),
	TileType.WATER_W : Vector2(7, 11),
	TileType.WATER_SW : Vector2(7, 12),
	TileType.WATER_S : Vector2(8, 12),
	TileType.WATER_SE : Vector2(9, 12),
	TileType.WATER_E : Vector2(9, 11),
	TileType.WATER_NE : Vector2(9, 10),
	TileType.WATER_N : Vector2(8, 10),

	TileType.WATER_01 : Vector2(10, 11),
	TileType.WATER_02 : Vector2(11, 11),
	TileType.WATER_03 : Vector2(11, 10),
	TileType.WATER_04 : Vector2(10, 10),
	TileType.WATER_05 : Vector2(0, 10),
	# TileType.WATER_06 : Vector2(0, 11),
	TileType.WATER_07 : Vector2(0, 12),
	TileType.WATER_08 : Vector2(1,13),
	# TileType.WATER_09 : Vector2(2, 13),
	TileType.WATER_10 : Vector2(3,13),

	TileType.WATER_11 : Vector2(5, 10),
	TileType.WATER_12 : Vector2(5, 12),
	TileType.WATER_13 : Vector2(6, 11),
	TileType.WATER_14 : Vector2(4, 11),
	TileType.WATER_15 : Vector2(5, 11),
	# TileType.WATER_16 : Vector2(2, 11),
	# TileType.WATER_17 : Vector2(2, 10),
	# TileType.WATER_18 : Vector2(1, 10),
	# TileType.WATER_19 : Vector2(1, 11),
	# TileType.WATER_20 : Vector2(1, 12),
	# TileType.WATER_21 : Vector2(2, 12),
	# TileType.WATER_22 : Vector2(3, 12),
	# TileType.WATER_23 : Vector2(3, 11),
	# TileType.WATER_24 : Vector2(3, 10),
	# TileType.WATER_NO_SPRITE_1 : Vector2(22, 4),
	# TileType.WATER_NO_SPRITE_2 : Vector2(22, 4),
	# TileType.WATER_NO_SPRITE_3 : Vector2(22, 4),
	# TileType.WATER_NO_SPRITE_4 : Vector2(22, 4),
}

const priority_options = [TileType.WATER, TileType.WATER_15]

const  cell_to_tile_options : Dictionary = {
	Enums.Cell.DISTRICT_STAND_IN : [TileType.TILE_DISTRICT],
	Enums.Cell.WATER_BORDER : 
		[
					TileType.WATER_NW, 
					TileType.WATER_W, 
					TileType.WATER_SW, 
					TileType.WATER_S, 
					TileType.WATER_SE, 
					TileType.WATER_E, 
					TileType.WATER_NE, 
					TileType.WATER_N,
					TileType.WATER_01, 
					TileType.WATER_02, 
					TileType.WATER_03, 
					TileType.WATER_04, 
					TileType.WATER_05, 
					# TileType.WATER_06, 
					TileType.WATER_07, 
					TileType.WATER_08, 
					# TileType.WATER_09, 
					TileType.WATER_10, 
						
					TileType.WATER_11, 
					TileType.WATER_12, 
					TileType.WATER_13, 
					TileType.WATER_14, 
						
					# TileType.WATER_NO_SPRITE_1, 
					# TileType.WATER_NO_SPRITE_2, 
					# TileType.WATER_NO_SPRITE_3, 
					# TileType.WATER_NO_SPRITE_4,
					],
					# TileType.WATER_16, 
					# TileType.WATER_17, 
					# TileType.WATER_18, 
					# TileType.WATER_19, 
					# TileType.WATER_20, 
					# TileType.WATER_21, 
					# TileType.WATER_22, 
					# TileType.WATER_23, 
					# TileType.WATER_24,
	Enums.Cell.WATER : [
					TileType.WATER, 
					# TileType.WATER_15, 
					TileType.WATER_01, 
					TileType.WATER_02, 
					TileType.WATER_03, 
					TileType.WATER_04,
					TileType.WATER_11, 
					TileType.WATER_12, 
					TileType.WATER_13, 
					TileType.WATER_14, 
	],
	# Enums.Cell.DISTRICT_WALL : [],
	# Enums.Cell.CITY_WALL : [],
	# Enums.Cell.DISTRICT_CENTER : [],
	Enums.Cell.MAJOR_ROAD : [TileType.TILE_DISTRICT],
	# Enums.Cell.VOID_SPACE_0: [],
	# Enums.Cell.VOID_SPACE_1: [],
	Enums.Cell.OUTSIDE_SPACE : [
				TileType.LAND_01,
				TileType.LAND_02,
				TileType.LAND_03,
				TileType.LAND_04,
				TileType.LAND_05,
				TileType.LAND_06,
				TileType.LAND_07,
				TileType.LAND_08,
				TileType.LAND_09,
				TileType.LAND_10,
				TileType.LAND_11,
				TileType.LAND_12,
				TileType.LAND_13,
				# TileType.LAND_14,
				TileType.LAND_15,
				TileType.LAND_16,
				TileType.LAND_17,
				TileType.LAND_18,
	],
}

func get_opposite_direction(direction : int) -> int:
	match direction: 
		Dir.NORTH: return Dir.SOUTH
		Dir.SOUTH: return Dir.NORTH
		Dir.EAST: return Dir.WEST
		Dir.WEST: return Dir.EAST
		_: 
			print_debug("Bad value")
			return -1


enum OverlayTiles {
	TREE_1, 
	TREE_2,
}

const overlay_vector : Dictionary = {
	OverlayTiles.TREE_1 : Vector2(0,29),
	OverlayTiles.TREE_2 : Vector2(0,30),
}

const valid_for_overlay : Array[int] = [
				TileType.LAND_01,
				TileType.LAND_02,
				TileType.LAND_03,
				TileType.LAND_04,
				TileType.LAND_05,
				TileType.LAND_06,
				TileType.LAND_07,
				TileType.LAND_08,
				TileType.LAND_09,
]
