shader_type canvas_item;

uniform float scale: hint_range(0.0, 2.0) = 1.0;
uniform vec2 pivot = vec2(0.5, 0.5);
uniform vec2 pixel_size = vec2(0.01, 0.01);

void vertex() {
	VERTEX -= pivot;
	VERTEX *= scale;
	VERTEX += pivot;
}
