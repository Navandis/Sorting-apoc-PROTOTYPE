shader_type spatial;
render_mode blend_mix, depth_prepass_alpha, cull_disabled, shadows_disabled;

uniform sampler2D base_color_texture : source_color;
uniform sampler2D opacity_texture;
uniform sampler2D normal_texture : hint_normal;
uniform sampler2D roughness_texture;
uniform sampler2D metallic_texture;
uniform sampler2D imperfection_texture : filter_linear_mipmap, repeat_enable;
uniform int preview_mode = 0; // 0 diagnostic, 1 illustrative opacity, 2 approved soft wear
uniform float scalar_bias = 0.0;
uniform bool invert_scalar = false;

uniform bool has_color = false;
uniform bool has_opacity = false;
uniform bool has_normal = false;
uniform bool has_roughness = false;
uniform bool has_metallic = false;
uniform bool has_imperfection = false;
uniform bool embedded_alpha = false;
uniform vec4 atlas_region = vec4(0.0, 0.0, 1.0, 1.0);
uniform vec2 mirror_uv = vec2(0.0);
uniform float opacity_multiplier : hint_range(0.0, 1.0) = 1.0;
uniform float albedo_strength : hint_range(0.0, 1.0) = 0.5;
uniform vec4 albedo_tint : source_color = vec4(1.0);
uniform float normal_strength : hint_range(0.0, 2.0) = 1.0;
uniform bool normal_y_flip = false;
uniform float roughness_strength : hint_range(0.0, 1.0) = 1.0;
uniform vec2 imperfection_scale = vec2(1.0);
uniform float imperfection_rotation = 0.0;
uniform float imperfection_contrast = 1.0;
uniform float imperfection_strength : hint_range(0.0, 1.0) = 0.0;
uniform float edge_feather : hint_range(0.0, 0.2) = 0.035;

// A source roughness map is only a scalar here; it never modifies the substrate.
float audition_scalar(vec2 uv) {
    vec2 p = (uv - vec2(0.5)) * imperfection_scale;
    float c = cos(imperfection_rotation);
    float s = sin(imperfection_rotation);
    vec2 rotated = vec2(c*p.x - s*p.y, s*p.x + c*p.y) + vec2(0.5);
    float scalar = texture(imperfection_texture, rotated).r;
    if (invert_scalar) { scalar = 1.0 - scalar; }
    return clamp((scalar - 0.5)*imperfection_contrast + 0.5 + scalar_bias, 0.0, 1.0);
}

void fragment() {
    vec2 local_uv = mix(UV, vec2(1.0) - UV, mirror_uv);
    vec2 map_uv = atlas_region.xy + local_uv * atlas_region.zw;
    vec4 source = vec4(1.0);
    if (has_color) {
        source = texture(base_color_texture, map_uv);
    }
    float mask = 1.0;
    if (has_opacity) {
        mask = texture(opacity_texture, map_uv).r;
    } else if (embedded_alpha) {
        mask = source.a;
    }
    if (has_imperfection && imperfection_strength > 0.0) {
        float scalar = audition_scalar(local_uv);
        mask *= mix(1.0, scalar, imperfection_strength);
    }
    if (preview_mode == 0) {
        source.rgb = vec3(audition_scalar(local_uv));
        mask = 1.0;
    } else if (preview_mode == 1) {
        mask = audition_scalar(local_uv);
    }
    float border = min(min(UV.x, 1.0 - UV.x), min(UV.y, 1.0 - UV.y));
    mask *= smoothstep(0.0, max(edge_feather, 0.0001), border);
    ALBEDO = preview_mode == 0 ? source.rgb :
        (preview_mode == 1 ? albedo_tint.rgb : mix(albedo_tint.rgb, source.rgb, albedo_strength));
    ALPHA = clamp(mask * opacity_multiplier, 0.0, 1.0);

    ROUGHNESS = preview_mode == 2 && has_roughness ? mix(0.8, texture(roughness_texture, map_uv).r, roughness_strength) : 0.8;
    METALLIC = preview_mode == 2 && has_metallic ? texture(metallic_texture, map_uv).r : 0.0;
    if (preview_mode == 2 && has_normal) {
        vec3 normal_sample = texture(normal_texture, map_uv).rgb;
        if (normal_y_flip) {
            normal_sample.g = 1.0 - normal_sample.g;
        }
        NORMAL_MAP = normal_sample;
        NORMAL_MAP_DEPTH = normal_strength;
    }
}
