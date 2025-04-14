extends "res://code/helpers.gd"

class_name TileManager

var tile_splicer : TileSplicer # TODO: Get rid of loaders across files
var tile_grid : Array[Array]
var height : int
var width : int

func _init(id_grid : Grid) -> void:
    height = id_grid.height
    width = id_grid.width
    generate_tile_grid(id_grid)
    tile_splicer = TileSplicer.new(Image.load_from_file("res://tileset.png"), 16, 16, Vector2(id_grid.square_size, id_grid.square_size))


var grasses : Array[int] = [Enums.Tiles.GRASS_0, Enums.Tiles.GRASS_1, Enums.Tiles.GRASS_2, Enums.Tiles.GRASS_3, Enums.Tiles.GRASS_4, Enums.Tiles.GRASS_5, Enums.Tiles.GRASS_6, Enums.Tiles.GRASS_7, Enums.Tiles.GRASS_8]
var tiles_dict = {
    Enums.Tiles.GRASS_0 : Vector2i(0,0),
    Enums.Tiles.GRASS_1 : Vector2i(0,1),
    Enums.Tiles.GRASS_2 : Vector2i(0,2),
    Enums.Tiles.GRASS_3 : Vector2i(1,0),
    Enums.Tiles.GRASS_4 : Vector2i(1,1),
    Enums.Tiles.GRASS_5 : Vector2i(1,2),
    Enums.Tiles.GRASS_6 : Vector2i(2,0),
    Enums.Tiles.GRASS_7 : Vector2i(2,1),
    Enums.Tiles.GRASS_8 : Vector2i(2,2),
}
func generate_tile_grid(id_grid : Grid) -> void:
    for y in height: 
        tile_grid.append([])
        for x in width:
            if id_grid.index(y, x) == Enums.Cell.OUTSIDE_SPACE:
                tile_grid[y].append(grasses[randi() % len(grasses)])
            else: 
                tile_grid[y].append(Enums.Tiles.NONE)

func _draw() -> void:
    for y in height: for x in width:
        if tile_grid[y][x] == Enums.Tiles.NONE: continue

        # var callback : Dictionary = tile_splicer.get_drawing_data(tiles_dict[tile_grid[y][x]], Vector2i(y, x))
        var callback : Dictionary = tile_splicer.get_drawing_data(Vector2i(7,10), Vector2i(y, x))
        draw_texture_rect_region( tile_splicer.tileset_texture, callback["rect"], callback["src_rect"] )