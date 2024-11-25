# --------------------------------------------------------- EXTRA CODE --------------------------------------------------------- 
func generate_checkerboard() -> Array: 
	var i : int = 0
	var newBoolGrid : Array = []
	
	for x in width:
		newBoolGrid.append([])
		if height %2 == 0: i+=1
		for y in height:
			i+=1
			var rect := Rect2(Vector2(x*squareSize,y*squareSize), Vector2(squareSize, squareSize))
			newBoolGrid[x].append(i%2==0)
	
	return newBoolGrid
	
func init_noise(): 
	noise.seed = rng.randi()
	noise.noise_type = FastNoiseLite.TYPE_PERLIN
	
func generate_perlin_noise_grid() -> Array: 
	var newBoolGrid : Array = []
	for x in width:
		newBoolGrid.append([])
		for y in height:
			newBoolGrid[x].append(noise.get_noise_2d(x,y) > threshold)
	
	return newBoolGrid

# This is a good function, but gdscript has trouble with recursion, so skip 
func flood_fill_recurse_(idArrayArg : Array, id : int, x : int, y : int):
	var newX : int
	var newY : int
	idArrayArg[x][y] = id 
	
	for n in neighbors: 
		newX = x + n[0]
		newY = y + n[1]
		
		# Bounds check
		if not (newX >=0 and newX < idArrayArg.size() and newY >= 0 and newY < idArrayArg[newX].size()): continue 
		
		# Recursive call
		if not idArrayArg[newX][newY] == 0: continue 
		idArrayArg = flood_fill_recurse_(idArrayArg, id, newX, newY)
	
	return idArrayArg

func draw_oval(idArrayArg : Array, h : int, k : int, a : int, b : int) -> Array: 
	for x in range(len(idArrayArg)): for y in range(len(idArrayArg[x])): 
		if pos_in_oval(x, y, h, k, a, b, true): idArrayArg[x][y] = 2
	
	return idArrayArg
	
# (x,y) is the points position (h,k) is the center of the oval a is the width of the oval b is the height of the oval
# A point (x,y) is in an oval if (x-h)^2/a^2 + (y-k)^2/b^2 <= 1
func pos_in_oval(x : int, y : int, h : int, k : int, a : int, b : int, pos_on_edge : bool = false) -> bool: 
	#if pos_on_edge: 
		#return pow(x-h, 2)/pow(a,2) + pow(y-k, 2)/pow(b, 2) - 1 < 0.01
	#return pow(x-h, 2)/pow(a,2) + pow(y-k, 2)/pow(b, 2) <= 1
	
	return pow(x-h, 2)/pow(a,2) + pow(y-k, 2)/pow(b, 2) - 1 > 0.0001

func expand_outside_in(idArrayArg : Array): 
	for x in range(len(idArrayArg)): for y in range(len(idArrayArg[x])): 
		if idArrayArg[x][y] != 2: continue
		idArrayArg = expand_outside_in_cell(idArrayArg, x, y, 6)
	return idArrayArg
	
# TODO: Depreciating probability? 
func expand_outside_in_cell(idArrayArg : Array, x : int, y : int, ttl : int) -> Array:
	ttl -= 1
	var candidates : Array = get_candidate_expansion_neighbors(idArrayArg, x, y, false)
	idArrayArg[x][y] = 2
	
	for candidate in candidates: 
		if ttl <= 0 and randi() % 100 < 05:
			idArrayArg[x][y] = 1
			return idArrayArg
		idArrayArg = expand_outside_in_cell(idArrayArg, x+candidate[0], y+candidate[1], ttl)
	return idArrayArg
	
	for i in range(len(dcs)): 
		idArray[dcs[i][0]][dcs[i][1]] = -2
		for j in range(i+1, len(dcs)):

			var d_x : float = dcs[j][0] - dcs[i][0]
			var d_y : float = dcs[j][1] - dcs[i][1]
			var m : float = d_y / d_x
			var b : float = -1.0 * ((d_y * float(dcs[i][0]) / d_x) - dcs[i][1])
			
			print(range(min(dcs[i][0], dcs[j][0]), max(dcs[i][0], dcs[j][0])))
			print("(", dcs[i][0], ",", dcs[i][1], ")")
			print("(", dcs[j][0], ",", dcs[j][1], ")")
			print(d_x, " ", d_y, " ", m, " ", b)
			for k in range(min(dcs[i][0], dcs[j][0]), max(dcs[i][0], dcs[j][0])):
		
				var y_val : int = round(m*float(k) + b)
				if not bounds_check(k, y_val, len(idArray), len(idArray[0])): continue
				
				idArray[k][y_val] = -1
