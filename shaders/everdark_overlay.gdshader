shader_type canvas_item;

uniform float amplitude = 0.075;
uniform float frequency = 10.0;
uniform float speed = 2.0;
uniform float amplitude_vertical = 0.0;
uniform float frequency_vertical = 0.0;
uniform float speed_vertical = 0.0;
uniform vec2 scroll_direction = vec2(0.0, 0.0);
uniform float scrolling_speed = 0.08;
uniform sampler2D palette;
uniform float palette_speed = 0.1;

uniform sampler2D noise_tex: repeat_enable;
uniform vec2[64] lumin_positions;
uniform vec2 player_position;
uniform int lumin_count;

uniform float player_circle_start = 8.0;
uniform float player_circle_end = 16.0;
uniform float lumin_circle_start = 128.0;
uniform float lumin_circle_end = 160.0;
uniform float everdark_scroll_speed = 0.001;

void weirdify(vec2 uv, sampler2D base_texture, out vec4 output_color)
{
	float diff_x = amplitude * sin((frequency * uv.y) + (speed * TIME));
	float diff_y = amplitude_vertical * sin((frequency_vertical * uv.y)  + (speed_vertical * TIME));
	vec2 scroll = scroll_direction * TIME * scrolling_speed;
	vec4 tex = texture(base_texture, vec2(uv.x + diff_x, uv.y + diff_y) + scroll);
	float palette_swap = mod(tex.r - TIME * palette_speed, 1.0);

	output_color = vec4(texture(palette, vec2(palette_swap, 0)).rgb, tex.a);
}

float get_alpha(vec2 uv, sampler2D input_texture, vec2 pixel_size) {
	vec2 tex_size = vec2(textureSize(input_texture, 0));
	vec2 current_pos = uv * tex_size;

	float player_distance = distance(current_pos, player_position);
	float min_distance = 9999.0;
	vec2 hole_center = vec2(0.0);

	for (int i = 0; i < lumin_count; i++) {
		vec2 pos = lumin_positions[i];
		float current_distance = distance(current_pos, pos);
		if (current_distance < min_distance) {
			min_distance = current_distance;
			hole_center = pos;
		}
	}

	vec2 dir_to_center = normalize((hole_center - tex_size * 0.5));

	vec2 noise_uv = normalize(hole_center - current_pos) * 2.0 + dir_to_center * TIME * everdark_scroll_speed;

	float radial_factor = distance(current_pos, hole_center) / 256.0;
	noise_uv += normalize(hole_center - current_pos) * radial_factor * 0.2;

	float noise_val = texture(noise_tex, noise_uv).r;

	float player_alpha = smoothstep(player_circle_start, player_circle_end, player_distance + noise_val * 30.0);
	float lumin_alpha = smoothstep(lumin_circle_start, lumin_circle_end, min_distance + noise_val * 60.0);

	return min(player_alpha, lumin_alpha);
}


void fragment() {
	weirdify(UV, TEXTURE, COLOR);
	COLOR.a = get_alpha(UV, TEXTURE, TEXTURE_PIXEL_SIZE);
}