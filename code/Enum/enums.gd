class_name Enums

enum Cell {
    CASTLE_WALL = -16,
    DISTRICT_STAND_IN = -15,
    DISTRICT_STAND_IN_CASTLE = -14,
    DISTRICT_STAND_IN_SLUMS = -13,
    DISTRICT_STAND_IN_3 = -12,
    DISTRICT_STAND_IN_2 = -11,
    DISTRICT_STAND_IN_MARKET = -10,
    CITY_ROAD = -9,
    WATER_BORDER = -8,
    HELPER = -7,
    WATER = -6,
    BRIDGE = -5,
    DISTRICT_WALL = -4,
    CITY_WALL = -3,
    DISTRICT_CENTER = -2,
    MAJOR_ROAD = -1,
    VOID_SPACE_0 = 0,
    VOID_SPACE_1 = 1,
    OUTSIDE_SPACE = 2, 
}

enum Border {
    NORTH = 0,
    EAST = 1, 
    SOUTH = 2, 
    WEST = 3,
    ANY = 4,
}

enum GridInitType {
    EMPTY = 0,
    RANDOM = 1,
    VORONOI = 2,
}

enum NeighborsType {
    FOUR_NEIGHBORS = 0, 
    EIGHT_NEIGHBORS = 1,
}

enum Tiles {
    NONE = -1,
    GRASS_0 = 0, 
    GRASS_1 = 1,
    GRASS_2 = 2, 
    GRASS_3 = 3, 
    GRASS_4 = 4, 
    GRASS_5 = 5, 
    GRASS_6 = 6, 
    GRASS_7 = 7, 
    GRASS_8 = 8,
}