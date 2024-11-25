extends "res://code/grid_gen_functions.gd"

func sprite_overlay(idArray, squareSize) -> Array:
	
	for x in range(len(idArray)): for y in range(len(idArray[x])): 
		var val = idArray[x][y]
		if val == -3: 
			wall_overlay(idArray, squareSize, x, y)
		elif val == -1:
			road_overlay(idArray, squareSize, x, y)
			
	return idArray

func road_overlay(idArray, squareSize, x, y): 
	pass
	
var square_tower_tex_1 = preload("res://Resources/Village Assets/Village Map Assets/Square Tower 1.png")
var square_tower_tex_2 = preload("res://Resources/Village Assets/Village Map Assets/Square Tower 2.png")
var square_tower_tex_3 = preload("res://Resources/Village Assets/Village Map Assets/Square Tower 3.png")
var round_tower_tex_1 = preload("res://Resources/Village Assets/Village Map Assets/Round Tower 1.png")
var round_tower_tex_2 = preload("res://Resources/Village Assets/Village Map Assets/Round Tower 2.png")
var round_tower_tex_3 = preload("res://Resources/Village Assets/Village Map Assets/Round Tower 3.png")
var round_tower_tex_4 = preload("res://Resources/Village Assets/Village Map Assets/Round Tower 4.png")
var square_towers = [square_tower_tex_1, square_tower_tex_2, square_tower_tex_3] 
var round_towers = [round_tower_tex_1, round_tower_tex_2, round_tower_tex_3, round_tower_tex_4] 
var wall_tex = preload("res://Resources/Village Assets/Village Map Assets/Large Stone Wall.png")

func wall_overlay(idArray, squareSize, x, y):
	var left = idArray[x-1][y] == -3
	var right = idArray[x+1][y] == -3
	var up = idArray[x][y+1] == -3
	var down = idArray[x][y-1] == -3
	var count = int(left) + int(right) + int(up) + int(down)
	
	var sprite = Sprite2D.new()
	sprite.position = Vector2(x*squareSize + squareSize/2, y * squareSize + squareSize / 2)
	var tower = null
	
	
	var scale_x = 1.0
	var scale_y = 1.0
	if count > 2: 
		sprite.texture = square_tower_tex_2
	if (left and right):
		tower = false
		sprite.rotation = deg_to_rad(90)
	elif(up and down):
		tower = false
	#TODO: These are not bounds checked
	elif(idArray[x-1][y+1] == 2 and left and up and not(idArray[x-2][y]==-3 or idArray[x][y+2]==-3)): 
		sprite.position = Vector2(x*squareSize, y * squareSize + squareSize)		
		sprite.rotation = deg_to_rad(135)
		tower = false
		
	elif(idArray[x+1][y+1] == 2 and right and up and not(idArray[x+2][y]==-3 or idArray[x][y+2]==-3)): 
		sprite.position = Vector2(x*squareSize + squareSize, y * squareSize + squareSize)				
		sprite.rotation = deg_to_rad(45)
		tower = false

	elif(idArray[x+1][y-1] == 2 and right and down and not(idArray[x+2][y]==-3 or idArray[x][y-2]==-3)): 
		sprite.position = Vector2(x*squareSize + squareSize, y * squareSize)
		sprite.rotation = deg_to_rad(135)
		tower = false
	
	elif(idArray[x-1][y-1] == 2 and left and down and not(idArray[x-2][y]==-3 or idArray[x][y-2]==-3)): 
		sprite.position = Vector2(x*squareSize, y * squareSize)				
		sprite.rotation = deg_to_rad(45)		
		tower = false
		
	else: 
		tower = true
	
	if tower:
		scale_x = 1.1
		scale_y=1.1
		sprite.z_index = 10
		if true: #randi() % 10 > 6
			#sprite.texture = square_towers[randi()%len(square_towers)]
			sprite.texture = square_towers[1]
		else: 
			sprite.texture = round_towers[randi()%len(round_towers)]			
	else:  
		scale_x = 0.7
		scale_y=1.0
		sprite.z_index = -10
		sprite.texture = wall_tex
		
	sprite.scale = Vector2(scale_x, scale_y) * Vector2(squareSize / sprite.texture.get_width(), squareSize / sprite.texture.get_height())
	add_child(sprite)
	
