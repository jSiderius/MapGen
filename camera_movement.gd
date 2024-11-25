extends Camera2D

# Speed of the camera movement
var speed: float = 200.0

func _process(delta: float) -> void:
	# Initialize a variable to hold the movement vector
	var movement: Vector2 = Vector2.ZERO
	
	# Check for input and update the movement vector accordingly
	if Input.is_action_pressed("ui_right"):
		movement.x += 1
	if Input.is_action_pressed("ui_left"):
		movement.x -= 1
	if Input.is_action_pressed("ui_down"):
		movement.y += 1
	if Input.is_action_pressed("ui_up"):
		movement.y -= 1
	
	# Normalize the movement vector to avoid faster diagonal movement
	movement = movement.normalized()
	
	# Move the camera based on the movement vector
	position += movement * speed * delta
