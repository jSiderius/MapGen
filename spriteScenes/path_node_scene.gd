extends Node2D

class_name PathNode

var points : Array
var pivot_offset : Vector2
var scene : PackedScene
	
#TODO Get scale from texture if necessary
func _init(scene : PackedScene, points : Array, rotation : float, scale : float):
	self.points = points 
	self.rotation = rotation
	self.scene = scene
	
	self.scale = Vector2(scale, scale)
	for point in self.points: 
		point.scale_point(self.scale)
	
func _return_next_points(position : Vector2, orientation : Vector2):
	var positions : Array = []
	for point in points: 
		positions.append(position + point.position) 
	return positions
