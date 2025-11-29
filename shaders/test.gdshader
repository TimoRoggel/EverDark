shader_type canvas_item;

const float PX = 0.0004;

uniform vec2 lumin_positions[256];
uniform float lumin_radii[256];
uniform int lumin_count;
uniform int aggression;
uniform float threshold = 0.95;
uniform float pixel_offset = 0.2;

float get_lumin_strength(vec2 uv) {
	float mask = 1.0;
	float d;
	for (int i = 0; i < lumin_count; i++) {
		d = distance(uv, lumin_positions[i]) - lumin_radii[i] * PX;
		float inside = 1.0 - step(0.0, d);
		mask = min(mask, 1.0 - inside);
	}
	return mask;
}

float remove_gaps(vec2 uv, vec2 pixel_size) {
	vec2[] dirs = {
		vec2(1.0, 0.0),
		vec2(-1.0, 0.0),
		vec2(0.0, 1.0),
		vec2(0.0, -1.0)
	};
	float[] averages = { 0.0, 0.0, 0.0, 0.0 };
	for (int dir_index = 0; dir_index < 4; dir_index++) {
		vec2 dir = dirs[dir_index];
		for (int i = 1; i < aggression + 2; i++) {
			vec2 offset = pixel_size * dir * float(i);
			averages[dir_index] += get_lumin_strength(uv + offset);
		}
	}
	for (int dir_index = 0; dir_index < 4; dir_index++) {
		if (averages[dir_index] / float(aggression) > threshold) {
			return 1.0;
		}
	}
	return 0.0;
}

void fragment() {
	vec2 uv = UV;
	float lumin_strength = get_lumin_strength(uv);
	vec2 pixel = 1.0 / vec2(textureSize(TEXTURE, 0));
	if (lumin_strength > 0.0) {
		lumin_strength = remove_gaps(uv, pixel * pixel_offset);
	}
	COLOR = vec4(0.1, 0.0, 0.4, lumin_strength);
}
