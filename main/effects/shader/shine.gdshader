shader_type canvas_item;

// --- EINSTELLUNGEN ---
uniform float speed : hint_range(0.0, 5.0) = 1.0;
uniform float intensity : hint_range(0.0, 1.0) = 0.5;
uniform float pause_between : hint_range(0.0, 5.0) = 2.0;

// WICHTIG: Wie dick ist dein Rand in Prozent? (0.05 = 5% Rand)
// Pass das an, bis es genau auf deinen StyleBoxTexture-Rand passt!
uniform float border_threshold : hint_range(0.0, 0.5) = 0.05;

void fragment() {
	// 1. Hole die Farbe der Textur (dein goldener/blauer Rahmen)
	vec4 original_color = COLOR;
	
	// 2. Erstelle eine Maske: Sind wir im Randbereich oder in der Mitte?
	// step(a, b) gibt 0.0 wenn b < a, sonst 1.0
	float is_left = step(UV.x, border_threshold);
	float is_right = step(1.0 - border_threshold, UV.x);
	float is_top = step(UV.y, border_threshold);
	float is_bottom = step(1.0 - border_threshold, UV.y);
	
	// Wenn IRGENDEINE dieser Bedingungen wahr ist (Wert > 0), sind wir im Rand
	float is_border = max(max(is_left, is_right), max(is_top, is_bottom));
	
	// 3. Schimmer-Berechnung (wie vorher, aber nur aktiv wenn is_border == 1.0)
	float cycle = (TIME * speed);
	float movement = mod(cycle, pause_between + 2.0) - 1.0;
	float pos = UV.x + UV.y;
	float shine = smoothstep(0.2, 0.0, abs(pos - movement));
	
	// 4. Den Schimmer anwenden -> NUR wenn wir im Rand sind
	vec3 shine_color = vec3(1.0, 1.0, 1.0) * shine * intensity * is_border;
	
	// 5. Mischen
	COLOR.rgb = original_color.rgb + shine_color;
	COLOR.a = original_color.a;
}