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
uniform vec2[256] lumin_positions;
uniform float[256] lumin_sizes;
uniform vec2 player_position;
uniform int lumin_count;

uniform float player_circle_start = 8.0;
uniform float player_circle_end = 16.0;
uniform float lumin_circle_start = 128.0;
uniform float lumin_circle_end = 160.0;
uniform float everdark_scroll_speed = 0.001;
uniform vec4 quantization = vec4(64.0);

vec4 quantize(vec4 color) {
	float r = round(color.r * quantization.r) / quantization.r;
	float g = round(color.g * quantization.g) / quantization.g;
	float b = round(color.b * quantization.b) / quantization.b;
	float a = round(color.a * quantization.a) / quantization.a;
	return vec4(r,g,b,a);
}

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
	
	float min_edge_distance = 1e7;
	vec2 hole_center = vec2(0.0);
	float selected_size = 0.0;
	
	for (int i = 0; i < lumin_count; i++) {
		vec2 pos = lumin_positions[i];
		float size = lumin_sizes[i];
		
		float center_dist = distance(current_pos, pos);
		float edge_dist = center_dist - size;
		
		if (edge_dist < min_edge_distance) {
			min_edge_distance = edge_dist;
			hole_center = pos;
			selected_size = size;
		}
	}
	
	float dist_adjusted = max(min_edge_distance, 0.0);
	
	vec2 dir_to_center = hole_center - tex_size * 0.5;
	float d = length(dir_to_center);
	if (d > 0.0001) {
		dir_to_center /= d;
	} else {
		dir_to_center = vec2(0.0);
	}
	
	vec2 noise_uv = normalize(hole_center - current_pos) * 2.0 + dir_to_center * TIME * everdark_scroll_speed;
	
	float radial_factor = distance(current_pos, hole_center) / 256.0;
	noise_uv += normalize(hole_center - current_pos) * radial_factor * 0.2;
	
	float noise_val = texture(noise_tex, noise_uv).r;
	
	float player_alpha = smoothstep(player_circle_start, player_circle_end, player_distance + noise_val * 30.0);
	
	float lumin_alpha = smoothstep(lumin_circle_start, lumin_circle_end, dist_adjusted + noise_val * 30.0);
	
	if (player_alpha >= 0.5 && lumin_alpha >= 0.5) {
		return min(player_alpha, lumin_alpha);
	}
	
    if (player_alpha < 0.1 || lumin_alpha < 0.1) {
		return min(player_alpha, lumin_alpha);
	}
	
	return smoothstep(player_alpha, lumin_alpha, 0.9);
}

void fragment() {
	weirdify(UV, TEXTURE, COLOR);
	COLOR.a = get_alpha(UV, TEXTURE, TEXTURE_PIXEL_SIZE);
	COLOR = quantize(COLOR);
}