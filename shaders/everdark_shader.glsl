#[compute]
#version 450

// Binding 0: source texture (sampled)
layout(set = 0, binding = 0) uniform sampler2D src_texture;
// Binding 1: destination texture (writable)
layout(set = 0, binding = 1, rgba8) uniform writeonly image2D dst_texture;
// Binding 2: lights array
layout(set = 0, binding = 2, std430) buffer Lights {
    vec2 lights[1024];
} lights_buffer;
// Binding 3: number of lights
layout(set = 0, binding = 3) uniform LightCount {
    int light_count;
};
// Binding 4: falloff start
layout(set = 0, binding = 4) uniform FalloffStart {
    float falloff_start;
};
// Binding 5: falloff end
layout(set = 0, binding = 5) uniform FalloffEnd {
    float falloff_end;
};

void main() {
    ivec2 gid = ivec2(gl_GlobalInvocationID.xy);
    ivec2 tex_size = imageSize(dst_texture);

    if (gid.x >= tex_size.x || gid.y >= tex_size.y) {
        return; // Outside texture bounds
    }

    vec3 color = texelFetch(src_texture, gid, 0).rgb;
    vec2 pixel_pos = vec2(gid);

    float nearest_dist = 1e6;
    for (int i = 0; i < light_count; i++) {
        float d = distance(pixel_pos, lights_buffer.lights[i]);
        if (d < nearest_dist) {
            nearest_dist = d;
        }
    }

    float factor = 1.0;
    if (nearest_dist > falloff_start) {
        float t = clamp((nearest_dist - falloff_start) / (falloff_end - falloff_start), 0.0, 1.0);
        factor = mix(1.0, 0.0, t);
    }

    imageStore(dst_texture, gid, vec4(color * factor, 1.0));
}
