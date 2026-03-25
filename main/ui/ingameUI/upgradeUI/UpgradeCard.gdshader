shader_type canvas_item;

uniform float speed : hint_range(0.0, 5.0) = 1.0;
uniform float intensity : hint_range(0.0, 1.0) = 0.0;
uniform vec4 base_tint : source_color = vec4(1.0, 1.0, 1.0, 1.0);
uniform vec4 glow_color : source_color = vec4(1.0, 0.5, 0.1, 1.0); 
uniform sampler2D noise_pattern : repeat_enable;
uniform float dirt_strength : hint_range(0.0, 1.0) = 0.4;
uniform float random_offset = 0.0; 

void fragment() {
    // 1. HIER STECKT DER FADE-IN TWEEN DRIN! Wir speichern ihn ab.
    vec4 fade_in_color = COLOR; 
    
    vec4 card_texture = texture(TEXTURE, UV);
    vec2 noise_uv = UV + (TIME * 0.01 * speed) + vec2(random_offset, random_offset * 0.7);
    float noise_val = texture(noise_pattern, noise_uv).r;
    
    vec3 final_rgb = card_texture.rgb * base_tint.rgb;
    float dirt_mask = smoothstep(0.4, 0.6, noise_val);
    final_rgb = mix(final_rgb, final_rgb * 0.2, dirt_mask * dirt_strength);
    
    float ember_threshold = 1.0 - (intensity * 0.5); 
    float ember_mask = smoothstep(ember_threshold, ember_threshold + 0.1, noise_val);
    final_rgb += glow_color.rgb * ember_mask * intensity * 2.0;
    
    COLOR.rgb = final_rgb;
    COLOR.a = card_texture.a;
}