shader_type canvas_item;

uniform float xSpeed;
uniform float ySpeed;

vec4 screen(vec4 base, vec4 blend){
	return 1.0 - (1.0 - base) * (1.0 - blend);
}

void fragment() {
	float circ = cos(TIME);
	float ratio = SCREEN_PIXEL_SIZE.x / SCREEN_PIXEL_SIZE.y;
	vec2 offsetUV = UV - vec2(xSpeed * TIME, ySpeed * circ);
	vec4 base = texture(SCREEN_TEXTURE, SCREEN_UV);
	vec4 color_offset = texture(TEXTURE, offsetUV);
	COLOR = screen(base, color_offset);
}
