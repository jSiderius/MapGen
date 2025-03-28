extends "res://code/helpers.gd"

# TODO: Should grid be its own class?

func generate_random_grid(width : int, height : int, alt_edges : bool = false) -> Array: 
	''' Generates a 2D grid with dimensions 'width'x'height', each value is randomly assigned to be 0 or 1 '''
	
	var newBoolGrid : Array = []
	for x in width:
		newBoolGrid.append([])
		for y in height:
			if alt_edges and is_edge(x,y,width,height):
				newBoolGrid[x].append(1)
				continue 
			newBoolGrid[x].append(randi() % 2)
	
	return newBoolGrid 

func generate_empty_id_array(width : int, height : int) -> Array: 
	''' Generates a 2D grid with dimensions 'width'x'height', each value is 0 '''

	var newIdArray : Array = []
	for x in width: 
		newIdArray.append([])
		for y in range(height): 
			newIdArray[x].append(0)
	return newIdArray
