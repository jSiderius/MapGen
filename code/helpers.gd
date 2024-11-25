extends Control

# Array of neighboring positions that can be iterated for several algorithms 
var neighbors : Array = [
		Vector2(-1,-1), Vector2(0,-1), Vector2(1,-1),
		Vector2(-1,0),                 Vector2(1,0),
		Vector2(-1,1), Vector2(0,1)  , Vector2(1,1)
	]
	
var four_neighbors : Array = [
					   Vector2(0,-1), 
		Vector2(-1,0),                 Vector2(1,0),
					   Vector2(0,1)
	]

func is_edge(x : int, y : int, boundX : int, boundY : int) -> bool:
	return x <=0 or y <= 0 or x >=boundX-1 or y >= boundY-1
	
func bounds_check(x : int, y : int, boundX : int, boundY : int):
	return x >=0 and x < boundX and y >= 0 and y < boundY
