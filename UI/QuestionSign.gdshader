shader_type canvas_item;
uniform float unlock_progress : hint_range(0.0, 1.0) = 1.0;
uniform bool has_image = true;
uniform sampler2D question_mark_tex : filter_nearest;

void fragment() {
	vec4 main_tex = texture(TEXTURE, UV);
	vec4 locked_final = vec4(0.6, 0.6, 0.6, 1.0);
	vec4 q_color = vec4(0.3, 0.3, 0.3, 1.0);
	float scale = 3.0;

	vec2 centered_uv = UV - vec2(0.5);
	vec2 scaled_uv = centered_uv * scale + vec2(0.5);
	float q_mask = texture(question_mark_tex, scaled_uv).a;
	if (scaled_uv.x < 0.0 || scaled_uv.x > 1.0 || scaled_uv.y < 0.0 || scaled_uv.y > 1.0) {
		q_mask = 0.0;
	}
	locked_final.rgb = mix(locked_final.rgb, q_color.rgb, q_mask);
	locked_final.a = main_tex.a;
	if (has_image) {
		float smooth_val = smoothstep(0.0, 1.0, unlock_progress);
		COLOR = mix(locked_final, main_tex, smooth_val);
	} else {
		COLOR = vec4(0.0);
	}
}