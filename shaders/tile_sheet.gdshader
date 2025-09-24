shader_type canvas_item;

uniform sampler2D overlay_tex: repeat_enable, filter_nearest;
uniform float scale = 0.0078125; // calculated by 1/texture size e.g. 1/144
varying vec2 world_position;
uniform vec2 scroll_speed = vec2(0.0);
uniform bool add_to_alpha = false;

vec4 overlay(vec4 x, vec4 y, float z) {
    vec4 overlay_color = mix(2.0 * x * y, 1.0 - 2.0 * (1.0 - x) * (1.0 - y), step(0.5, y));
    return mix(y, overlay_color, z);
}


void vertex(){
	// calculate the world position for use in the fragment shader
	world_position = (MODEL_MATRIX * vec4(VERTEX, 0.0, 1.0)).xy;
}

void fragment() {
	// only apply overlay_tex on the fully red parts of the original tiles
	float mix_amount = floor(COLOR.r);
	
	// sample the overlay_tex using worldPos
	vec4 overlay_color = texture(overlay_tex, world_position * scale + scroll_speed * TIME);
	
	bool has_alpha = COLOR.a < 1.0;
	
	// combine original color and overlay color together
	COLOR = mix(COLOR, overlay_color, mix_amount);
	
	if (add_to_alpha && has_alpha) {
		COLOR = mix(overlay(COLOR, overlay_color, COLOR.a), COLOR, 1.0 - COLOR.a);
	}
}