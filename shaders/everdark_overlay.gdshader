shader_type canvas_item;

uniform vec2[64] lumin_positions;
uniform vec2 player_position;
uniform int lumin_count;
uniform vec3 color: source_color;

void fragment() {
	vec2 current_pos = UV * vec2(textureSize(TEXTURE, 0));
	float player_distance = distance(current_pos, player_position);
	float min_distance = 9999.0;
	for (int i = 0; i < lumin_count; i++) {
		vec2 pos = lumin_positions[i];
		float current_distance = distance(current_pos, pos);
		if (current_distance < min_distance) {
			min_distance = current_distance;
		}
	}
	float alpha = min(smoothstep(8.0, 16.0, player_distance), smoothstep(120.0, 128.0, min_distance));
	
	COLOR = vec4(color, alpha);
}
