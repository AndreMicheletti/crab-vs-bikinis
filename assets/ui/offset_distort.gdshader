shader_type canvas_item;

uniform vec2 direction = vec2(1, 0);
uniform float speed = 0.1;
uniform sampler2D noise;
uniform float force;

vec4 overlay(vec4 base, vec4 blend){
	vec4 limit = step(0.5, base);
	return mix(2.0 * base * blend, 1.0 - 2.0 * (1.0 - base) * (1.0 - blend), limit);
}

vec4 screen(vec4 base, vec4 blend){
	return 1.0 - (1.0 - base) * (1.0 - blend);
}

void fragment()
{
	// image texture
	vec4 base = texture(SCREEN_TEXTURE, SCREEN_UV);
	// noise texture
	vec2 move = vec2(direction.x * speed * sin(TIME), direction.y * speed * cos(TIME));
	vec4 blend = texture(noise, UV + move);
	vec4 overlay_blend = screen(base, blend);
	
	if (overlay_blend.rgb == vec3(1.0)) {
		COLOR = texture(SCREEN_TEXTURE, SCREEN_UV + vec2(force, force));
	} else {
		COLOR = texture(SCREEN_TEXTURE, SCREEN_UV);
	}
}