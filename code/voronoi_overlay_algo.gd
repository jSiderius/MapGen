#extends "res://code/reduce_districts_algo.gd"
extends "res://code/reduction_algos.gd"

func generate_voronoi_bool_map(width : int, height : int) -> Array: 
	var idArrayTemp : Array = generate_empty_id_array(width, height)
	
	var num_cells : int = 100
	var cells : Array = []
	for i in range(num_cells): cells.append(Vector2(randi()%width, randi()%height))
	
	idArrayTemp = color_voronoi(idArrayTemp, cells)
	
	var edge_cells : Array = find_voronoi_edge_cells(idArrayTemp)
	idArrayTemp = clear_voronoi_edge_cells(idArrayTemp, edge_cells)
	
	var boolArrayTemp : Array = id_array_to_bool_array(idArrayTemp)
	return boolArrayTemp

func color_voronoi(idArrayArg : Array, cells : Array, p=1) -> Array: 
	for x in range(len(idArrayArg)): for y in range(len(idArrayArg[x])): 
		var vec : Vector2 = Vector2(x, y)
		var col : Color
		
		var minIndex : int = 0
		var minDistance : float = 100000
		for i in range(len(cells)): 
			#var distance : float = sqrt(pow(x - cells[i].x, p) + pow(y - cells[i].y, p))
			var distance : float = pow( pow(abs(x - cells[i].x), p) + pow(abs(y - cells[i].y), p), 1.0/p)
			if distance < minDistance:
				minIndex = i 
				minDistance = distance
				
		idArrayArg[x][y] = minIndex
	
	return idArrayArg
	
func find_voronoi_edge_cells(idArrayArg : Array) -> Array:
	 
	var edge_cells : Array = []
	for x in range(len(idArrayArg)): for y in range(len(idArrayArg[x])): 
		var val : int = idArrayArg[x][y]
		if val in edge_cells: continue
		if is_edge(x, y, len(idArrayArg), len(idArrayArg[x])): edge_cells.append(val)
	
	return edge_cells

func clear_voronoi_edge_cells(idArrayArg : Array, edge_cells : Array) -> Array: 
	for x in range(len(idArrayArg)): for y in range(len(idArrayArg[x])): 
		if idArrayArg[x][y] in edge_cells: 
			idArrayArg[x][y] = 1
			
	return idArrayArg

func create_voronoi_border(idArrayArg : Array) -> Array:
	for x in range(len(idArrayArg)): for y in range(len(idArrayArg[x])): 
		if idArrayArg[x][y] != 2 or is_edge(x, y, len(idArrayArg), len(idArrayArg[x])): continue
		for n in neighbors:	
			if idArrayArg[x + n[0]][y + n[1]] > 2: idArrayArg[x][y] = 1
	return idArrayArg
		
func clear_id_array_by_bool_array(idArrayArg : Array, boolArrayArg : Array) -> Array: 
	for x in range(len(idArrayArg)): for y in range(len(idArrayArg[x])): 
		idArrayArg[x][y] = idArrayArg[x][y] if boolArrayArg[x][y] else 2
	return idArrayArg 
