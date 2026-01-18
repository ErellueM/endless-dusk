shader_type canvas_item;

// --- EINSTELLUNGEN ---
uniform sampler2D noise_texture : repeat_enable, filter_nearest;

// HIER IST DIE ÄNDERUNG:
// Wir fügen eine eigene Zeit-Variable hinzu, die wir per Script steuern.
uniform float custom_time; 

uniform vec2 speed1 = vec2(0.05, 0.02);
uniform vec2 speed2 = vec2(-0.03, 0.04);
uniform float pixel_size : hint_range(0.001, 0.1) = 0.015;

uniform vec4 water_color : source_color = vec4(0.0, 0.1, 0.3, 1.0);
uniform vec4 light_color : source_color = vec4(0.4, 1.5, 3.0, 1.0);
uniform float sharpness : hint_range(0.0, 1.0) = 0.8;

uniform float rotation_angle = 0.5; 

vec2 rotate(vec2 uv, float angle) {
    float s = sin(angle);
    float c = cos(angle);
    return vec2(uv.x * c - uv.y * s, uv.x * s + uv.y * c);
}

void fragment() {
    // 1. PIXELIERUNG
    vec2 pixel_uv = floor(UV / pixel_size) * pixel_size;

    // 2. EBENE 1
    // HIER ÄNDERUNG: custom_time statt TIME
    vec2 uv1 = pixel_uv + custom_time * speed1;
    float noise1 = texture(noise_texture, uv1).r;

    // 3. EBENE 2
    vec2 rotated_uv = rotate(pixel_uv, rotation_angle);
    rotated_uv.x *= -1.0; 
    
    // HIER ÄNDERUNG: custom_time statt TIME
    vec2 uv2 = rotated_uv + custom_time * speed2;
    float noise2 = texture(noise_texture, uv2).r;

    // 4. KOMBINATION
    float combined_noise = (noise1 + noise2) * 0.5;
    
    // 5. SCHÄRFEN
    float caustics = smoothstep(sharpness - 0.05, sharpness + 0.05, combined_noise);
    caustics = pow(caustics, 3.0);

    // 6. FARBE
    vec3 final_color = mix(water_color.rgb, light_color.rgb, caustics);
    COLOR = vec4(final_color, 1.0);
}