extends "res://code/helpers.gd"

class_name DistrictDataFlagStruct

var update_size_location_data : bool = false
var update_percentage_data : bool = false
var update_centrality_data : bool = false

func _init(set_all : bool = false): 
	if set_all: 
		update_size_location_data = true
		update_percentage_data = true
		update_centrality_data = true
