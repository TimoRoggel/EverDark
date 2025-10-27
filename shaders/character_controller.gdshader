shader_type canvas_item;

uniform vec3 damage_color: source_color;
uniform bool damaged = false;

void vertex() {
	// Called for every vertex the material is visible on.
}

void fragment() {
	if (damaged && sin(TIME * 64.0) > -0.5) {
		COLOR.rgb = damage_color;
	}
}
