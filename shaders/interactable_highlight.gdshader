shader_type canvas_item;

global uniform vec4 highlight_color;
uniform bool highlighted = false;

void fragment() {
	vec4 color = texture(TEXTURE, UV);
	if (highlighted) {
		color.rgb = mix(color.rgb, highlight_color.rgb, highlight_color.a);
	}
	COLOR = color;
}

