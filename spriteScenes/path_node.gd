extends Sprite2D

class_name PathNode

var points : Array
var pivot_offset : Vector2

func _init(texture : Texture2D, points : Array, rotation : float, squareSize : float, pivot_offset : Vector2):
	self.points = points 
	self.texture = texture
	self.rotation = rotation
	self.scale = Vector2(squareSize / texture.get_width(), squareSize / texture.get_height())
	self.pivot_offset = pivot_offset * scale
	
	for point in self.points: 
		point.scale_point(self.scale)
	
func _return_next_points(position : Vector2, orientation : Vector2):
	var positions : Array = []
	for point in points: 
		positions.append(position + point.position) 
	return positions
