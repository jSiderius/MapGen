extends "res://code/voronoi_overlay_algo.gd"

# Takes an ID array, an array of ids that are autonomous (can't be expanded into), and a bool indicating if empty space (2) should expand
# Single iteration of each group node (>2) into null space (1) if possible 
func expand_id_array(idArray : Array, autonomous_ids : Array[int] = [], empty_space_expands : bool = false, checks : Array = []) -> Array: 
	var idArrayNew : Array = idArray.duplicate(true)
	var newChecks : Array = []

	if checks == []:
		for x in range(len(idArray)): for y in range(len(idArray[x])): 
			expand_id_array_instance(idArray, idArrayNew, x, y, newChecks, autonomous_ids, empty_space_expands)
	else: 
		for check in checks: 
			expand_id_array_instance(idArray, idArrayNew, check[0], check[1], newChecks, autonomous_ids, empty_space_expands)
	
	if idArrayNew != idArray and len(newChecks) > 0: return expand_id_array(idArrayNew, autonomous_ids, empty_space_expands, newChecks)
	return idArrayNew 

func expand_id_array_instance(idArray : Array, idArrayNew : Array, x : int, y : int, checks : Array, autonomous_ids : Array[int] = [], empty_space_expands : bool = false): 
	# check_square_for_expansion(x, y, idArray, idArrayNew, newChecks, empty_space_expands, autonomous_ids)
	# Make sure the square is a group node, and has not been previously updated in this iteration
	if idArray[x][y] != idArrayNew[x][y]: return
	if idArray[x][y] <= 2 and not (idArray[x][y] == 2 and empty_space_expands): return 
	
	# Determine if any candidates are valid for expansion
	for n in neighbors: 
		var newX : int = x + n[0]
		var newY : int = y + n[1]
		if not bounds_check(newX, newY, len(idArray), len(idArray[x])): continue
		if idArray[newX][newY] in autonomous_ids: continue 

		if idArrayNew[newX][newY] == 1: 
			idArrayNew[newX][newY] = idArray[x][y]
			checks.append([newX, newY])
