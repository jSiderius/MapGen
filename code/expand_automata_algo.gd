extends "res://code/voronoi_overlay_algo.gd"

# Takes an ID array, an array of ids that are autonomous (can't be expanded into) district ids > 2 are assumed autonomous, and a bool indicating if empty space (2) should expand
# Iteratively expands the groups (>2) of the array into the null space (1) until they are maximally expanded 
func expand_id_array(idArray : Array, autonomous_ids : Array[int] = [], empty_space_expands : bool = false) -> Array:

	var next : Array = idArray
	while true: 
		idArray = next
		next = expand_id_array_instance(idArray, autonomous_ids, empty_space_expands)
		if next == idArray: break
	return idArray

# Takes an ID array, an array of ids that are autonomous (can't be expanded into), and a bool indicating if empty space (2) should expand
# Single iteration of each group node (>2) into null space (1) if possible 
func expand_id_array_instance(idArray : Array, autonomous_ids : Array[int] = [], empty_space_expands : bool = false) -> Array: 
	
	var idArrayNew : Array = idArray.duplicate(true)
	
	for x in range(len(idArray)): 
		for y in range(len(idArray[x])): 
			# Make sure the square is a group node, and has not been previously updated in this iteration
			if idArray[x][y] != idArrayNew[x][y]: continue
			if idArray[x][y] <= 2 or (idArray[x][y] == 2 and empty_space_expands): continue 
			
			# Gather the candidate expansion neighbors 
			var candidateNeighbors : Array = get_candidate_expansion_neighbors(idArrayNew, Vector2(x,y), autonomous_ids)
			
			# Determine if any candidates are valid for expansion
			for n in candidateNeighbors: 
				if is_valid_expansion_candidate(idArrayNew, Vector2(x+n[0], y+n[1]), idArrayNew[x][y], autonomous_ids, 1): 
					idArrayNew[x+n[0]][y+n[1]] = idArray[x][y]
					
	return idArrayNew

# Takes an ID array, a position vector (Vector2(x,y)), and an array of ids that are autonomous (can't be expanded into)
# Returns valid candidates under bound and value contraints
func get_candidate_expansion_neighbors(idArrayArg : Array, pos : Vector2, autonomous_ids : Array[int] = []) -> Array: 
	var candidates : Array = []

	for n in neighbors: 
		var newX : int = pos[0] + n[0]
		var newY : int = pos[1] + n[1]
		
		# Bounds check & validity check
		if not bounds_check(newX, newY, len(idArrayArg), len(idArrayArg[0])): continue 
		if idArrayArg[newX][newY] in autonomous_ids: continue 
		
		candidates.append(n)
	
	return candidates
		
# Takes an ID array, a position vector (Vector2(x,y)), an id (int), and time to live (int) representing the distance from a node that must be null space or matching id for it to expand
# Returns a bool indicating if the node can be exanded on 
func is_valid_expansion_candidate(idArray : Array, pos : Vector2, id : int, autonomous_ids : Array[int], ttl : int) -> bool: 
	if ttl == 0: return true
	var x : int = int(pos[0])
	var y : int = int(pos[1])
	
	# If the node is not valid return true
	if not bounds_check(x, y, len(idArray), len(idArray[x])): return true
	
	# If the node is node edge space or equal to the ID of the neighbor checking itself
	# if (idArray[x][y] > 2 and not idArray[x][y] == id): return false
	if (idArray[x][y] > 2 or idArray[x][y] in autonomous_ids) and not idArray[x][y] == id: return false
	
	# Check all neighbors recursively with updated ttl 
	for n in neighbors: 
		if not is_valid_expansion_candidate(idArray, Vector2(x + n[0], y + n[1]), id, autonomous_ids, ttl-1): return false
	
	return true
