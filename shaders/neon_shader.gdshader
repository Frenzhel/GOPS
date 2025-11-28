shader_type canvas_item;

uniform vec4 neon_color = vec4(0.0, 1.0, 1.0, 1.0); // default cyan
uniform float glow_strength = 3.0;
uniform float outline_thickness = 6.0;

void fragment() {
    vec4 tex_color = texture(TEXTURE, UV);
    float alpha = tex_color.a;

    // Check if this pixel is near the edge of the texture
    float edge_distance = min(min(UV.x, 1.0 - UV.x), min(UV.y, 1.0 - UV.y));
    bool is_edge = edge_distance < (outline_thickness / 100.0); // Adjust for thickness

    if (is_edge && alpha > 0.1) {
        COLOR = neon_color * glow_strength;
    } else {
        COLOR = tex_color;
    }
}
