extends "res://code/reduction_algos.gd"


func reduce_districts(idArrayArg : Array) -> Array:
	var districts : Dictionary = get_districts_dict(idArrayArg, true)
	var min_districts : int = 12
	
	while len(districts.keys()) > min_districts:
		
		var smallest_district = districts.keys()[0]
		for district_id in districts.keys(): 
			if districts[district_id]["cells"] < districts[smallest_district]["cells"]:
				smallest_district = district_id
		
		if len(districts[smallest_district]["borders"].keys()) == 0: 
			districts.erase(smallest_district)
			continue
		var largest_border = districts[smallest_district]["borders"].keys()[0] #TODO: Could be empty 
		for border_district in districts[smallest_district]["borders"].keys(): 
			#if border_district == 2: continue
			if districts[smallest_district]["borders"][border_district] > districts[smallest_district]["borders"][largest_border]:
				largest_border = border_district
		
		idArrayArg = merge_districts(idArrayArg, largest_border, smallest_district)
		districts = merge_districts_dict(districts, largest_border, smallest_district)
		districts.erase(smallest_district)
		
	return idArrayArg

func merge_districts(idArrayArg : Array, absorbingId : int, absorbedId) -> Array: 
	print(absorbingId, " ", absorbedId)
	for x in range(len(idArrayArg)): for y in range(len(idArrayArg[x])): 
		if idArrayArg[x][y] == absorbedId: idArrayArg[x][y] = absorbingId
	return idArrayArg

func merge_districts_dict(districts : Dictionary, absorbingId : int, absorbedId) -> Dictionary: 
	districts[absorbingId]["cells"] += districts[absorbedId]["cells"]
	for districtId in districts.keys(): 
		if absorbedId not in districts[districtId]["borders"]: continue 
		if absorbingId in districts[districtId]["borders"]: 
			districts[districtId]["borders"][absorbingId] += districts[districtId]["borders"][absorbedId] 
		else: 
			districts[districtId]["borders"][absorbingId] = districts[districtId]["borders"][absorbedId]
	return districts

func get_districts_dict(idArrayArg : Array, exclude_neutral : bool = false) -> Dictionary: 
	var districts : Dictionary = {}
	for x in range(len(idArrayArg)): for y in range(len(idArrayArg[x])): 
		var id = idArrayArg[x][y]
		if id <= 2: continue 
		if id not in districts: 
			districts[id] = {
				"cells" = 0,
				"absorbed" = [],
				"borders" = {}
			}
		districts[id]["cells"] += 1
		districts[id]["borders"] = update_borders(idArrayArg, x, y, districts[id]["borders"])
		print(id, ": ", districts[id])
		if exclude_neutral: 
			districts[id]["borders"].erase(2)
			districts[id]["borders"].erase(1)
			districts[id]["borders"].erase(0)
			districts[id]["borders"].erase(id)
	
	return districts

func update_borders(idArrayArg : Array, x : int, y : int, borders : Dictionary) -> Dictionary:
	
	var unique_neighbors : Dictionary = get_unique_neighbors(idArrayArg, x, y)
	for n in unique_neighbors.keys(): 
		if n in borders: 
			borders[n] += 1
			continue 
		borders[n] = 1
	
	return borders
		
func get_unique_neighbors(idArrayArg : Array, x : int, y : int, jump_borders=false) -> Dictionary:
	var unique_neighbors : Dictionary = {}
	for n in neighbors: 
		var newX : int = x + n[0]
		var newY : int = y + n[0]
		
		if not (newX >=0 and newX < idArrayArg.size() and newY >= 0 and newY < idArrayArg[newX].size()): continue 
		
		var nVal : int = idArrayArg[newX][newY]
		unique_neighbors[nVal] = true
		if nVal == 1 and jump_borders: 
			unique_neighbors.merge(get_unique_neighbors(idArrayArg, x, y, false))

	return unique_neighbors

