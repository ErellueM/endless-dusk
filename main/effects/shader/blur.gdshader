shader_type canvas_item;

// WICHTIG: filter_nearest behalten, damit die Pixel hart bleiben!
uniform sampler2D screen_texture : hint_screen_texture, filter_nearest;

// --- EINSTELLUNGEN ---

// Wie dunkel? (0.3 ist ein guter Wert)
uniform float darkening : hint_range(0.0, 1.0) = 0.3;

// Wie grau? (1.0 = komplett Schwarz-Weiß)
uniform float saturation : hint_range(0.0, 1.0) = 1.0;

// Der "Retro-Blur" Effekt (Farbverschiebung)
// Wie viele Pixel weit sollen sich die Farben trennen?
// 0.0 = aus, 2.0 = subtil, 5.0 = starker Effekt
uniform float aberration_amount : hint_range(0.0, 10.0) = 2.5;

// Optional: Ein leichter Farb-Tint (z.B. dunkles Blau für Atmosphäre)
uniform vec4 tint_color : source_color = vec4(1.0, 1.0, 1.0, 1.0); // Weiß = kein Tint


void fragment() {
	// Wir brauchen die Größe eines echten Bildschirm-Pixels für die Verschiebung
	vec2 pixel_size = SCREEN_PIXEL_SIZE;

	// 1. CHROMATISCHE ABERRATION (Der "Blur"-Ersatz)
	// Wir holen uns den Rot-Kanal etwas von links versetzt
	float r = texture(screen_texture, SCREEN_UV - vec2(pixel_size.x * aberration_amount, 0.0)).r;
	// Grün bleibt in der Mitte
	float g = texture(screen_texture, SCREEN_UV).g;
	// Blau holen wir uns etwas von rechts versetzt
	float b = texture(screen_texture, SCREEN_UV + vec2(pixel_size.x * aberration_amount, 0.0)).b;

	vec3 mixed_color = vec3(r, g, b);

	// 2. ENTSÄTTIGUNG (Graustufen)
	// Standard-Formel für Luminanz
	float grey = dot(mixed_color, vec3(0.299, 0.587, 0.114));
	vec3 final_color = mix(mixed_color, vec3(grey), saturation);

	// 3. ABDUNKELN & TINT
	final_color *= darkening;
	final_color *= tint_color.rgb;

	COLOR.rgb = final_color;
	COLOR.a = 1.0;
}