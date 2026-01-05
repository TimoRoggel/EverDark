shader_type canvas_item;

group_uniforms Albedo;
	uniform vec4 water_color: source_color;
	uniform vec4 foam_color: source_color;
group_uniforms Distortion;
	uniform sampler2D screen_distortion: repeat_enable, filter_nearest_mipmap;
	uniform float distortion_amount: hint_range(0.0, 10.0, 0.001);
	uniform vec2 distortion_speed = vec2(0.1, 0.2);
group_uniforms Caustics;
	uniform sampler2D caustic_texture: repeat_enable, filter_nearest_mipmap;
	uniform sampler2D caustic_noise: repeat_enable, filter_nearest_mipmap;
	uniform float caustic_scale: hint_range(0.0, 10.0, 0.001);
	uniform float caustic_opacity: hint_range(0.0, 1.0, 0.001);
	uniform sampler2D caustic_gradient: hint_default_transparent;
	uniform vec2 caustic_direction = vec2(0.1, 0.2);
	uniform float caustic_distortion_amount: hint_range(0.0, 10.0, 0.001);
	uniform float caustic_distortion_speed: hint_range(0.0, 10.0, 0.001);
group_uniforms Mask;
	uniform vec4 mask_color: source_color = vec4(0.0);
	uniform float mask_threshold = 0.1;

uniform sampler2D screen_texture: repeat_disable, hint_screen_texture, filter_nearest_mipmap;
varying vec2 world_pos;

void vertex() {
    world_pos = (MODEL_MATRIX * vec4(VERTEX, 0.0, 1.0)).xy;
}

vec2 pixelate(vec2 uv) {
	return step((uv - 0.5) * 8.0, vec2(0.01));
}

vec4 get_caustic(vec4 screen_color) {
	vec2 uv = texture(caustic_noise, world_pos * caustic_scale).xy * caustic_distortion_amount;
	vec2 offset = uv * caustic_direction * sin(TIME * caustic_distortion_speed);
	offset += caustic_direction * TIME * caustic_distortion_speed * 5.0;
	vec2 caustic_uv = (world_pos + offset) * caustic_scale;
	//caustic_uv = pixelate(caustic_uv);
	vec4 caustic = texture(caustic_texture, caustic_uv);
	
	vec4 color = texture(caustic_gradient, vec2(caustic.r));
	
	caustic = mix(screen_color, color, (caustic.r + 0.25) / 32.0);
	
	return caustic;
}

void fragment() {
	vec4 base_color = texture(TEXTURE, UV);
	if (distance(base_color, mask_color) > mask_threshold) {
		COLOR = base_color;
	} else {
		vec4 input = COLOR;
	
		vec2 uv = texture(screen_distortion, world_pos * caustic_scale).xy * distortion_amount;
		vec2 offset = uv * distortion_speed * sin(TIME * distortion_speed);
		offset += distortion_speed * sin(TIME * distortion_speed * 10.0);
		vec4 screen_color = texture(TEXTURE, UV + offset);
		screen_color = mix(screen_color, water_color, water_color.a);
		
		vec4 caustic = get_caustic(screen_color);
		
		COLOR = mix(screen_color, caustic, caustic_opacity);
		COLOR = mix(COLOR, foam_color, caustic.r);
		COLOR.a = input.a;
	}
}