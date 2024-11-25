extends Node2D

class_name Point

var cost : float 
var direction : Vector2

func _init(position : Vector2, rotation : float, cost : float = 1.0):
	self.position = position
	self.cost = cost
	self.rotation = rotation
	self.direction = Vector2(cos(rotation), sin(rotation))
	
func scale_point(scale : Vector2): 
	self.position = scale * self.position
