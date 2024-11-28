extends "res://code/grid_gen_functions.gd"

# SUBDIVIDING THE DISTRICTS 
    #var bbs : Dictionary = find_district_bounding_boxes(idArray)
    #var temp = idArray
    #for key in bbs.keys():
        #idArray = subdivide_district(temp, bbs[key], key)
        #idArray = flood_fill(idArray, key)
        #if debug: await redraw_and_pause("9", 2.0)

# INCOMPLETE: Will have to somehow subdivide the districts such that one node is now 4
func subdivide_district(idArrayArg : Array, bb : Array, key : int) -> Array: 
    var sub_array : Array = get_array_between(bb[0], bb[1], idArrayArg)
    print(key)
    return sub_array

# Takes an ID array 
# Returns a dictionary from group id (key) to bounding box (value)
func find_district_bounding_boxes(idArray : Array) -> Dictionary:
    var groups_dict : Dictionary = {} 
    for x in range(len(idArray)): for y in range(len(idArray[x])): 
	
        # Get and screen the value 
        var val : int = idArray[x][y]
        if val <= 2: continue
        if val not in groups_dict: 
            groups_dict[val] = [Vector2(x,y), Vector2(x,y)]
            continue 
        
        # If the value is outside the current bounding box expand the box
        groups_dict[val][0][0] = groups_dict[val][0][0] if groups_dict[val][0][0] < x else x 
        groups_dict[val][0][1] = groups_dict[val][0][1] if groups_dict[val][0][1] < y else y 
        groups_dict[val][1][0] = groups_dict[val][1][0] if groups_dict[val][1][0] > x else x 
        groups_dict[val][1][1] = groups_dict[val][1][1] if groups_dict[val][1][1] > y else y 

    return groups_dict

# Takes 2 vectors (Vector2) and an ID array 
# Returns a 2D array of all values between the vectors in the ID array
func get_array_between(v1: Vector2, v2: Vector2, idArray: Array) -> Array:
    # Ensure v1 has the smaller x and y values
    var start = Vector2(min(v1.x, v2.x), min(v1.y, v2.y))
    var end = Vector2(max(v1.x, v2.x), max(v1.y, v2.y))
	
    # Create a 2D array of all the values between start and end in array
    var result = []
    for x in range(start.x, end.x+1): 
        result.append([])
        for y in range(start.y, end.y+1):
            if not bounds_check(x, y, len(idArray), len(idArray[x])): continue 
            result[x-start.x].append(idArray[x][y])

    return result
	