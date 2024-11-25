shader_type canvas_item;

//uniform vec2 checker_size : hint_range(0.1, 10.0) = vec2(1.0, 1.0); // Size of the checkers
uniform vec2 checker_size = vec2(10.0, 10.0); // Size of the checkers
uniform vec4 color1 : source_color = vec4(1.0, 1.0, 1.0, 1.0); // Color of the first checker
uniform vec4 color2 : source_color = vec4(0.0, 0.0, 0.0, 1.0); // Color of the second checker

void fragment() {
    // Calculate the checkerboard coordinates
    vec2 uv = SCREEN_UV.xy; // Get UV coordinates
	//vec2 uv = UV.xy / TEXTURE_PIXEL_SIZE;
    vec2 checker_coord = floor(uv / checker_size);

    // Determine the color based on the position
    float checker = mod(checker_coord.x + checker_coord.y, 2.0);
    if (checker < 1.0) {
        COLOR = color1;
    } else {
        COLOR = color2;
    }
}

void vertex(){
}




