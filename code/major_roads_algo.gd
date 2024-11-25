extends "res://code/sprite_overlay.gd"

func find_major_roads(idArray) -> Array: 
	var dcs : Array = find_district_centers(idArray).keys()
	var roads : Array = []
	for i in range(len(dcs)): for j in range(i+1, len(dcs)): 
		roads.append([dcs[i], dcs[j]])
	
	roads = find_mst(roads, dcs)
	return roads

func find_district_centers(idArray): 
	var groups_dict : Dictionary = {}
	for x in range(len(idArray)): for y in range(len(idArray[x])): 
		var val : int = idArray[x][y]
		if val not in groups_dict: 
			if val <= 2: continue 
			groups_dict[val] = [x, y, 1, Vector2(x,y)]
			continue
		
		groups_dict[val][0] += x
		groups_dict[val][1] += y
		groups_dict[val][2] += 1
	
	var centers : Dictionary = {}
	for key in groups_dict.keys(): 
		var center_x = floor(groups_dict[key][0] / groups_dict[key][2])
		var center_y = floor(groups_dict[key][1] / groups_dict[key][2])
		if idArray[center_x][center_y] != key: 
			centers[groups_dict[key][3]] = key
			continue
		centers[Vector2(center_x, center_y)] = key
	
	return centers

func find_mst(edges, vertices, prob : int = 90): 
	edges.sort_custom(_sort_by_length)
	var sets : Dictionary = {} 
	for v in vertices: 
		sets[v] = [v, 0]
	
	var mst_edges : Array = []
	for e in edges: 
		var p1_head : Vector2 = find_set_head(sets, e[0])
		var p2_head : Vector2 = find_set_head(sets, e[1])
		if p1_head == p2_head: 
			#var r = 
			#print(r,                                                                                                                                                                                                    prob, r < prob)
			if randi() % 100 + 1 < prob: 
				mst_edges.append(e)                                                                                                                        
				prob -= 10                                                                                                    
			continue
		if sets[p1_head][1] > sets[p2_head][1]: 
			sets[p2_head][0] = p1_head
			sets[p1_head][1] += 1
		else: 
			sets[p1_head][0] = p2_head
			sets[p2_head][1] += 1
		mst_edges.append(e)
	return mst_edges

func find_set_head(sets, v): 
	if sets[v][0] == v: return v
	return find_set_head(sets, sets[v][0]) #Can do the log* thing but not a primary concern
	
func _sort_by_length(a,b): 
	var len_a : float = pow(pow(float(a[0][0]) - float(a[1][0]), 2.0) + pow(float(a[0][1]) - float(a[1][1]), 2.0), 0.5)
	var len_b : float = pow(pow(float(b[0][0]) - float(b[1][0]), 2.0) + pow(float(b[0][1]) - float(b[1][1]), 2.0), 0.5)
	return len_a < len_b
	
func a_star(idArray : Array, start : Vector2, end : Vector2): 
	
	idArray[start[0]][start[1]] = -1
	var min_n : Vector2 = Vector2(0,0)
	var min_value = INF
	for i in range(len(four_neighbors)): 
		var n : Vector2 = Vector2(start[0]+four_neighbors[i][0], start[1]+four_neighbors[i][1])
		if n == end: return idArray
		#elif idArray[n[0]][n[1]] == 2: continue # Creates possible problems 
		if not bounds_check(n[0], n[1], len(idArray), len(idArray[0])): continue 
		var hueristic_value = pow(pow(float(n[0]) - float(end[0]), 2.0) + pow(float(n[1]) - float(end[1]), 2.0), 0.5) #all cost's are g(n)=1
		if hueristic_value < min_value: 
			min_value = hueristic_value
			min_n = n
		#if hueristic_value == min_value: Give pr chance if map appears uneven
	return a_star(idArray, min_n, end)
