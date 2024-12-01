extends "res://code/voronoi_overlay_algo.gd"


# Takes an ID array, an array of ids that are autonomous (can't be expanded into) district ids > 2 are assumed autonomous, and a bool indicating if empty space (2) should expand
# Iteratively expands the groups (>2) of the array into the null space (1) until they are maximally expanded 
func expand_id_array(idArray : Array, autonomous_ids : Array[int] = [], empty_space_expands : bool = false) -> Array:
	# var checks : Array = []
	# var next : Array = idArray
	# while true: 
	# 	idArray = next
	# 	next = expand_id_array_instance(idArray, autonomous_ids, empty_space_expands, [])
	# 	if next == idArray: break
	# 	print("loop")
	idArray = expand_id_array_instance(idArray, autonomous_ids, empty_space_expands, [])
	return idArray

# Takes an ID array, an array of ids that are autonomous (can't be expanded into), and a bool indicating if empty space (2) should expand
# Single iteration of each group node (>2) into null space (1) if possible 
func expand_id_array_instance(idArray : Array, autonomous_ids : Array[int] = [], empty_space_expands : bool = false, checks : Array = []) -> Array: 
	var idArrayNew : Array = idArray.duplicate(true)
	# var newChecks : Array = []

	# if checks == []:
	for x in range(len(idArray)): for y in range(len(idArray[x])): 
		# check_square_for_expansion(x, y, idArray, idArrayNew, newChecks, empty_space_expands, autonomous_ids)
		# Make sure the square is a group node, and has not been previously updated in this iteration
		if idArray[x][y] != idArrayNew[x][y]: continue
		if idArray[x][y] <= 2 and not (idArray[x][y] == 2 and empty_space_expands): continue
		
		# Determine if any candidates are valid for expansion
		for n in neighbors: 
			var newX : int = x + n[0]
			var newY : int = y + n[1]
			if not bounds_check(newX, newY, len(idArray), len(idArray[x])): continue
			if idArray[newX][newY] in autonomous_ids: continue 

			if idArrayNew[newX][newY] == 1: 
				idArrayNew[newX][newY] = idArray[x][y]
	
	if idArrayNew != idArray: return expand_id_array_instance(idArrayNew, autonomous_ids, empty_space_expands, checks)
	return idArrayNew 
