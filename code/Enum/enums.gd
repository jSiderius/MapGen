class_name Enums

enum Cell {
    HELPER = -7,
    WATER = -6,

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
    SOUTH = 1, 
    EAST = 2, 
    WEST = 3,
}

enum GridInitType {
    EMPTY = 0,
    RANDOM = 1,
    VORONOI = 2,
}