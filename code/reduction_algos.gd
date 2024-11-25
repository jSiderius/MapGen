extends "res://code/major_roads_algo.gd"

func parse_groups_by_size(idArrayArg : Array, min_group : int = 20) -> Array: 
	var groups_dict = {} 
	for row in idArrayArg: for val in row: 
		if val not in groups_dict: 
			groups_dict[val] = 1
			continue
		groups_dict[val]+=1
	
	var groups_to_parse : Array = []
	for key in groups_dict.keys(): 
		if groups_dict[key] < min_group:
			groups_to_parse.append(key)
	
	for x in range(len(idArrayArg)): 
		for y in range(len(idArrayArg[x])): 
			if idArrayArg[x][y] in groups_to_parse: 
				idArrayArg[x][y] = 1
	
	return idArrayArg

func parse_smallest_groups(idArrayArg : Array, num_districts : int = 15) -> Array: 
	var groups_dict = {} 
	for row in idArrayArg: for val in row: 
		if val not in groups_dict: 
			groups_dict[val] = 1
			continue
		groups_dict[val]+=1
	
	var groups_array : Array = []
	for key in groups_dict.keys(): 
		if key == 2: continue
		groups_array.append([key, groups_dict[key]])
	if len(groups_array) <= num_districts: return idArrayArg
	groups_array.sort_custom(_sort_by_second_element)
	
	var groups_to_parse : Array = []
	for i in range(len(groups_array) - num_districts - 1): 
		groups_to_parse.append(groups_array[i][0])
	
	for x in range(len(idArrayArg)): 
		for y in range(len(idArrayArg[x])): 
			if idArrayArg[x][y] in groups_to_parse: 
				idArrayArg[x][y] = 1
	
	return idArrayArg

func _sort_by_second_element(a, b):
	return a[1] < b[1]
