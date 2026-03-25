shader_type canvas_item;

uniform float speed : hint_range(0.0, 5.0) = 1.5;
uniform float intensity : hint_range(0.0, 1.0) = 0.5;
uniform float line_width : hint_range(0.0, 0.5) = 0.15;
uniform float angle : hint_range(0.0, 6.28) = 0.785;
uniform float pause_time : hint_range(0.0, 5.0) = 2.0;

// NEU: Welche Farbe hat der Lichtschweif? (Weiß für normal, Orange/Gold für Legendary)
uniform vec4 shine_tint : source_color = vec4(1.0, 1.0, 1.0, 1.0);

void fragment() {
    vec4 current_color = COLOR;
    float cycle = mod(TIME * speed, 1.0 + pause_time);
    vec2 uv = UV - 0.5;
    float rot_x = uv.x * cos(angle) - uv.y * sin(angle);
    float pos = (cycle * 2.5) - 1.0; 
    float dist = abs(rot_x - pos);
    
    float shine = smoothstep(line_width, 0.0, dist);
    float shine2 = smoothstep(line_width * 0.2, 0.0, abs(rot_x - (pos + 0.1)));
    
    float total_shine = (shine + shine2) * intensity;
    
    // NEU: Wir multiplizieren den Glanz mit unserem shine_tint!
    COLOR.rgb = current_color.rgb + (shine_tint.rgb * total_shine * current_color.a);
    COLOR.a = current_color.a;
}