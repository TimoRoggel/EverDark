shader_type canvas_item;

uniform float scale: hint_range(0.0, 2.0) = 1.0;
uniform vec2 pivot = vec2(0.5, 0.5);

void vertex() {
	VERTEX -= pivot * POINT_SIZE;
	VERTEX *= scale;
	VERTEX += pivot * POINT_SIZE;
}
