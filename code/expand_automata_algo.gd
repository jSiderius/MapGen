extends "res://code/voronoi_overlay_algo.gd"

func expand_id_array(idArrayArg : Array):
	var next : Array = idArrayArg
	while true: 
		idArrayArg = next
		next = expand_id_array_instance(idArrayArg)
		if next == idArrayArg: break
	return idArrayArg

# Algorithm may be more effecient for each expansion to determine its neareast region, probably doesn't matter though
func expand_id_array_instance(idArrayArg : Array) -> Array: 
	var candidate_neighbors : Array = []
	var idArrayNew : Array = idArrayArg 
	
	for x in range(len(idArrayArg)): 
		for y in range(len(idArrayArg[x])): 
			if idArrayArg[x][y] != idArrayNew[x][y] or idArrayArg[x][y] < 2: continue 
			
			candidate_neighbors = get_candidate_expansion_neighbors(idArrayNew, x, y)
			
			for n in candidate_neighbors: 
				if is_valid_expansion_candidate(idArrayNew, x+n[0], y+n[1], idArrayNew[x][y], 2): 
					idArrayNew[x+n[0]][y+n[1]] = idArrayArg[x][y]
	return idArrayNew

func get_candidate_expansion_neighbors(idArrayArg : Array, x : int, y : int, autonomousIds : bool = true) -> Array: 
	var newX : int
	var newY : int
	var candidates : Array = []
	for n in neighbors: 
		newX = x + n[0]
		newY = y + n[1]
		
		#TODO: Check bounds function
		# Bounds check & validity check
		if not (newX >=0 and newX < idArrayArg.size() and newY >= 0 and newY < idArrayArg[newX].size()): continue 
		if (autonomousIds and idArrayArg[newX][newY] >= 2) or idArrayArg[newX][newY]==2: continue 
		
		candidates.append(n)
	
	return candidates
		
func is_valid_expansion_candidate(idArrayArg : Array, x : int, y : int, id : int, ttl : int) -> bool: 
	if ttl == 0: return true
	ttl -= 1
	
	# TODO: Bounds check should be its own function
	if not (x >=0 and x < idArrayArg.size() and y >= 0 and y < idArrayArg[x].size()): return true
	if idArrayArg[x][y] not in [0,1,id]: return false
	
	for n in neighbors: 
		if not is_valid_expansion_candidate(idArrayArg, x + n[0], y + n[1], id, ttl): return false
	
	return true
