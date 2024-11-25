extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready():
	var rng = RandomNumberGenerator.new()
	rng.randomize()
	
	var noise = FastNoiseLite.new() 
	noise.seed = rng.randi()
	noise.noise_type = FastNoiseLite.TYPE_PERLIN
	
	var viewport_size = get_viewport().size
	var sprite = $black_tile
	
	for x in range(10*ceil(viewport_size.x/(10*sprite.scale.x))): 
		for y in range(10*ceil(viewport_size.y/(10*sprite.scale.y))):
			sprite = $black_tile.duplicate() if noise.get_noise_2d(x,y) > 0.01 else $white_tile.duplicate()
			sprite.position = Vector2(x*sprite.texture.get_size().x, y*sprite.texture.get_size().y)*sprite.scale.x
			add_child(sprite)
			
