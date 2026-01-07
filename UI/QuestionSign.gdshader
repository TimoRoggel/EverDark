shader_type canvas_item;

uniform bool is_locked = false;
uniform bool has_image = true;
uniform sampler2D question_mark_tex : filter_nearest;

void fragment() {
	vec4 main_tex = texture(TEXTURE, UV);

	if (is_locked) {
		vec4 final_color = vec4(0.6, 0.6, 0.6, 1.0);
		vec4 q_color = vec4(0.3, 0.3, 0.3, 1.0);
		float scale = 3.0;

		vec2 centered_uv = UV - vec2(0.5);
		vec2 scaled_uv = centered_uv * scale + vec2(0.5);
		
		float q_mask = texture(question_mark_tex, scaled_uv).a;
		
		if (scaled_uv.x < 0.0 || scaled_uv.x > 1.0 || scaled_uv.y < 0.0 || scaled_uv.y > 1.0) {
			q_mask = 0.0;
		}
		
		final_color.rgb = mix(final_color.rgb, q_color.rgb, q_mask);
		final_color.a = main_tex.a;
		
		COLOR = final_color;
	} 
	else {
		if (has_image) {
			COLOR = main_tex;
		} else {
			COLOR = vec4(0.0);
		}
	}
}