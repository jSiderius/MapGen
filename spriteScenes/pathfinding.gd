extends Node2D

var r_480410 = preload("res://spriteScenes/480410.tscn")
# Called when the node enters the scene tree for the first time.
func _ready():
	var start = $start
	var end = $end 
	
	var path_node_script = load("res://spriteScenes/path_node_scene.gd")
	var point_script = load("res://spriteScenes/point.gd")
	
	var squareSize = 200
	var nodes = [
		#path_node_script.new(load("res://spriteScenes/480410.tscn"), [point_script.new(Vector2(56, 405), deg_to_rad(-1.8), 10.0)], 3.0*PI / 2.0, 0.25),
		#path_node_script.new(load("res://spriteScenes/480410_i.tscn"), [point_script.new(Vector2(-35, 418), deg_to_rad(3.2), 10.0)], 3.0*PI / 2.0, 0.25),
		path_node_script.new(load("res://spriteScenes/480412.tscn"), [point_script.new(Vector2(-12, 417), deg_to_rad(-9.8), 10.0)], 3.0*PI / 2.0, 0.25),
		path_node_script.new(load("res://spriteScenes/480412_i.tscn"), [point_script.new(Vector2(-12, 417), deg_to_rad(-9.8), 10.0)], 3.0*PI / 2.0, 0.25),
		
		#path_node_script.new(load("res://spriteScenes/480414.tscn"), [point_script.new(Vector2(16, 426), deg_to_rad(5.3), 10.0)], 3.0*PI / 2.0, 0.25),
		#path_node_script.new(load("res://spriteScenes/480414_i.tscn"), [point_script.new(Vector2(80, 420), deg_to_rad(16.7), 10.0)], 3.0*PI / 2.0, 0.25),	
		
		#path_node_script.new(load("res://spriteScenes/480416.tscn"), [point_script.new(Vector2(23, 404), deg_to_rad(14.2), 10.0)], 3.0*PI / 2.0, 0.25),
		#path_node_script.new(load("res://spriteScenes/480416_i.tscn"), [point_script.new(Vector2(102, 392), deg_to_rad(-26.7), 10.0)], 3.0*PI / 2.0, 0.25),
		
		#path_node_script.new(load("res://spriteScenes/480418.tscn"), [point_script.new(Vector2(4, 439), deg_to_rad(-10.4), 10.0)], 3.0*PI / 2.0, 0.25),
		#path_node_script.new(load("res://spriteScenes/480418_i.tscn"), [point_script.new(Vector2(-6, 437), deg_to_rad(-10.4), 10.0)], 3.0*PI / 2.0, 0.25),
		path_node_script.new(load("res://spriteScenes/480420.tscn"), [point_script.new(Vector2(10, 398), deg_to_rad(-8.5), 10.0)], 3.0*PI / 2.0, 0.25),
		#path_node_script.new(load("res://spriteScenes/480420_i.tscn"), [point_script.new(Vector2(-74, 392), deg_to_rad(-8.5), 10.0)], 3.0*PI / 2.0, 0.25)
	]
	#Vector2(0.0, 1.0)
	await a_star(start.position, end.position, Vector2(0.0, 1.0), [], nodes, squareSize)
	print("done")

func a_star(start : Vector2, end : Vector2, direction : Vector2, path : Array, nodes : Array, squareSize : float, tol : float = 10.0): 
	if start.distance_to(end) < tol: return path
	
	var min_node = null
	var min_pos = null 
	var min_rot = 0.0
	var min_value = INF
	
	for node in nodes: 
		
		for point in node.points: 
			var theta = -acos(direction[1])
			var pos = point.position
			var rotated_point = Vector2(cos(theta)*pos[0]-sin(theta)*pos[1], sin(theta)*pos[0]+cos(theta)*pos[1])
			var new_pos = rotated_point + start
			
			#var new_dir = direction.rotated(min_rot)
			#var vec_to_end = end - new_pos
			#var angle_to_ideal = acos(new_dir.dot(vec_to_end) / (new_dir.length() * vec_to_end.length()))
			#print(angle_to_ideal)
			var remaining_distance = pow(pow(float(new_pos[0]) - float(end[0]), 2.0) + pow(float(new_pos[1]) - float(end[1]), 2.0), 0.5)
			var distance_travelled = pow(pow(float(new_pos[0]) - float(pos[0]), 2.0) + pow(float(new_pos[1]) - float(pos[1]), 2.0), 0.5)
			
			var hueristic_value = point.cost +  distance_travelled + remaining_distance # + angle_to_ideal * 500.0
			
			#all cost's are NOT g(n)=1
			if hueristic_value < min_value: 
				min_value = hueristic_value
				min_node = node
				min_pos = new_pos
				min_rot = point.rotation
				
		#if hueristic_value == min_value: Give pr chance if map appears uneven
	sprite_from_path_node(min_node, start, direction)
	await get_tree().create_timer(0.2).timeout
	
	path.append(min_node) 
	return await a_star(min_pos, end, direction.rotated(min_rot), path, nodes, tol, squareSize)
	
func sprite_from_path_node(node, position, direction): 
	var instance = node.scene.instantiate()
	instance.position = position
	instance.scale = node.scale
	instance.rotation = node.rotation + direction.angle()
	add_child(instance)
