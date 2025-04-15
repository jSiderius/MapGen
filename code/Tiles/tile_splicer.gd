extends "res://code/helpers.gd"

class_name TileSplicer

var tileset_texture : Texture
var tileset_image : Image
var tile_width : float
var tile_height : float
var rect_size : Vector2
var square_size_w : float
var square_size_h : float

func _init(_image: Image, _tile_width: float, _tile_height: float, _rect_size : Vector2) -> void:
	tileset_image = _image
	tileset_texture = ImageTexture.create_from_image(tileset_image)
	tile_width = _tile_width
	tile_height = _tile_height
	rect_size = _rect_size

func get_drawing_data(tile_vec : Vector2, screen_pos : Vector2i) -> Dictionary:
	''' Returns data to be used by draw_texture_rect_region ''' 

	var return_dict: Dictionary = {}

	var src_pos = tile_vec * Vector2(tile_width, tile_height) + Vector2(0.2, 0.2)
	var src_size = Vector2(tile_width, tile_height) - Vector2(0.4, 0.4)
	
	return_dict["src_rect"] = Rect2(src_pos, src_size)
	return_dict["rect"] = Rect2(Vector2(screen_pos[1] * rect_size[1], screen_pos[0] * rect_size[0]), rect_size)

	return return_dict
