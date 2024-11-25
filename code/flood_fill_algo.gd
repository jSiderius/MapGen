extends "res://code/expand_automata_algo.gd"

var minUniqueID : int = 3
func flood_fill(idArrayArg : Array, replaced : int = 0): 
	
	#var minUniqueID : int = 3
	for x in range(len(idArrayArg)): 
		for y in range(len(idArrayArg[x])): 
			if not idArrayArg[x][y] == replaced: continue 
			idArrayArg = flood_fill_solve_group(idArrayArg, minUniqueID, Vector2(x,y), replaced)
			minUniqueID += 1
	
	return idArrayArg

func flood_fill_elim_inside_terrain(idArrayArg : Array): 
	idArrayArg = flood_fill_solve_group(idArrayArg, 0, Vector2(0,0), 2)
	for x in range(len(idArrayArg)): for y in range(len(idArrayArg[x])): 
		if idArrayArg[x][y] == 2: idArrayArg[x][y] = minUniqueID
	minUniqueID += 1
	idArrayArg = flood_fill_solve_group(idArrayArg, 2, Vector2(0,0))
	return idArrayArg

# Helper: flood_fill
func flood_fill_solve_group(idArrayArg : Array, id : int, loc : Vector2, replaced : int = 0) -> Array:
	var newX : int
	var newY : int
	var x : int 
	var y : int
	
	var validSquares : Array = [] 
	validSquares.append(loc)
	
	while len(validSquares) > 0: 
		var square = validSquares.pop_back()
		x = square[0]
		y = square[1]
		idArrayArg[x][y] = id 
	
		for n in neighbors: 
			newX = x + n[0]
			newY = y + n[1]
			
			# Bounds check
			if not bounds_check(newX, newY, idArrayArg.size(), idArrayArg[0].size()): continue
			
			#if (not alt and not idArrayArg[newX][newY] == 0) or (alt and not idArrayArg[newX][newY] == 2): continue 
			if not idArrayArg[newX][newY] == replaced: continue 
			validSquares.append(Vector2(newX, newY))
	
	return idArrayArg
