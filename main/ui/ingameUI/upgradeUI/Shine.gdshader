shader_type canvas_item;

uniform vec4 ray_color : source_color = vec4(1.0, 0.9, 0.4, 0.8); // Warmes Gold
uniform float speed : hint_range(0.0, 1.0) = 0.05; // Sehr langsam
uniform float ray_count = 8.0;

void fragment() {
    vec2 uv = UV - 0.5;
    float dist = length(uv);
    float angle = atan(uv.y, uv.x);

    // Sanfte Rotation
    angle += TIME * speed;

    // Weiche Strahlen-Berechnung
    float rays = 0.5 + 0.5 * cos(angle * ray_count);
    
    // Heiligenschein-Effekt (Innen hell, nach außen weich auslaufend)
    float halo = 0.2 / dist; // Erzeugt das Zentrum-Glühen
    halo = clamp(halo, 0.0, 1.0);
    
    // Maske, damit es nicht den ganzen Bildschirm füllt
    float mask = smoothstep(0.5, 0.2, dist);
    
    float final_alpha = (rays * halo) * mask * ray_color.a;
    
    COLOR = vec4(ray_color.rgb, final_alpha);
}