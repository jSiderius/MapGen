extends "res://code/expand_automata_algo.gd"

# Store minUniqueID globally to track ID's over the course of the program
var minUniqueID : int = 3

# Takes an id array and an int 
# Runs flood fill to identify the unique regions with a current ID 'replaced', replaces them with the minimum unique ID 
func flood_fill(idArray : Array, replaced : int = 0) -> Array: 
	
	for x in range(len(idArray)): for y in range(len(idArray[x])): 
		if not idArray[x][y] == replaced: continue 
		idArray = flood_fill_solve_group(idArray, Vector2(x,y), minUniqueID, replaced)
		minUniqueID += 1
	
	return idArray

# Takes an id array, a (x, y) location, a new ID a an ID to replace
# Replaces all nodes of value replaced_id that are adjecent to loc through other nodes of value replaced_id
func flood_fill_solve_group(idArray : Array, loc : Vector2, new_id : int, replaced_id : int = 0) -> Array:
	
	var validSquares : Array = [] 
	validSquares.append(loc)
	
	while len(validSquares) > 0: 
		var square = validSquares.pop_back()
		var x : int = square[0]
		var y : int = square[1]
		idArray[x][y] = new_id 
	
		for n in neighbors: 
			var newX : int = x + n[0]
			var newY : int = y + n[1]
			
			# Bounds check & value check
			if not bounds_check(newX, newY, idArray.size(), idArray[0].size()): continue
			if not idArray[newX][newY] == replaced_id: continue 

			validSquares.append(Vector2(newX, newY))
	
	return idArray

# Takes an ID array
# Fill's in any group of '2' (empty space) that is not connected to an edge with an ID
# This function is a fix to a consistent bug of a region generating on the inside of the city 
func flood_fill_elim_inside_terrain(idArray : Array) -> Array: 

	# Flood fill the edge group from (0,0) and replace values of '2' with '0'
	idArray = flood_fill_solve_group(idArray, Vector2(0,0), 0, 2)

	# Replace any remaining values of '2' with a new group
	# TODO: technically could be more than one group but haven't observed this 
	for x in range(len(idArray)): for y in range(len(idArray[x])): 
		if idArray[x][y] == 2: idArray[x][y] = minUniqueID
	minUniqueID += 1
	
	# Flood fill the edge group from '0' back to '2'
	idArray = flood_fill_solve_group(idArray, Vector2(0,0), 2, 0)
	return idArray

# Takes an ID array 
# Determine which nodes should be walls and update them in the array, return 
func indentify_walls(idArray) -> Array:
	for x in range(len(idArray)): for y in range(len(idArray[x])): 
		# Only checking for void (1) nodes 
		if idArray[x][y] != 1: continue

		# If any neighbor is open space (2) set at city wall (-3)
		for n in neighbors: 
			if idArray[x+n[0]][y+n[1]] == 2: 
				idArray[x][y] = -3
				break

		# Has not been set as city wall (-3) therefore must be district wall (-4)
		# if idArray[x][y] == 1: idArray[x][y] = -4

	return idArray
