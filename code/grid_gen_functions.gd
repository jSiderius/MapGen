extends "res://code/helpers.gd"

# Generates a random idArray where each value is randomly 0 or 1
func generate_random_grid(width : int, height : int, alt_edges : bool = false) -> Array: 
	var newBoolGrid : Array = []
	for x in width:
		newBoolGrid.append([])
		for y in height:
			if alt_edges and is_edge(x,y,width,height):
				newBoolGrid[x].append(1)
				continue 
			newBoolGrid[x].append(randi() % 2)
	
	return newBoolGrid 

# Generates an idArray with values of all 0
func generate_empty_id_array(width : int, height : int) -> Array: 
	var newIdArray : Array = []
	for x in width: 
		newIdArray.append([])
		for y in range(height): 
			newIdArray[x].append(0)
	return newIdArray

# Converts a boolArray to an idArray (false -> 0, true -> 1)
func bool_array_to_id_array(boolArray : Array) -> Array: 
	var idArrayNew : Array = []
	for x in range(len(boolArray)):
		idArrayNew.append([])
		for y in range(len(boolArray[x])): 
			idArrayNew[x].append(1 if boolArray[x][y] else 0)
	
	return idArrayNew

# Converts an idArray to a bool array (1 -> false, 0 -> true) 
# Used in Voronoi bool map
# Not sure the reasoning for the conversion but not touching it because I don't currently need / use this function 
func id_array_to_bool_array(idArrayArg : Array) -> Array: 
	var boolArrayNew : Array = [] 
	for x in range(len(idArrayArg)): 
		boolArrayNew.append([])
		for y in range(len(idArrayArg[x])):
			boolArrayNew[x].append(false if idArrayArg[x][y] == 1 else true)
	return boolArrayNew

# Set the value of all edge squares in and idArray to 2
# DEPRECIATED
func id_array_create_edge_group(idArrayArg : Array) -> Array: 
	for x in range(len(idArrayArg)): for y in range(len(idArrayArg[x])): 
		if is_edge(x,y,len(idArrayArg),len(idArrayArg[x])): 
			idArrayArg[x][y] = 2
	return idArrayArg

