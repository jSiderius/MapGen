extends "res://code/flood_fill_algo.gd"


# TODO: REAL TIME REDRAWING NOT WORKING
func cellular_automata_trials(trialThresholds : Array, idArray : Array, redraw : bool = false) -> Array: 
	for threshold in trialThresholds:
		idArray = cellular_automata(threshold, idArray)
		
		if redraw: 
			await get_tree().create_timer(0.2).timeout
			queue_redraw()
			
	return idArray
	
func cellular_automata(threshold : int, idArray : Array) -> Array: 
	var newIdArray : Array = []
	var newX : int = 0
	var newY : int = 0
	
	for x in range(len(idArray)): 
		newIdArray.append([])
		for y in range(len(idArray[x])): 
			if idArray[x][y] not in [0,1]: 
				newIdArray[x].append(idArray[x][y])
				continue
	
			var numNeighbors : int = 0
			for n in neighbors: 
				newX = x + n[0]
				newY = y + n[1]
				
				if newX >=0 and newX < idArray.size() and newY >= 0 and newY < idArray[newX].size(): 
					#numNeighbors += 1 if idArray[newX][newY] else 0
					numNeighbors += idArray[newX][newY]
			
			newIdArray[x].append(1 if numNeighbors >= threshold else 0)
	
	return newIdArray
