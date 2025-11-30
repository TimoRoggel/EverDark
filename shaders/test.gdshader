shader_type canvas_item;

const float PX = 0.0004;

uniform vec2 lumin_positions[256];
uniform float lumin_radii[256];
uniform int lumin_count;
uniform int aggression;
uniform float threshold = 0.95;
uniform float pixel_offset = 0.2;

float get_lumin_strength(vec2 uv) {
    float mask = 1.0;
    float d;

    for (int i = 0; i < lumin_count; i++) {
        float r = lumin_radii[i] * PX;
        float r2 = r * 1.25;          // secondary margin radius

        d = distance(uv, lumin_positions[i]);

        // true inside
        float inside_primary = 1.0 - step(r, d);      // 1.0 when inside primary radius
        // inside secondary margin only
        float inside_secondary = step(r, d) * (1.0 - step(r2, d)); // 1.0 between r and r2

        // primary region forces mask to 0
        float primary_effect = inside_primary * 0.0;

        // secondary region forces mask to 0.5
        float secondary_effect = inside_secondary * 0.5;

        // outside both stays at 1.0
        float combined = mix(1.0, 0.5, inside_secondary);
        combined = mix(combined, 0.0, inside_primary);

        mask = min(mask, combined);
    }

    return mask;
}


void fragment() {
	vec2 uv = UV;
	float lumin_strength = step(pixel_offset, get_lumin_strength(uv));
	COLOR = vec4(0.1, 0.0, 0.4, lumin_strength);
}
