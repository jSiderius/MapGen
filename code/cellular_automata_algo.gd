extends "res://code/flood_fill_algo.gd"

# Takes an ID array and an array trialThresholds 
# Runs cellular automata on idArray len(trialThresholds) times passing the respective threshold value from the array
func cellular_automata_trials(idArray : Array, trialThresholds : Array) -> Array: 
	for threshold in trialThresholds:
		idArray = cellular_automata(idArray, threshold)
		
	return idArray
	
# Takes an ID array and a threshold
# Follows the cellular automata algorithm to update the values in idArray based on the number of neighbors a cell has w.r.t. the threshold
# Exclusively considers 1 & 0 values, any other value is untouched and not considered a neighbor 
func cellular_automata(idArray : Array, threshold : int) -> Array: 
	var newIdArray : Array = []
	
	for x in range(len(idArray)): 
		newIdArray.append([])
		for y in range(len(idArray[x])): 
			if idArray[x][y] not in [0,1]: 
				newIdArray[x].append(idArray[x][y])
				continue
	
			var numNeighbors : int = 0
			for n in neighbors: 
				var newX = x + n[0]
				var newY = y + n[1]
				
				if not bounds_check(newX, newY, len(idArray), len(idArray[x])): continue 
				numNeighbors += idArray[newX][newY]
			
			newIdArray[x].append(1 if numNeighbors >= threshold else 0)
	
	return newIdArray
