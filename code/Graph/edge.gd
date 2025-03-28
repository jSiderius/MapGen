extends "res://code/helpers.gd"

class_name Edge

var first : Vector2i
var second : Vector2i
var line : Vector3
var length : float

func _init(_first : Vector2i, _second : Vector2i) -> void:
	first = _first
	second = _second
	length = pow(pow(float(first.x) - float(second.x), 2) + pow(float(first.y) - float(second.y), 2) , 0.5)
	setStandardLineEquation()

func contains_vertex(vertex : Vector2i) -> bool:
	''' Returns a boolean indicating if the 'vertex' argument is equivalent to either the edges first or second vertex '''

	return (vertex == first or vertex == second)

func setStandardLineEquation():
	''' The function returns an array of floats [a, b, c] representing the standard equation of a line ( ay + bx + c = 0 ) between p1 and second '''
	
	if first.x == second.x: return [0, -1, first.x]
	var m : float = float(first.y - second.y) / float(first.x - second.x) 
	var b : float = first.y - m*first.x

	line = Vector3(1, -m, -b)
