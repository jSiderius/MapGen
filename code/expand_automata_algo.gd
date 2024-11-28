extends "res://code/voronoi_overlay_algo.gd"

# Takes an ID array
# Iteratively expands the groups (>2) of the array into the null space (1) until they are maximally expanded 
func expand_id_array(idArray : Array) -> Array:
	var next : Array = idArray
	while true: 
		idArray = next
		next = expand_id_array_instance(idArray)
		if next == idArray: break
	return idArray

# Takes an ID array
# Single iteration of each group node (>2) into null space (1) if possible 
# TODO: Algorithm may be more effecient for each expansion to determine its neareast region, probably doesn't matter though
func expand_id_array_instance(idArrayArg : Array) -> Array: 
	
	var idArrayNew : Array = idArrayArg 
	
	for x in range(len(idArrayArg)): for y in range(len(idArrayArg[x])): 
		# Make sure the square is a group node, and has not been previously updated in this iteration
		if idArrayArg[x][y] != idArrayNew[x][y] or idArrayArg[x][y] < 2: continue 
		
		# Gather the candidate expansion neighbors 
		var candidateNeighbors : Array = get_candidate_expansion_neighbors(idArrayNew, x, y)
		
		# Determine if any candidates are valid for expansion
		for n in candidateNeighbors: 
			if is_valid_expansion_candidate(idArrayNew, x+n[0], y+n[1], idArrayNew[x][y], 2): 
				idArrayNew[x+n[0]][y+n[1]] = idArrayArg[x][y]
	return idArrayNew

# Takes an ID array, a position (x (int), y (int)), a bool for whether ID'd groups can be expanded to 
# Returns valid candidates under bound and value contraints
# TODO: should this be combined with is_valid_expansion_candidate ? 
func get_candidate_expansion_neighbors(idArrayArg : Array, x : int, y : int, autonomousIds : bool = true) -> Array: 
	var candidates : Array = []

	for n in neighbors: 
		var newX : int = x + n[0]
		var newY : int = y + n[1]
		
		# Bounds check & validity check
		if not bounds_check(newX, newY, len(idArrayArg), len(idArrayArg[0])): continue 
		if (autonomousIds and idArrayArg[newX][newY] >= 2) or idArrayArg[newX][newY]==2: continue 
		
		candidates.append(n)
	
	return candidates
		
# Takes an ID array, a position (x (int), y (int)), an id (int), and time to live (int) representing the distance from a node that must be null space or matching id for it to expand
# Returns a bool indicating if the node can be exanded on 
func is_valid_expansion_candidate(idArray : Array, x : int, y : int, id : int, ttl : int) -> bool: 
	if ttl == 0: return true
	ttl -= 1
	
	# If the node is not valid return true
	if not bounds_check(x, y, len(idArray), len(idArray[x])): return true
	
	# If the node is node edge space or equal to the ID of the neighbor checking itself
	if idArray[x][y] not in [0,1,id]: return false
	
	# Check all neighbors recursively with updated ttl 
	for n in neighbors: 
		if not is_valid_expansion_candidate(idArray, x + n[0], y + n[1], id, ttl): return false
	
	return true
