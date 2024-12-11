extends "res://code/grid_gen_functions.gd"

var graph : Resource = preload("res://code/graph.gd")

# Takes an ID array
# Determines the set of major roads between district centers, sets them in the array, returns 
func add_roads(idArray : Array, vertices : Array[Vector2i], colorVert : bool = false, mod : bool = true) -> Array: 
	
	print("Looking for MST on ", len(vertices), " vertices")
	var roads : Array[Array] = []
	for i in range(len(vertices)): for j in range(i+1, len(vertices)): 
		roads.append([vertices[i], vertices[j]])
	
	var g : Graph = graph.new(roads, vertices, len(idArray), len(idArray[0]))
	# idArray = g.add_modified_mst(idArray, 8.0, mod)
	g.add_modified_mst2(idArray)

	# if colorVert: 
	for v in vertices: idArray[v[0]][v[1]] = -2 if colorVert else -1
	
	roads = []
	return roads
